require("onedark").setup({
	-- Main options --
	style = "dark", -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
	transparent = false, -- Show/hide background
	term_colors = true, -- Change terminal color as per the selected theme style
	ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
	cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu

	-- toggle theme style ---
	toggle_style_key = nil, -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
	toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" }, -- List of styles to toggle between

	-- Change code style ---
	-- Options are italic, bold, underline, none
	-- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
	code_style = {
		comments = "italic",
		keywords = "none",
		functions = "none",
		strings = "none",
		variables = "none",
	},

	-- Lualine options --
	lualine = {
		transparent = false, -- lualine center bar transparency
	},

	-- Custom Highlights --
	colors = {
		bg0 = "#282a36",
	}, -- Override default colors
	highlights = {}, -- Override highlight groups

	-- Plugins Config --
	diagnostics = {
		darker = true, -- darker colors for diagnostic
		undercurl = true, -- use undercurl instead of underline for diagnostics
		background = true, -- use background color for virtual text
	},
})
require("kanagawa").setup({
	compile = false, -- enable compiling the colorscheme
	undercurl = true, -- enable undercurls
	commentStyle = { italic = true },
	functionStyle = {},
	keywordStyle = { italic = true },
	statementStyle = { bold = true },
	typeStyle = {},
	transparent = false, -- do not set background color
	dimInactive = false, -- dim inactive window `:h hl-NormalNC`
	terminalColors = true, -- define vim.g.terminal_color_{0,17}
	colors = { -- add/modify theme and palette colors
		palette = {},
		theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
	},
	overrides = function(colors) -- add/modify highlights
		return {}
	end,
	theme = "dragon", -- Load "wave" theme when 'background' option is not set
	background = { -- map the value of 'background' option to a theme
		dark = "dragon", -- try "dragon" !
		light = "lotus",
	},
})

require("nvim-autopairs").setup({
	disable_filetype = { "tex" },
})

-- see notes on copilot in the install.lua file
-- require("copilot").setup({
-- 	panel = {
-- 		enabled = true,
-- 		auto_refresh = false,
-- 		keymap = {
-- 			jump_prev = "[[",
-- 			jump_next = "]]",
-- 			accept = "<CR>",
-- 			refresh = "gr",
-- 			open = "<M-CR>",
-- 		},
-- 		layout = {
-- 			position = "bottom", -- | top | left | right
-- 			ratio = 0.4,
-- 		},
-- 	},
-- 	suggestion = {
-- 		enabled = true,
-- 		auto_trigger = false,
-- 		hide_during_completion = true,
-- 		debounce = 75,
-- 		keymap = {
-- 			accept = "<M-l>",
-- 			accept_word = false,
-- 			accept_line = false,
-- 			next = "<M-]>",
-- 			prev = "<M-[>",
-- 			dismiss = "<C-]>",
-- 		},
-- 	},
-- 	filetypes = {
-- 		yaml = false,
-- 		markdown = true,
-- 		help = false,
-- 		gitcommit = false,
-- 		gitrebase = false,
-- 		hgcommit = false,
-- 		svn = false,
-- 		cvs = false,
-- 		["."] = false,
-- 	},
-- 	copilot_node_command = "node", -- Node.js version must be > 18.x
-- 	server_opts_overrides = {},
-- })
-- set colorscheme for overall vim
-- :TODO: fix this to actually look decent
require("bufferline").setup({
	options = {
		themable = true,
		indicator = { style = "icon", icon = "▎" },
		separator_style = { "", "" },
		buffer_close_icon = "",
		modified_icon = "●",
		close_icon = "",
		left_trunc_marker = "",
		right_trunc_marker = "",
		max_name_length = 20,
		max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
		tab_size = 22,
		show_buffer_close_icons = true,
		show_close_icon = true,
		always_show_bufferline = true,
	},
})
require("gitsigns").setup({
	signs = {
		add = { text = "┃" },
		change = { text = "┃" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signs_staged = {
		add = { text = "┃" },
		change = { text = "┃" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
	signs_staged_enable = true,
	signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
	numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
	linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
	word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
	watch_gitdir = {
		follow_files = true,
	},
	auto_attach = true,
	attach_to_untracked = false,
	current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
		delay = 1000,
		ignore_whitespace = false,
		virt_text_priority = 100,
		use_focus = true,
	},
	current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
	sign_priority = 6,
	update_debounce = 100,
	status_formatter = nil, -- Use default
	max_file_length = 40000, -- Disable if file is longer than this (in lines)
	preview_config = {
		-- Options passed to nvim_open_win
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},
})
-- lowkey like the other gruvbox more for a lot of color choices so review that for more changes because idk if I like the current one.
vim.cmd("colorscheme gruvbox-flat")
