## Dotfiles
![macos screenshot](https://github.com/yawnbo/yawnbo/blob/main/media/dots/mac.png?raw=true)
Clone repo
``` bash
git clone https://github.com/yawnbo/dots.git ~/
```
Stow files (this REMOVES and OVERWRITES files do NOT use without backing up)
``` bash
cd ~/dots && \
stow --adopt . && \
git restore .
```
### fix (still)  
---  
get frac snippet to consume \\left and \\right  
gruvbox.nvim instead of gruvbox.vim (will need manual configuration)  
just actually do some work instead of this idk  
