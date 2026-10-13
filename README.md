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

### fix (still)
---
Maybe switch to typst instead of latex/word/markdown? Needs proper snippets and I don't know if they exist, but a vimtex replacement exists [here](https://github.com/niuiic/typst-preview.nvim)
