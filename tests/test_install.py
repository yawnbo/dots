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

    def prepare_bootstrap(self):
        # Hide host executables, including Nix. Never source the host's daemon
        # profile or contact the network when testing a missing installation.
        installed_bin = self.work / "installed-nix/bin"
        installed_bin.mkdir(parents=True)
        shutil.copy2(self.bin / "nix", installed_bin / "nix")
        (self.bin / "nix").unlink()
        for command in ["dirname", "date", "mktemp", "rm", "sh", "cat"]:
            (self.bin / command).symlink_to(shutil.which(command))
        profile = self.work / ".nix-profile/etc/profile.d/nix.sh"
        profile.parent.mkdir(parents=True)
        startup = self.work / "bash-env"
        startup.write_text('''source() {
    case "$1" in
        /nix/*) return 0 ;;
        *) builtin source "$@" ;;
    esac
}
''')
        installer = self.work / "mock-installer"
        installer.write_text('''#!/bin/sh
set -eu
printf '%s\\n' "$@" > "$CAPTURE.installer"
if [ "${MOCK_INSTALL_STATUS:-0}" != 0 ]; then exit "$MOCK_INSTALL_STATUS"; fi
if [ "${MOCK_NO_PROFILE:-0}" = 0 ]; then
    printf 'export PATH="%s:$PATH"\\n' "$MOCK_NIX_BIN" > "$MOCK_NIX_PROFILE"
fi
''')
        self.env.update(
            PATH=str(self.bin), TMPDIR=str(self.work), BASH_ENV=str(startup),
            MOCK_INSTALLER=str(installer), MOCK_NIX_BIN=str(installed_bin),
            MOCK_NIX_PROFILE=str(profile),
        )
        self.stub("curl", '''printf '%s\\n' "$@" > "$CAPTURE.curl"
while [ "$#" -gt 0 ]; do
    case "$1" in
        --output) output=$2; shift 2 ;;
        *) shift ;;
    esac
done
/bin/cp "$MOCK_INSTALLER" "$output"
exit "${MOCK_DOWNLOAD_STATUS:-0}"''')
        return profile

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

    def test_missing_nix_is_installed_before_build(self):
        self.prepare_bootstrap()
        result = self.run_script("build")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(Path(f"{self.capture}.installer").read_text().splitlines(), ["--daemon"])
        download = Path(f"{self.capture}.curl").read_text().splitlines()
        self.assertIn("--fail", download)
        self.assertIn("--proto-redir", download)
        self.assertEqual(download[-1], "https://nixos.org/nix/install")
        self.assertEqual(self.capture.read_text().splitlines()[3], "build")
        self.assertEqual(list(self.work.glob("dots-nix-install.*")), [])

    def test_existing_nix_does_not_run_installer(self):
        self.stub("curl", 'echo unexpected > "$CAPTURE.curl"; exit 99')
        result = self.run_script("build")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(Path(f"{self.capture}.curl").exists())

    def test_existing_nix_profile_is_loaded_without_reinstalling(self):
        profile = self.prepare_bootstrap()
        profile.write_text(f'export PATH="{self.env["MOCK_NIX_BIN"]}:$PATH"\n')
        result = self.run_script("build")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(Path(f"{self.capture}.curl").exists())
        self.assertTrue(self.capture.exists())

    def test_missing_curl_has_actionable_error(self):
        self.prepare_bootstrap()
        (self.bin / "curl").unlink()
        result = self.run_script("build")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Install curl first", result.stderr)
        self.assertFalse(self.capture.exists())

    def test_failed_download_is_not_executed_and_is_cleaned_up(self):
        self.prepare_bootstrap()
        self.env["MOCK_DOWNLOAD_STATUS"] = "22"
        result = self.run_script("build")
        self.assertEqual(result.returncode, 22, result.stderr)
        self.assertFalse(Path(f"{self.capture}.installer").exists())
        self.assertFalse(self.capture.exists())
        self.assertEqual(list(self.work.glob("dots-nix-install.*")), [])

    def test_installer_failure_stops_home_manager_and_is_cleaned_up(self):
        self.prepare_bootstrap()
        self.env["MOCK_INSTALL_STATUS"] = "17"
        result = self.run_script("build")
        self.assertEqual(result.returncode, 17, result.stderr)
        self.assertFalse(self.capture.exists())
        self.assertEqual(list(self.work.glob("dots-nix-install.*")), [])

    def test_installer_without_usable_nix_has_actionable_error(self):
        self.prepare_bootstrap()
        self.env["MOCK_NO_PROFILE"] = "1"
        result = self.run_script("build")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("nix is still unavailable", result.stderr)
        self.assertFalse(self.capture.exists())

    def test_bootstrap_switch_preserves_activation_backup(self):
        self.prepare_bootstrap()
        result = self.run_script("switch", answer="yes\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        args = self.capture.read_text().splitlines()
        self.assertEqual(args[3], "switch")
        self.assertEqual(args[-2], "-b")
        self.assertTrue(Path(f"{self.capture}.installer").exists())

    def test_cancelled_switch_does_not_install_nix(self):
        self.prepare_bootstrap()
        result = self.run_script("switch", answer="n\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(Path(f"{self.capture}.curl").exists())
        self.assertFalse(self.capture.exists())

    def test_invalid_checkout_does_not_install_nix(self):
        self.prepare_bootstrap()
        self.env["MOCK_GIT_STATUS"] = "1"
        result = self.run_script("build")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git add flake.nix", result.stderr)
        self.assertFalse(Path(f"{self.capture}.curl").exists())

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
