#!/usr/bin/env bash
# ! THIS IS A PERSONAL SCRIPT AND HAS NO PROTECTIONS FOR USAGE !

# please dont have this as a symlink or this breaks and i dont wanna fix
cd "$(dirname "$0")"
cp -f .tmux.conf.local ~/src/gitrepos/dots/
cp -f .tmux.conf ~/src/gitrepos/dots/
cp -f .vimrc ~/src/gitrepos/dots/
cp -f .zshrc ~/src/gitrepos/dots/
cp -f .p10k.zsh ~/src/gitrepos/dots/

# these should be xdg_config_home or whatever but ion feel like it
cp -f .config/nvim/init.lua ~/src/gitrepos/dots/.config/nvim/init.lua
cp -f .config/tmux/tmux.conf ~/src/gitrepos/dots/.config/tmux/tmux.conf
cp -f .config/starship.toml ~/src/gitrepos/dots/.config/starship.toml
