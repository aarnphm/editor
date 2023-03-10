require "user.globals"
require "user.options"
require "user.keymapping"
require "user.events"

local icons = require "icons"

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
	-- NOTE: interface
	{
		"echasnovski/mini.bufremove",
		keys = {
            -- stylua: ignore
            { "<C-x>", function() require("mini.bufremove").delete(0, false) end, desc = "buf: delete" },
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
		config = function(_, opts) require("mini.ai").setup(opts) end,
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
			for k, v in pairs(opts) do
				leap.opts[k] = v
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
					local k = require "keybind"

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
	{
		"folke/todo-comments.nvim",
		lazy = true,
		cmd = { "TodoTrouble", "TodoTelescope" },
		event = "VeryLazy",
		config = true,
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
					prompt_prefix = " " .. icons.ui_space.Telescope .. " ",
					selection_caret = icons.ui_space.DoubleSeparator,
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

			local k = require "keybind"

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

			local k = require "keybind"
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
	{ "folke/neodev.nvim", lazy = true, ft = "lua" },
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
					f.taplo,
					-- NOTE: Using deno fmt for markdown
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
			{
				"folke/trouble.nvim",
				lazy = true,
				cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
				event = "BufReadPost",
				config = true,
			},
			{ "dnlhc/glance.nvim", cmd = "Glance", lazy = true, config = true },
			{
				"glepnir/lspsaga.nvim",
				branch = "main",
				events = "BufReadPost",
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
							separator = " " .. icons.ui_space.Separator,
							show_file = false,
						},
						callhierarchy = { show_detail = true },
					}
				end,
			},
		},
		config = function()
			local nvim_lsp = require "lspconfig"
			local mason = require "mason"

			require("lspconfig.ui.windows").default_options.border = "single"

			mason.setup {}
			require("mason-lspconfig").setup {
				ensure_installed = {
					"bashls",
					"bufls",
					"clangd",
					"dockerls",
					"lua_ls",
					"marksman",
					"html",
					"jdtls",
					"jsonls",
					"pyright",
					"rnix",
					"ruff_lsp",
					"svelte",
					"cssls",
					"rust_analyzer",
					"spectral",
					"taplo",
					"tflint",
					"tsserver",
					"vimls",
					"yamlls",
					"denols",
					"gopls",
				},
				automatic_installation = true,
			}

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if ok then capabilities = cmp_nvim_lsp.default_capabilities(capabilities) end
			capabilities.offsetEncoding = { "utf-16" }

			local on_attach = function(client, bufnr)
				require("user.format").on_attach(client, bufnr)

				local k = require "keybind"
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
			end

			local options = {
				on_attach = on_attach,
				capabilities = capabilities,
			}

			--- A small wrapper to setup lsp with nvim-lspconfig
			--- @param lsp_name string name of given lsp server
			local mason_handler = function(lsp_name)
				local success, handler = pcall(require, "lsp." .. lsp_name)

				if not success then
					nvim_lsp[lsp_name].setup(options)
					return
				end

				if type(handler) == "function" then
					--- This is the case where the language server has its own setup
					--- e.g. clangd_extensions, lua_ls, rust_analyzer
					handler(options)
				elseif type(handler) == "table" then
					nvim_lsp[lsp_name].setup(vim.tbl_extend("force", options, handler))
				else
					error(
						string.format(
							"Failed to setup '%s'. Server defined "
								.. "under lsp/ must return either a "
								.. "function(opts) or a table. Got type '%s' instead.",
							lsp_name,
							type(handler)
						),
						vim.log.levels.ERROR
					)
				end
			end

			require("mason-lspconfig").setup_handlers { mason_handler }

			mason_handler "starlark_rust"
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
			local k = require "keybind"
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

			local k = require "keybind"
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
				"zipPlugin",
				"editorconfig",
			},
		},
	},
})

vim.o.background = "dark"
vim.cmd.colorscheme "rose-pine"
