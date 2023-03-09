return {
	{
		"folke/which-key.nvim",
		lazy = true,
		event = "BufReadPost",
		opts = {
			window = { border = "single" },
			plugins = { spelling = { enabled = true } },
		},
	},
	{
		"folke/noice.nvim",
		lazy = true,
		event = "BufReadPost",
		dependencies = { { "MunifTanjim/nui.nvim", lazy = true } },
		opts = {
			cmdline = { view = "cmdline" },
			lsp = { progress = { enabled = false } },
			popupmenu = { enabled = true, backend = "cmp" },
			presets = { command_palette = true, lsp_doc_border = true, bottom_search = true },
			routes = {
				{
					-- hide search virtual text
					filter = { event = "msg_show", kind = "search_count" },
					opts = { skip = true },
				},
			},
		},
	},
	{
		"nathom/filetype.nvim",
		event = { "CursorHoldI", "CursorHold" },
		opts = {
			overrides = {
				extension = {
					conf = "conf",
					mdx = "markdown",
					mjml = "html",
					sh = "bash",
					m = "objc",
					BUILD = "bzl",
				},
				complex = {
					[".*%.env.*"] = "sh",
					["ignore$"] = "conf",
					["*.rc"] = "conf",
					["yup.lock"] = "yaml",
					["WORKSPACE"] = "bzl",
					["BUILD"] = "bzl",
				},
				shebang = { dash = "sh" },
			},
		},
	},
	{
		"NvChad/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup {
				filetypes = { "*" },
				user_default_options = {
					names = false, -- "Name" codes like Blue
					RRGGBBAA = true, -- #RRGGBBAA hex codes
					rgb_fn = true, -- CSS rgb() and rgba() functions
					hsl_fn = true, -- CSS hsl() and hsla() functions
					css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
					css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
					sass = { enable = true, parsers = { "css" } },
					mode = "background",
				},
			}
		end,
	},
	{ "romainl/vim-cool", lazy = true, event = { "CursorHoldI", "CursorHold" } },
	{ "stevearc/dressing.nvim", event = "VeryLazy", opts = { input = { insert_only = false } } },
	{
		dir = vim.fn.stdpath "config" .. "/rose-pine",
		as = "rose-pine",
		branch = "canary",
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
	},
	{
		"j-hui/fidget.nvim",
		lazy = true,
		event = "BufReadPost",
		opts = {
			window = { blend = 0 },
			text = { spinner = "dots_snake" },
		},
	},
	{
		"folke/todo-comments.nvim",
		lazy = true,
		cmd = { "TodoTrouble", "TodoTelescope" },
		event = "LspAttach",
		config = true,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		lazy = true,
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			show_first_indent_level = true,
			buftype_exclude = { "terminal", "nofile" },
			filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
			show_trailing_blankline_indent = false,
			show_current_context = false,
		},
	},
	-- active indent guide and indent text objects
	{
		"echasnovski/mini.indentscope",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			symbol = "│",
			options = { try_as_border = true },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"lazy",
					"mason",
					"TelescopePrompt",
					"NvimTree",
				},
				callback = function() vim.b.miniindentscope_disable = true end,
			})
		end,
		config = function(_, opts) require("mini.indentscope").setup(opts) end,
	},
	{
		"lewis6991/gitsigns.nvim",
		lazy = true,
		event = "VeryLazy",
		config = function()
			require("gitsigns").setup {
				numhl = true,
				word_diff = false,
				current_line_blame = false,
				diff_opts = { internal = true },
				on_attach = function(bufnr)
					local k = require "zox.keybind"

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
							:with_desc "git: undo stage hunk",
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
		event = "BufReadPost",
		config = true,
	},
	{ "dnlhc/glance.nvim", cmd = "Glance", lazy = true, config = true },
	{
		"zbirenbaum/neodim",
		event = "BufReadPost",
		opts = { blend_color = require("zox.utils").hl_to_rgb("Normal", true) },
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{ "romgrk/nvim-treesitter-context" },
			{ "nvim-treesitter/nvim-treesitter-textobjects" },
		},
		config = function()
			require("nvim-treesitter.configs").setup {
				ensure_installed = {
					"python",
					"rust",
					"lua",
					"c",
					"go",
					"cpp",
					"yaml",
					"json",
					"toml",
					"bash",
					"css",
					"vim",
					"regex",
				},
				ignore_install = { "phpdoc", "gitcommit" },
				indent = { enable = true, disable = { "python" } },
				highlight = { enable = true },
				context_commentstring = { enable = true, enable_autocmd = false },
				matchup = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = "<nop>",
						node_decremental = "<bs>",
					},
				},
			}
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		lazy = true,
		event = "BufReadPost",
		dependencies = {
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
			{
				"ahmedkhalf/project.nvim",
				as = "project_nvim",
				event = "BufReadPost",
				config = function()
					require("project_nvim").setup {
						manual_mode = false,
						detection_methods = { "lsp", "pattern" },
						patterns = {
							".git",
							"_darcs",
							".hg",
							".bzr",
							".svn",
							"Makefile",
							"package.json",
						},
						ignore_lsp = { "null-ls", "copilot", "pyright" },
						exclude_dirs = {},
						show_hidden = true,
						silent_chdir = true,
						scope_chdir = "wins",
					}
				end,
			},
		},
		config = function()
			require("telescope").setup {
				defaults = {
					prompt_prefix = " " .. require("zox").ui_space.Telescope .. " ",
					selection_caret = require("zox").ui_space.DoubleSeparator,
					file_ignore_patterns = { ".git/" },
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
								["<C-j>"] = require("telescope-live-grep-args.actions").quote_prompt {
									postfix = " -t ",
								},
							},
						},
					},
				},
				pickers = {
					find_files = { hidden = true },
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
			require("telescope").load_extension "live_grep_args"
			require("telescope").load_extension "projects"
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
		event = "BufReadPost",
		config = function()
			require("nvim-tree").setup {
				hijack_cursor = true,
				sort_by = "extensions",
				prefer_startup_root = true,
				respect_buf_cwd = true,
				reload_on_bufenter = true,
				sync_root_with_cwd = true,
				actions = { open_file = { quit_on_open = false } },
				update_focused_file = { enable = true, update_root = true },
				git = { ignore = false },
				filters = { custom = { "^.git$", ".DS_Store", "__pycache__", "lazy-lock.json" } },
				renderer = {
					group_empty = true,
					indent_markers = { enable = true },
					root_folder_label = ":.:s?.*?/..?",
					root_folder_modifier = ":e",
					icons = {
						padding = " ",
						symlink_arrow = "  ",
					},
				},
				trash = {
					cmd = require("zox.utils").get_binary_path "rip",
					require_confirm = true,
				},
				view = { width = "12%", side = "right" },
			}
		end,
	},
	{
		"nvim-pack/nvim-spectre",
		lazy = true,
		event = "BufReadPost",
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

			local k = require "zox.keybind"

			k.nvim_register_mapping {
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
	},
	{
		"akinsho/toggleterm.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = function()
			require("toggleterm").setup {
				-- size can be a number or function which is passed the current terminal
				size = function(term)
					local factor = 0.3
					if term.direction == "horizontal" then
						return vim.o.lines * factor
					elseif term.direction == "vertical" then
						return vim.o.columns * factor
					end
				end,
				open_mapping = false, -- default mapping
				shade_terminals = false,
				direction = "vertical",
				shell = vim.o.shell,
				highlight = require "rose-pine.plugins.toggleterm",
			}

			local k = require "zox.keybind"
			k.nvim_register_mapping {
				["n|<C-\\>"] = k.cr([[execute v:count . "ToggleTerm direction=horizontal"]])
					:with_defaults "terminal: Toggle horizontal",
				["i|<C-\\>"] = k.cmd("<Esc><Cmd>ToggleTerm direction=horizontal<CR>")
					:with_defaults "terminal: Toggle horizontal",
				["t|<C-\\>"] = k.cmd("<Esc><Cmd>ToggleTerm<CR>")
					:with_defaults "terminal: Toggle horizontal",
				["n|<C-t>"] = k.cr([[execute v:count . "ToggleTerm direction=vertical"]])
					:with_defaults "terminal: Toggle vertical",
				["i|<C-t>"] = k.cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>")
					:with_defaults "terminal: Toggle vertical",
				["t|<C-t>"] = k.cmd("<Esc><Cmd>ToggleTerm<CR>")
					:with_defaults "terminal: Toggle vertical",
			}
		end,
	},
}
