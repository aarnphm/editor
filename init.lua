require "user.globals"
require "user.options"
require "user.events"

local k = require "keybind"

-- Bootstrap lazy.nvim plugin manager.
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
	{ "nvim-lua/plenary.nvim" },
	{
		"echasnovski/mini.bufremove",
		keys = {
			{
				"<C-x>",
				function() require("mini.bufremove").delete(0, false) end,
				desc = "buf: delete",
			},
			{
				"<leader>bD",
				function() require("mini.bufremove").delete(0, true) end,
				desc = "buf: force delete",
			},
		},
	},
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
		cmd = { "Git", "G" },
		keys = {
			{
				"<Leader>P",
				function() vim.cmd [[ Git pull --rebase ]] end,
				desc = "git: pull rebase",
			},
			{ "<Leader>p", function() vim.cmd [[ Git push ]] end, desc = "git: push" },
		},
	},
	{
		"nmac427/guess-indent.nvim",
		event = { "CursorHold", "CursorHoldI" },
		config = true,
	},
	{
		"max397574/better-escape.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		opts = { timeout = 200 },
	},
	{
		"numToStr/Comment.nvim",
		lazy = true,
		event = "BufReadPost",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = true,
	},
	{
		-- better text-objects
		"echasnovski/mini.ai",
		event = "VeryLazy",
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
		config = function(_, opts)
			require("mini.ai").setup(opts)

			if _G.HAS "which-key.nvim" then
				--- register text-objects with which-key
				---@type table<string, string|table>
				local i = {
					[" "] = "Whitespace",
					["\""] = "Balanced \"",
					["'"] = "Balanced '",
					["`"] = "Balanced `",
					["("] = "Balanced (",
					[")"] = "Balanced ) including white-space",
					[">"] = "Balanced > including white-space",
					["<lt>"] = "Balanced <",
					["]"] = "Balanced ] including white-space",
					["["] = "Balanced [",
					["}"] = "Balanced } including white-space",
					["{"] = "Balanced {",
					["?"] = "User Prompt",
					_ = "Underscore",
					a = "Argument",
					b = "Balanced ), ], }",
					c = "Class",
					f = "Function",
					o = "Block, conditional, loop",
					q = "Quote `, \", '",
					t = "Tag",
				}
				local a = vim.deepcopy(i)
				for key, val in pairs(a) do
					a[key] = val:gsub(" including.*", "")
				end

				local ic = vim.deepcopy(i)
				local ac = vim.deepcopy(a)
				for key, name in pairs { n = "Next", l = "Last" } do
					i[key] =
						vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
					a[key] =
						vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
				end
				require("which-key").register { mode = { "o", "x" }, i = i, a = a }
			end
		end,
	},
	{
		"echasnovski/mini.align",
		lazy = true,
		event = "VeryLazy",
		config = function() require("mini.align").setup() end,
	},
	{
		"echasnovski/mini.surround",
		lazy = true,
		event = "VeryLazy",
		config = function() require("mini.surround").setup() end,
	},
	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		config = function(_, opts) require("mini.pairs").setup(opts) end,
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
	-- easily jump to any location and enhanced f/t motions for Leap
	{
		"ggandor/flit.nvim",
		keys = function()
			local ret = {}
			for _, key in ipairs { "f", "F", "t", "T" } do
				ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
			end
			return ret
		end,
		opts = { labeled_modes = "nx" },
	},
	{
		"ggandor/leap.nvim",
		keys = {
			{ "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
			{ "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
			{ "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
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
	-- nice bufferline
	{
		"akinsho/nvim-bufferline.lua",
		lazy = true,
		branch = "main",
		event = "VeryLazy",
		opts = {
			options = {
				always_show_bufferline = false,
				offsets = {
					{
						filetype = "neo-tree",
						text = "Neo-tree",
						highlight = "File explorer",
						text_align = "left",
					},
				},
			},
		},
	},
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
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
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
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
				TelescopeSelectionCaret = { fg = "rose", bg = "rose" },
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		lazy = true,
		event = "VeryLazy",
		config = function()
			require("gitsigns").setup {
				numhl = true,
				word_diff = false,
				current_line_blame = true,
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
						["n|<Leader>twd"] = k.callback(
							function() require("gitsigns.actions").toggle_word_diff() end
						)
							:with_buffer(bufnr)
							:with_desc "git: toggle word diff",
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
	-- folke is neovim's tpope
	{ "folke/neodev.nvim", lazy = true, ft = "lua" },
	{
		"folke/trouble.nvim",
		lazy = true,
		cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
		event = "BufReadPost",
		config = true,
	},
	{ "folke/zen-mode.nvim" },
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
		"folke/todo-comments.nvim",
		lazy = true,
		cmd = { "TodoTrouble", "TodoTelescope" },
		event = "LspAttach",
		config = true,
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
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{ "romgrk/nvim-treesitter-context" },
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
					"markdown",
					"markdown_inline",
				},
				ignore_install = { "phpdoc", "gitcommit" },
				indent = { enable = true },
				highlight = { enable = true },
				context_commentstring = { enable = true, enable_autocmd = false },
				matchup = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-a>",
						node_incremental = "<C-a>",
						scope_incremental = "<nop>",
						node_decremental = "<bs>",
					},
				},
			}
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		event = "BufReadPost",
		dependencies = {
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
			{
				"ahmedkhalf/project.nvim",
				as = "project_nvim",
				config = function()
					require("project_nvim").setup {
						manual_mode = false,
						detection_methods = { "lsp", "pattern" },
						ignore_lsp = { "null-ls", "copilot" },
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
					prompt_prefix = " " .. " " .. " ",
					selection_caret = " ",
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
		"nvim-neo-tree/neo-tree.nvim",
		cmd = "Neotree",
		dependencies = {
			{ "MunifTanjim/nui.nvim", lazy = true },
			{ "nvim-lua/plenary.nvim" },
			{
				"s1n7ax/nvim-window-picker",
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
			filesystem = {
				bind_to_cwd = false,
				follow_current_file = true,
			},
			window = {
				mappings = {
					["<space>"] = "none",
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
			k.nvim_register_mapping {
				["v|<LocalLeader>sv"] = k.callback(function() require("spectre").open_visual() end)
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
	{ "fatih/vim-go", lazy = true, ft = "go", run = ":GoInstallBinaries" },
	{ "simrat39/rust-tools.nvim", lazy = true, ft = { "rs", "rust" } },
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		opts = { popup = { border = "rounded" } },
	},
	{ "p00f/clangd_extensions.nvim", lazy = true, ft = { "c", "cpp", "hpp", "h" } },
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = "BufReadPre",
		dependencies = { "nvim-lua/plenary.nvim", "jayp0521/mason-null-ls.nvim" },
		keys = {
			{ "<Leader><Leader>", vim.lsp.buf.format, desc = "lsp: manual format" },
		},
		config = function()
			-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins
			local f = require("null-ls").builtins.formatting
			local d = require("null-ls").builtins.diagnostics
			local ca = require("null-ls").builtins.code_actions

			require("mason-null-ls").setup { automatic_setup = true }
			require("null-ls").setup {
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
						extra_args = { "-style={BasedOnStyle: LLVM, IndentWidth: 2}" },
					},
					f.eslint.with { extra_filetypes = { "astro", "svelte" } },
					f.buildifier,
					f.taplo.with {
						extra_args = { "fmt", "-o", "indent_string='" .. string.rep(" ", 4) .. "'" },
					},
					f.deno_fmt.with { extra_args = { "--line-width", "80" } },
					f.yamlfmt,

					-- NOTE: diagnostics
					d.clang_check,
					d.eslint.with { extra_filetypes = { "astro", "svelte" } },
					d.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
					d.selene,
					d.golangci_lint,
					d.markdownlint.with { extra_args = { "--disable MD033" } },
					d.zsh,
					d.buf,
					d.buildifier,
					d.stylelint,
					d.vulture.with { extra_args = { "--min-confidence 70" } },
					d.vint,

					-- NOTE: code actions
					ca.gitrebase,
					ca.shellcheck,
					ca.eslint.with {
						extra_filetypes = { "astro", "svelte" },
					},
				},
			}
			require("mason-null-ls").setup_handlers {}
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		dependencies = {
			{ "williamboman/mason-lspconfig.nvim" },
			{ "williamboman/mason.nvim", cmd = "Mason", lazy = true },
			{ "dnlhc/glance.nvim", cmd = "Glance", lazy = true, config = true },
			{
				"glepnir/lspsaga.nvim",
				branch = "main",
				events = "LspAttach",
				dependencies = { "nvim-tree/nvim-web-devicons", "nvim-treesitter/nvim-treesitter" },
				config = function()
					require("lspsaga").setup {
						finder = { keys = { jump_to = "e" } },
						lightbulb = { enable = false },
						diagnostic = { keys = { exec_action = "<CR>" } },
						definition = { split = "<C-c>s" },
						beacon = { enable = false },
						outline = {
							auto_preview = false,
							win_width = math.floor(vim.o.columns * 0.21),
							with_position = "left",
							keys = { jump = "<CR>" },
						},
						code_actions = { extend_gitsigns = false },
						symbol_in_winbar = {
							enable = false,
							ignore_patterns = { "%w_spec" },
							respect_root = true,
							separator = "  ",
							show_file = false,
						},
						callhierarchy = { show_detail = true },
					}
				end,
			},
		},
		config = function()
			local lspconfig = require "lspconfig"
			require("lspconfig.ui.windows").default_options.border = "single"

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if ok then capabilities = cmp_nvim_lsp.default_capabilities(capabilities) end
			capabilities.offsetEncoding = { "utf-16" }

			local options = {
				on_attach = function(client, bufnr)
					require("user.format").on_attach(client, bufnr)
					k.nvim_register_mapping {
						-- lsp
						["n|K"] = k.cr("Lspsaga hover_doc")
							:with_buffer(bufnr)
							:with_defaults "lsp: Signature help",
						["n|gh"] = k.callback(vim.show_pos)
							:with_buffer(bufnr)
							:with_defaults "lsp: Show hightlight",
						["n|g["] = k.cr("Lspsaga diagnostic_jump_prev")
							:with_buffer(bufnr)
							:with_defaults "lsp: Prev diagnostic",
						["n|g]"] = k.cr("Lspsaga diagnostic_jump_next")
							:with_buffer(bufnr)
							:with_defaults "lsp: Next diagnostic",
						["n|gr"] = k.callback(vim.lsp.buf.rename)
							:with_buffer(bufnr)
							:with_defaults "lsp: Rename in file range",
						["n|gd"] = k.cr("Glance definitions")
							:with_buffer(bufnr)
							:with_defaults "lsp: Peek definition",
						["n|gD"] = k.cr("Lspsaga goto_definition")
							:with_buffer(bufnr)
							:with_defaults "lsp: Goto definition",
						["n|ca"] = k.callback(vim.lsp.buf.code_action)
							:with_buffer(bufnr)
							:with_defaults "lsp: Code action for cursor",
						["v|ca"] = k.callback(vim.lsp.buf.code_action)
							:with_buffer(bufnr)
							:with_defaults "lsp: Code action for range",
						["n|go"] = k.cr("Lspsaga outline")
							:with_buffer(bufnr)
							:with_defaults "lsp: Show outline",
						["n|gR"] = k.cr("TroubleToggle lsp_references")
							:with_buffer(bufnr)
							:with_defaults "lsp: Show references",
					}
				end,
				capabilities = capabilities,
			}

			-- NOTE: call neodev before setup lua_ls
			require("neodev").setup {
				library = {
					plugins = {
						"lazy",
						"lualine.nvim",
						"null-ls.nvim",
						"nvim-lspconfig",
						"nvim-treesitter",
						"telescope.nvim",
						"gitsigns.nvim",
						"lspsaga.nvim",
					},
				},
			}

			require("mason").setup {}
			require("mason-lspconfig").setup_handlers {
				function(lsp_name)
					local servers = {
						bufls = { cmd = { "bufls", "serve", "--debug" }, filetypes = { "proto" } },
						clangd = function()
							options.capabilities.offsetEncoding = { "utf-16", "utf-8" }

							local switch_source_header_splitcmd = function(bufnr, splitcmd)
								bufnr = lspconfig.util.validate_bufnr(bufnr)
								local clangd_client =
									lspconfig.util.get_active_client_by_name(bufnr, "clangd")
								local params = { uri = vim.uri_from_bufnr(bufnr) }
								if clangd_client then
									clangd_client.request(
										"textDocument/switchSourceHeader",
										params,
										function(err, result)
											if err then error(tostring(err)) end
											if not result then
												vim.notify(
													"Corresponding file can’t be determined",
													vim.log.levels.ERROR,
													{ title = "LSP Error!" }
												)
												return
											end
											vim.api.nvim_command(
												splitcmd .. " " .. vim.uri_to_fname(result)
											)
										end
									)
								else
									vim.notify(
										"Method textDocument/switchSourceHeader is not supported by any active server on this buffer",
										vim.log.levels.ERROR,
										{ title = "LSP Error!" }
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
									on_attach = options.on_attach,
									capabilities = options.capabilities,
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
									hints = {
										assignVariableTypes = true,
										compositeLiteralFields = true,
										compositeLiteralTypes = true,
										constantValues = true,
										functionTypeParameters = true,
										parameterNames = true,
										rangeVariableTypes = true,
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
							flags = { debounce_text_changes = 500 },
							settings = {
								json = {
									-- Schemas https://www.schemastore.org
									schemas = {
										{
											fileMatch = { "package.json" },
											url = "https://json.schemastore.org/package.json",
										},
										{
											fileMatch = { "tsconfig*.json" },
											url = "https://json.schemastore.org/tsconfig.json",
										},
										{
											fileMatch = {
												".prettierrc",
												".prettierrc.json",
												"prettier.config.json",
											},
											url = "https://json.schemastore.org/prettierrc.json",
										},
										{
											fileMatch = { ".eslintrc", ".eslintrc.json" },
											url = "https://json.schemastore.org/eslintrc.json",
										},
										{
											fileMatch = {
												".babelrc",
												".babelrc.json",
												"babel.config.json",
											},
											url = "https://json.schemastore.org/babelrc.json",
										},
										{
											fileMatch = { "lerna.json" },
											url = "https://json.schemastore.org/lerna.json",
										},
										{
											fileMatch = {
												".stylelintrc",
												".stylelintrc.json",
												"stylelint.config.json",
											},
											url = "http://json.schemastore.org/stylelintrc.json",
										},
										{
											fileMatch = { "/.github/workflows/*" },
											url = "https://json.schemastore.org/github-workflow.json",
										},
									},
								},
							},
						},
						lua_ls = function()
							-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/lua_ls.lua
							lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", options, {
								settings = {
									Lua = {
										completion = {
											callSnippet = "Replace",
										},
										diagnostics = {
											enable = true,
											globals = { "vim" },
											disable = { "different-requires" },
										},
										hint = { enable = true },
										runtime = {
											version = "LuaJIT",
											special = { reload = "require" },
										},
										workspace = {
											library = {
												vim.env.VIMRUNTIME,
												require("neodev.config").types(),
											},
											checkThirdParty = false,
											maxPreload = 100000,
											preloadFileSize = 10000,
										},
										telemetry = { enable = false },
										semantic = { enable = false },
									},
								},
							}))
						end,
						pyright = {
							flags = { debounce_text_changes = 500 },
							root_dir = function(fname)
								return lspconfig.util.root_pattern(
									"WORKSPACE",
									".git",
									"Pipfile",
									"pyrightconfig.json",
									"setup.py",
									"setup.cfg",
									"pyproject.toml",
									"requirements.txt"
								)(fname) or lspconfig.util.path.dirname(fname)
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
						rust_analyzer = function()
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
								if vim.loop.os_uname().sysname == "Darin" then
									extension = ".dylib"
								end
								local liblldb_path = codelldb_extension_path
									.. "/lldb/lib/liblldb"
									.. extension
								return require("rust-tools.dap").get_codelldb_adapter(
									codelldb_path,
									liblldb_path
								)
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
									on_attach = function(client, bufnr)
										vim.api.nvim_buf_set_option(
											bufnr,
											"formatexpr",
											"v:lua.vim.lsp.formatexpr()"
										)
										vim.api.nvim_buf_set_option(
											bufnr,
											"omnifunc",
											"v:lua.vim.lsp.omnifunc"
										)
										vim.api.nvim_buf_set_option(
											bufnr,
											"tagfunc",
											"v:lua.vim.lsp.tagfunc"
										)
										options.on_attach(client, bufnr)
									end,
									capabilities = options.capabilities,
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
						tsserver = {
							root_dir = lspconfig.util.root_pattern(
								"tsconfig.json",
								"package.json",
								".git"
							),
							settings = {
								javascript = {
									inlayHints = {
										includeInlayEnumMemberValueHints = true,
										includeInlayFunctionLikeReturnTypeHints = true,
										includeInlayFunctionParameterTypeHints = true,
										includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
										includeInlayParameterNameHintsWhenArgumentMatchesName = true,
										includeInlayPropertyDeclarationTypeHints = true,
										includeInlayVariableTypeHints = true,
									},
								},
								typescript = {
									inlayHints = {
										includeInlayEnumMemberValueHints = true,
										includeInlayFunctionLikeReturnTypeHints = true,
										includeInlayFunctionParameterTypeHints = true,
										includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
										includeInlayParameterNameHintsWhenArgumentMatchesName = true,
										includeInlayPropertyDeclarationTypeHints = true,
										includeInlayVariableTypeHints = true,
									},
								},
							},
						},
						yamlls = {
							settings = {
								yaml = {
									schemaStore = {
										enable = true,
									},
									schemas = {
										["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
									},
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
						denols = {},
					}

					if not vim.tbl_contains(servers, lsp_name) then
						lspconfig[lsp_name].setup(options)
						return
					end

					local handler = servers[lsp_name]

					if type(handler) == "function" then
						--- This is the case where the language server has its own setup
						--- e.g. clangd_extensions, lua_ls, rust_analyzer
						local run_ok, _ = pcall(handler)
						if not run_ok then lspconfig[lsp_name].setup(options) end
					elseif type(handler) == "table" then
						lspconfig[lsp_name].setup(vim.tbl_extend("force", options, handler))
					end
				end,
			}

			-- starlark_rust
			lspconfig.starlark_rust.setup {
				on_attach = options.on_attach,
				capabilities = options.capabilities,
				cmd = { "starlark", "--lsp" },
				filetypes = { "bzl", "WORKSPACE", "star", "BUILD.bazel", "bazel", "bzlmod" },
				root_dir = function(fname)
					return lspconfig.util.root_pattern(unpack {
						"WORKSPACE",
						"WORKSPACE.bzlmod",
						"WORKSPACE.bazel",
						"MODULE.bazel",
						"MODULE",
					})(fname) or lspconfig.util.find_git_ancestor(fname) or lspconfig.util.path.dirname(
						fname
					)
				end,
			}
		end,
	},
	-- Setup completions.
	{
		"hrsh7th/nvim-cmp",
		lazy = true,
		event = "BufReadPost",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				lazy = true,
				dependencies = { "rafamadriz/friendly-snippets" },
				config = function()
					require("luasnip").config.set_config {
						history = true,
						updateevents = "TextChanged,TextChangedI",
						delete_check_events = "TextChanged,InsertLeave",
					}
					require("luasnip.loaders.from_lua").lazy_load()
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},
			{ "onsails/lspkind.nvim" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-buffer" },
			{
				"petertriho/cmp-git",
				dependencies = { "nvim-lua/plenary.nvim" },
				config = true,
				opts = { filetypes = { "gitcommit", "octo", "neogitCommitMessage" } },
			},
			{
				"zbirenbaum/copilot.lua",
				cmd = "Copilot",
				event = "InsertEnter",
				config = function()
					vim.defer_fn(
						function()
							require("copilot").setup {
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
							}
						end,
						100
					)
				end,
			},
		},
		config = function()
			local cmp = require "cmp"
			local lspkind = require "lspkind"

			local cmp_window = require "cmp.utils.window"
			local prev_info = cmp_window.info
			---@diagnostic disable-next-line: duplicate-set-field
			cmp_window.info = function(self)
				local info = prev_info(self)
				info.scrollable = false
				return info
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

			cmp.setup {
				preselect = cmp.PreselectMode.None,
				snippet = {
					expand = function(args) require("luasnip").lsp_expand(args.body) end,
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						local kind = lspkind.cmp_format {
							mode = "symbol_text",
							maxwidth = 50,
						}(entry, vim_item)
						local strings = vim.split(kind.kind, "%s", { trimempty = true })
						kind.kind = " " .. strings[1] .. " "
						kind.menu = "    (" .. strings[2] .. ")"
						return kind
					end,
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
							vim.fn.feedkeys(k.replace_termcodes "<Plug>luasnip-expand-or-jump", "")
						elseif check_backspace() then
							vim.fn.feedkeys(k.replace_termcodes "<Tab>", "n")
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
							vim.fn.feedkeys(k.replace_termcodes "<Plug>luasnip-jump-prev", "")
						elseif require("utils").has_words_before() then
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
					{ name = "crates" },
					{ name = "buffer" },
					{ name = "git" },
				},
				window = {
					completion = cmp.config.window.bordered { border = "single" },
					documentation = cmp.config.window.bordered { border = "single" },
				},
			}
		end,
	},
	-- NOTE: tools
	{
		"epwalsh/obsidian.nvim",
		ft = "markdown",
		lazy = true,
		cmd = {
			"ObsidianBacklinks",
			"ObsidianFollowLink",
			"ObsidianSearch",
			"ObsidianOpen",
			"ObsidianLink",
		},
		config = function()
			require("obsidian").setup {
				dir = vim.NIL ~= vim.env.WORKSPACE and vim.env.WORKSPACE .. "/garden/content/"
					or vim.fn.getcwd(),
				use_advanced_uri = true,
				completion = { nvim_cmp = true },
				note_frontmatter_func = function(note)
					local out = { id = note.id, tags = note.tags }
					-- `note.metadata` contains any manually added fields in the frontmatter.
					-- So here we just make sure those fields are kept in the frontmatter.
					if
						note.metadata ~= nil
						and require("obsidian").util.table_length(note.metadata) > 0
					then
						for k, v in pairs(note.metadata) do
							out[k] = v
						end
					end
					return out
				end,
			}

			k.nvim_register_mapping {
				["n|<Leader>gf"] = k.callback(function()
					if require("obsidian").utils.cursor_on_markdown_link() then
						pcall(vim.cmd.ObsidianFollowLink)
					end
				end):with_defaults "obsidian: Follow link",
				["n|<LocalLeader>obl"] = k.cr("ObsidianBacklinks")
					:with_defaults "obsidian: Backlinks",
				["n|<LocalLeader>on"] = k.cr("ObsidianNew"):with_defaults "obsidian: New notes",
				["n|<LocalLeader>oo"] = k.cr("ObsidianOpen"):with_defaults "obsidian: Open",
			}
		end,
	},
}, {
	install = { colorscheme = { "rose-pine" } },
	change_detection = { notify = false },
	concurrency = vim.loop.os_uname() == "Darwin" and 30 or nil,
	checker = { enable = true },
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
				"editorconfig",
			},
		},
	},
})

vim.o.background = "dark"
vim.cmd.colorscheme "rose-pine"
