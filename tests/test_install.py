"""Test installer dispatch without Nix, network access, or home changes."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.bin = self.work / "bin"
        self.bin.mkdir()
        self.capture = self.work / "nix-args"
        self.env = {
            **os.environ,
            "PATH": f"{self.bin}:{os.environ['PATH']}",
            "HOME": str(self.work),
            "CAPTURE": str(self.capture),
            "MOCK_SYSTEM": "Darwin",
            "MOCK_ARCH": "arm64",
            "MOCK_GIT_STATUS": "0",
            "MOCK_USERNAME": "yawnbo",
            "MOCK_UID": "501",
            "NIX_CONFIG": "warn-dirty = false",
        }
        self.stub("uname", 'case "$1" in -s) echo "$MOCK_SYSTEM";; -m) echo "$MOCK_ARCH";; esac')
        self.stub("id", 'case "$1" in -u) echo "$MOCK_UID";; -un) echo "$MOCK_USERNAME";; *) exit 1;; esac')
        self.stub("git", 'exit "$MOCK_GIT_STATUS"')
        self.stub("nix", '''printf "%s\\n" "$@" > "$CAPTURE"
printf "%s\\n" "$NIX_CONFIG" > "$CAPTURE.config"
printf "%s\\n" "$DOTS_USERNAME" "$DOTS_HOME" "$DOTS_CHECKOUT" > "$CAPTURE.identity"''')

    def stub(self, name, body):
        path = self.bin / name
        path.write_text(f"#!/bin/sh\nset -eu\n{body}\n")
        path.chmod(0o755)

    def run_script(self, *args, answer="", script="install.sh"):
        return subprocess.run(
            ["/bin/bash", str(ROOT / script), *args],
            input=answer,
            capture_output=True,
            text=True,
            env=self.env,
            cwd=self.work,
            check=False,
        )

    def test_build_profiles(self):
        for system, arch, profile in [
            ("Darwin", "arm64", "aarch64-darwin"),
            ("Darwin", "x86_64", "x86_64-darwin"),
            ("Linux", "aarch64", "aarch64-linux"),
            ("Linux", "x86_64", "x86_64-linux"),
        ]:
            with self.subTest(system=system, arch=arch):
                self.env.update(MOCK_SYSTEM=system, MOCK_ARCH=arch)
                result = self.run_script("build")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.capture.read_text().splitlines(), [
                    "run", f"{ROOT}#home-manager", "--", "build", "--impure", "--flake",
                    f"{ROOT}#{profile}",
                ])

    def test_local_identity_is_not_pinned_to_an_account(self):
        home = self.work / "nonstandard home"
        home.mkdir()
        self.env.update(
            HOME=str(home), MOCK_SYSTEM="Linux", MOCK_ARCH="aarch64",
            USER="wrong-user", DOTS_USERNAME="wrong-user",
            DOTS_HOME="/wrong-home", DOTS_CHECKOUT="/wrong-checkout",
        )
        for username in ["yan", "yan-kovari", "yawnbo"]:
            with self.subTest(username=username):
                self.env["MOCK_USERNAME"] = username
                result = self.run_script("build")
                self.assertEqual(result.returncode, 0, result.stderr)
                identity = Path(f"{self.capture}.identity").read_text().splitlines()
                self.assertEqual(identity, [username, str(home), str(ROOT)])
                self.assertEqual(self.capture.read_text().splitlines()[-1], f"{ROOT}#aarch64-linux")

    def test_checkout_does_not_have_to_be_home_dots(self):
        checkout = self.work / "config repos" / "my dots"
        checkout.mkdir(parents=True)
        script = checkout / "install.sh"
        shutil.copy2(ROOT / "install.sh", script)
        result = self.run_script("build", script=script)
        self.assertEqual(result.returncode, 0, result.stderr)
        identity = Path(f"{self.capture}.identity").read_text().splitlines()
        self.assertEqual(identity[2], str(checkout.resolve()))
        self.assertEqual(self.capture.read_text().splitlines()[-1], f"{checkout.resolve()}#aarch64-darwin")

    def test_root_is_rejected_before_running_nix(self):
        self.env["MOCK_UID"] = "0"
        for action in ["build", "switch"]:
            with self.subTest(action=action):
                result = self.run_script(action, answer="yes\n")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("not root or sudo", result.stderr)
                self.assertFalse(self.capture.exists())

    def test_invalid_home_is_rejected(self):
        for home in [None, "", "relative/home", "/", str(self.work / "missing")]:
            with self.subTest(home=home):
                if home is None:
                    self.env.pop("HOME", None)
                else:
                    self.env["HOME"] = home
                result = self.run_script("build")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("HOME must be", result.stderr)
                self.assertFalse(self.capture.exists())

    def test_explicit_profile_is_one_argument(self):
        result = self.run_script("build", "custom-profile")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.capture.read_text().splitlines()[-1], f"{ROOT}#custom-profile")

    def test_switch_requires_confirmation_and_adds_backup(self):
        result = self.run_script(answer="yes\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        args = self.capture.read_text().splitlines()
        self.assertEqual(args[3], "switch")
        self.assertEqual(args[-2], "-b")
        self.assertRegex(args[-1], r"^hm-backup-\d{8}T\d{6}Z-\d+$")

    def test_switch_cancellation_does_not_run_nix(self):
        result = self.run_script("switch", answer="n\n")
        self.assertEqual(result.returncode, 0)
        self.assertIn("Cancelled", result.stdout)
        self.assertFalse(self.capture.exists())

    def test_switch_eof_does_not_run_nix(self):
        self.assertNotEqual(self.run_script("switch").returncode, 0)
        self.assertFalse(self.capture.exists())

    def test_missing_nix_has_actionable_error(self):
        (self.bin / "nix").unlink()
        self.env["PATH"] = str(self.bin)
        result = self.run_script("build")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Nix is not installed", result.stderr)

    def test_untracked_flake_is_rejected(self):
        self.env["MOCK_GIT_STATUS"] = "1"
        result = self.run_script("build")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git add flake.nix", result.stderr)
        self.assertFalse(self.capture.exists())

    def test_unsupported_platform_and_architecture(self):
        for system, arch in [("FreeBSD", "x86_64"), ("Linux", "riscv64")]:
            with self.subTest(system=system, arch=arch):
                self.env.update(MOCK_SYSTEM=system, MOCK_ARCH=arch)
                self.assertNotEqual(self.run_script("build").returncode, 0)
                self.assertFalse(self.capture.exists())

    def test_invalid_arguments(self):
        for args in [("remove",), ("build", "profile", "extra")]:
            with self.subTest(args=args):
                self.assertEqual(self.run_script(*args).returncode, 2)
                self.assertFalse(self.capture.exists())

    def test_help_does_not_run_nix(self):
        result = self.run_script("--help")
        self.assertEqual(result.returncode, 0)
        self.assertIn("Usage:", result.stdout)
        self.assertFalse(self.capture.exists())

    def test_existing_nix_config_is_preserved(self):
        result = self.run_script("build")
        self.assertEqual(result.returncode, 0, result.stderr)
        config = Path(f"{self.capture}.config").read_text()
        self.assertIn("warn-dirty = false", config)
        self.assertIn("extra-experimental-features = nix-command flakes", config)

    def test_nix_failure_is_propagated(self):
        self.stub("nix", "exit 17")
        self.assertEqual(self.run_script("build").returncode, 17)

    def test_vtr_is_skipped_on_mac_without_ssh(self):
        self.stub("ssh", 'echo contacted > "$CAPTURE"; exit 99')
        result = self.run_script(script="scripts/install-vtr.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("skipped on macOS", result.stdout)
        self.assertFalse(self.capture.exists())

    def test_existing_vtr_is_not_reinstalled(self):
        self.env["MOCK_SYSTEM"] = "Linux"
        self.stub("vtr", "exit 0")
        self.stub("ssh", 'echo contacted > "$CAPTURE"; exit 99')
        result = self.run_script(script="scripts/install-vtr.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("already installed", result.stdout)
        self.assertFalse(self.capture.exists())


if __name__ == "__main__":
    unittest.main()
