vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.opt.termguicolors = true
vim.g.airline_extensions_tabline_enabled = 0
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- This works but I don't know if i like it more or less i guess we will find out
-- ** TESTING **
vim.o.laststatus = 0

vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	command = "setlocal laststatus=0",
})

-- opts
vim.o.wildmenu = true
--vim.o.wildmode = "list:longest,list:full"
vim.opt.showbreak = "↳"
vim.opt.splitbelow = true
vim.opt.splitright = true

-- i don't remember where i got this list but i think its been working
vim.opt.wildignore:append({ ".javac", "node_modules", "*.pyc" })
vim.opt.wildignore:append({ ".aux", ".out", ".toc" })
vim.opt.wildignore:append({
	".o",
	".obj",
	".dll",
	".exe",
	".so",
	".a",
	".lib",
	".pyc",
	".pyo",
	".pyd",
	".swp",
	".swo",
	".class",
	".DS_Store",
	".git",
	".hg",
	".orig",
})
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.showmode = true
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
-- this one is nice but makes me lag very badly on large latex files for some reason
vim.opt.cursorline = false
vim.opt.scrolloff = 10

-- these are important (i feel like there is a third one that im forgetting)
vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- gruvbox theme stuff
vim.g.gruvbox_contrast_dark = "soft"
vim.g.gruvbox_invert_selection = 0

-- latex dont know if needed or not - i still have no idea however many months later
vim.cmd("filetype plugin on")
vim.g.UltiSnippetDirectories = "$HOME/.config/nvim/ultisnips"

-- keybinds for buffers
vim.api.nvim_set_keymap("n", "<leader>bn", ":bnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>bp", ":bprevious<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>b", ":buffers<CR>:b ", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>dd", ":bd<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>bo", ":tabonly<CR>", { noremap = true, silent = true })

vim.g.airline_powerline_fonts = 1

--clear highlight on search in norm
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

--term mode exits
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

--window focusing with hjkl
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeToggle<CR>", {
	desc = "Toggle filetree",
	noremap = true,
	silent = true,
})

--highlight yanks (amazing feature from kickstart)
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- sync clipboard
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- stuff to autowrite tex files on insertion leave
vim.api.nvim_create_augroup("AutoSaveTex", { clear = true })
vim.api.nvim_create_autocmd("InsertLeave", {
	group = "AutoSaveTex",
	pattern = "*.tex",
	command = "write",
})
