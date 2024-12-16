## Dotfiles

Clone repo
```
git clone https://github.com/yawnbo/dots.git ~/
```
Stow files (this REMOVES and OVERWRITES files do NOT use without backing up)
```
cd ~/dots
stow --adopt . && \
git restore .
```
### fix (still)  
make alt init.lua's for different colorschemes and less clutter in plugins/install.lua
