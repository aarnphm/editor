local k = require "zox.keybind"

return {
	{ "romainl/vim-cool", lazy = true, event = { "CursorMoved", "InsertEnter" } },
	{
		"sindrets/diffview.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
		config = true,
		keys = function()
			return k.to_lazy_mapping {
				["n|<LocalLeader>D"] = k.cr("DiffviewOpen"):with_defaults "git: Show diff view",
				["n|<LocalLeader><LocalLeader>D"] = k.cr("DiffviewClose")
					:with_defaults "git: Close diff view",
			}
		end,
	},
	{
		"j-hui/fidget.nvim",
		lazy = true,
		event = "BufReadPost",
		opts = {
			text = { spinner = "dots" },
			window = { blend = 0 },
		},
	},
	{
		"rcarriga/nvim-notify",
		lazy = true,
		event = "LspAttach",
		cond = function()
			if #vim.api.nvim_list_uis() ~= 0 then
				return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype)
			end
			return false
		end,
		config = function()
			local notify = require "notify"
			notify.setup {
				stages = "static",
				---@usage User render fps value
				fps = 60,
				max_height = function() return math.floor(vim.o.lines * 0.55) end,
				max_width = function() return math.floor(vim.o.columns * 0.55) end,
				render = "minimal",
				background_colour = "Normal",
				---@usage notifications with level lower than this would be ignored. [ERROR > WARN > INFO > DEBUG > TRACE]
				level = "INFO",
			}

			vim.notify = notify
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		lazy = true,
		event = "LspAttach",
		config = function()
			local escape_status = function()
				local ok, m = pcall(require, "better_escape")
				return ok and m.waiting and ZoxIcon.MiscSpace.EscapeST or ""
			end

			local _cache = { context = "", bufnr = -1 }
			local lspsaga_symbols = function()
				if
					vim.api.nvim_win_get_config(0).zindex
					or vim.tbl_contains({
						"terminal",
						"toggleterm",
						"prompt",
						"alpha",
						"dashboard",
						"help",
						"TelescopePrompt",
					}, vim.bo.filetype)
				then
					return "" -- Excluded filetypes
				else
					local currbuf = vim.api.nvim_get_current_buf()
					local ok, lspsaga = pcall(require, "lspsaga.symbolwinbar")
					if ok and lspsaga:get_winbar() ~= nil then
						_cache.context = lspsaga:get_winbar()
						_cache.bufnr = currbuf
					elseif _cache.bufnr ~= currbuf then
						_cache.context = "" -- NOTE: Reset [invalid] cache (usually from another buffer)
					end

					return _cache.context
				end
			end

			local diff_source = function()
				local gitsigns = vim.b.gitsigns_status_dict
				if gitsigns then
					return {
						added = gitsigns.added,
						modified = gitsigns.changed,
						removed = gitsigns.removed,
					}
				end
			end

			local get_cwd = function()
				local cwd = vim.fn.getcwd()
				if not vim.loop.os_uname().sysname == "Windows_NT" then
					local home = os.getenv "HOME"
					if home and cwd:find(home, 1, true) == 1 then
						cwd = "~" .. cwd:sub(#home + 1)
					end
				end
				return ZoxIcon.UiSpace.RootFolderOpened .. cwd
			end

			local mini_sections = {
				lualine_a = { "filetype" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			}
			local outline = {
				sections = mini_sections,
				filetypes = { "lspsagaoutline" },
			}
			local diffview = {
				sections = mini_sections,
				filetypes = { "DiffviewFiles" },
			}

			require("lualine").setup {
				options = {
					theme = "auto",
					disabled_filetypes = {
						statusline = {
							"alpha",
							"dashboard",
							"NvimTree",
							"prompt",
							"toggleterm",
							"terminal",
							"help",
							"lspsagaoutine",
							"_sagaoutline",
							"DiffviewFiles",
							"quickfix",
							"Trouble",
							"neorepl",
						},
					},
					component_separators = "|",
					section_separators = { left = "", right = "" },
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						{ "branch", icons_enabled = true, icon = ZoxIcon.Git.Branch },
						{ "diff", source = diff_source },
					},
					lualine_c = { lspsaga_symbols },
					lualine_x = {
						{ escape_status },
						{
							"diagnostics",
							sources = { "nvim_diagnostic" },
							symbols = {
								error = ZoxIcon.Diagnostics.Error,
								warn = ZoxIcon.Diagnostics.Warning,
								info = ZoxIcon.Diagnostics.Information,
							},
						},
						{ get_cwd },
					},
					lualine_y = {},
					lualine_z = { "progress", "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				extensions = {
					"quickfix",
					"nvim-tree",
					"nvim-dap-ui",
					"toggleterm",
					"fugitive",
					outline,
					diffview,
				},
			}

			-- Properly set background color for lspsaga
			for _, hlGroup in pairs(require("lspsaga.lspkind").get_kind()) do
				require("zox.utils").extend_hl("LspSagaWinbar" .. hlGroup[1])
			end
			require("zox.utils").extend_hl "LspSagaWinbarSep"
		end,
	},
	{
		"goolord/alpha-nvim",
		lazy = true,
		event = "BufWinEnter",
		cond = function() return #vim.api.nvim_list_uis() > 0 end,
		config = function()
			local dashboard = require "alpha.themes.dashboard"
			dashboard.section.buttons.opts.hl = "String"
			dashboard.section.buttons.val = {}
			local gen_footer = function()
				local stats = require("lazy").stats()
				local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
				return ZoxIcon.MiscSpace.BentoBox
					.. "github.com/aarnphm"
					.. "   v"
					.. vim.version().major
					.. "."
					.. vim.version().minor
					.. "."
					.. vim.version().patch
					.. "   "
					.. stats.count
					.. " plugins in "
					.. ms
					.. "ms"
			end

			dashboard.section.footer.opts.hl = "Function"
			dashboard.section.footer.val = gen_footer()

			local top_button_pad = 2
			local footer_button_pad = 1
			local heights = #dashboard.section.header.val
				+ 2 * #dashboard.section.buttons.val
				+ top_button_pad

			dashboard.config.layout = {
				{
					type = "padding",
					val = math.max(0, math.ceil((vim.fn.winheight(0) - heights) * 0.12)),
				},
				dashboard.section.header,
				{ type = "padding", val = top_button_pad },
				dashboard.section.buttons,
				{ type = "padding", val = footer_button_pad },
				dashboard.section.footer,
			}

			require("alpha").setup(dashboard.config)

			vim.api.nvim_create_autocmd("User", {
				pattern = "LazyVimStarted",
				callback = function()
					dashboard.section.footer.val = gen_footer()
					pcall(vim.cmd.AlphaRedraw)
				end,
			})
		end,
	},
	{
		"nathom/filetype.nvim",
		event = "BufReadPost",
		opts = {
			overrides = {
				extension = {
					conf = "conf",
					mdx = "markdown",
					mjml = "html",
					sh = "bash",
				},
				complex = {
					[".*%.env.*"] = "sh",
					["ignore$"] = "conf",
					["yup.lock"] = "yaml",
					["WORKSPACE"] = "bzl",
				},
				shebang = {
					-- Set the filetype of files with a dash shebang to sh
					dash = "sh",
				},
			},
		},
	},
	{
		"akinsho/nvim-bufferline.lua",
		lazy = true,
		branch = "main",
		event = { "BufReadPost", "BufRead" },
		keys = function()
			return k.to_lazy_mapping {
				["n|<LocalLeader>p"] = k.cr("BufferLinePick"):with_defaults "buffer: Pick",
				["n|<LocalLeader>c"] = k.cr("BufferLinePickClose"):with_defaults "buffer: Close",
				["n|<Leader>."] = k.cr("BufferLineCycleNext")
					:with_defaults "buffer: Cycle to next buffer",
				["n|<Leader>,"] = k.cr("BufferLineCyclePrev")
					:with_defaults "buffer: Cycle to previous buffer",
				["n|<Leader>1"] = k.cr("BufferLineGoToBuffer 1")
					:with_defaults "buffer: Goto buffer 1",
				["n|<Leader>2"] = k.cr("BufferLineGoToBuffer 2")
					:with_defaults "buffer: Goto buffer 2",
				["n|<Leader>3"] = k.cr("BufferLineGoToBuffer 3")
					:with_defaults "buffer: Goto buffer 3",
				["n|<Leader>4"] = k.cr("BufferLineGoToBuffer 4")
					:with_defaults "buffer: Goto buffer 4",
				["n|<Leader>5"] = k.cr("BufferLineGoToBuffer 5")
					:with_defaults "buffer: Goto buffer 5",
				["n|<Leader>6"] = k.cr("BufferLineGoToBuffer 6")
					:with_defaults "buffer: Goto buffer 6",
				["n|<Leader>7"] = k.cr("BufferLineGoToBuffer 7")
					:with_defaults "buffer: Goto buffer 7",
				["n|<Leader>8"] = k.cr("BufferLineGoToBuffer 8")
					:with_defaults "buffer: Goto buffer 8",
				["n|<Leader>9"] = k.cr("BufferLineGoToBuffer 9")
					:with_defaults "buffer: Goto buffer 9",
			}
		end,
		opts = {
			options = {
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						text_align = "center",
						padding = 1,
					},
					{
						filetype = "undotree",
						text = "Undo Tree",
						text_align = "center",
						highlight = "Directory",
						separator = true,
					},
				},
			},
		},
	},
	{
		"zbirenbaum/neodim",
		lazy = true,
		event = "LspAttach",
		config = function()
			require("neodim").setup {
				blend_color = require("zox.utils").hl_to_rgb("Normal", true),
				update_in_insert = { delay = 100 },
				hide = {
					virtual_text = false,
					signs = false,
					underline = false,
				},
			}
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "BufRead",
		config = function()
			require("todo-comments").setup {}

			k.nvim_register_mapping {
				["n|<Leader>tqf"] = k.cr("TodoQuickFix")
					:with_defaults "todo-comments: Open quickfix",
				["n|]t"] = k.callback(function() require("todo-comments").jump_next() end)
					:with_defaults "todo-comments: Next",
				["n|[t"] = k.callback(function() require("todo-comments").jump_prev() end)
					:with_defaults "todo-comments: Previous",
				["n|<Leader>tt"] = k.cr("TodoTelescope"):with_defaults "todo-comments: Telescope",
			}
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		lazy = true,
		event = "BufRead",
		config = function()
			require("indent_blankline").setup {
				char = "│",
				show_first_indent_level = true,
				filetype_exclude = {
					"startify",
					"dashboard",
					"alpha",
					"log",
					"fugitive",
					"gitcommit",
					"vimwiki",
					"markdown",
					"json",
					"txt",
					"vista",
					"help",
					"todoist",
					"peekaboo",
					"git",
					"TelescopePrompt",
					"undotree",
					"flutterToolsOutline",
					"", -- for all buffers without a file type
				},
				buftype_exclude = { "terminal", "nofile" },
				show_trailing_blankline_indent = false,
				show_current_context = true,
				context_patterns = {
					"class",
					"function",
					"method",
					"block",
					"list_literal",
					"selector",
					"^if",
					"^table",
					"if_statement",
					"while",
					"for",
					"type",
					"var",
					"import",
				},
				space_char_blankline = " ",
			}
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		lazy = true,
		event = "BufReadPost",
		config = function()
			require("gitsigns").setup {
				numhl = true,
				---@diagnostic disable-next-line: undefined-global
				word_diff = false,
				current_line_blame = false,
				current_line_blame_opts = { virtual_text_pos = "eol" },
				diff_opts = { internal = true },
				on_attach = function(bufnr)
					k.nvim_register_mapping {
						["n|]g"] = k.callback(function()
							if vim.wo.diff then return "]g" end
							vim.schedule(function() require("gitsigns.actions").next_hunk() end)
							return "<Ignore>"
						end)
							:with_buffer(bufnr)
							:with_expr()
							:with_desc "git: Goto next hunk",
						["n|[g"] = k.callback(function()
							if vim.wo.diff then return "[g" end
							vim.schedule(function() require("gitsigns.actions").prev_hunk() end)
							return "<Ignore>"
						end)
							:with_buffer(bufnr)
							:with_expr()
							:with_desc "git: Goto prev hunk",
						["n|<Leader>hs"] = k.callback(
							function() require("gitsigns.actions").stage_hunk() end
						)
							:with_buffer(bufnr)
							:with_desc "git: Stage hunk",
						["v|<Leader>hs"] = k.callback(
							function()
								require("gitsigns.actions").stage_hunk {
									vim.fn.line ".",
									vim.fn.line "v",
								}
							end
						)
							:with_buffer(bufnr)
							:with_desc "git: Stage hunk",
						["n|<Leader>hu"] = k.callback(
							function() require("gitsigns.actions").undo_stage_hunk() end
						)
							:with_buffer(bufnr)
							:with_desc "git: Undo stage hunk",
						["n|<Leader>hr"] = k.callback(
							function() require("gitsigns.actions").reset_hunk() end
						)
							:with_buffer(bufnr)
							:with_desc "git: Reset hunk",
						["v|<Leader>hr"] = k.callback(
							function()
								require("gitsigns.actions").reset_hunk {
									vim.fn.line ".",
									vim.fn.line "v",
								}
							end
						)
							:with_buffer(bufnr)
							:with_desc "git: Reset hunk",
						["n|<Leader>hR"] = k.callback(
							function() require("gitsigns.actions").reset_buffer() end
						)
							:with_buffer(bufnr)
							:with_desc "git: Reset buffer",
						["n|<Leader>hp"] = k.callback(
							function() require("gitsigns.actions").preview_hunk() end
						)
							:with_buffer(bufnr)
							:with_desc "git: Preview hunk",
						["n|<Leader>hb"] = k.callback(
							function() require("gitsigns.actions").blame_line { full = true } end
						)
							:with_buffer(bufnr)
							:with_desc "git: Blame line",
						["n|<Leader>hbl"] = k.callback(
							function() require("gitsigns.actions").toggle_current_line_blame() end
						)
							:with_buffer(bufnr)
							:with_desc "git: Toggle current line blame",
						["n|<Leader>hwd"] = k.callback(
							function() require("gitsigns.actions").toggle_word_diff() end
						)
							:with_buffer(bufnr)
							:with_desc "git: Toogle word diff",
						["n|<Leader>hd"] = k.callback(
							function() require("gitsigns.actions").toggle_deleted() end
						)
							:with_buffer(bufnr)
							:with_desc "git: Toggle deleted diff",
						-- Text objects
						["o|ih"] = k.callback(
							function() require("gitsigns.actions").text_object() end
						)
							:with_buffer(bufnr),
						["x|ih"] = k.callback(
							function() require("gitsigns.actions").text_object() end
						)
							:with_buffer(bufnr),
					}
				end,
			}
		end,
	},
	{
		"folke/trouble.nvim",
		lazy = true,
		cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
		config = function()
			require("trouble").setup {
				position = "left",
				mode = "document_diagnostics",
				auto_close = true,
			}

			k.nvim_register_mapping {
				["n|gt"] = k.cr("TroubleToggle"):with_defaults "lsp: Toggle trouble list",
				["n|gR"] = k.cr("TroubleToggle lsp_references")
					:with_defaults "lsp: Show lsp references",
				["n|<LocalLeader>td"] = k.cr("TroubleToggle document_diagnostics")
					:with_defaults "lsp: Show document diagnostics",
				["n|<LocalLeader>tw"] = k.cr("TroubleToggle workspace_diagnostics")
					:with_defaults "lsp: Show workspace diagnostics",
				["n|<LocalLeader>tq"] = k.cr("TroubleToggle quickfix")
					:with_defaults "lsp: Show quickfix list",
				["n|<LocalLeader>tl"] = k.cr("TroubleToggle loclist")
					:with_defaults "lsp: Show loclist",
			}
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		branch = "canary",
		lazy = false,
		priority = 1000,
		opts = {
			disable_italics = true,
			disable_float_background = true,
			highlight_groups = {
				Comment = { fg = "muted", italic = true },
				StatusLine = { fg = "iris", bg = "iris", blend = 10 },
				StatusLineNC = { fg = "subtle", bg = "surface" },
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = "BufReadPost",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects" },
			{ "romgrk/nvim-treesitter-context" },
			{ "JoosepAlviste/nvim-ts-context-commentstring" },
			{
				"andymass/vim-matchup",
				event = "BufReadPost",
				config = function()
					vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
				end,
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
				ignore_install = { "phpdoc", "gitcommit" },
				indent = { enable = false },
				highlight = { enable = true },
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
		end,
	},
	{
		"phaazon/hop.nvim",
		lazy = true,
		branch = "v2",
		event = { "CursorHold", "CursorHoldI" },
		cond = function()
			return not vim.tbl_contains(
				{ "nofile", "alpha", "gitcommit", "gitrebase" },
				vim.bo.filetype
			)
		end,
		config = function()
			local hop = require "hop"

			hop.setup()
			-- set f/F to use hop
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
				["n|<LocalLeader>c"] = k.cu("HopChar1")
					:with_noremap()
					:with_desc "jump: Goto one char",
				["n|<LocalLeader>cc"] = k.cu("HopChar2")
					:with_noremap()
					:with_desc "jump: Goto two chars",
			}
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		event = "BufRead",
		dependencies = {
			{
				"nvim-tree/nvim-web-devicons",
				opts = {
					override = {
						zsh = {
							icon = "",
							color = "#428850",
							cterm_color = "65",
							name = "Zsh",
						},
					},
				},
			},
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-lua/popup.nvim" },
			{ "jvgrootveld/telescope-zoxide" },
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
			{
				"nvim-telescope/telescope-dap.nvim",
				dependencies = { "mfussenegger/nvim-dap", "nvim-treesitter/nvim-treesitter" },
			},
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
		cmd = "Telescope",
		keys = {
			{
				"<leader>f",
				"<cmd>Telescope find_files find_command=fd,-t,f,-H,-E,.git,--strip-cwd-prefix theme=dropdown previewer=false<cr>",
				desc = "find: file in project",
			},
			{
				"<leader>r",
				"",
				desc = "find: recent files",
				callback = function()
					require("telescope").extensions.frecency.frecency { previewer = false }
				end,
			},
			{
				"<leader>w",
				"",
				desc = "find: text",
				callback = function()
					require("telescope").extensions.live_grep_args.live_grep_args()
				end,
			},
			{
				"<leader>/",
				"<cmd>Telescope grep_string<cr>",
				desc = "find: Current word",
			},
			{
				"<leader>b",
				"<cmd>Telescope buffers<cr>",
				desc = "find: Buffer opened",
			},
			{
				"<leader>n",
				"<C-u>enew<CR>",
				desc = "buffer: New",
			},
			{
				"<leader>\\",
				function()
					require("telescope").extensions.projects.projects { promp_title = "Projects" }
				end,
				desc = "find: Projects",
			},
			{
				"<C-p>",
				"",
				desc = "tools: Show keymap legends",
				callback = function()
					require("telescope.builtin").keymaps {
						lhs_filter = function(lhs) return not string.find(lhs, "Þ") end,
						layout_config = {
							width = 0.6,
							height = 0.6,
							prompt_position = "top",
						},
					}
				end,
			},
		},
		config = function()
			require("telescope").setup {
				defaults = {
					borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
					path_display = { "absolute" },
					mappings = {
						i = {
							["<C-a>"] = { "<esc>0i", type = "command" },
							["<Esc>"] = require("telescope.actions").close,
						},
						n = { ["q"] = require("telescope.actions").close },
					},
					file_ignore_patterns = {
						"static_content",
						"node_modules",
						".git/",
						".cache",
						"%.class",
						"%.pdf",
						"%.mkv",
						"%.mp4",
						"%.zip",
						"lazy-lock.json",
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
				},
				extensions = {
					frecency = {
						show_scores = true,
						show_unindexed = true,
						ignore_patterns = { "*.git/*", "*/tmp/*", "*/lazy-lock.json" },
					},
					fzf = {
						fuzzy = false,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
					live_grep_args = {
						auto_quoting = false,
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
			}
			for _, v in ipairs {
				"fzf",
				"frecency",
				"live_grep_args",
				"zoxide",
				"notify",
				"projects",
				"dap",
			} do
				require("telescope").load_extension(v)
			end
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		cmd = {
			"NvimTreeToggle",
			"NvimTreeOpen",
			"NvimTreeFindFile",
			"NvimTreeFindFileToggle",
			"NvimTreeRefresh",
		},
		keys = {
			{
				"<C-n>",
				"<cmd>NvimTreeFindFileToggle<cr>",
				desc = "Toggle file tree",
			},
		},
		opts = {
			actions = {
				open_file = {
					quit_on_open = true,
				},
			},
			hijack_cursor = true,
			hijack_unnamed_buffer_when_opening = true,
			reload_on_bufenter = true,
			sync_root_with_cwd = true,
			update_focused_file = { enable = true, update_root = true },
			git = { ignore = false },
			filters = { custom = { "^.git$", ".DS_Store", "__pycache__", "lazy-lock.json" } },
			renderer = {
				special_files = {
					"Cargo.toml",
					"Makefile",
					"README.md",
					"readme.md",
					"CMakeLists.txt",
				},
				root_folder_label = ":.:s?.*?/..?",
				root_folder_modifier = ":e",
				icons = { symlink_arrow = "  " },
			},
			trash = {
				cmd = require("zox.utils").get_binary_path "rip",
				require_confirm = true,
			},
			view = {
				adaptive_size = false,
				side = "right",
				mappings = {
					list = {
						{ key = "d", action = "trash" },
						{ key = "D", action = "remove" },
					},
				},
			},
		},
	},
	{
		"nvim-pack/nvim-spectre",
		lazy = true,
		build = "./build.sh",
		event = { "CursorHold", "CursorHoldI" },
		config = function()
			require("spectre").setup {
				live_update = true,
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

			k.nvim_register_mapping {
				["n|<Leader>sv"] = k.callback(function() require("spectre").open_visual() end)
					:with_defaults "replace: Open visual replace",
				["n|<Leader>so"] = k.callback(function() require("spectre").open() end)
					:with_defaults "replace: Open panel",
				["n|<Leader>sw"] = k.callback(
					function() require("spectre").open_visual { select_word = true } end
				):with_defaults "replace: Replace word under cursor",
				["n|<Leader>sp"] = k.callback(function() require("spectre").open_file_search() end)
					:with_defaults "replace: Replace word under file search",
			}
		end,
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
		event = { "CursorHold", "CursorHoldI" },
		keys = {
			{
				"<C-\\>",
				"<cmd>execute v:count . \"ToggleTerm direction=horizontal\"<CR>",
				mode = "n",
				desc = "terminal: toggle horizontal",
			},
			{
				"<C-\\>",
				"<Esc><Cmd>ToggleTerm direction=horizontal<CR>",
				mode = "i",
				desc = "terminal: toggle horizontal",
			},
			{
				"<C-\\>",
				"<Esc><Cmd>ToggleTerm direction=horizontal<CR>",
				mode = "t",
				desc = "terminal: toggle horizontal",
			},
			{
				"<C-t>",
				mode = "n",
				"<cmd>execute v:count . \"ToggleTerm direction=vertical\"<CR>",
				desc = "terminal: toggle vertical",
			},
			{
				"<C-t>",
				"<Esc><Cmd>ToggleTerm direction=vertical<CR>",
				mode = "i",
				desc = "terminal: toggle vertical",
			},
			{
				"<C-t>",
				"<Esc><Cmd>ToggleTerm direction=vertical<CR>",
				mode = "t",
				desc = "terminal: toggle vertical",
			},
		},
		opts = {
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
			open_mapping = false, -- default mapping
			shade_terminals = false,
			direction = "vertical",
		},
	},

	--- NOTE: Dap setup
	{
		"rcarriga/nvim-dap-ui",
		as = "dapui",
		lazy = true,
		events = "BufRead",
		opts = {
			icons = {
				expanded = ZoxIcon.UiSpace.ArrowOpen,
				collapsed = ZoxIcon.UiSpace.ArrowClosed,
				current_frame = ZoxIcon.UiSpace.Indicator,
			},
			layouts = {
				{
					elements = {
						-- Provide as ID strings or tables with "id" and "size" keys
						{
							id = "scopes",
							size = 0.25, -- Can be float or integer > 1
						},
						{ id = "breakpoints", size = 0.25 },
						{ id = "stacks", size = 0.25 },
						{ id = "watches", size = 0.25 },
					},
					size = 40,
					position = "left",
				},
				{ elements = { "repl" }, size = 10, position = "bottom" },
			},
			controls = {
				icons = {
					pause = ZoxIcon.DapSpace.Pause,
					play = ZoxIcon.DapSpace.Play,
					step_into = ZoxIcon.DapSpace.StepInto,
					step_over = ZoxIcon.DapSpace.StepOver,
					step_out = ZoxIcon.DapSpace.StepOut,
					step_back = ZoxIcon.DapSpace.StepBack,
					run_last = ZoxIcon.DapSpace.RunLast,
					terminate = ZoxIcon.DapSpace.Terminate,
				},
			},
			windows = { indent = 1 },
		},
	},
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		cmd = {
			"DapSetLogLevel",
			"DapShowLog",
			"DapContinue",
			"DapToggleBreakpoint",
			"DapToggleRepl",
			"DapStepOver",
			"DapStepInto",
			"DapStepOut",
			"DapTerminate",
		},
		events = "BufRead",
		dependencies = { "rcarriga/nvim-dap-ui" },
		config = function()
			local ok
			ok, _ = pcall(require, "dap")
			if not ok then return end
			ok, _ = pcall(require, "dapui")
			if not ok then return end
			for _, v in ipairs {
				"Breakpoint",
				"BreakpointRejected",
				"BreakpointCondition",
				"LogPoint",
				"Stopped",
			} do
				vim.fn.sign_define("Dap" .. v, {
					text = ZoxIcon.DapSpace[v],
					texthl = "Dap" .. v,
					line = "",
					numhl = "",
				})
			end
			-- Config lang adapters
			for _, value in ipairs { "dlv", "lldb" } do
				ok, _ = pcall(require, "zox.adapters." .. value)
				if not ok then
					vim.notify_once(
						"Failed to setup dap for " .. value,
						vim.log.levels.ERROR,
						{ title = "dap" }
					)
				end
			end

			local run_dap = function()
				require("dap.ext.vscode").load_launchjs()
				require("dap").continue()
				require("dapui").open()
			end

			local stop_dap = function()
				local has_dap, dap = pcall(require, "dap")
				if has_dap then
					dap.disconnect()
					dap.close()
					dap.repl.close()
				end
				local has_dapui, dapui = pcall(require, "dapui")
				if has_dapui then dapui.close() end
			end

			k.nvim_register_mapping {
				["n|<Leader>dr"] = k.callback(run_dap):with_defaults "dap: Run/Continue",
				["n|<Leader>ds"] = k.callback(stop_dap):with_defaults "dap: Stop",
				["n|<Leader>db"] = k.callback(function() require("dap").toggle_breakpoint() end)
					:with_defaults "dap: Toggle breakpoint",
				["n|<Leader>dbs"] = k.callback(
					function() require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ") end
				):with_defaults "dap: Set breakpoint with condition",
				["n|<Leader>di"] = k.callback(function() require("dap").step_into() end)
					:with_defaults "dap: Step into",
				["n|<Leader>do"] = k.callback(function() require("dap").step_out() end)
					:with_defaults "dap: Step out",
				["n|<Leader>dn"] = k.callback(function() require("dap").step_over() end)
					:with_defaults "dap: Step over",
				["n|<Leader>dc"] = k.callback(function() require("dap").continue {} end)
					:with_defaults "dap: Continue",
				["n|<Leader>dl"] = k.callback(function() require("dap").run_last() end)
					:with_defaults "dap: Run last",
				["n|<Leader>dR"] = k.callback(function() require("dap").repl.open() end)
					:with_defaults "dap: Open REPL",
				["n|<Leader>dt"] = k.callback(function() require("dapui").toggle() end)
					:with_defaults "dap: toggle UI",
				["n|<Leader>dC"] = k.callback(function() require("dapui").close() end)
					:with_defaults "dap: close UI",
			}
		end,
	},
	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("dap-python").setup()
			require("dap-python").test_runner = "pytest"
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		lazy = true,
		ft = "python",
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("nvim-dap-virtual-text").setup {
				enabled = true,
				enabled_commands = true,
				all_frames = true,
			}
		end,
	},
}
