## Dotfiles
![macos screenshot](https://github.com/yawnbo/yawnbo/blob/main/media/dots/mac2.png?raw=true)
Clone repo
``` bash
git clone https://github.com/yawnbo/dots.git ~/
```
Run the installer to install the default tools (including Oh My Pi) and stow their settings:
``` bash
cd ~/dots && ./install.sh
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
avante nvim if i feel like paying for api use 
just actually do some work instead of this idk  
