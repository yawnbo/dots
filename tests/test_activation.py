"""Check Home Manager's generated pre-activation guard in temporary homes."""

import os
from pathlib import Path
import platform
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("nix"), "Nix is not installed or not on PATH")
class ConfigLayoutTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        work = Path(self.temp.name)
        self.home = work / "home"
        self.config = self.home / ".config"
        self.config.mkdir(parents=True)
        self.checkout = work / "checkout with spaces"
        self.source = self.checkout / ".config"
        self.init = self.source / "nvim/init.lua"
        self.init.parent.mkdir(parents=True)
        self.init.write_text("-- Keep this source file.\n")
        architecture = {"arm64": "aarch64", "aarch64": "aarch64", "x86_64": "x86_64"}[platform.machine()]
        system = f"{architecture}-{'darwin' if platform.system() == 'Darwin' else 'linux'}"
        result = subprocess.run(
            [
                "nix", "--extra-experimental-features", "nix-command flakes",
                "eval", "--no-write-lock-file", "--impure", "--raw",
                f"{ROOT}#homeConfigurations.{system}.config.home.activation.checkDotsCheckout.data",
            ],
            env={
                **os.environ,
                "DOTS_USERNAME": "test-user",
                "DOTS_HOME": str(self.home),
                "DOTS_CHECKOUT": str(self.checkout),
            },
            capture_output=True,
            text=True,
            timeout=120,
            check=True,
        )
        self.guard = result.stdout

    def run_guard(self):
        return subprocess.run(
            ["/bin/bash", "-c", self.guard],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )

    def test_source_alias_is_rejected_without_modifying_files(self):
        self.config.rmdir()
        self.config.symlink_to(self.source, target_is_directory=True)
        result = self.run_guard()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Refusing activation", result.stderr)
        self.assertTrue(self.config.is_symlink())
        self.assertEqual(self.init.read_text(), "-- Keep this source file.\n")

    def test_separate_config_directory_is_accepted(self):
        result = self.run_guard()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_unrelated_config_symlink_is_accepted(self):
        external = self.home / "external-config"
        external.mkdir()
        self.config.rmdir()
        self.config.symlink_to(external, target_is_directory=True)
        result = self.run_guard()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_missing_neovim_source_is_rejected(self):
        self.init.unlink()
        result = self.run_guard()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Neovim checkout missing", result.stderr)


if __name__ == "__main__":
    unittest.main()
