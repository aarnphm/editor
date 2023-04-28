--# selene: allow(global_usage)

-- NOTE: compatible block with vscode
if vim.g.vscode then return end

require "user.globals"

local icons = _G.icons
local utils = require "user.utils"
local user = require "user.options"

-- bootstrap logics
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	}
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
	-- NOTE: utilities
	"lewis6991/impatient.nvim",
	"nvim-lua/plenary.nvim",
	"jghauser/mkdir.nvim",
	"nvim-tree/nvim-web-devicons",
	{ "dstein64/vim-startuptime", cmd = "StartupTime" },
	{
		"stevearc/dressing.nvim",
		opts = {
			input = {
				enabled = true,
				override = function(config)
					return vim.tbl_deep_extend("force", config, { col = -1, row = 0 })
				end,
			},
			select = { enabled = true, backend = "telescope", trim_prompt = true },
		},
		init = function()
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load { plugins = { "dressing.nvim" } }
				return vim.ui.select(...)
			end
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.input = function(...)
				require("lazy").load { plugins = { "dressing.nvim" } }
				return vim.ui.input(...)
			end
		end,
		config = true,
	},
	-- NOTE: cozy colorscheme
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		opts = {
			disable_italics = true,
			dark_variant = "main",
			highlight_groups = {
				Comment = { fg = "muted", italic = true },
				StatusLine = { fg = "rose", bg = "iris", blend = 10 },
				StatusLineNC = { fg = "subtle", bg = "surface" },
				TelescopeBorder = { fg = "highlight_high" },
				TelescopeNormal = { fg = "subtle" },
				TelescopePromptNormal = { fg = "text" },
				TelescopeSelection = { fg = "text" },
				TelescopeSelectionCaret = { fg = "iris" },
			},
		},
	},
	{ "nyoom-engineering/oxocarbon.nvim", lazy = false },
	-- NOTE: hidden tech the harpoon
	{
		"theprimeagen/harpoon",
		event = "BufReadPost",
		config = function()
			local mark = require "harpoon.mark"
			local ui = require "harpoon.ui"
			require("harpoon").setup {}

			vim.keymap.set("n", "<leader>a", mark.add_file)
			vim.keymap.set("n", "<leader>e", ui.toggle_quick_menu)
			vim.keymap.set("n", "<LocalLeader><LocalLeader>h", function() ui.nav_file(1) end)
			vim.keymap.set("n", "<LocalLeader><LocalLeader>i", function() ui.nav_file(2) end)
			vim.keymap.set("n", "<LocalLeader><LocalLeader>n", function() ui.nav_file(3) end)
			vim.keymap.set("n", "<LocalLeader><LocalLeader>s", function() ui.nav_file(4) end)
		end,
	},
	-- NOTE: scratch buffer
	{
		"mtth/scratch.vim",
		cmd = "Scratch",
		keys = { { "<Space><Space>s", "<cmd>Scratch<cr>", desc = "buffer: open scratch" } },
	},
	-- NOTE: Gigachad Git
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "G" },
		keys = {
			{
				"<Leader>p",
				function() vim.cmd [[ Git pull --rebase ]] end,
				desc = "git: pull rebase",
			},
			{ "<Leader>P", function() vim.cmd [[ Git push ]] end, desc = "git: push" },
		},
	},
	-- NOTE: nice git integration and UI
	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPost",
		config = function()
			require("gitsigns").setup {
				numhl = true,
				word_diff = false,
				current_line_blame = false,
				diff_opts = { internal = true },
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local map = function(mode, l, r, desc)
						vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
					end
                    -- stylua: ignore start
					map("n", "]h", gs.next_hunk, "git: next hunk")
					map("n", "[h", gs.prev_hunk, "git: prev hunk")
					map("n", "<leader>hu", gs.undo_stage_hunk, "git: undo stage hunk")
					map("n", "<leader>hR", gs.reset_buffer, "git: reset buffer")
					map("n", "<leader>hS", gs.stage_buffer, "git: stage buffer")
					map("n", "<leader>hp", gs.preview_hunk, "git: preview hunk")
                    map("n", "<leader>hd", gs.diffthis, "git: diff this")
                    map("n", "<leader>hD", function() gs.diffthis("~") end, "git: diff this ~")
                    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "git: blame Line")
					map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "git: stage hunk")
					map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "git: reset hunk")
                    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
					-- stylua: ignore end
				end,
			}
		end,
	},
	-- NOTE: exit fast af
	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		opts = { timeout = 200, clear_empty_lines = true, keys = "<Esc>" },
	},
	-- NOTE: treesitter-based dependencies
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			if #vim.api.nvim_list_uis() ~= 0 then vim.api.nvim_command "TSUpdate" end
		end,
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"windwp/nvim-ts-autotag",
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				init = function()
					-- PERF: no need to load the plugin, if we only need its queries for mini.ai
					local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
					local opts = require("lazy.core.plugin").values(plugin, "opts", false)
					local enabled = false
					if opts.textobjects then
						for _, mod in ipairs { "move", "select", "swap", "lsp_interop" } do
							if opts.textobjects[mod] and opts.textobjects[mod].enable then
								enabled = true
								break
							end
						end
					end
					if not enabled then
						require("lazy.core.loader").disable_rtp_plugin "nvim-treesitter-textobjects"
					end
				end,
			},
		},
		keys = { { "<bs>", desc = "Decrement selection", mode = "x" } },
		opts = {
			ensure_installed = {
				"python",
				"rust",
				"lua",
				"c",
				"cpp",
				"toml",
				"bash",
				"css",
				"vim",
				"regex",
				"markdown",
				"markdown_inline",
				"yaml",
				"go",
			},
			ignore_install = { "phpdoc", "gitcommit" },
			indent = { enable = true },
			highlight = { enable = true },
			context_commentstring = { enable = true, enable_autocmd = false },
			autotag = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-a>",
					node_incremental = "<C-a>",
					scope_incremental = "<nop>",
					node_decremental = "<bs>",
				},
			},
		},
		config = function(_, opts)
			if utils.has "typescript.nvim" then
				vim.list_extend(opts.ensure_installed, { "typescript", "tsx" })
			end
			if utils.has "SchemaStore.nvim" then
				vim.list_extend(opts.ensure_installed, { "json", "jsonc", "json5" })
			end
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	{ "m-demare/hlargs.nvim", lazy = true, config = true },
	-- NOTE: comments, you say what?
	{
		"numToStr/Comment.nvim",
		lazy = true,
		event = "BufReadPost",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = true,
	},
	-- NOTE: mini libraries of deps because it is light and easy to use.
	{
		"echasnovski/mini.bufremove",
		keys = {
			{
				"<C-x>",
				function() require("mini.bufremove").delete(0, false) end,
				desc = "buf: delete",
			},
			{
				"<C-q>",
				function() require("mini.bufremove").delete(0, true) end,
				desc = "buf: force delete",
			},
		},
	},
	{
		-- better text-objects
		"echasnovski/mini.ai",
		event = "InsertEnter",
		dependencies = { "nvim-treesitter-textobjects" },
		opts = function()
			local ai = require "mini.ai"
			return {
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}, {}),
					f = ai.gen_spec.treesitter(
						{ a = "@function.outer", i = "@function.inner" },
						{}
					),
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
				},
			}
		end,
		config = function(_, opts) require("mini.ai").setup(opts) end,
	},
	{
		"echasnovski/mini.align",
		event = "InsertEnter",
		config = function(_, opts) require("mini.align").setup(opts) end,
	},
	{
		"echasnovski/mini.surround",
		event = "InsertEnter",
		config = function(_, opts) require("mini.surround").setup(opts) end,
	},
	{
		"echasnovski/mini.pairs",
		event = "InsertEnter",
		config = function(_, opts) require("mini.pairs").setup(opts) end,
	},
	{
		-- active indent guide and indent text objects
		"echasnovski/mini.indentscope",
		event = { "BufReadPre", "BufNewFile" },
		enabled = user.ui,
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
					"scratch",
					"nofile",
					"toggleterm",
					"terminal",
				},
				callback = function() vim.b.miniindentscope_disable = true end,
			})
		end,
		config = function(_, opts) require("mini.indentscope").setup(opts) end,
	},
	-- NOTE: cuz sometimes `set list` is not enough and you need some indent guides
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			show_first_indent_level = false,
			buftype_exclude = { "terminal", "nofile" },
			filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
			show_trailing_blankline_indent = false,
			show_current_context = false,
		},
	},
	-- NOTE: easily jump to any location and enhanced f/t motions for Leap
	{
		"ggandor/flit.nvim",
		opts = { labeled_modes = "nx" },
		---@diagnostic disable-next-line: assign-type-mismatch
		keys = function()
			---@type table<string, LazyKeys[]>
			local ret = {}
			for _, key in ipairs { "f", "F", "t", "T" } do
				ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
			end
			return ret
		end,
	},
	{
		"ggandor/leap.nvim",
		keys = {
			{ "s", mode = { "n", "x", "o" }, desc = "motion: Leap forward to" },
			{ "S", mode = { "n", "x", "o" }, desc = "motion: Leap backward to" },
			{ "gs", mode = { "n", "x", "o" }, desc = "motion: Leap from windows" },
		},
		config = function(_, opts)
			local leap = require "leap"
			for key, val in pairs(opts) do
				leap.opts[key] = val
			end
			leap.add_default_mappings(true)
			vim.keymap.del({ "x", "o" }, "x")
			vim.keymap.del({ "x", "o" }, "X")
		end,
	},
	-- NOTE: better UI components
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			{ "junegunn/fzf", lazy = true, build = ":call fzf#install()" },
		},
		config = true,
	},
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = { text = { spinner = "dots" }, window = { blend = 0 } },
	},
	-- NOTE: folke is neovim's tpope
	{
		"folke/zen-mode.nvim",
		event = "BufReadPost",
		cmd = "ZenMode",
		opts = {
			window = {
				width = function() return vim.o.columns * 0.73 end,
			},
		},
	},
	{ "folke/paint.nvim", event = "BufReadPost", config = true },
	{
		"folke/noice.nvim",
		event = { "BufWinEnter", "BufNewFile", "WinEnter" },
		opts = {
			lsp = {
				progress = { enabled = false },
				signature = { enabled = false },
				hover = { enabled = false },
			},
			cmdline = { view = "cmdline" },
			messages = { view = "mini", view_error = "mini", view_warn = "mini" },
			hover = { enabled = false },
			signature = { enabled = false },
			popupmenu = { backend = "cmp" },
			presets = { bottom_search = true, command_palette = false, inc_rename = true },
		},
	},
	{
		"folke/trouble.nvim",
		cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
		opts = { use_diagnostic_signs = true },
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"[q",
				function()
					if #vim.fn.getqflist() > 0 then
						if require("trouble").is_open() then
							require("trouble").previous { skip_groups = true, jump = true }
						else
							vim.cmd.cprev()
						end
					else
						vim.notify("trouble: No items in quickfix", vim.log.levels.INFO)
					end
				end,
				desc = "qf: Previous item",
			},
			{
				"]q",
				function()
					if #vim.fn.getqflist() > 0 then
						if require("trouble").is_open() then
							require("trouble").next { skip_groups = true, jump = true }
						else
							vim.cmd.cnext()
						end
					else
						vim.notify("trouble: No items in quickfix", vim.log.levels.INFO)
					end
				end,
				desc = "qf: Next item",
			},
		},
	},
	{
		"folke/which-key.nvim",
		event = "BufReadPost",
		opts = { plugins = { presets = { operators = false } } },
		config = function(_, opts)
			if user.ui then opts.window = { border = user.window.border } end
			require("which-key").setup(opts)
		end,
	},
	{
		"folke/todo-comments.nvim",
		cmd = { "TodoTrouble", "TodoTelescope" },
		event = { "BufReadPost", "BufNewFile" },
		config = true,
		keys = {
			{
				"]t",
				function() require("todo-comments").jump_next() end,
				desc = "todo: Next comment",
			},
			{
				"[t",
				function() require("todo-comments").jump_prev() end,
				desc = "todo: Previous comment",
			},
		},
	},
	-- NOTE: fuzzy finder ftw
	{
		"nvim-telescope/telescope.nvim",
		event = "BufReadPost",
		dependencies = {
			"nvim-telescope/telescope-live-grep-args.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make -C ~/.local/share/nvim/lazy/telescope-fzf-native.nvim",
			},
		},
		keys = {
			{
				"<Leader>f",
				function()
					require("telescope.builtin").find_files {
						find_command = {
							"fd",
							"-H",
							"-tf",
							"-E",
							"lazy-lock.json",
							"--strip-cwd-prefix",
						},
						theme = "dropdown",
						previewer = false,
					}
				end,
				desc = "telescope: Find files in current directory",
				noremap = true,
				silent = true,
			},
			{
				"<Leader>r",
				function()
					require("telescope.builtin").git_files {
						find_command = {
							"fd",
							"-H",
							"-tf",
							"-E",
							"lazy-lock.json",
							"--strip-cwd-prefix",
						},
						theme = "dropdown",
						previewer = false,
					}
				end,
				desc = "telescope: Find files in git repository",
				noremap = true,
				silent = true,
			},
			{
				"<Leader>'",
				function() require("telescope.builtin").live_grep {} end,
				desc = "telescope: Live grep",
				noremap = true,
				silent = true,
			},
			{
				"<Leader>w",
				function() require("telescope").extensions.live_grep_args.live_grep_args() end,
				desc = "telescope: Live grep args",
				noremap = true,
				silent = true,
			},
			{
				"<Leader>/",
				"<cmd>Telescope grep_string<cr>",
				desc = "telescope: Grep string under cursor",
				noremap = true,
				silent = true,
			},
			{
				"<Leader>b",
				"<cmd>Telescope buffers show_all_buffers=true previewer=false<cr>",
				desc = "telescope: Manage buffers",
				noremap = true,
				silent = true,
			},
			{
				"<C-p>",
				function()
					require("telescope.builtin").keymaps {
						lhs_filter = function(lhs) return not string.find(lhs, "Þ") end,
						layout_config = {
							width = 0.6,
							height = 0.6,
							prompt_position = "top",
						},
					}
				end,
				desc = "telescope: Keymaps",
				noremap = true,
				silent = true,
			},
		},
		config = function()
			require("telescope").setup {
				defaults = {
					prompt_prefix = " " .. icons.ui_space.Telescope .. " ",
					selection_caret = icons.ui_space.DoubleSeparator,
					file_ignore_patterns = {
						".git/",
						"node_modules/",
						"static_content/",
						"lazy-lock.json",
					},
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
				fzf = {
					fuzzy = true, -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case", -- or "ignore_case" or "respect_case"
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
			require("telescope").load_extension "fzf"
		end,
	},
	-- NOTE: better nvim-tree.lua
	{
		"nvim-neo-tree/neo-tree.nvim",
		cmd = "Neotree",
		dependencies = {
			{ "MunifTanjim/nui.nvim", lazy = true },
			"nvim-lua/plenary.nvim",
			{
				"s1n7ax/nvim-window-picker",
				lazy = true,
				config = function()
					require("window-picker").setup {
						autoselect_one = true,
						include_current = false,
						filter_rules = {
							-- filter using buffer options
							bo = {
								-- if the file type is one of following, the window will be ignored
								filetype = { "neo-tree", "neo-tree-popup", "notify" },
								-- if the buffer type is one of following, the window will be ignored
								buftype = { "terminal", "quickfix", "Scratch" },
							},
						},
						other_win_hl_color = "#e35e4f",
					}
				end,
			},
		},
		keys = {
			{
				"<C-n>",
				function()
					require("neo-tree.command").execute {
						toggle = true,
						dir = vim.loop.cwd(),
					}
				end,
				desc = "explorer: root dir",
			},
		},
		deactivate = function() vim.cmd [[Neotree close]] end,
		init = function()
			vim.g.neo_tree_remove_legacy_commands = 1
			if vim.fn.argc() == 1 then
				---@diagnostic disable-next-line: param-type-mismatch
				local stat = vim.loop.fs_stat(vim.fn.argv(0))
				if stat and stat.type == "directory" then require "neo-tree" end
			end
		end,
		opts = {
			enable_diagnostics = false, -- default is set to true here.
			filesystem = {
				bind_to_cwd = true,
				follow_current_file = true,
			},
			event_handlers = {
				{
					event = "neo_tree_window_after_open",
					handler = function(args)
						if args.position == "left" or args.position == "right" then
							vim.cmd "wincmd ="
						end
					end,
				},
				{
					event = "neo_tree_window_after_close",
					handler = function(args)
						if args.position == "left" or args.position == "right" then
							vim.cmd "wincmd ="
						end
					end,
				},
				-- disable last status on neo-tree
				-- If I use laststatus, then uncomment this
				{
					event = "neo_tree_buffer_enter",
					handler = function() vim.opt_local.laststatus = 0 end,
				},
				{
					event = "neo_tree_buffer_leave",
					handler = function() vim.opt_local.laststatus = 2 end,
				},
			},
			always_show = { ".github" },
			window = {
				mappings = {
					["<space>"] = "none", -- disable space since it is leader
					["s"] = "split_with_window_picker",
					["v"] = "vsplit_with_window_picker",
				},
			},
			default_component_configs = {
				indent = {
					with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
			},
		},
	},
	-- NOTE: Chad colorizer
	{
		"NvChad/nvim-colorizer.lua",
		event = "LspAttach",
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
	-- NOTE: spectre for magic search and replace
	{
		"nvim-pack/nvim-spectre",
		event = "BufReadPost",
		keys = {
			{
				"<Leader>so",
				function() require("spectre").open() end,
				desc = "replace: Open panel",
			},
			{
				"<Leader>so",
				function() require("spectre").open_visual() end,
				desc = "replace: Open panel",
				mode = "v",
			},
			{
				"<Leader>sw",
				function() require("spectre").open_visual { select_word = true } end,
				desc = "replace: Replace word under cursor",
			},
			{
				"<Leader>sp",
				function() require("spectre").open_file_search() end,
				desc = "replace: Replace word under file search",
			},
		},
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
	-- NOTE: terminal-in-terminal PacMan (also we only really need this with LspAttach)
	{
		"akinsho/toggleterm.nvim",
		cmd = "ToggleTerm",
		---@diagnostic disable-next-line: assign-type-mismatch
		module = true,
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
			on_open = function(_)
				vim.cmd "startinsert!"
				vim.opt_local.statusline =
					'%{&ft == "toggleterm" ? "terminal (".b:toggle_number.")" : ""}'
			end,
			open_mapping = false, -- default mapping
			shade_terminals = false,
			direction = "vertical",
			shell = vim.o.shell,
		},
		config = true,
	},
	-- NOTE: all specific language plugins
	{
		"jose-elias-alvarez/typescript.nvim",
		ft = { "typescript", "tsx" },
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			utils.on_attach(function(client, buffer)
				if client.name == "tsserver" then
					vim.keymap.set(
						"n",
						"<leader>co",
						"<cmd>TypescriptOrganizeImports<CR>",
						{ buffer = buffer, desc = "lsp: organize imports" }
					)
					vim.keymap.set(
						"n",
						"<leader>cR",
						"<cmd>TypescriptRenameFile<CR>",
						{ desc = "lsp: rename file", buffer = buffer }
					)
				end
			end)
			require("typescript").setup {
				server = {
					capabilities = require("lsp").gen_capabilities(),
					completions = { completeFunctionCalls = true },
				},
			}
		end,
	},
	{ "saecki/crates.nvim", event = { "BufRead Cargo.toml" }, config = true },
	{
		"simrat39/rust-tools.nvim",
		ft = "rust",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			local get_rust_adapters = function()
				if vim.loop.os_uname().sysname == "Windows_NT" then
					return {
						type = "executable",
						command = "lldb-vscode",
						name = "rt_lldb",
					}
				end
				local codelldb_extension_path = vim.fn.stdpath "data"
					.. "/mason/packages/codelldb/extension"
				local codelldb_path = codelldb_extension_path .. "/adapter/codelldb"
				local extension = ".so"
				if vim.loop.os_uname().sysname == "Darwin" then extension = ".dylib" end
				local liblldb_path = codelldb_extension_path .. "/lldb/lib/liblldb" .. extension
				return require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
			end

			require("rust-tools").setup {
				tools = {
					inlay_hints = {
						auto = true,
						other_hints_prefix = ":: ",
						only_current_line = true,
						show_parameter_hints = false,
					},
				},
				dap = { adapter = get_rust_adapters() },
				server = {
					on_attach = function(_, bufnr)
                        -- stylua: ignore start
						vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.vim.lsp.formatexpr()")
						vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
						vim.api.nvim_buf_set_option(bufnr, "tagfunc", "v:lua.vim.lsp.tagfunc")
						-- stylua: ignore end
					end,
					capabilities = require("lsp").gen_capabilities(),
					standalone = true,
					settings = {
						["rust-analyzer"] = {
							cargo = {
								loadOutDirsFromCheck = true,
								buildScripts = { enable = true },
							},
							diagnostics = {
								disabled = { "unresolved-proc-macro" },
								enableExperimental = true,
							},
							checkOnSave = { command = "clippy" },
							procMacro = { enable = true },
						},
					},
				},
			}
		end,
	},
	{
		"p00f/clangd_extensions.nvim",
		ft = { "c", "cpp", "hpp", "h" },
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			local lspconfig = require "lspconfig"
			local capabilities = require("lsp").gen_capabilities()

			capabilities.offsetEncoding = { "utf-16", "utf-8" }

			local switch_source_header_splitcmd = function(bufnr, splitcmd)
				bufnr = lspconfig.util.validate_bufnr(bufnr)
				local params = { uri = vim.uri_from_bufnr(bufnr) }

				local clangd_client = lspconfig.util.get_active_client_by_name(bufnr, "clangd")

				if clangd_client then
					clangd_client.request(
						"textDocument/switchSourceHeader",
						params,
						function(err, result)
							if err then error(tostring(err)) end
							if not result then
								error(
									"Corresponding file can’t be determined",
									vim.log.levels.ERROR
								)
								return
							end
							vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
						end
					)
				else
					error(
						"Method textDocument/switchSourceHeader is not supported by any active server on this buffer",
						vim.log.levels.ERROR
					)
				end
			end

			local get_binary_path_list = function(binaries)
				local get_binary_path = function(binary)
					local path = nil
					if vim.loop.os_uname().sysname == "Windows_NT" then
						path = vim.fn.trim(vim.fn.system("where " .. binary))
					else
						path = vim.fn.trim(vim.fn.system("which " .. binary))
					end
					if vim.v.shell_error ~= 0 then path = nil end
					return path
				end

				local path_list = {}
				for _, binary in ipairs(binaries) do
					local path = get_binary_path(binary)
					if path then table.insert(path_list, path) end
				end
				return table.concat(path_list, ",")
			end

			require("clangd_extensions").setup {
				-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/clangd.lua
				server = {
					capabilities = capabilities,
					single_file_support = true,
					cmd = {
						"clangd",
						"--background-index",
						"--pch-storage=memory",
						-- You MUST set this arg ↓ to your c/cpp compiler location (if not included)!
						"--query-driver="
							.. get_binary_path_list {
								"clang++",
								"clang",
								"gcc",
								"g++",
							},
						"--clang-tidy",
						"--all-scopes-completion",
						"--completion-style=detailed",
						"--header-insertion-decorators",
						"--header-insertion=never",
					},
					filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
					commands = {
						ClangdSwitchSourceHeader = {
							function() switch_source_header_splitcmd(0, "edit") end,
							description = "cpp: Open source/header in current buffer",
						},
						ClangdSwitchSourceHeaderVSplit = {
							function() switch_source_header_splitcmd(0, "vsplit") end,
							description = "cpp: Open source/header in a new vsplit",
						},
						ClangdSwitchSourceHeaderSplit = {
							function() switch_source_header_splitcmd(0, "split") end,
							description = "cpp: Open source/header in a new split",
						},
					},
				},
			}
		end,
	},
	---@diagnostic disable-next-line: assign-type-mismatch
	{ "b0o/SchemaStore.nvim", version = false, ft = { "json", "yaml", "yml" } },
	-- NOTE: format for days
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"jayp0521/mason-null-ls.nvim",
			"mason.nvim",
		},
		opts = function()
			-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins
			local f = require("null-ls").builtins.formatting
			local d = require("null-ls").builtins.diagnostics
			local ca = require("null-ls").builtins.code_actions
			local options = {
				debug = true,
				-- NOTE: add neoconf.json to root pattern
				root_dir = require("null-ls.utils").root_pattern(
					".null-ls-root",
					".neoconf.json",
					"Makefile",
					".git"
				),
				sources = {
					-- NOTE: formatting
					f.prettierd.with {
						extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
						extra_filetypes = { "jsonc", "astro", "svelte" },
						disabled_filetypes = { "markdown" },
					},
					f.shfmt.with { extra_args = { "-i", 4, "-ci", "-sr" } },
					f.black,
					f.ruff,
					f.isort,
					f.stylua,
					f.beautysh,
					f.rustfmt,
					f.jq,
					f.buf,
					f.clang_format.with {
						extra_args = {
							string.format("--style=file:%s/.clang-format", utils.get_root()),
						},
					},
					f.buildifier,
					f.taplo.with {
						extra_args = {
							"-o",
							string.format("indent_string=%s", string.rep(" ", 4)),
						},
					},
					f.deno_fmt.with {
						extra_args = { "--line-width", "80" },
						disabled_filetypes = {
							"javascript",
							"javascriptreact",
							"typescript",
							"typescriptreact",
						},
					},
					f.yamlfmt,

					-- NOTE: diagnostics
					d.clang_check,
					d.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
					d.selene,
					d.golangci_lint,
					d.markdownlint.with { extra_args = { "--disable MD033" } },
					d.zsh,
					d.buf,
					d.buildifier,
					d.stylelint,
					d.vint,

					-- NOTE: code actions
					ca.gitrebase,
					ca.shellcheck,
				},
			}

			if vim.fn.executable "eslint" == 1 then
				vim.list_extend(options.sources, {
					f.eslint.with { extra_filetypes = { "astro", "svelte" } },
					d.eslint.with { extra_filetypes = { "astro", "svelte" } },
					ca.eslint.with { extra_filetypes = { "astro", "svelte" } },
				})
			end

			return options
		end,
		config = function(_, opts)
			require("null-ls").setup(opts)
			require("mason-null-ls").setup {
				ensure_installed = nil,
				automatic_installation = true,
				handlers = {},
			}
		end,
	},
	-- NOTE: lua related
	{
		"ii14/neorepl.nvim",
		ft = "lua",
		keys = {
			{
				"<LocalLeader>or",
				function()
					-- get current buffer and window
					local buf = vim.api.nvim_get_current_buf()
					local win = vim.api.nvim_get_current_win()
					-- create a new split for the repl
					vim.cmd "split"
					-- spawn repl and set the context to our buffer
					require("neorepl").new { lang = "lua", buffer = buf, window = win }
					-- resize repl window and make it fixed height
					vim.cmd "resize 10 | setl winfixheight"
				end,
				desc = "repl: Open lua repl",
			},
		},
	},
	-- NOTE: nice winbar
	{
		"utilyre/barbecue.nvim",
		event = "BufReadPost",
		version = "*",
		dependencies = { "SmiteshP/nvim-navic", "nvim-tree/nvim-web-devicons" },
		opts = {
			attach_navic = false, -- handled via on_attach hooks
			exclude_filetypes = {
				"toggleterm",
				"Scratch",
				"Trouble",
				"gitrebase",
				"gitcommit",
				"gitconfig",
				"gitignore",
			},
			symbols = { separator = icons.ui_space.Separator },
			show_modified = true,
		},
	},
	{
		"stevearc/aerial.nvim",
		cmd = "AerialToggle",
		config = true,
		opts = { close_automatic_events = { "unsupported" } },
	},
	{ "smjonas/inc-rename.nvim", cmd = "IncRename", config = true },
	-- NOTE: lspconfig
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"mason.nvim",
			{
				"dnlhc/glance.nvim",
				cmd = "Glance",
				lazy = true,
				config = true,
				opts = {
					border = { enable = user.ui },
				},
			},
			{
				"hrsh7th/cmp-nvim-lsp",
				cond = function() return utils.has "nvim-cmp" end,
			},
			{ "folke/neoconf.nvim", cmd = "Neoconf", config = true },
			{ "folke/neodev.nvim", config = true, ft = "lua" },
		},
		---@class LspOptions
		opts = {
			---@type lspconfig.options
			servers = {
				bufls = { cmd = { "bufls", "serve", "--debug" }, filetypes = { "proto" } },
				gopls = {
					flags = { debounce_text_changes = 500 },
					cmd = { "gopls", "-remote=auto" },
					settings = {
						gopls = {
							usePlaceholders = true,
							analyses = {
								nilness = true,
								shadow = true,
								unusedparams = true,
								unusewrites = true,
							},
						},
					},
				},
				html = {
					cmd = { "html-languageserver", "--stdio" },
					filetypes = { "html" },
					init_options = {
						configurationSection = { "html", "css", "javascript" },
						embeddedLanguages = { css = true, javascript = true },
					},
					settings = {},
					single_file_support = true,
					flags = { debounce_text_changes = 500 },
				},
				jdtls = {
					flags = { debounce_text_changes = 500 },
					settings = {
						root_dir = {
							-- Single-module projects
							{
								"build.xml", -- Ant
								"pom.xml", -- Maven
								"settings.gradle", -- Gradle
								"settings.gradle.kts", -- Gradle
							},
							-- Multi-module projects
							{ "build.gradle", "build.gradle.kts" },
							{ "$BENTOML_GIT_ROOT/grpc-client/java" },
							{ "$BENTOML_GIT_ROOT/grpc-client/kotlin" },
						} or vim.fn.getcwd(),
					},
				},
				jsonls = {
					-- lazy-load schemastore when needed
					on_new_config = function(config)
						config.settings.json.schemas = config.settings.json.schemas or {}
						vim.list_extend(
							config.settings.json.schemas,
							require("schemastore").json.schemas()
						)
					end,
					settings = {
						json = {
							format = { enable = true },
							validate = { enable = true },
						},
					},
				},
				yamlls = {
					-- lazy-load schemastore when needed
					on_new_config = function(config)
						if utils.has "SchemaStore" then
							config.settings.yaml.schemas = require("schemastore").yaml.schemas()
						end
					end,
					settings = { yaml = { hover = true, validate = true, completion = true } },
				},
				pyright = {
					flags = { debounce_text_changes = 500 },
					root_dir = function(fname)
						return require("lspconfig.util").root_pattern(
							"WORKSPACE",
							".git",
							"Pipfile",
							"pyrightconfig.json",
							"setup.py",
							"setup.cfg",
							"pyproject.toml",
							"requirements.txt"
						)(fname) or require("lspconfig.util").path.dirname(fname)
					end,
					settings = {
						python = {
							analysis = {
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
							},
						},
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
							hint = { enable = true },
							runtime = {
								version = "LuaJIT",
								special = { reload = "require" },
							},
							workspace = { checkThirdParty = false },
							telemetry = { enable = false },
							semantic = { enable = false },
						},
					},
				},
				bashls = {},
				dockerls = {},
				marksman = {},
				rnix = {},
				ruff_lsp = {},
				svelte = {},
				cssls = {},
				spectral = {},
				taplo = {},
				-- NOTE: isolated servers will have their own plugins for setup
				clangd = { isolated = true },
				rust_analyzer = { isolated = true },
				tsserver = { isolated = true },
				-- NOTE: servers that mason is currently not supported but nvim-lspconfig is.
				starlark_rust = { mason = false },
			},
			---@type table<string, fun(lspconfig:any, options:_.lspconfig.options):boolean?>
			setup = {
				starlark_rust = function(lspconfig, options)
					lspconfig.starlark_rust.setup {
						capabilities = options.capabilities,
						cmd = { "starlark", "--lsp" },
						filetypes = {
							"bzl",
							"WORKSPACE",
							"star",
							"BUILD.bazel",
							"bazel",
							"bzlmod",
						},
						root_dir = function(fname)
							return require("lspconfig").util.root_pattern(unpack {
								"WORKSPACE",
								"WORKSPACE.bzlmod",
								"WORKSPACE.bazel",
								"MODULE.bazel",
								"MODULE",
							})(fname) or require("lspconfig").util.find_git_ancestor(fname) or require(
								"lspconfig"
							).util.path.dirname(fname)
						end,
					}
					return true
				end,
			},
		},
		---@param opts LspOptions
		config = function(_, opts)
			---@module "lspconfig"
			local lspconfig = require "lspconfig"

			local servers = opts.servers
			local setup = opts.setup

			require("lspconfig.ui.windows").default_options.border = user.window.border

			utils.on_attach(require("lsp").on_attach)

			local mason_handler = function(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = require("lsp").gen_capabilities(),
					flags = { debounce_text_changes = 150 },
				}, servers[server] or {})

				if setup[server] then
					if setup[server](lspconfig, server_opts) then return end
				elseif setup["*"] then
					if setup["*"](lspconfig, server_opts) then return end
				end
				lspconfig[server].setup(server_opts)
			end

			local have_mason, mason_lspconfig = pcall(require, "mason-lspconfig")
			local available = have_mason and mason_lspconfig.get_available_servers() or {}

			local ensure_installed = {} ---@type string[]
			for server, server_opts in pairs(servers) do
				if server_opts then
					server_opts = server_opts == true and {} or server_opts
					-- NOTE: servers that are isolated should be setup manually.
					if server_opts.isolated then
						ensure_installed[#ensure_installed + 1] = server
					else
						-- NOTE: run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
						if
							server_opts.mason == false
							or not vim.tbl_contains(available, server)
						then
							mason_handler(server)
						else
							ensure_installed[#ensure_installed + 1] = server
						end
					end
				end
			end

			-- check if mason is available, then call setup
			if have_mason then
				mason_lspconfig.setup { ensure_installed = ensure_installed }
				mason_lspconfig.setup_handlers { mason_handler }
			end
		end,
	},
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		opts = { ensure_installed = { "lua-language-server", "pyright" } },
		---@param opts MasonSettings | {ensure_installed: string[]}
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require "mason-registry"
			for _, tool in ipairs(opts.ensure_installed) do
				local p = mr.get_package(tool)
				if not p:is_installed() then p:install() end
			end
		end,
	},
	-- NOTE: lets do some dap
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			-- Creates a beautiful debugger UI
			"rcarriga/nvim-dap-ui",
			-- Installs the debug adapters for you
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
			-- Add your own debuggers here
			"leoluz/nvim-dap-go",
		},
		config = function()
			local dap = require "dap"
			local dapui = require "dapui"

			require("mason-nvim-dap").setup {
				automatic_setup = true,
				ensure_installed = { "delve", "codelldb" },
			}

			-- You can provide additional configuration to the handlers,
			-- see mason-nvim-dap README for more information
			require("mason-nvim-dap").setup_handlers()

			-- Dap UI setup
			-- For more information, see |:help nvim-dap-ui|
			dapui.setup {
				icons = {
					expanded = icons.ui_space.ArrowOpen,
					collapsed = icons.ui_space.ArrowClosed,
					current_frame = icons.ui_space.Indicator,
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
						pause = icons.dap_space.Pause,
						play = icons.dap_space.Play,
						step_into = icons.dap_space.StepInto,
						step_over = icons.dap_space.StepOver,
						step_out = icons.dap_space.StepOut,
						step_back = icons.dap_space.StepBack,
						run_last = icons.dap_space.RunLast,
						terminate = icons.dap_space.Terminate,
					},
				},
				windows = { indent = 1 },
			}

			dap.listeners.after.event_initialized["dapui_config"] = dapui.open
			dap.listeners.before.event_terminated["dapui_config"] = dapui.close
			dap.listeners.before.event_exited["dapui_config"] = dapui.close

			for _, v in ipairs {
				"Breakpoint",
				"BreakpointRejected",
				"BreakpointCondition",
				"LogPoint",
				"Stopped",
			} do
				vim.fn.sign_define(
					"Dap" .. v,
					{ text = icons.dap_space[v], texthl = "Dap" .. v, line = "", numhl = "" }
				)
			end

			-- Basic debugging keymaps, feel free to change to your liking!
			vim.keymap.set("n", "<F6>", dap.continue, { desc = "dap: continue" })
			vim.keymap.set("n", "<F7>", function()
				dap.terminate()
				dapui.close()
			end, { desc = "dap: stop" })
			vim.keymap.set("n", "<F8>", dap.toggle_breakpoint, { desc = "dap: toggle breakpoint" })
			vim.keymap.set("n", "<F9>", dap.step_into, { desc = "dap: step into" })
			vim.keymap.set("n", "<F10>", dap.step_out, { desc = "dap: step out" })
			vim.keymap.set("n", "<F10>", dap.step_over, { desc = "dap: step over" })
			vim.keymap.set(
				"n",
				"<leader>db",
				function() dap.set_breakpoint(vim.fn.input "Breakpoint condition: ") end,
				{ desc = "dap: set breakpoint condition" }
			)

			-- Install golang specific config
			require("dap-go").setup()

			dap.adapters.lldb = {
				type = "executable",
				command = "/usr/bin/lldb-vscode",
				name = "lldb",
			}
			dap.configurations.cpp = {
				{
					name = "Launch",
					type = "lldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = function()
						local input = vim.fn.input "Input args: "
						return vim.fn.split(input, " ", true)
					end,

					-- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
					--
					--    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
					--
					-- Otherwise you might get the following error:
					--
					--    Error on launch: Failed to attach to the target process
					--
					-- But you should be aware of the implications:
					-- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
					runInTerminal = false,
				},
			}

			dap.configurations.c = dap.configurations.cpp
			dap.configurations.rust = dap.configurations.cpp
		end,
	},
	-- NOTE: Setup completions.
	{
		"petertriho/cmp-git",
		dependencies = { "nvim-lua/plenary.nvim" },
		ft = { "gitcommit", "octo", "neogitCommitMessage" },
		opts = { filetypes = { "gitcommit", "octo", "neogitCommitMessage" } },
		config = true,
	},
	{
		"hrsh7th/nvim-cmp",
		---@diagnostic disable-next-line: assign-type-mismatch
		version = false,
		event = "InsertEnter",
		dependencies = {
			"onsails/lspkind.nvim",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-emoji",
			"lukas-reineke/cmp-under-comparator",
			"ray-x/cmp-treesitter",
			{
				"L3MON4D3/LuaSnip",
				dependencies = { "rafamadriz/friendly-snippets" },
				config = function()
					require("luasnip").config.set_config {
						history = true,
						update_events = "TextChanged,TextChangedI",
						delete_check_events = "TextChanged,InsertLeave",
					}
					require("luasnip.loaders.from_lua").lazy_load()
					require("luasnip.loaders.from_vscode").lazy_load()
					require("luasnip.loaders.from_snipmate").lazy_load()
				end,
			},
			{
				"zbirenbaum/copilot.lua",
				cmd = "Copilot",
				event = "InsertEnter",
				opts = {
					cmp = { enabled = true, method = "getCompletionsCycling" },
					panel = { enabled = false },
					suggestion = { enabled = true, auto_trigger = true },
					filetypes = {
						markdown = true,
						help = false,
						terraform = false,
						hgcommit = false,
						svn = false,
						cvs = false,
						["dap-repl"] = false,
						octo = false,
						TelescopePrompt = false,
						big_file_disabled_ft = false,
						neogitCommitMessage = false,
					},
				},
				config = function(_, opts)
					vim.defer_fn(function() require("copilot").setup(opts) end, 100)
				end,
			},
		},
		config = function()
			local cmp = require "cmp"
			local lspkind = require "lspkind"

			if user.ui then
				local cmp_window = require "cmp.utils.window"
				local prev_info = cmp_window.info
				---@diagnostic disable-next-line: duplicate-set-field
				cmp_window.info = function(self)
					local info = prev_info(self)
					info.scrollable = false
					return info
				end
			end

			local has_words_before = function()
				if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api
							.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]
							:match "^%s*$"
						== nil
			end

			local check_backspace = function()
				local col = vim.fn.col "." - 1
				---@diagnostic disable-next-line: param-type-mismatch
				local current_line = vim.fn.getline "."
				---@diagnostic disable-next-line: undefined-field
				return col == 0 or current_line:sub(col, col):match "%s"
			end

			local compare = require "cmp.config.compare"
			compare.lsp_scores = function(entry1, entry2)
				local diff
				if entry1.completion_item.score and entry2.completion_item.score then
					diff = (entry2.completion_item.score * entry2.score)
						- (entry1.completion_item.score * entry1.score)
				else
					diff = entry2.score - entry1.score
				end
				return (diff < 0)
			end

			---@param str string
			---@return string
			local replace_termcodes = function(str)
				return vim.api.nvim_replace_termcodes(str, true, true, true)
			end

			local opts = {
				preselect = cmp.PreselectMode.None,
				snippet = {
					expand = function(args) require("luasnip").lsp_expand(args.body) end,
				},
				formatting = {
					format = lspkind.cmp_format {
						-- show only symbol annotations
						mode = "symbol_text",
						-- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
						maxwidth = 50,
					},
				},
				mapping = cmp.mapping.preset.insert {
					["<CR>"] = cmp.mapping.confirm {
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					},
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<Tab>"] = function(fallback)
						if require("copilot.suggestion").is_visible() then
							require("copilot.suggestion").accept()
						elseif cmp.visible() then
							cmp.select_next_item()
						elseif require("luasnip").expand_or_jumpable() then
							vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-expand-or-jump", "")
						elseif check_backspace() then
							vim.fn.feedkeys(replace_termcodes "<Tab>", "n")
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end,
					["<S-Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif require("luasnip").jumpable(-1) then
							vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-jump-prev", "")
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end,
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "luasnip" },
					{ name = "nvim-lua" },
					{ name = "buffer" },
					{ name = "cmdline" },
					{ name = "emoji" },
					{ name = "treesitter" },
				},
			}

			if utils.has "cmp-git" then
				-- Set configuration for specific filetype.
				cmp.setup.filetype("gitcommit", {
					sources = cmp.config.sources({
						{ name = "cmp_git" },
					}, { { name = "buffer" } }),
				})
			end

			-- special cases with crates.nvim
			vim.api.nvim_create_autocmd({ "BufRead" }, {
				group = _G.simple_augroup "cmp_source_cargo",
				pattern = "Cargo.toml",
				callback = function() cmp.setup.buffer { sources = { { name = "crates" } } } end,
			})

			if user.ui then
				opts.window = {
					completion = cmp.config.window.bordered { border = user.window.border },
					documentation = cmp.config.window.bordered { border = user.window.border },
				}
			end

			opts.sorting = {
				priority_weight = 2,
				comparators = {
					compare.offset,
					compare.exact,
					compare.lsp_scores,
					require("cmp-under-comparator").under,
					compare.kind,
					compare.sort_text,
					compare.length,
					compare.order,
				},
			}
			cmp.setup(opts)

			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = { { name = "buffer" } },
			})
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({ { name = "path" } }, {
					{
						name = "cmdline",
						option = { ignore_cmds = { "Man", "!" } },
					},
				}),
				enabled = function()
					-- Set of commands where cmp will be disabled
					local disabled = { IncRename = true }
					-- Get first word of cmdline
					local cmd = vim.fn.getcmdline():match "%S+"
					-- Return true if cmd isn't disabled
					-- else call/return cmp.close(), which returns false
					return not disabled[cmd] or cmp.close()
				end,
			})
		end,
	},
	-- NOTE: obsidian integration with garden
	{
		"epwalsh/obsidian.nvim",
		ft = "markdown",
		cmd = {
			"ObsidianBacklinks",
			"ObsidianFollowLink",
			"ObsidianSearch",
			"ObsidianOpen",
			"ObsidianLink",
		},
		keys = {
			{
				"<Leader>gf",
				function()
					if require("obsidian").utils.cursor_on_markdown_link() then
						pcall(vim.cmd.ObsidianFollowLink)
					end
				end,
				desc = "obsidian: follow link",
			},
			{
				"<LocalLeader>obl",
				"<cmd>ObsidianBacklinks<cr>",
				desc = "obsidian: go backlinks",
			},
			{
				"<LocalLeader>on",
				"<cmd>ObsidianNew<cr>",
				desc = "obsidian: new notes",
			},
			{
				"<LocalLeader>op",
				"<cmd>ObsidianOpen<cr>",
				desc = "obsidian: open",
			},
		},
		opts = {
			use_advanced_uri = true,
			completion = { nvim_cmp = true },
		},
		config = function(_, opts)
			-- stylua: ignore
			-- NOTE: this is for my garden, you can remove this
			opts.dir = vim.NIL ~= vim.env.WORKSPACE and vim.env.WORKSPACE .. "/garden/content/" or vim.fn.getcwd()
			opts.note_frontmatter_func = function(note)
				local out = { id = note.id, tags = note.tags }
				-- `note.metadata` contains any manually added fields in the frontmatter.
				-- So here we just make sure those fields are kept in the frontmatter.
				if
					note.metadata ~= nil
					and require("obsidian").util.table_length(note.metadata) > 0
				then
					for key, value in pairs(note.metadata) do
						out[key] = value
					end
				end
				return out
			end

			require("obsidian").setup(opts)
		end,
	},
}, {
	install = { colorscheme = { user.colorscheme } },
	defaults = { lazy = true },
	change_detection = { notify = false },
	concurrency = vim.loop.os_uname() == "Darwin" and 30 or nil,
	checker = { enable = true },
	ui = {
		border = user.ui and user.window.border or "none",
		icons = {
			cmd = icons.misc.Code,
			config = icons.ui.Gear,
			event = icons.kind.Event,
			ft = icons.documents.Files,
			init = icons.misc.ManUp,
			import = icons.documents.Import,
			keys = icons.ui.Keyboard,
			lazy = icons.misc.BentoBox,
			loaded = icons.ui.Check,
			not_loaded = icons.misc.Ghost,
			plugin = icons.ui.Package,
			runtime = icons.misc.Vim,
			source = icons.kind.StaticMethod,
			start = icons.ui.Play,
			list = {
				icons.ui_space.BigCircle,
				icons.ui_space.BigUnfilledCircle,
				icons.ui_space.Square,
				icons.ui_space.ChevronRight,
			},
		},
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"2html_plugin",
				"getscript",
				"getscriptPlugin",
				"gzip",
				"logipat",
				"netrw",
				"netrwPlugin",
				"netrwSettings",
				"netrwFileHandlers",
				"matchit",
				"matchparen",
				"tar",
				"tarPlugin",
				"tohtml",
				"tutor",
				"rrhelper",
				"spellfile_plugin",
				"vimball",
				"vimballPlugin",
				"zip",
				"rplugin",
				"zipPlugin",
				"syntax",
				"synmenu",
				"optwin",
				"compiler",
				"bugreport",
				"ftplugin",
				"editorconfig",
			},
		},
	},
})

vim.o.background = user.background
vim.cmd.colorscheme(user.colorscheme)
