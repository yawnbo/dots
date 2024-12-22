require("nvim-autopairs").setup({
	disable_filetype = { "tex" },
})

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
vim.cmd("AirlineTheme minimalist")
vim.cmd("colorscheme gruvbox")
