## Dotfiles
![macos screenshot](https://github.com/yawnbo/yawnbo/blob/main/media/dots/mac2.png?raw=true)
Clone repo
``` bash
git clone https://github.com/yawnbo/dots.git ~/
```
Manager by nix+homemanager. Lorri for direnv.
```
cd dots
./install.sh build
./install.sh switch
```

Run the installer as your normal account, not with `sudo`. It detects your
username with `id`, uses your current `$HOME`, and finds this checkout's actual
path. Neither the username nor the checkout directory needs to be `yawnbo` or
`~/dots`.

Profiles are platform-only: `aarch64-darwin`, `x86_64-darwin`, `aarch64-linux`,
and `x86_64-linux`. The installer selects the matching profile automatically
and prints the target account, home directory, and checkout before proceeding.

Use `./install.sh` for subsequent builds and switches too. It passes
`DOTS_USERNAME`, `DOTS_HOME`, and `DOTS_CHECKOUT` to Home Manager with `--impure`.
These local values choose the installation target; dependency versions remain
pinned by `flake.lock`. Package-only flake outputs do not require local identity.
Activation still asks for confirmation and backs up conflicting files.

### Default development tools

Rust and Cargo are pinned to **1.99.0** through `rust-overlay`. The overlay follows
our existing Nixpkgs input; this does not upgrade the rest of the package set.
The Rust toolchain also includes matching rustfmt and Clippy components.

Nix installs `libiconv`. On macOS, the default Clang wrapper includes its header
and library paths, so ordinary Cargo builds can link `-liconv` without a project
shell. These flags belong to that compiler wrapper, not global environment
variables; project-specific compilers retain their own configuration.

After switching, check the installed toolchain:

```sh
python3 tests/test_toolchain.py
```

To check a generation before activation, set `DOTS_TEST_BIN` to its
`home-path/bin` directory when running the test.

### fix (still)
---
Maybe switch to typst instead of latex/word/markdown? Needs proper snippets and I don't know if they exist, but a vimtex replacement exists [here](https://github.com/niuiic/typst-preview.nvim)
