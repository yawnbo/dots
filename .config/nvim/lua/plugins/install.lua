require("lazy").setup({
	-- theme
	{
		"eddyekofo94/gruvbox-flat.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme gruvbox-flat]])
		end,
	},

	-- git
	{
		"kdheepak/lazygit.nvim",
		lazy = true,
		cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	-- editing
	{ "tpope/vim-surround", event = "VeryLazy" },
	{ "tpope/vim-commentary", event = "VeryLazy" },
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = { disable_filetype = { "tex" } },
	},

	-- search & replace
	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{
				"<leader>R",
				function()
					require("spectre").toggle()
				end,
				desc = "Toggle Spectre",
			},
			{
				"<leader>rw",
				function()
					require("spectre").open_visual({ select_word = true })
				end,
				desc = "Search current word",
			},
			{
				"<leader>rw",
				function()
					require("spectre").open_visual()
				end,
				mode = "v",
				desc = "Search selection",
			},
			{
				"<leader>rf",
				function()
					require("spectre").open_file_search({ select_word = true })
				end,
				desc = "Search in current file",
			},
		},
	},

	-- latex
	{ "SirVer/ultisnips" },
	{
		"lervag/vimtex",
		ft = "tex",
		init = function()
			vim.g.tex_flavor = "latex"
			vim.g.vimtex_compiler_method = "latexmk"
			vim.g.vimtex_view_method = "sioyek"
			vim.g.vimtex_format_enabled = 1
			vim.g.maplocalleader = "\\"
			vim.g.vimtex_quickfix_mode = 0
			vim.o.conceallevel = 1
			vim.g.tex_conceal = "adbmg"
			vim.g.UltiSnipsSnippetDirectories = { "UltiSnips", vim.fn.stdpath("config") .. "/UltiSnips" }
			vim.g.UltiSnipsExpandTrigger = "<tab>"
			vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
			vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
		end,
	},
	{ "honza/vim-snippets" },

	-- ui
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {
			options = {
				themable = true,
				indicator = { style = "icon", icon = "▎" },
				separator_style = { "", "" },
				buffer_close_icon = "",
				modified_icon = "●",
				close_icon = "",
				left_trunc_marker = "",
				right_trunc_marker = "",
				max_name_length = 20,
				max_prefix_length = 15,
				tab_size = 22,
				show_buffer_close_icons = true,
				show_close_icon = true,
				always_show_bufferline = true,
			},
		},
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			lazygit = { configure = true },
			quickfile = { enabled = true },
			notifier = { enabled = true },
			dashboard = {
				preset = {
					header = [[
                                           .:=****+-.
                                         -*%@@@@@@@@%#+.
                          .=+*####*=:. :#@@@%%@@@%%@@@@%=
                        -#@@@@@@@@@@@%%%%%%@@@@@@@@@@@%@@+
                       *@@@%@@@@@@@@%@@@%%@#-@@@:-%@@@@@%@:
                      +@%@@@@@@@*##%@@%@@%*  =#=   #@@@@%@+
                     .%@@@@@@@@@=  .=%@@%@+        :@%@@@@+
                     =@%@@@@*.=*+    .%@@@%        =@%@@%@=
                     *@@@@%@=         =@%@@:      -@@@@@@@-
                   .-#@@@@@@#         *@%@@#=:::=#@@@@@@@#*=.
                  :+##%@@@@%@#:      =@@@@%%@@@@@@%@@@@%####*-.
                .-#####%@@@@@@@#+==*%@@@@%%%%@@@@@@@@%########+:
               .=#############%@@@@@@%@@%*##%%%%%%%############*-
              .=########*****+--*@@@@@%##############**##########-.
             .-################+.-**++=========++**+=*############-.
             :###################   #%%%%%%%%%%-   .###############-
            .+##################+   -#=:-*%%%#-    .################:
      :=++===#############**++=:                    .=**############*::::::
      :*##################**+=                         :#############=:::::
      .=##*###################                         *#############*::::
       .=##*###############*#*                        .###############-::
        .-*#****************#*                        -#*###########*#=.
         .:+#***************#*                        *#*************#+.
          .-#*****************                       :#**************#+.
           -******************.    :=+==---:         +#***************+.
           :*****************#-   =++++++++++:      :#***************#+.
           :+*****************+  -++++++++++++-     ******************=.
           .=******************..++++++++++++++-   =******************:
            :******************-:+++++++++++++++. -#*****************+.
            .-******************-%*+++++++++++++::*******************-
             .=*****************=+@++++++++++++=-*******************=.
              :+*****************==++++++++*#+--*******************+:
               :=*****************=:-+#@@@@@%=-*******************+:
                .-+****************+--+*#*+==+*******************=.
                  :=******************+====+*******************+-.
                    :=+****++*******+************************+-.
                      .-=++****+++++++++++++++++++++*****++=:.
                         .:-==++*++*++++************++==-:.
                             ..:=++++++++=+++++===--:..
                                .-+*++*=..::::::::.
                                  :++++:   ::::::
                                   .:-:.   .:::.
					]],
				},
			},
		},
	},

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
				disable = { "latex" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
	},

	-- navigation
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		opts = {
			icons = {
				mappings = vim.g.have_nerd_font,
				keys = vim.g.have_nerd_font and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
					CR = "<CR> ",
					Esc = "<Esc> ",
					ScrollWheelDown = "<ScrollWheelDown> ",
					ScrollWheelUp = "<ScrollWheelUp> ",
					NL = "<NL> ",
					BS = "<BS> ",
					Space = "<Space> ",
					Tab = "<Tab> ",
					F1 = "<F1>",
					F2 = "<F2>",
					F3 = "<F3>",
					F4 = "<F4>",
					F5 = "<F5>",
					F6 = "<F6>",
					F7 = "<F7>",
					F8 = "<F8>",
					F9 = "<F9>",
					F10 = "<F10>",
					F11 = "<F11>",
					F12 = "<F12>",
				},
			},
			spec = {
				{ "<leader>c", group = "[C]ode", mode = { "n", "x" } },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			},
		},
	},
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					mappings = {
						i = { ["<c-enter>"] = "to_fuzzy_refine" },
					},
				},
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"-u",
				},
				pickers = {
					live_grep = {
						additional_args = function()
							return { "--hidden" }
						end,
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", function()
				builtin.find_files({ hidden = true })
			end, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })
			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })
			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	-- lsp
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end

					vim.diagnostic.config({ virtual_lines = { current_line = true } })
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local servers = {
				clangd = {
					cmd = { "clangd", "--offset-encoding=utf-16", "--fallback-style=webkit" },
				},
				gopls = {},
				pyright = {},
				rust_analyzer = {
					settings = {
						["rust-analyzer"] = {
							cargo = { allTargets = true },
							procMacro = { enable = true },
							checkOnSave = { command = "clippy", allTargets = true },
						},
					},
				},
				jdtls = {},
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
						},
					},
				},
			}

			require("mason").setup()

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, { "stylua" })
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						vim.lsp.config(server_name, server)
						vim.lsp.enable(server_name)
					end,
				},
			})
		end,
	},

	-- formatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = {}
				local lsp_format_opt
				if disable_filetypes[vim.bo[bufnr].filetype] then
					lsp_format_opt = "never"
				else
					lsp_format_opt = "fallback"
				end
				return { timeout_ms = 500, lsp_format = lsp_format_opt }
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				c = { "clang-format" },
				javascript = { "clang-format" },
				javascriptreact = { "clang-format" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
			},
		},
	},

	-- completion
	{ "hrsh7th/cmp-buffer" },
	{ "mfussenegger/nvim-jdtls" },
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.setup({
				experimental = { ghost_text = true },
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.confirm({ select = true }),
					["<C-y>"] = cmp.mapping.complete({}),
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "lazydev", group_index = 0 },
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				},
			})
		end,
	},

	-- misc
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	install = { colorscheme = { "gruvbox-flat" } },
	checker = { enabled = true },
})
