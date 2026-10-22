"""Check the built or installed toolchain without a project development shell.

Set DOTS_TEST_BIN to a built Home Manager generation's home-path/bin directory
before activation. The default is the installed ~/.nix-profile/bin directory.
"""

import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


BIN = Path(os.environ.get("DOTS_TEST_BIN", str(Path.home() / ".nix-profile/bin")))


class ToolchainTests(unittest.TestCase):
    def run_command(self, *args):
        result = subprocess.run(
            [str(arg) for arg in args],
            env={**os.environ, "PATH": f"{BIN}{os.pathsep}{os.environ.get('PATH', '')}"},
            capture_output=True,
            text=True,
            timeout=60,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result.stdout

    def test_rust_and_cargo_versions(self):
        self.assertTrue(self.run_command(BIN / "rustc", "--version").startswith("rustc 1.99.0 "))
        self.assertTrue(self.run_command(BIN / "cargo", "--version").startswith("cargo 1.99.0 "))

    @unittest.skipUnless(sys.platform == "darwin", "macOS linker regression")
    def test_rust_can_link_iconv(self):
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            source = work / "main.rs"
            source.write_text('fn main() {}\n')
            executable = work / "rust-iconv"
            # Reproduce the -liconv lookup that failed for the aws-lc-sys build script.
            self.run_command(BIN / "rustc", source, "-l", "iconv", "-o", executable)
            self.run_command(executable)

    @unittest.skipUnless(sys.platform == "darwin", "macOS compiler configuration")
    def test_c_uses_nix_iconv_headers_and_library(self):
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            source = work / "main.c"
            source.write_text(
                '#include <iconv.h>\n'
                'int main(void) {\n'
                '    iconv_t converter = iconv_open("UTF-8", "UTF-8");\n'
                '    if (converter == (iconv_t)-1) return 1;\n'
                '    return iconv_close(converter);\n'
                '}\n'
            )
            executable = work / "c-iconv"
            self.run_command(BIN / "cc", source, "-liconv", "-o", executable)
            self.run_command(executable)
            libraries = self.run_command("/usr/bin/otool", "-L", executable)
            self.assertRegex(libraries, r"/nix/store/[^\s]+/lib/libiconv[^\s]*\.dylib")


if __name__ == "__main__":
    unittest.main()
