local k = require "keybind"
local icons = {
	ui = require("icons").get "ui",
	diagnostics = require("icons").get "diagnostics",
	dap = require("icons").get("dap", true),
	documents = require("icons").get "documents",
	git = require("icons").get "git",
	misc_space = require("icons").get("misc", true),
	ui_space = require("icons").get("ui", true),
	diagnostic_space = require("icons").get("diagnostics", true),
}

return {
	{ "nathom/filetype.nvim", lazy = false },
	{
		"j-hui/fidget.nvim",
		lazy = true,
		event = "BufRead",
		config = function()
			require("fidget").setup {
				text = { spinner = "dots" },
				window = { blend = 0 },
			}
		end,
	},
	{
		"rcarriga/nvim-notify",
		lazy = true,
		event = "VeryLazy",
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
				level = require("editor").config.debug and "DEBUG" or "INFO",
				---@usage Icons for the different levels
				icons = {
					ERROR = icons.diagnostics.Error,
					WARN = icons.diagnostics.Warning,
					INFO = icons.diagnostics.Information,
					DEBUG = icons.ui.Bug,
					TRACE = icons.ui.Pencil,
				},
			}

			vim.notify = notify
		end,
	},
	{
		"zbirenbaum/neodim",
		lazy = true,
		event = "LspAttach",
		config = function()
			require("neodim").setup {
				blend_color = require("utils").hl_to_rgb("Normal", true),
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
		config = function() require("todo-comments").setup {} end,
		init = function()
			k.nvim_register_mapping {
				["n|<Leader>tqf"] = k.cr("TodoQuickFix"):with_defaults "todo-comments: Open quickfix",
				["n|]t"] = k.callback(function() require("todo-comments").jump_next() end)
					:with_defaults "todo-comments: Next",
				["n|[t"] = k.callback(function() require("todo-comments").jump_prev() end)
					:with_defaults "todo-comments: Previous",
				["n|<Leader>tt"] = k.cr("TodoTelescope"):with_defaults "todo-comments: Telescope",
			}
		end,
	},

	-- NOTE: Colorscheme
	{
		"rose-pine/neovim",
		as = "rose-pine",
		lazy = false,
		priority = 1000,
		branch = "canary",
		name = "rose-pine",
		config = function()
			require("rose-pine").setup {
				--- @usage 'main' | 'moon'
				dark_variant = require("editor").config.plugins["rose-pine"].dark_variant,
				disable_background = true,
				disable_float_background = true,
				highlight_groups = {
					Comment = { fg = "muted", italic = true },
					StatusLine = { fg = "iris", bg = "iris", blend = 10 },
					StatusLineNC = { fg = "subtle", bg = "surface" },
				},
			}
		end,
	},
	{
		"catppuccin/nvim",
		as = "catppuccin",
		lazy = false,
		name = "catppuccin",
		config = function()
			require("catppuccin").setup {
				-- Can be one of: latte, frappe, macchiato, mocha
				flavour = vim.o.background == "dark" and require("editor").config.plugins.catppuccin.dark_variant
					or require("editor").config.plugins.catppuccin.light_variant,
				background = {
					light = require("editor").config.plugins.catppuccin.light_variant,
					dark = require("editor").config.plugins.catppuccin.dark_variant,
				},
				term_colors = true,
				styles = {
					comments = { "italic" },
					properties = { "italic" },
					functions = { "italic", "bold" },
					keywords = { "italic" },
					operators = { "bold" },
					conditionals = { "bold" },
					loops = { "bold" },
					booleans = { "bold", "italic" },
				},
				integrations = {
					dap = { enabled = true, enable_ui = true },
					fidget = true,
					hop = true,
					indent_blankline = { enabled = true, colored_indent_levels = false },
					lsp_saga = true,
					lsp_trouble = true,
					markdown = true,
					mason = true,
					notify = true,
					nvimtree = true,
					treesitter_context = true,
					which_key = true,
				},
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
					"NvimTree",
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
				word_diff = require("editor").config.plugins.gitsigns.word_diff,
				current_line_blame = false,
				current_line_blame_opts = { virtual_text_pos = "eol" },
				diff_opts = { internal = true },
				signs = {
					add = {
						hl = "GitSignsAdd",
						text = "│",
						numhl = "GitSignsAddNr",
						linehl = "GitSignsAddLn",
					},
					change = {
						hl = "GitSignsChange",
						text = "│",
						numhl = "GitSignsChangeNr",
						linehl = "GitSignsChangeLn",
					},
					delete = {
						hl = "GitSignsDelete",
						text = "_",
						numhl = "GitSignsDeleteNr",
						linehl = "GitSignsDeleteLn",
					},
					topdelete = {
						hl = "GitSignsDelete",
						text = "‾",
						numhl = "GitSignsDeleteNr",
						linehl = "GitSignsDeleteLn",
					},
					changedelete = {
						hl = "GitSignsChange",
						text = "~",
						numhl = "GitSignsChangeNr",
						linehl = "GitSignsChangeLn",
					},
				},
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
						["n|<Leader>hs"] = k.callback(function() require("gitsigns.actions").stage_hunk() end)
							:with_buffer(bufnr)
							:with_desc "git: Stage hunk",
						["v|<Leader>hs"] = k.callback(
							function() require("gitsigns.actions").stage_hunk { vim.fn.line ".", vim.fn.line "v" } end
						)
							:with_buffer(bufnr)
							:with_desc "git: Stage hunk",
						["n|<Leader>hu"] = k.callback(function() require("gitsigns.actions").undo_stage_hunk() end)
							:with_buffer(bufnr)
							:with_desc "git: Undo stage hunk",
						["n|<Leader>hr"] = k.callback(function() require("gitsigns.actions").reset_hunk() end)
							:with_buffer(bufnr)
							:with_desc "git: Reset hunk",
						["v|<Leader>hr"] = k.callback(
							function() require("gitsigns.actions").reset_hunk { vim.fn.line ".", vim.fn.line "v" } end
						)
							:with_buffer(bufnr)
							:with_desc "git: Reset hunk",
						["n|<Leader>hR"] = k.callback(function() require("gitsigns.actions").reset_buffer() end)
							:with_buffer(bufnr)
							:with_desc "git: Reset buffer",
						["n|<Leader>hp"] = k.callback(function() require("gitsigns.actions").preview_hunk() end)
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
						["n|<Leader>hwd"] = k.callback(function() require("gitsigns.actions").toggle_word_diff() end)
							:with_buffer(bufnr)
							:with_desc "git: Toogle word diff",
						["n|<Leader>hd"] = k.callback(function() require("gitsigns.actions").toggle_deleted() end)
							:with_buffer(bufnr)
							:with_desc "git: Toggle deleted diff",
						-- Text objects
						["o|ih"] = k.callback(function() require("gitsigns.actions").text_object() end)
							:with_buffer(bufnr),
						["x|ih"] = k.callback(function() require("gitsigns.actions").text_object() end)
							:with_buffer(bufnr),
					}
				end,
			}
		end,
	},
	{
		"goolord/alpha-nvim",
		lazy = true,
		event = "BufWinEnter",
		cond = function() return #vim.api.nvim_list_uis() > 0 end,
		config = function()
			local alpha = require "alpha"
			local dashboard = require "alpha.themes.dashboard"

			---@param postfix string postfix to use with leader
			---@param description string name of the button
			---@param lhs string prefix to use with sc
			---@param opts? table<string, any> Options to be passed to the keybind. See |vim.api.nvim_set_keymap|
			local button = function(postfix, description, lhs, opts)
				local binding = postfix:gsub("%s", ""):gsub(lhs, "<leader>")
				local defaults = { noremap = true, silent = true, nowait = true }
				opts = opts or {}
				if vim.NIL == vim.tbl_get(opts, "callback") then
					vim.notify("No callback provided for " .. description, vim.log.levels.ERROR, { title = "Alpha" })
				end

				return {
					val = description,
					type = "button",
					on_press = function()
						vim.api.nvim_feedkeys(
							vim.api.nvim_replace_termcodes(binding .. "<Ignore>", true, false, true),
							"t",
							false
						)
					end,
					opts = {
						position = "center",
						cursor = 5,
						width = 50,
						shortcut = postfix,
						align_shortcut = "right",
						hl_shortcut = "Keyword",
						keymap = {
							"n",
							binding,
							"",
							vim.tbl_extend("keep", opts, defaults),
						},
					},
				}
			end

			local leader = "SPC"

			dashboard.section.buttons.opts.hl = "String"
			dashboard.section.buttons.val = {
				button(
					"SPC r",
					icons.misc_space.Rocket .. "File frecency",
					leader,
					{ callback = function() require("telescope").extensions.frecency.frecency() end }
				),
				button("SPC \\", icons.ui_space.List .. "Project find", leader, {
					callback = function()
						require("telescope").extensions.projects.projects { promp_title = "Projects" }
					end,
				}),
				button(
					"SPC w",
					icons.misc_space.WordFind .. "Word find",
					leader,
					{ callback = function() require("telescope").extensions.live_grep_args.live_grep_args() end }
				),
				button(
					"SPC f",
					icons.misc_space.FindFile .. "File find",
					leader,
					{ callback = function() require("utils").find_files(false) end }
				),
				button(
					"SPC n",
					icons.ui_space.NewFile .. "File new",
					leader,
					{ callback = function() vim.api.nvim_command "enew" end }
				),
			}
			local gen_footer = function()
				local stats = require("lazy").stats()
				local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
				return icons.misc_space.BentoBox
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
			local heights = #dashboard.section.header.val + 2 * #dashboard.section.buttons.val + top_button_pad

			dashboard.config.layout = {
				{
					type = "padding",
					val = math.max(0, math.ceil((vim.fn.winheight(0) - heights) * 0.25)),
				},
				dashboard.section.header,
				{ type = "padding", val = top_button_pad },
				dashboard.section.buttons,
				{ type = "padding", val = footer_button_pad },
				dashboard.section.footer,
			}

			alpha.setup(dashboard.opts)

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
		"nvim-lualine/lualine.nvim",
		lazy = true,
		event = "VeryLazy",
		config = function()
			local escape_status = function()
				local ok, m = pcall(require, "better_escape")
				return ok and m.waiting and icons.misc_space.EscapeST or ""
			end

			local _cache = { context = "", bufnr = -1 }
			local lspsaga_symbols = function()
				if
					vim.api.nvim_win_get_config(0).zindex
					or vim.tbl_contains(require("editor").global.exclude_ft, vim.bo.filetype)
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
				if not require("editor").global.is_windows then
					local home = os.getenv "HOME"
					if home and cwd:find(home, 1, true) == 1 then cwd = "~" .. cwd:sub(#home + 1) end
				end
				return icons.ui_space.RootFolderOpened .. cwd
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

			local python_venv = function()
				local function env_cleanup(venv)
					if string.find(venv, "/") then
						local final_venv = venv
						for w in venv:gmatch "([^/]+)" do
							final_venv = w
						end
						venv = final_venv
					end
					return venv
				end

				if vim.bo.filetype == "python" then
					local venv = os.getenv "CONDA_DEFAULT_ENV"
					if venv then return string.format(icons.misc_space.PyEnv .. ":(%s)", env_cleanup(venv)) end
					venv = os.getenv "VIRTUAL_ENV"
					if venv then return string.format(icons.misc_space.PyEnv .. ":(%s)", env_cleanup(venv)) end
				end
				return ""
			end

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
						},
					},
					component_separators = "|",
					section_separators = { left = "", right = "" },
					globalstatus = require("editor").config.plugins.lualine.globalstatus,
				},
				sections = {
					lualine_a = { { "mode" } },
					lualine_b = {
						{ "branch", icons_enabled = true, icon = icons.git.Branch },
						{ "diff", source = diff_source },
					},
					lualine_c = { lspsaga_symbols },
					lualine_x = {
						{ escape_status },
						{
							"diagnostics",
							sources = { "nvim_diagnostic" },
							symbols = {
								error = icons.diagnostic_space.Error,
								warn = icons.diagnostic_space.Warning,
								info = icons.diagnostic_space.Information,
							},
						},
						{ get_cwd },
					},
					lualine_y = {
						{ "filetype", colored = true, icon_only = true },
						{ python_venv },
						{ "encoding" },
						{
							"fileformat",
							icons_enabled = true,
							symbols = {
								unix = "LF",
								dos = "CRLF",
								mac = "CR",
							},
						},
					},
					lualine_z = { "progress", "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
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
				require("utils").extend_hl("LspSagaWinbar" .. hlGroup[1])
			end
			require("utils").extend_hl "LspSagaWinbarSep"
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
		init = function()
			k.nvim_register_mapping {
				["n|<C-n>"] = k.cr("NvimTreeToggle"):with_defaults "file-explorer: Toggle",
				["n|<LocalLeader>nr"] = k.cr("NvimTreeRefresh"):with_defaults "file-explorer: Refresh",
			}
		end,
		config = function()
			require("nvim-tree").setup {
				hijack_cursor = true,
				hijack_unnamed_buffer_when_opening = true,
				reload_on_bufenter = true,
				sync_root_with_cwd = true,
				view = { adaptive_size = false, side = "right" },
				renderer = {
					group_empty = true,
					highlight_opened_files = "none",
					special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md", "CMakeLists.txt" },
					indent_markers = { enable = true },
					root_folder_label = ":.:s?.*?/..?",
					root_folder_modifier = ":e",
					icons = {
						symlink_arrow = "  ",
						glyphs = {
							default = icons.documents.Default, --
							symlink = icons.documents.Symlink, --
							bookmark = icons.ui.Bookmark,
							git = {
								unstaged = icons.git.ModHolo,
								staged = icons.git.Add, --
								unmerged = icons.git.Unmerged,
								renamed = icons.git.Rename, --
								untracked = icons.git.Untracked, -- "ﲉ"
								deleted = icons.git.Remove, --
								ignored = icons.git.Ignore, --◌
							},
							folder = {
								arrow_open = icons.ui.ArrowOpen,
								arrow_closed = icons.ui.ArrowClosed,
								default = icons.ui.Folder,
								open = icons.ui.FolderOpen,
								empty = icons.ui.EmptyFolder,
								empty_open = icons.ui.EmptyFolderOpen,
								symlink = icons.ui.SymlinkFolder,
								symlink_open = icons.ui.FolderOpen,
							},
						},
					},
				},
				update_focused_file = { enable = true, update_root = true },
				system_open = { cmd = require("editor").global.is_mac and "open" or "xdg-open" },
				filters = { custom = { "^.git$", ".DS_Store", "__pycache__", "lazy-lock.json" } },
				actions = {
					open_file = {
						resize_window = false,
						window_picker = {
							exclude = {
								filetype = { "notify", "qf", "diff", "fugitive", "fugitiveblame", "alpha", "Trouble" },
								buftype = { "nofile", "terminal", "help" },
							},
						},
					},
				},
				git = {
					enable = true,
					show_on_dirs = true,
					timeout = 500,
					ignore = require("editor").config.plugins.nvim_tree.git.ignore,
				},
				trash = {
					cmd = require("utils").get_binary_path "rip",
					require_confirm = true,
				},
			}
		end,
	},
	{
		"akinsho/nvim-bufferline.lua",
		lazy = true,
		branch = "main",
		event = { "BufReadPost", "BufAdd", "BufRead", "BufNewFile" },
		config = function()
			require("bufferline").setup {
				options = {
					modified_icon = icons.ui.Modified,
					buffer_close_icon = icons.ui.Close,
					left_trunc_marker = icons.ui.Left,
					right_trunc_marker = icons.ui.Right,
					diagnostics = "nvim_lsp",
					separator_style = { "|", "|" },
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
			}
		end,
		init = function()
			k.nvim_register_mapping {
				["n|<LocalLeader>p"] = k.cr("BufferLinePick"):with_defaults "buffer: Pick",
				["n|<LocalLeader>c"] = k.cr("BufferLinePickClose"):with_defaults "buffer: Close",
				["n|<Leader>."] = k.cr("BufferLineCycleNext"):with_defaults "buffer: Cycle to next buffer",
				["n|<Leader>,"] = k.cr("BufferLineCyclePrev"):with_defaults "buffer: Cycle to previous buffer",
				["n|<Leader>1"] = k.cr("BufferLineGoToBuffer 1"):with_defaults "buffer: Goto buffer 1",
				["n|<Leader>2"] = k.cr("BufferLineGoToBuffer 2"):with_defaults "buffer: Goto buffer 2",
				["n|<Leader>3"] = k.cr("BufferLineGoToBuffer 3"):with_defaults "buffer: Goto buffer 3",
				["n|<Leader>4"] = k.cr("BufferLineGoToBuffer 4"):with_defaults "buffer: Goto buffer 4",
				["n|<Leader>5"] = k.cr("BufferLineGoToBuffer 5"):with_defaults "buffer: Goto buffer 5",
				["n|<Leader>6"] = k.cr("BufferLineGoToBuffer 6"):with_defaults "buffer: Goto buffer 6",
				["n|<Leader>7"] = k.cr("BufferLineGoToBuffer 7"):with_defaults "buffer: Goto buffer 7",
				["n|<Leader>8"] = k.cr("BufferLineGoToBuffer 8"):with_defaults "buffer: Goto buffer 8",
				["n|<Leader>9"] = k.cr("BufferLineGoToBuffer 9"):with_defaults "buffer: Goto buffer 9",
			}
		end,
	},
}
