local k = require "keybind"

---@class ToogleTermCmd toggleterm command cache object
---@field lazygit Terminal | nil
---@field btop Terminal | nil
---@field ipython Terminal | nil
local cmd = { lazygit = nil, btop = nil, ipython = nil }
local icons = {
	ui = require("icons").get "ui",
	ui_space = require("icons").get("ui", true),
	misc = require("icons").get "misc",
	diagnostics = require("icons").get "diagnostics",
	dap = require("icons").get "dap",
}

return {
	{ "jghauser/mkdir.nvim" },
	{ "dstein64/vim-startuptime", lazy = true, cmd = "StartupTime" },
	{
		"asiryk/auto-hlsearch.nvim",
		lazy = true,
		event = "InsertEnter",
		config = function() require("auto-hlsearch").setup() end,
	},
	{
		"nmac427/guess-indent.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = function() require("guess-indent").setup {} end,
	},
	{
		"folke/which-key.nvim",
		lazy = true,
		event = "VeryLazy",
		config = function()
			require("which-key").setup {
				plugins = {
					presets = { operators = false, motions = false, text_objects = false, windows = false, nav = false },
				},
				icons = { breadcrumb = icons.ui.Separator, separator = icons.misc.Vbar, group = icons.misc.Add },
				disable = { filetypes = { "help", "lspsagaoutine", "_sagaoutline" } },
			}
		end,
	},
	{
		"ojroques/nvim-bufdel",
		lazy = true,
		event = "BufReadPost",
		config = function()
			k.nvim_register_mapping {
				["n|<C-x>"] = k.cr("BufDel"):with_defaults "bufdel: Delete current buffer",
			}
		end,
	},
	{
		"m4xshen/autoclose.nvim",
		lazy = true,
		event = "InsertEnter",
		config = function() require("autoclose").setup() end,
	},
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		config = function()
			require("dressing").setup {
				input = {
					enabled = true,
				},
				select = {
					enabled = true,
					backend = "telescope",
					trim_prompt = true,
				},
			}
		end,
	},
	{
		"kylechui/nvim-surround",
		lazy = true,
		event = "InsertEnter",
		config = function() require("nvim-surround").setup() end,
	},
	{
		"pwntester/octo.nvim",
		lazy = true,
		cmd = "Octo",
		event = { "CursorHold", "CursorHoldI" },
		config = function()
			require("octo").setup { default_remote = { "upstream", "origin" } }
			k.nvim_register_mapping {
				["n|<Leader>o"] = k.args("Octo"):with_defaults "octo: List pull request",
			}
		end,
	},
	{
		"nvim-pack/nvim-spectre",
		lazy = true,
		build = "./build.sh nvim_oxi",
		config = function()
			require("spectre").setup {
				live_update = true,
				default = {
					replace = { cmd = not require("editor").global.is_mac and "oxi" or "sed" },
				},
				mapping = {
					["change_replace_sed"] = {
						map = "<LocalLeader>trs",
						cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
						desc = "replace: Using sed",
					},
					["change_replace_oxi"] = {
						map = "<LocalLeader>tro",
						cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
						desc = "replace: Using oxi",
					},
					["toggle_live_update"] = {
						map = "<LocalLeader>tu",
						cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
						desc = "replace: update live changes",
					},
					-- only work if the find_engine following have that option
					["toggle_ignore_case"] = {
						map = "<LocalLeader>ti",
						cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
						desc = "replace: toggle ignore case",
					},
					["toggle_ignore_hidden"] = {
						map = "<LocalLeader>th",
						cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
						desc = "replace: toggle search hidden",
					},
				},
			}
		end,
		init = function()
			k.nvim_register_mapping {
				["n|<Leader>sv"] = k.callback(function() require("spectre").open_visual() end)
					:with_defaults "replace: Open visual replace",
				["n|<Leader>so"] = k.callback(function() require("spectre").open() end)
					:with_defaults "replace: Open panel",
				["n|<Leader>sw"] = k.callback(function() require("spectre").open_visual { select_word = true } end)
					:with_defaults "replace: Replace word under cursor",
				["n|<Leader>sp"] = k.callback(function() require("spectre").open_file_search() end)
					:with_defaults "replace: Replace word under file search",
			}
		end,
	},
	{
		"junegunn/vim-easy-align",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		cmd = "EasyAlign",
		config = function()
			k.nvim_register_mapping {
				["n|gea"] = k.callback(function() return k.replace_termcodes "<Plug>(EasyAlign)" end)
					:with_expr()
					:with_desc "edit: Align by char",
				["x|gea"] = k.callback(function() return k.replace_termcodes "<Plug>(EasyAlign)" end)
					:with_expr()
					:with_desc "edit: Align by char",
			}
		end,
	},
	{
		"tpope/vim-fugitive",
		lazy = false,
		command = { "Git", "G", "Ggrep", "GBrowse" },
		config = function()
			k.nvim_register_mapping {
				["n|<LocalLeader>G"] = k.cr("G"):with_defaults "git: Open git-fugitive",
				["n|<LocalLeader>gaa"] = k.cr("G add ."):with_defaults "git: Add all files",
				["n|<LocalLeader>gcm"] = k.cr("G commit"):with_defaults "git: Commit",
				["n|<LocalLeader>gps"] = k.cr("G push"):with_defaults "git: push",
				["n|<LocalLeader>gpl"] = k.cr("G pull"):with_defaults "git: pull",
			}
		end,
	},
	{
		"sindrets/diffview.nvim",
		lazy = true,
		cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
		init = function()
			k.nvim_register_mapping {
				["n|<LocalLeader>D"] = k.cr("DiffviewOpen"):with_defaults "git: Show diff view",
				["n|<LocalLeader><LocalLeader>D"] = k.cr("DiffviewClose"):with_defaults "git: Close diff view",
			}
		end,
	},
	-- plugins with simple setup
	{
		"max397574/better-escape.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = function()
			require("better_escape").setup {
				mapping = { "jj", "jk" }, -- a table with mappings to use
				timeout = 200, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
				clear_empty_lines = true, -- clear line after escaping if there is only whitespace
				keys = "<Esc>", -- the keys to use for escaping
			}
		end,
	},
	{
		"cshuaimin/ssr.nvim",
		lazy = true,
		module = "ssr",
		event = { "CursorHold", "CursorHoldI" },
		-- Calling setup is optional.
		config = function()
			require("ssr").setup {
				min_width = 50,
				min_height = 5,
				max_width = 120,
				max_height = 25,
				keymaps = {
					close = "q",
					next_match = "n",
					prev_match = "N",
					replace_confirm = "<cr>",
					replace_all = "<leader><cr>",
				},
			}
			k.nvim_register_mapping {
				["n|<LocalLeader>sr"] = k.callback(function() require("ssr").open() end)
					:with_defaults "edit: search and replace",
			}
		end,
	},
	{
		"LunarVim/bigfile.nvim",
		lazy = true,
		config = function()
			require("bigfile").config {
				filesize = 1, -- size of the file in MiB
				pattern = { "*" }, -- autocmd pattern
				features = { -- features to disable
					"indent_blankline",
					"lsp",
					"illuminate",
					"treesitter",
					"syntax",
					"vimopts",
					{
						name = "ftdetect",
						opts = { defer = true },
						disable = function()
							vim.api.nvim_set_option_value("filetype", "big_file_disabled_ft", { scope = "local" })
						end,
					},
					{
						name = "nvim-cmp",
						opts = { defer = true },
						disable = function() require("cmp").setup.buffer { enabled = false } end,
					},
				},
			}
		end,
		cond = require("editor").config.load_big_files_faster,
	},
	{
		"akinsho/toggleterm.nvim",
		lazy = true,
		cmd = {
			"ToggleTerm",
			"ToggleTermSetName",
			"ToggleTermToggleAll",
			"ToggleTermSendVisualLines",
			"ToggleTermSendCurrentLine",
			"ToggleTermSendVisualSelection",
		},
		config = function()
			require("toggleterm").setup {
				-- size can be a number or function which is passed the current terminal
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.40
					end
				end,
				on_open = function()
					-- Prevent infinite calls from freezing neovim.
					-- Only set these options specific to this terminal buffer.
					vim.api.nvim_set_option_value("foldmethod", "manual", { scope = "local" })
					vim.api.nvim_set_option_value("foldexpr", "0", { scope = "local" })
				end,
				open_mapping = false, -- [[<C-t>]],
				shade_terminals = false,
				shading_factor = vim.o.background == "dark" and "1" or "3",
				direction = "horizontal",
			}

			local program_term = function(name, opts)
				opts = opts or {}
				local path = require("utils").get_binary_path(name)

				if path then
					if not cmd[name] then
						cmd[name] = require("toggleterm.terminal").Terminal:new(vim.tbl_extend("keep", opts, {
							cmd = path,
							hidden = true,
							direction = "float",
							float_opts = {
								border = "double",
							},
							on_open = function(term)
								vim.api.nvim_buf_set_keymap(
									term.bufnr,
									"n",
									"q",
									"<cmd>close<CR>",
									{ noremap = true, silent = true }
								)
							end,
						}))
					end
					cmd[name]:toggle()
				else
					vim.notify(
						string.format("'%s' not found!. Make sure to include it in PATH.", name),
						vim.log.levels.ERROR,
						{ title = "toggleterm.nvim" }
					)
				end
			end

			k.nvim_register_mapping {
				["n|<C-\\>"] = k.cr([[execute v:count . "ToggleTerm direction=horizontal"]])
					:with_defaults "terminal: Toggle horizontal",
				["i|<C-\\>"] = k.cmd("<Esc><Cmd>ToggleTerm direction=horizontal<CR>")
					:with_defaults "terminal: Toggle horizontal",
				["t|<C-\\>"] = k.cmd("<Esc><Cmd>ToggleTerm<CR>"):with_defaults "terminal: Toggle horizontal",
				["n|<C-t>"] = k.cr([[execute v:count . "ToggleTerm direction=vertical"]])
					:with_defaults "terminal: Toggle vertical",
				["i|<C-t>"] = k.cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>")
					:with_defaults "terminal: Toggle vertical",
				["t|<C-t>"] = k.cmd("<Esc><Cmd>ToggleTerm<CR>"):with_defaults "terminal: Toggle vertical",
				["n|slg"] = k.callback(function() program_term "lazygit" end):with_defaults "git: Toggle lazygit",
				["t|slg"] = k.callback(function() program_term "lazygit" end):with_defaults "git: Toggle lazygit",
				["n|sbt"] = k.callback(function() program_term "btop" end):with_defaults "git: Toggle btop",
				["t|sbt"] = k.callback(function() program_term "btop" end):with_defaults "git: Toggle btop",
				["n|sipy"] = k.callback(function() program_term "ipython" end):with_defaults "git: Toggle ipython",
				["t|sipy"] = k.callback(function() program_term "ipython" end):with_defaults "git: Toggle ipython",
			}
		end,
	},
	{
		"folke/trouble.nvim",
		lazy = true,
		cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
		config = function()
			require("trouble").setup {
				position = "left", -- position of the list can be: bottom, top, left, right
				mode = "document_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
				fold_open = icons.ui.ArrowOpen, -- icon used for open folds
				fold_closed = icons.ui.ArrowClosed, -- icon used for closed folds
				auto_close = true, -- automatically close the list when you have no diagnostics
				auto_fold = false, -- automatically fold a file trouble list at creation
				auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
				signs = {
					-- icons / text used for a diagnostic
					error = icons.diagnostics.ErrorHolo,
					warning = icons.diagnostics.WarningHolo,
					hint = icons.diagnostics.HintHolo,
					information = icons.diagnostics.InformationHolo,
					other = icons.diagnostics.QuestionHolo,
				},
				use_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
			}

			k.nvim_register_mapping {
				["n|gt"] = k.cr("TroubleToggle"):with_defaults "lsp: Toggle trouble list",
				["n|gR"] = k.cr("TroubleToggle lsp_references"):with_defaults "lsp: Show lsp references",
				["n|<LocalLeader>td"] = k.cr("TroubleToggle document_diagnostics")
					:with_defaults "lsp: Show document diagnostics",
				["n|<LocalLeader>tw"] = k.cr("TroubleToggle workspace_diagnostics")
					:with_defaults "lsp: Show workspace diagnostics",
				["n|<LocalLeader>tq"] = k.cr("TroubleToggle quickfix"):with_defaults "lsp: Show quickfix list",
				["n|<LocalLeader>tl"] = k.cr("TroubleToggle loclist"):with_defaults "lsp: Show loclist",
			}
		end,
	},
	{
		"phaazon/hop.nvim",
		lazy = true,
		branch = "v2",
		event = { "CursorHold", "CursorHoldI" },
		cond = function() return not vim.tbl_contains({ "nofile", "alpha", "gitcommit", "gitrebase" }, vim.bo.filetype) end,
		config = function()
			require("hop").setup()
			-- set f/F to use hop
			local hop = require "hop"
			local d = require("hop.hint").HintDirection
			vim.api.nvim_set_keymap("", "f", "", {
				noremap = false,
				callback = function()
					hop.hint_char1 {
						direction = d.AFTER_CURSOR,
						current_line_only = true,
					}
				end,
				desc = "motion: f 1 char",
			})
			vim.api.nvim_set_keymap("", "F", "", {
				noremap = false,
				callback = function()
					hop.hint_char1 {
						direction = d.BEFORE_CURSOR,
						current_line_only = true,
					}
				end,
				desc = "motion: F 1 char",
			})
			vim.api.nvim_set_keymap("", "t", "", {
				noremap = false,
				callback = function()
					hop.hint_char1 {
						direction = d.AFTER_CURSOR,
						current_line_only = true,
						hint_offset = -1,
					}
				end,
				desc = "motion: t 1 char",
			})
			vim.api.nvim_set_keymap("", "T", "", {
				noremap = false,
				callback = function()
					hop.hint_char1 {
						direction = d.BEFORE_CURSOR,
						current_line_only = true,
						hint_offset = 1,
					}
				end,
				desc = "motion: T 1 char",
			})

			k.nvim_register_mapping {
				["n|<LocalLeader>w"] = k.cu("HopWord"):with_noremap():with_desc "jump: Goto word",
				["n|<LocalLeader>j"] = k.cu("HopLine"):with_noremap():with_desc "jump: Goto line",
				["n|<LocalLeader>k"] = k.cu("HopLine"):with_noremap():with_desc "jump: Goto line",
				["n|<LocalLeader>c"] = k.cu("HopChar1"):with_noremap():with_desc "jump: Goto one char",
				["n|<LocalLeader>cc"] = k.cu("HopChar2"):with_noremap():with_desc "jump: Goto two chars",
			}
		end,
	},
	{
		"gelguy/wilder.nvim",
		lazy = true,
		event = "CmdlineEnter",
		dependencies = { "romgrk/fzy-lua-native" },
		config = function()
			local wilder = require "wilder"
			wilder.setup { modes = { ":", "/", "?" } }
			wilder.set_option("use_python_remote_plugin", 0)
			wilder.set_option("pipeline", {
				wilder.branch(
					wilder.cmdline_pipeline {
						use_python = 0,
						fuzzy = 1,
						fuzzy_filter = wilder.lua_fzy_filter(),
					},
					wilder.vim_search_pipeline(),
					{
						wilder.check(function(_, x) return x == "" end),
						wilder.history(),
						wilder.result {
							draw = {
								function(_, x) return " " .. x end,
							},
						},
					}
				),
			})

			local popupmenu_renderer = wilder.popupmenu_renderer(wilder.popupmenu_border_theme {
				border = "rounded",
				empty_message = wilder.popupmenu_empty_message_with_spinner(),
				highlighter = wilder.lua_fzy_highlighter(),
				left = {
					" ",
					wilder.popupmenu_devicons(),
					wilder.popupmenu_buffer_flags {
						flags = " a + ",
						icons = { ["+"] = "", a = "", h = "" },
					},
				},
				right = {
					" ",
					wilder.popupmenu_scrollbar(),
				},
			})
			local wildmenu_renderer = wilder.wildmenu_renderer {
				highlighter = wilder.lua_fzy_highlighter(),
				apply_incsearch_fix = true,
				separator = " | ",
				left = { " ", wilder.wildmenu_spinner(), " " },
				right = { " ", wilder.wildmenu_index() },
			}
			wilder.set_option(
				"renderer",
				wilder.renderer_mux {
					[":"] = popupmenu_renderer,
					["/"] = wildmenu_renderer,
					substitute = wildmenu_renderer,
				}
			)
		end,
	},
	{
		"numToStr/Comment.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = function()
			require("Comment").setup {
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			}

			k.nvim_register_mapping {
				["n|gcc"] = k.callback(
					function()
						return vim.v.count == 0 and k.replace_termcodes "<Plug>(comment_toggle_linewise_current)"
							or k.replace_termcodes "<Plug>(comment_toggle_linewise_count)"
					end
				)
					:with_expr()
					:with_defaults "edit: Toggle comment for line",
				["n|gbc"] = k.callback(
					function()
						return vim.v.count == 0 and k.replace_termcodes "<Plug>(comment_toggle_blockwise_current)"
							or k.replace_termcodes "<Plug>(comment_toggle_blockwise_count)"
					end
				)
					:with_expr()
					:with_defaults "edit: Toggle comment for block",
				["n|gc"] = k.cmd("<Plug>(comment_toggle_linewise)")
					:with_defaults "edit: Toggle comment for line with operator",
				["n|gb"] = k.cmd("<Plug>(comment_toggle_blockwise)")
					:with_defaults "edit: Toggle comment for block with operator",
				["x|gc"] = k.cmd("<Plug>(comment_toggle_linewise_visual)")
					:with_defaults "edit: Toggle comment for line with selection",
				["x|gb"] = k.cmd("<Plug>(comment_toggle_blockwise_visual)")
					:with_defaults "edit: Toggle comment for block with selection",
			}
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = true,
		build = function()
			if #vim.api.nvim_list_uis() ~= 0 then vim.api.nvim_command "TSUpdate" end
		end,
		event = { "CursorHold", "CursorHoldI" },
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects" },
			{ "romgrk/nvim-treesitter-context" },
			{ "mrjones2014/nvim-ts-rainbow" },
			{ "JoosepAlviste/nvim-ts-context-commentstring" },
			{
				"andymass/vim-matchup",
				event = "BufReadPost",
				config = function() vim.g.matchup_matchparen_offscreen = { method = "status_manual" } end,
			},
			{
				"NvChad/nvim-colorizer.lua",
				config = function()
					require("colorizer").setup {
						filetypes = { "*", "!lazy" },
						buftype = { "*", "!prompt", "!nofile" },
						user_default_options = {
							RGB = true, -- #RGB hex codes
							RRGGBB = true, -- #RRGGBB hex codes
							names = false, -- "Name" codes like Blue
							RRGGBBAA = true, -- #RRGGBBAA hex codes
							AARRGGBB = false, -- 0xAARRGGBB hex codes
							rgb_fn = true, -- CSS rgb() and rgba() functions
							hsl_fn = true, -- CSS hsl() and hsla() functions
							css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
							css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
							mode = "background", -- `mode`: foreground, background,  virtualtext
							virtualtext = "■",
						},
					}
				end,
			},
		},
		config = function()
			vim.api.nvim_set_option_value("foldmethod", "expr", {})
			vim.api.nvim_set_option_value("foldexpr", "nvim_treesitter#foldexpr()", {})

			require("nvim-treesitter.configs").setup {
				ensure_installed = "all",
				ignore_install = { "phpdoc" },
				indent = { enable = false },
				highlight = {
					enable = true,
					disable = function(ft, bufnr)
						if vim.tbl_contains({ "vim", "help" }, ft) then return true end
						local ok, is_large_file = pcall(vim.api.nvim_buf_get_var, bufnr, "bigfile_disable_treesitter")
						return ok and is_large_file
					end,
					additional_vim_regex_highlighting = false,
				},
				-- NOTE: Highlight (extended mode) also non-parentheses delimiters, boolean or table: lang -> boolean
				rainbow = { enable = true, extended_mode = true },
				context_commentstring = { enable = true, enable_autocmd = false },
				matchup = { enable = true },
				textobjects = {
					select = {
						enable = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]["] = "@function.outer",
							["]m"] = "@class.outer",
						},
						goto_next_end = {
							["]]"] = "@function.outer",
							["]M"] = "@class.outer",
						},
						goto_previous_start = {
							["[["] = "@function.outer",
							["[m"] = "@class.outer",
						},
						goto_previous_end = {
							["[]"] = "@function.outer",
							["[M"] = "@class.outer",
						},
					},
				},
			}

			require("nvim-treesitter.install").prefer_git = true
			local parsers = require "nvim-treesitter.parsers"
			local parsers_config = parsers.get_parser_configs()
			for _, p in pairs(parsers_config) do
				p.install_info.url = p.install_info.url:gsub("https://github.com/", "git@github.com:")
			end

			-- set octo.nvim to use treesitter
			if vim.api.nvim_get_commands({})["Octo"] then parsers.filetype_to_parsername.octo = "markdown" end
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		lazy = true,
		dependencies = {
			{
				"nvim-tree/nvim-web-devicons",
				config = function()
					require("nvim-web-devicons").setup {
						override = {
							zsh = { icon = "", color = "#428850", cterm_color = "65", name = "Zsh" },
						},
						-- globally enable default icons (default to false)
						-- will get overriden by `get_icons` option
						default = true,
					}
				end,
			},
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-lua/popup.nvim" },
			{ "debugloop/telescope-undo.nvim" },
			{ "jvgrootveld/telescope-zoxide" },
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
			{ "nvim-telescope/telescope-frecency.nvim", dependencies = { "kkharji/sqlite.lua" } },
			{
				"ahmedkhalf/project.nvim",
				event = "BufReadPost",
				config = function()
					require("project_nvim").setup {
						ignore_lsp = { "null-ls", "copilot" },
						show_hidden = true,
						silent_chdir = true,
						scope_chdir = "win",
					}
				end,
			},
		},
		config = function()
			require("telescope").setup(vim.tbl_deep_extend("keep", require("editor").config.plugins.telescope, {
				defaults = {
					prompt_prefix = " " .. icons.ui_space.Telescope .. " ",
					selection_caret = icons.ui_space.DoubleSeparator,
					borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
					scroll_strategy = "limit",
					layout_strategy = "horizontal",
					path_display = { "absolute" },
					results_title = false,
					mappings = {
						i = {
							["<C-a>"] = { "<esc>0i", type = "command" },
							["<Esc>"] = require("telescope.actions").close,
						},
						n = { ["q"] = require("telescope.actions").close },
					},
					layout_config = {
						horizontal = {
							preview_width = 0.5,
							prompt_position = "top",
						},
						vertical = {
							preview_height = 0.5,
							prompt_position = "top",
						},
					},
					generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
				},
				extensions = {
					undo = { side_by_side = true },
					fzf = {
						fuzzy = false,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
					frecency = {
						show_scores = true,
						show_unindexed = true,
						ignore_patterns = { "*.git/*", "*/tmp/*", "*/lazy-lock.json" },
					},
					live_grep_args = {
						auto_quoting = true,
						mappings = {
							i = {
								["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
								["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt {
									postfix = " --iglob ",
								},
							},
						},
					},
				},
				pickers = {
					keymaps = {
						theme = "dropdown",
					},
					live_grep = {
						on_input_filter_cb = function(prompt)
							-- AND operator for live_grep like how fzf handles spaces with wildcards in rg
							return { prompt = prompt:gsub("%s", ".*") }
						end,
						attach_mappings = function(_)
							require("telescope.actions.set").select:enhance {
								post = function() vim.cmd ":normal! zx" end,
							}
							return true
						end,
					},
					diagnostics = {
						initial_mode = "normal",
					},
				},
			}))

			for _, v in ipairs { "fzf", "frecency", "live_grep_args", "zoxide", "notify", "undo", "projects" } do
				require("telescope").load_extension(v)
			end
		end,
		init = function()
			local command_panel = function()
				require("telescope.builtin").keymaps {
					lhs_filter = function(lhs) return not string.find(lhs, "Þ") end,
					layout_config = {
						width = 0.6,
						height = 0.6,
						prompt_position = "top",
					},
				}
			end

			k.nvim_register_mapping {
				["n|<Leader>w"] = k.callback(
					function() require("telescope").extensions.live_grep_args.live_grep_args() end
				)
					:with_defaults "find: Word in project",
				["n|<Leader>r"] = k.callback(function() require("telescope").extensions.frecency.frecency() end)
					:with_defaults "find: File by frecency",
				["n|<Leader>b"] = k.cu("Telescope buffers"):with_defaults "find: Buffer opened",
				["n|<Leader>\\"] = k.callback(
					function() require("telescope").extensions.projects.projects { promp_title = "Projects" } end
				):with_defaults "find: Project",
				["n|<Leader>f"] = k.callback(function() require("utils").find_files(false) end)
					:with_defaults "find: file in project",
				["n|<Leader>'"] = k.cu("Telescope zoxide list")
					:with_defaults "edit: Change current direrctory by zoxide",
				["n|<Leader>u"] = k.callback(function() require("telescope").extensions.undo.undo() end)
					:with_defaults "edit: Show undo history",
				["n|<Leader>/"] = k.cu("Telescope grep_string"):with_defaults "find: Current word",
				["n|<Leader>n"] = k.cu("enew"):with_defaults "buffer: New",
				["n|<C-p>"] = k.callback(command_panel):with_defaults "tools: Show keymap legends",
				["n|<LocalLeader>e"] = k.callback(
					function() require("utils").find_files { cwd = vim.fn.stdpath "config" } end
				)
					:with_defaults "tools: edit NVIM config",
			}
		end,
	},
}
