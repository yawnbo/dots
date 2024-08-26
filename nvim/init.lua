local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


-- lazy init list of plugs
require("lazy").setup({
	{ "rebelot/kanagawa.nvim", lazy = false, priority = 1000},
	{ "nvim-neotest/nvim-nio", lazy = false,},
	{
    		"nvim-treesitter/nvim-treesitter",
    		build = ":TSUpdate",
    		config = function () 
      		local configs = require("nvim-treesitter.configs")

      		configs.setup({
          		ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
          		sync_install = false,
          		highlight = { enable = true },
          		indent = { enable = true },  
        	})
    		end
 	},
	{ "morhetz/gruvbox", lazy = true,},
	{ "rust-lang/rust.vim", lazy = true,},
	{ "luochen1990/rainbow", lazy = false,},
	{ "tpope/vim-surround", lazy = false,},
	{ "tpope/vim-commentary", lazy = false,},
	{"tpope/vim-dispatch", lazy = false,},
	{"tpope/vim-fugitive", lazy = false,},
	{"tpope/vim-abolish", lazy = false,},
	{"Shirk/vim-gas", lazy = false,},
	{"junegunn/fzf", lazy = false,},
	{"junegunn/fzf.vim", lazy = false,},
	{"nvim-lua/plenary.nvim", lazy = false,},
	{"BurntSushi/ripgrep", lazy = false,},
	{"nvim-pack/nvim-spectre", lazy = false,},
	{"DingDean/wgsl.vim", lazy = false,},
	{"alaviss/nim.nvim", lazy = false,},
	{"neovim/nvim-lspconfig", lazy = false,},
	install = { colorscheme = { "kaganawa" } },
	checker = { enabled = true },
})

-- setup of individual plugins begin here
require('kanagawa').setup({
    compile = false,             -- enable compiling the colorscheme
    undercurl = true,            -- enable undercurls
    commentStyle = { italic = true },
    functionStyle = {},
    keywordStyle = { italic = true},
    statementStyle = { bold = true },
    typeStyle = {},
    transparent = false,         -- do not set background color
    dimInactive = false,         -- dim inactive window `:h hl-NormalNC`
    terminalColors = true,       -- define vim.g.terminal_color_{0,17}
    colors = {                   -- add/modify theme and palette colors
        palette = {},
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
    },
    overrides = function(colors) -- add/modify highlights
        return {}
    end,
    theme = "wave",              -- Load "wave" theme when 'background' option is not set
    background = {               -- map the value of 'background' option to a theme
        dark = "wave",           -- try "dragon" !
        light = "lotus"
    },
})
-- Treesitter init
require('nvim-treesitter.configs').setup({
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})
-- set colorscheme for overall vim
vim.cmd("colorscheme kanagawa")
