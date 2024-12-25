" load vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin()

Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'

call plug#end()
" important 
let mapleader = " "
let maplocalleader = " "
let g:have_nerd_font = 1
set t_Co=256

" opts
set wildmenu
set wildmode=list:longest,list:full
set showbreak=↳
set splitbelow
set splitright
set number
set mouse=a
set breakindent
set undofile
set signcolumn=yes
set cursorline
set ignorecase
set smartcase
set relativenumber
set updatetime=250
set timeoutlen=300
set list
set listchars=tab:»\ ,trail:·,nbsp:␣
set scrolloff=10
set tabstop=3
set shiftwidth=3

" Theme settings
let g:gruvbox_contrast_dark = "soft"
let g:gruvbox_invert_selection = 0
colorscheme gruvbox
set background=dark

" Filetype plugin on
filetype plugin on

" Keybindings for buffers
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>b :buffers<CR>:b 
nnoremap <leader>bd :bd<CR>
nnoremap <leader>bo :tabonly<CR>

" airline things
let g:airline_powerline_fonts = 1
let g:airline_extensions_tabline_enabled = 0
let g:airline_theme='minimalist'

" Clear highlight on search in normal mode
nnoremap <Esc> :nohlsearch<CR>

" Terminal mode exits
tnoremap <Esc><Esc> <C-\><C-n>

" Window focusing with hjkl
nnoremap <C-h> <C-w><C-h>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>

" Highlight yanks
augroup highlight-yank
  autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
    augroup END

    " Sync clipboard
    set clipboard=unnamedplus

" AutoSaveTex for .tex files
augroup AutoSaveTex
	autocmd!
		autocmd InsertLeave *.tex write
		augroup END
