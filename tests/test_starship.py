"""Check the lorri label with Starship's actual custom-module renderer."""

import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import tomllib
import unittest


CONFIG = Path(__file__).resolve().parents[1] / ".config/starship.toml"
ANSI = re.compile(r"\x1b\[[0-9;]*m")


class StarshipLayoutTests(unittest.TestCase):
    def test_lorri_is_on_the_right_immediately_before_battery(self):
        config = tomllib.loads(CONFIG.read_text())
        self.assertIn("$fill$memory_usage${custom.lorri}$battery", config["format"])


@unittest.skipUnless(shutil.which("starship"), "Starship is not installed")
class LorriLabelTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)

    def render(self, project=None):
        env = {
            **os.environ,
            "STARSHIP_CONFIG": str(CONFIG),
            "STARSHIP_CACHE": self.temp.name,
            "TERM": "xterm-256color",
        }
        env.pop("NO_COLOR", None)
        env.pop("LORRI_PROJECT", None)
        if project is not None:
            env["LORRI_PROJECT"] = project
        result = subprocess.run(
            ["starship", "module", "custom.lorri"],
            cwd=self.temp.name,
            env=env,
            capture_output=True,
            text=True,
            timeout=10,
            check=True,
        )
        self.assertEqual(result.stderr, "")
        return result.stdout

    def test_uses_project_parent_not_current_directory(self):
        for filename in ["flake.nix", "shell.nix"]:
            with self.subTest(filename=filename):
                output = self.render(f"/Users/yawnbo/evo_ws/src/evo/{filename}")
                self.assertEqual(ANSI.sub("", output), "evo ")
                self.assertIn("\x1b[38;2;135;175;175m", output)

    def test_no_environment_is_hidden(self):
        for project in [None, ""]:
            with self.subTest(project=project):
                self.assertEqual(self.render(project), "")

    def test_spaces_in_project_name(self):
        output = self.render("/home/user/projects/evo workspace/flake.nix")
        self.assertEqual(ANSI.sub("", output), "evo workspace ")


if __name__ == "__main__":
    unittest.main()
