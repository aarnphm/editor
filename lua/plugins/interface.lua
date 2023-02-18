return {
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
				StatusLine = { fg = "rose", bg = "iris", blend = 10 },
				StatusLineNC = { fg = "subtle", bg = "surface" },
			},
		},
		config = function(_, opts)
			require("rose-pine").setup(opts)
			vim.cmd.colorscheme "rose-pine"
		end,
	},
	-- Better quickfix list
	{ "kevinhwang91/nvim-bqf", ft = "qf", opts = {} },
	{ url = "https://git.sr.ht/~whynothugo/lsp_lines.nvim", config = true },
	{
		"stevearc/dressing.nvim",
		lazy = true,
		event = "BufReadPost",
		enabled = true,
		opts = {
			input = { enabled = true, insert_only = false },
			select = { enabled = true, backend = "nui", trim_prompt = true },
		},
	},
	{
		"folke/noice.nvim",
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				command_palette = true,
				lsp_doc_border = true,
			},
			routes = {
				{
					view = "notify",
					filter = { event = "msg_showmode" },
				},
			},
		},
	},
	{ "MunifTanjim/nui.nvim", lazy = true },
	{
		"j-hui/fidget.nvim",
		lazy = true,
		event = "BufReadPost",
		opts = { text = { spinner = "dots" }, window = { blend = 0 } },
	},
	{
		"rcarriga/nvim-notify",
		lazy = true,
		opts = {
			stages = "static",
			---@usage User render fps value
			fps = 60,
			max_height = function() return math.floor(vim.o.lines * 0.55) end,
			max_width = function() return math.floor(vim.o.columns * 0.55) end,
			render = "minimal",
			background_colour = "Normal",
			level = "INFO",
		},
	},
	{
		"nathom/filetype.nvim",
		lazy = true,
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
		"zbirenbaum/neodim",
		lazy = true,
		event = "BufReadPost",
		opts = {
			blend_color = require("zox.utils").hl_to_rgb("Normal", true),
			update_in_insert = { delay = 100 },
		},
	},
	{
		"folke/todo-comments.nvim",
		cmd = { "TodoTrouble", "TodoTelescope" },
		event = "BufReadPost",
		opts = {},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		lazy = true,
		event = "BufReadPost",
		opts = {
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
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		lazy = true,
		event = { "CursorHoldI", "CursorHold" },
		opts = {
			numhl = true,
			---@diagnostic disable-next-line: undefined-global
			word_diff = false,
			current_line_blame = false,
			current_line_blame_opts = { virtual_text_pos = "eol" },
			diff_opts = { internal = true },
			on_attach = function(bufnr)
				local k = require "zox.keybind"

				local ok, _ = require "gitsigns"
				if not ok then return end

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
					["n|<Leader>tbl"] = k.callback(
						function() require("gitsigns.actions").toggle_current_line_blame() end
					)
						:with_buffer(bufnr)
						:with_desc "git: Toggle current line blame",
					["n|<Leader>twd"] = k.callback(
						function() require("gitsigns.actions").toggle_word_diff() end
					)
						:with_buffer(bufnr)
						:with_desc "git: Toogle word diff",
					["n|<Leader>thd"] = k.callback(
						function() require("gitsigns.actions").toggle_deleted() end
					)
						:with_buffer(bufnr)
						:with_desc "git: Toggle deleted diff",
					-- Text objects
					["o|ih"] = k.callback(function() require("gitsigns.actions").text_object() end)
						:with_buffer(bufnr),
					["x|ih"] = k.callback(function() require("gitsigns.actions").text_object() end)
						:with_buffer(bufnr),
				}
			end,
		},
	},
	{
		"folke/trouble.nvim",
		lazy = true,
		cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
		event = "BufReadPost",
		keys = function()
			local k = require "zox.keybind"
			return k.to_lazy_mapping {
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
		opts = { position = "left", mode = "document_diagnostics", auto_close = true },
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = "BufReadPost",
		lazy = true,
		dependencies = {
			{ "romgrk/nvim-treesitter-context" },
			{ "nvim-treesitter/nvim-treesitter-textobjects" },
			{
				"andymass/vim-matchup",
				event = "BufReadPost",
				config = function()
					vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
				end,
			},
			{
				"NvChad/nvim-colorizer.lua",
				opts = {
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
					},
				},
			},
		},
		opts = {
			ensure_installed = "all",
			ignore_install = { "phpdoc", "gitcommit" },
			indent = { enable = false },
			highlight = { enable = true },
			context_commentstring = { enable = true, enable_autocmd = false },
			matchup = { enable = true },
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@conditional.outer",
						["ic"] = "@conditional.inner",
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",
						["aS"] = "@statement.outer",
						["aC"] = "@class.outer",
						["iC"] = "@class.inner",
						["al"] = "@loop.outer",
						["il"] = "@loop.inner",
					},
				},
				swap = {
					enable = true,
					swap_next = {
						["<leader>Pa"] = "@parameter.inner",
					},
					swap_previous = {
						["<leader>PA"] = "@parameter.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]]"] = "@function.outer",
						["]c"] = "@class.outer",
					},
					goto_next_end = {
						["]["] = "@function.outer",
						["]C"] = "@class.outer",
					},
					goto_previous_start = {
						["[["] = "@function.outer",
						["[c"] = "@class.outer",
					},
					goto_previous_end = {
						["[]"] = "@function.outer",
						["[C"] = "@class.outer",
					},
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
			-- Use treesitter markdown parser for Octo buffer
			local ok, _ = pcall(require, "octo")
			if ok then
				require("nvim-treesitter.parsers").filetype_to_parsername.octo = "markdown"
			end
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
		keys = {
			{
				"<LocalLeader>w",
				"<cmd><C-u>HopWord<CR>",
				"jump: Goto word",
				noremap = true,
			},
			{
				"<LocalLeader>j",
				"<cmd><C-u>HopLine<CR>",
				"jump: Goto line",
				noremap = true,
			},
			{
				"<LocalLeader>k",
				"<cmd><C-u>HopLine<CR>",
				"jump: Goto line",
				noremap = true,
			},
			{
				"<LocalLeader>c",
				"<cmd><C-u>HopChar1<CR>",
				"jump: one char",
				noremap = true,
			},
			{
				"<LocalLeader>cc",
				"<cmd><C-u>HopChar2<CR>",
				"jump: one char",
				noremap = true,
			},
		},
		config = function()
			local hop = require "hop"
			hop.setup()

			-- set f/F to use hop
			local d = require("hop.hint").HintDirection
			vim.api.nvim_set_keymap("", "f", "", {
				noremap = false,
				callback = function()
					hop.hint_char1 { direction = d.AFTER_CURSOR, current_line_only = true }
				end,
				desc = "motion: f 1 char",
			})
			vim.api.nvim_set_keymap("", "F", "", {
				noremap = false,
				callback = function()
					hop.hint_char1 { direction = d.BEFORE_CURSOR, current_line_only = true }
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
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		lazy = true,
		event = "BufRead",
		cmd = "Telescope",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-lua/popup.nvim" },
			{
				"nvim-tree/nvim-web-devicons",
				lazy = true,
				event = "BufReadPost",
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
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
			{ "nvim-telescope/telescope-frecency.nvim", dependencies = { "kkharji/sqlite.lua" } },
			{
				"ahmedkhalf/project.nvim",
				name = "project_nvim",
				lazy = true,
				event = "BufReadPost",
				opts = {
					ignore_lsp = { "null-ls", "copilot" },
					show_hidden = true,
					silent_chdir = true,
					scope_chdir = "win",
				},
			},
		},
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
				"<cmd>Telescope buffers previewer=false<cr>",
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
					prompt_prefix = " " .. require("zox").ui_space.Telescope .. " ",
					selection_caret = require("zox").ui_space.DoubleSeparator,
					mappings = {
						i = {
							["<C-a>"] = { "<esc>0i", type = "command" },
							["<Esc>"] = require("telescope.actions").close,
						},
						n = { ["q"] = require("telescope.actions").close },
					},
					layout_config = { width = 0.6, height = 0.6, prompt_position = "top" },
				},
				extensions = {
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
					keymaps = { theme = "dropdown" },
					git_files = { theme = "dropdown" },
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
				},
			}
			for _, v in ipairs { "frecency", "live_grep_args", "notify", "projects" } do
				require("telescope").load_extension(v)
			end
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		lazy = true,
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
			actions = { open_file = { quit_on_open = true } },
			reload_on_bufenter = true,
			sync_root_with_cwd = true,
			update_focused_file = { enable = true, update_root = true },
			git = { ignore = false },
			filters = { custom = { "^.git$", ".DS_Store", "__pycache__", "lazy-lock.json" } },
			renderer = {
				group_empty = true,
				highlight_opened_files = "none",
				indent_markers = { enable = true },
				root_folder_label = ":.:s?.*?/..?",
				root_folder_modifier = ":e",
				icons = { symlink_arrow = "  " },
			},
			trash = {
				cmd = require("zox.utils").get_binary_path "rip",
				require_confirm = true,
			},
			view = { adaptive_size = false, side = "right" },
		},
	},
	{
		"nvim-pack/nvim-spectre",
		lazy = true,
		build = "./build.sh nvim_oxi",
		module = "spectre",
		event = { "CursorHold", "CursorHoldI" },
		keys = function()
			local k = require "zox.keybind"

			return k.to_lazy_mapping {
				["v|<Leader>sv"] = k.callback(function() require("spectre").open_visual() end)
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
		opts = {
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
		},
	},
	{
		"akinsho/toggleterm.nvim",
		event = { "CursorHold", "CursorHoldI" },
		opts = {
			-- size can be a number or function which is passed the current terminal
			size = function(term)
				local factor = 0.3
				if term.direction == "horizontal" then
					return vim.o.lines * factor
				elseif term.direction == "vertical" then
					return vim.o.columns * factor
				end
			end,
			open_mapping = "<C-t>", -- default mapping
			shade_terminals = false,
			direction = "vertical",
		},
	},
}
