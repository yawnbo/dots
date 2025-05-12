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
Maybe switch to typst instead of latex/word/markdown? Needs proper snippets and I don't know if they exist, but a vimtex replacement exists [here](https://github.com/niuiic/typst-preview.nvim)
just actually do some work instead of this idk  
