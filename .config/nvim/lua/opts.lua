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
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = false
vim.opt.scrolloff = 10

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.cmd("filetype plugin indent on")

vim.g.UltiSnipsNoPythonWarning = 1

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("js-ts-indent", { clear = true }),
	pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	callback = function()
		vim.bo.tabstop = 2
		vim.bo.shiftwidth = 2
		vim.bo.softtabstop = 2
		vim.bo.expandtab = true
		vim.bo.autoindent = true
		vim.bo.smartindent = false
	end,
})

-- keybinds for buffers
local function delete_buffer(buf, opts)
	opts = opts or {}
	buf = buf or vim.api.nvim_get_current_buf()
	local ok, snacks = pcall(require, "snacks")
	if ok and snacks.bufdelete then
		snacks.bufdelete(buf, opts)
	else
		vim.cmd((opts.force and "bdelete!" or "bdelete") .. " " .. buf)
	end
end

vim.keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>dd", function()
	delete_buffer()
end, { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bD", function()
	delete_buffer(nil, { force = true })
end, { desc = "Force delete buffer" })
vim.keymap.set("n", "<leader>bo", function()
	local visible = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		visible[vim.api.nvim_win_get_buf(win)] = true
	end
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and not visible[buf] then
			delete_buffer(buf)
		end
	end
end, { desc = "Delete hidden buffers" })

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
if vim.env.SSH_CONNECTION then
	local osc52 = require("vim.ui.clipboard.osc52")
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = osc52.copy("+"),
			["*"] = osc52.copy("*"),
		},
		paste = {
			["+"] = osc52.paste("+"),
			["*"] = osc52.paste("*"),
		},
	}
end

vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- auto-save tex files on insert leave
vim.api.nvim_create_autocmd("InsertLeave", {
	group = vim.api.nvim_create_augroup("AutoSaveTex", { clear = true }),
	pattern = "*.tex",
	command = "write",
})
