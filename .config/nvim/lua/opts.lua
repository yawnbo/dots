vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.opt.termguicolors = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.o.laststatus = 0

-- opts
vim.o.wildmenu = true
vim.opt.showbreak = "↳"
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wildignore:append({ ".javac", "node_modules", "*.pyc" })
vim.opt.wildignore:append({ ".aux", ".out", ".toc" })
vim.opt.wildignore:append({
	".o", ".obj", ".dll", ".exe", ".so", ".a", ".lib",
	".pyc", ".pyo", ".pyd", ".swp", ".swo", ".class",
	".DS_Store", ".git", ".hg", ".orig",
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
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = false
vim.opt.scrolloff = 10

vim.o.tabstop = 2
vim.o.shiftwidth = 2

-- keybinds for buffers
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>b", ":buffers<CR>:b ", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dd", ":bd<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>bo", ":tabonly<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle filetree", noremap = true, silent = true })

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

-- auto-save tex files on insert leave
vim.api.nvim_create_autocmd("InsertLeave", {
	group = vim.api.nvim_create_augroup("AutoSaveTex", { clear = true }),
	pattern = "*.tex",
	command = "write",
})
