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
	"nvim-tree/nvim-web-devicons",
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
		enabled = false,
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
		event = "BufReadPost",
		dependencies = {
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
		config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
	},
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
		enabled = false,
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
			context_char = "┃",
			show_first_indent_level = false,
			buftype_exclude = { "terminal", "nofile" },
			filetype_exclude = {
				"help",
				"alpha",
				"dashboard",
				"neo-tree",
				"TelescopePrompt",
				"undotree",
				"Trouble",
				"lazy",
				"Mason",
			},
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
	-- NOTE: folke is neovim's tpope
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
	-- NOTE: fuzzy finder ftw
	{
		"nvim-telescope/telescope.nvim",
		event = "BufReadPost",
		dependencies = {
			"nvim-telescope/telescope-live-grep-args.nvim",
			"jvgrootveld/telescope-zoxide",
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
					vimgrep_arguments = {
						"rg",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
					},
					prompt_prefix = " " .. icons.ui_space.Telescope .. " ",
					selection_caret = icons.ui_space.DoubleSeparator,
					file_ignore_patterns = {
						".git/",
						"node_modules/",
						"static_content/",
						"lazy-lock.json",
						"pdm.lock",
					},
					mappings = {
						i = {
							["<C-a>"] = { "<esc>0i", type = "command" },
							["<Esc>"] = require("telescope.actions").close,
						},
						n = { ["q"] = require("telescope.actions").close },
					},
					layout_config = { width = 0.8, height = 0.8, prompt_position = "top" },
					selection_strategy = "reset",
					sorting_strategy = "ascending",
					color_devicons = true,
					file_previewer = require("telescope.previewers").vim_buffer_cat.new,
					grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
					qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
					file_sorter = require("telescope.sorters").get_fuzzy_file,
					generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
					buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
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
					fuzzy = false, -- false will only do exact matching
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
			require("telescope").load_extension "zoxide"
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
								buftype = { "terminal", "quickfix" },
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
			close_if_last_window = true,
			enable_diagnostics = false, -- default is set to true here.
			filesystem = {
				bind_to_cwd = true,
				use_libuv_file_watcher = true, -- use system level watcher for file change
				follow_current_file = { enabled = true },
				filtered_items = {
					visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
					hide_dotfiles = false,
					hide_gitignored = true,
					hide_by_name = {
						"node_modules",
						"pdm.lock",
					},
					hide_by_pattern = { -- uses glob style patterns
						"*.meta",
						"*/src/*/tsconfig.json",
					},
				},
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
				local factor = 0.45
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
			highlights = {
				Normal = { link = "Normal" },
				NormalFloat = { link = "NormalFloat" },
				FloatBorder = { link = "FloatBorder" },
			},
			open_mapping = false, -- default mapping
			shade_terminals = false,
			direction = "vertical",
			shell = vim.o.shell,
		},
		config = true,
	},
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
			return {
				debug = true,
				-- NOTE: add neoconf.json to root pattern
				root_dir = require("null-ls.utils").root_pattern(
					".null-ls-root",
					".neoconf.json",
					"Makefile",
					".git",
					"pyproject.toml"
				),
				sources = {
					f.shfmt.with { extra_args = { "-i", 4, "-ci", "-sr" } },
					f.black,
					f.ruff.with {
						extra_args = {
							string.format("--config %s/pyproject.toml", utils.get_root()),
						},
					},
					f.stylua,
					f.jq,

					-- NOTE: diagnostics
					d.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
					d.selene,
				},
			}
		end,
		config = function(_, opts)
			local null_ls = require "null-ls"
			null_ls.setup(opts)
			require("mason-null-ls").setup {
				ensure_installed = nil,
				automatic_installation = false,
				handlers = {},
			}

			-- Setup usercmd to register/deregister available source(s)
			local _gen_completion = function()
				local sources_cont = null_ls.get_source {
					filetype = vim.api.nvim_get_option_value("filetype", { scope = "local" }),
				}
				local completion_items = {}
				for _, server in pairs(sources_cont) do
					table.insert(completion_items, server.name)
				end
				return completion_items
			end

			local toggle_command = function(args)
				if vim.tbl_contains(_gen_completion(), args.args) then
					null_ls.toggle { name = opts.args }
				else
					vim.notify(
						string.format(
							"[Null-ls] Unable to find any registered source named [%s].",
							opts.args
						),
						vim.log.levels.ERROR,
						{ title = "Null-ls Internal Error" }
					)
				end
			end
			vim.api.nvim_create_user_command("NullLsToggle", toggle_command, {
				nargs = 1,
				complete = _gen_completion,
			})
		end,
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
	-- NOTE: scrollview
	{
		"dstein64/nvim-scrollview",
		event = { "BufReadPost", "BufAdd", "BufNewFile" },
		config = function()
			require("scrollview").setup {
				scrollview_mode = "virtual",
				excluded_filetypes = { "NvimTree", "terminal", "nofile" },
				winblend = 0,
				signs_on_startup = { "folds", "marks", "search", "spell" },
			}
		end,
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
		event = { "CursorHold", "CursorHoldI" },
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
			"hrsh7th/cmp-nvim-lsp",
			{ "folke/neoconf.nvim", cmd = "Neoconf", config = true },
			{ "folke/neodev.nvim", config = true, ft = "lua" },
		},
		---@class LspOptions
		opts = {
			---@type lspconfig.options
			servers = {
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
							autoImportCompletions = true,
							autoSearchPaths = true,
							diagnosticMode = "workspace", -- workspace
							useLibraryCodeForTypes = true,
						},
					},
				},
				pylyzer = {
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
							checkOnType = false,
							diagnostics = false,
							inlayHints = true,
							smartCompletion = true,
						},
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
							hint = { enable = true, setType = true },
							runtime = {
								version = "LuaJIT",
								special = { reload = "require" },
							},
							diagnostics = {
								globals = { "vim" },
								disable = { "different-requires" },
							},
							workspace = { checkThirdParty = false },
							telemetry = { enable = false },
							semantic = { enable = false },
						},
					},
				},
				ruff_lsp = {},
			},
			---@type table<string, fun(lspconfig:any, options:_.lspconfig.options):boolean?>
			setup = {},
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

			vim.api.nvim_command [[LspStart]] -- Start LSPs
		end,
	},
	{
		"lvimuser/lsp-inlayhints.nvim",
		lazy = true,
		event = { "LspAttach" },
		opts = {
			inlay_hints = {
				parameter_hints = { show = true },
				type_hints = { show = true },
				label_formatter = function(tbl, kind, opts)
					if kind == 2 and not opts.parameter_hints.show then
						return ""
					elseif not opts.type_hints.show then
						return ""
					end

					return table.concat(tbl, ", ")
				end,
				virt_text_formatter = function(label, hint, opts, client_name)
					if client_name == "lua_ls" then
						if hint.kind == 2 then
							hint.paddingLeft = false
						else
							hint.paddingRight = false
						end
					end

					local vt = {}
					vt[#vt + 1] = hint.paddingLeft and { " ", "None" } or nil
					vt[#vt + 1] = { label, opts.highlight }
					vt[#vt + 1] = hint.paddingRight and { " ", "None" } or nil

					return vt
				end,
				only_current_line = false,
				-- highlight group
				highlight = "Comment",
				-- virt_text priority
				priority = 0,
			},
			enabled_at_startup = true,
			debug_mode = false,
		},
	},
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		opts = { ensure_installed = { "lua-language-server", "pyright", "pylyzer" } },
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
	-- NOTE: Setup completions.
	{

		"hrsh7th/nvim-cmp",
		---@diagnostic disable-next-line: assign-type-mismatch
		version = false,
		event = "InsertEnter",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			{
				"L3MON4D3/LuaSnip",
				dependencies = { "rafamadriz/friendly-snippets" },
				config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
				opts = { history = true, delete_check_events = "TextChanged" },
			},
		},
		config = function()
			local cmp = require "cmp"

			local cmp_format = function(opts)
				opts = opts or {}
				return function(entry, vim_item)
					if opts.before then vim_item = opts.before(entry, vim_item) end

					local item = icons.kind[vim_item.kind]
						or icons.type[vim_item.kind]
						or icons.cmp[vim_item.kind]
						or icons.kind.Undefined

					vim_item.kind = string.format("  %s  %s", item, vim_item.kind)

					if opts.maxwidth ~= nil then
						if opts.ellipsis_char == nil then
							vim_item.abbr = string.sub(vim_item.abbr, 1, opts.maxwidth)
						else
							local label = vim_item.abbr
							local truncated_label = vim.fn.strcharpart(label, 0, opts.maxwidth)
							if truncated_label ~= label then
								vim_item.abbr = truncated_label .. opts.ellipsis_char
							end
						end
					end
					return vim_item
				end
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
				preselect = cmp.PreselectMode.Item,
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				snippet = {
					expand = function(args) require("luasnip").lsp_expand(args.body) end,
				},
				formatting = {
					fields = { "menu", "abbr", "kind" },
					format = function(entry, vim_item)
						return cmp_format { maxwidth = 80 }(entry, vim_item)
					end,
				},
				sorting = {
					priority_weight = 2,
					comparators = {
						compare.offset, -- Items closer to cursor will have lower priority
						compare.exact,
						-- compare.scopes,
						compare.lsp_scores,
						compare.sort_text,
						compare.score,
						compare.recently_used,
						-- compare.locality, -- Items closer to cursor will have higher priority, conflicts with `offset`
						compare.kind,
						compare.length,
						compare.order,
					},
				},
				experimental = {
					ghost_text = {
						hl_group = "LspCodeLens",
					},
				},
				matching = {
					disallow_partial_fuzzy_matching = false,
				},
				performance = {
					async_budget = 1,
					max_view_entries = 120,
				},
				mapping = cmp.mapping.preset.insert {
					["<CR>"] = cmp.mapping.confirm {
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					},
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif require("luasnip").expand_or_jumpable() then
							vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-expand-or-jump", "")
						elseif check_backspace() then
							vim.fn.feedkeys(replace_termcodes "<Tab>", "n")
						else
							fallback()
						end
					end,
					["<S-Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif require("luasnip").jumpable(-1) then
							vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-jump-prev", "")
						else
							fallback()
						end
					end,
				},
				sources = {
					{ name = "nvim_lsp", max_item_count = 350 },
					{ name = "buffer" },
					{ name = "luasnip" },
					{ name = "path" },
				},
			}

			if user.ui then
				opts.window = {
					completion = cmp.config.window.bordered {
						border = user.window.border,
						winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,Search:PmenuSel",
						scrollbar = false,
					},
					documentation = cmp.config.window.bordered {
						border = user.window.border,
						winhighlight = "Normal:CmpDoc",
					},
				}
			end

			cmp.setup(opts)
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
				"tarPlugin",
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
			},
		},
	},
})

vim.o.background = user.background
vim.cmd.colorscheme(user.colorscheme)
