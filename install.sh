#!/usr/bin/env bash
# ! THIS IS A PERSONAL SCRIPT AND HAS NO PROTECTIONS FOR USAGE !

# please dont have this as a symlink or this breaks and i dont wanna fix
cd "$(dirname "$0")"
cp -f .tmux.conf.local ~/
cp -f .tmux.conf ~/
cp -f .vimrc ~/
cp -f .zshrc ~/
cp -f .p10k.zsh ~/
# these should be xdg_config_home or whatever but ion feel like it
cp -f .config/nvim/init.lua ~/.config/nvim/init.lua
cp -f .config/tmux/tmux.conf ~/.config/tmux/tmux.conf
cp -f .config/starship.toml ~/.config/starship.toml
