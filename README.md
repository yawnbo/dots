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
---

## Vim stuff (current)
trailing spaces on vim would be nice  
some of the opts are very weird still in .vimrc  
can the aux files and pdf storing PLEASE be fixed  
 - this should be done with custom flag passing to latexmk i think

## Stuff that is just everything else idk

make alt init.lua's for different colorschemes and less clutter in plugins/install.lua
