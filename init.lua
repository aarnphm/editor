require "user.globals"
require "user.options"
require "user.events"

local k = require "keybind"
local icons = require "user.icons"

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
	-- NOTE: cuz it is cool
	{ "romainl/vim-cool", event = { "CursorHold", "CursorHoldI" }, lazy = true },
	-- NOTE: Gigachad Git
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
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
		lazy = true,
		event = "LspAttach", -- we probably only need to use gitsigns with LspAttach
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
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		opts = { timeout = 500, clear_empty_lines = true, keys = "<Esc>" },
	},
	-- NOTE: treesitter-based dependencies
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
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
				"vim",
				"yaml",
			},
			ignore_install = { "phpdoc", "gitcommit" },
			indent = { enable = true, disable = { "python" } },
			highlight = { enable = true },
			context_commentstring = { enable = true, enable_autocmd = false },
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
			if require("user.utils").has "typescript.nvim" then
				vim.list_extend(opts.ensure_installed, { "typescript", "tsx" })
			end
			if require("user.utils").has "vim-go" then
				vim.list_extend(opts.ensure_installed, { "go" })
			end
			if require("user.utils").has "SchemaStore.nvim" then
				vim.list_extend(opts.ensure_installed, { "json", "jsonc", "json5" })
			end
			require("nvim-treesitter.configs").setup(opts)
		end,
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
		lazy = true,
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
		lazy = true,
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

			if require("user.utils").has "which-key.nvim" then
				--- register text-objects with which-key
				---@type table<string, string|table>
				local i = {
					[" "] = "Whitespace",
					['"'] = 'Balanced "',
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
		lazy = true,
		config = function(_, opts) require("mini.pairs").setup(opts) end,
	},
	{
		-- active indent guide and indent text objects
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
	-- NOTE: cuz sometimes `set list` is not enough and you need some indent guides
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
	-- NOTE: easily jump to any location and enhanced f/t motions for Leap
	{
		"ggandor/flit.nvim",
		---@return LazyKeys[]
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
	-- NOTE: better UI components
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
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		lazy = true,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			{ "junegunn/fzf", lazy = true, build = ":call fzf#install()" },
		},
		config = true,
	},
	-- NOTE: cozy colorscheme
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
	-- NOTE: folke is neovim's tpope
	{ "folke/zen-mode.nvim", event = "BufReadPost" },
	{
		"folke/trouble.nvim",
		lazy = true,
		cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
		opts = { use_diagnostic_signs = true },
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").previous { skip_groups = true, jump = true }
					else
						vim.cmd.cprev()
					end
				end,
				desc = "qf: Previous item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next { skip_groups = true, jump = true }
					else
						vim.cmd.cnext()
					end
				end,
				desc = "qf: Next item",
			},
		},
	},
	{
		"folke/which-key.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		opts = { window = { border = "single" } },
	},
	{
		"folke/todo-comments.nvim",
		lazy = true,
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
	{
		"folke/noice.nvim",
		lazy = true,
		event = "BufReadPost",
		dependencies = { { "MunifTanjim/nui.nvim", lazy = true } },
		opts = {
			cmdline = { view = "cmdline" },
			popupmenu = { enabled = true, backend = "cmp" },
			presets = { command_palette = true, lsp_doc_border = true, bottom_search = true },
		},
	},
	-- NOTE: fuzzy finder ftw
	{
		"nvim-telescope/telescope.nvim",
		event = "BufReadPost",
		dependencies = { "nvim-telescope/telescope-live-grep-args.nvim" },
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
		end,
	},
	-- NOTE: better nvim-tree.lua
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
	-- NOTE: Chad colorizer
	{
		"NvChad/nvim-colorizer.lua",
		lazy = true,
		enabled = false,
		event = "BufReadPost",
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
	-- NOTE: terminal-in-terminal PacMan
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
	-- NOTE: all specific language plugins
	{
		"fatih/vim-go",
		lazy = true,
		ft = "go",
		run = ":GoInstallBinaries",
		dependencies = { { "junegunn/fzf", lazy = true, build = ":call fzf#install()" } },
	},
	{
		"jose-elias-alvarez/typescript.nvim",
		lazy = true,
		ft = { "typescript", "tsx" },
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, cmp = pcall(require, "cmp_nvim_lsp")
			if ok then capabilities = cmp.default_capabilities(capabilities) end

			require("user.utils").on_attach(function(client, buffer)
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
					capabilities = capabilities,
					completions = { completeFunctionCalls = true },
				},
			}
		end,
	},
	{ "saecki/crates.nvim", event = { "BufRead Cargo.toml" }, config = true },
	{
		"simrat39/rust-tools.nvim",
		lazy = true,
		ft = "rust",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, cmp = pcall(require, "cmp_nvim_lsp")
			if ok then capabilities = cmp.default_capabilities(capabilities) end

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
				if vim.loop.os_uname().sysname == "Darin" then extension = ".dylib" end
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
					capabilities = capabilities,
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
		lazy = true,
		ft = { "c", "cpp", "hpp", "h" },
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			local lspconfig = require "lspconfig"
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, cmp = pcall(require, "cmp_nvim_lsp")
			if ok then capabilities = cmp.default_capabilities(capabilities) end

			capabilities.offsetEncoding = { "utf-16", "utf-8" }

			local switch_source_header_splitcmd = function(bufnr, splitcmd)
				bufnr = lspconfig.util.validate_bufnr(bufnr)
				local params = { uri = vim.uri_from_bufnr(bufnr) }

                        -- stylua: ignore start
						local clangd_client = lspconfig.util.get_active_client_by_name(bufnr, "clangd")
				-- stylua: ignore end

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
	{ "b0o/SchemaStore.nvim", lazy = true, ft = { "json", "yaml", "yml" } },
	-- NOTE: format for days
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = "BufReadPre",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"jayp0521/mason-null-ls.nvim",
			"williamboman/mason.nvim",
		},
		opts = function()
			-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins
			local f = require("null-ls").builtins.formatting
			local d = require("null-ls").builtins.diagnostics
			local ca = require("null-ls").builtins.code_actions
			return {
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
							string.format(
								"--style=file:%s/.clang-format",
								require("user.utils").get_root()
							),
						},
					},
					f.eslint.with { extra_filetypes = { "astro", "svelte" } },
					f.buildifier,
					f.taplo.with {
						extra_args = {
							"-o",
							string.format("indent_string=%s", string.rep(" ", 4)),
						},
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
		end,
		config = function(_, opts)
			require("mason-null-ls").setup { automatic_setup = true }
			require("null-ls").setup(opts)
			require("mason-null-ls").setup_handlers {}
		end,
	},
	-- NOTE: lua related
	{
		"ii14/neorepl.nvim",
		lazy = true,
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
	-- NOTE: lspconfig
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"williamboman/mason.nvim",
			{ "dnlhc/glance.nvim", cmd = "Glance", lazy = true, config = true },
			{
				"lewis6991/hover.nvim",
				lazy = true,
				config = function()
					require("hover").setup {
						init = function()
							require "hover.providers.lsp"
							require "hover.providers.gh"
							require "hover.providers.gh_user"
						end,
						-- Whether the contents of a currently open hover window should be moved
						-- to a :h preview-window when pressing the hover keymap.
						preview_window = false,
						title = true,
					}
				end,
			},
			{
				"hrsh7th/cmp-nvim-lsp",
				cond = function() return require("user.utils").has "nvim-cmp" end,
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
						config.settings.yaml.schemas = config.settings.yaml.schemas or {}
						vim.list_extend(
							config.settings.yaml.schemas,
							require("schemastore").yaml.schemas()
						)
					end,
					settings = {
						yaml = {
							format = { enable = true },
						},
					},
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
				denols = {},
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
						filetypes = { "bzl", "WORKSPACE", "star", "BUILD.bazel", "bazel", "bzlmod" },
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

			require("lspconfig.ui.windows").default_options.border = "single"

			require("user.utils").on_attach(require("lsp").on_attach)

			local capabilities = require("cmp_nvim_lsp").default_capabilities(
				vim.lsp.protocol.make_client_capabilities()
			)

			local mason_handler = function(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
					flags = { debounce_text_changes = 150 },
				}, servers[server] or {})

				if setup[server] then
					if setup[server](lspconfig, server_opts) then return end
				elseif setup["*"] then
					if setup["*"](lspconfig, server_opts) then return end
				end
				lspconfig[server].setup(server_opts)
			end

			local mason_lspconfig = require "mason-lspconfig"
			local available = mason_lspconfig.get_available_servers()

			local ensure_installed = {} ---@type string[]
			for server, server_opts in pairs(servers) do
				if server_opts then
					server_opts = server_opts == true and {} or server_opts
					-- XXX: servers that are isolated should be setup manually.
					if server_opts.isolated then
						ensure_installed[#ensure_installed + 1] = server
					else
						-- XXX: run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
						if
							server_opts.mason == false or not vim.tbl_contains(available, server)
						then
							mason_handler(server)
						else
							ensure_installed[#ensure_installed + 1] = server
						end
					end
				end
			end

			require("mason").setup {}
			mason_lspconfig.setup { ensure_installed = ensure_installed }
			mason_lspconfig.setup_handlers { mason_handler }
		end,
	},
	-- NOTE: Setup completions.
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
				build = ":Copilot auth",
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
	-- NOTE: obsidian integration with garden
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
						for key, value in pairs(note.metadata) do
							out[key] = value
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
	ui = {
		icons = {
			cmd = icons.misc.Code,
			config = icons.ui.Gear,
			event = icons.kind.Event,
			ft = icons.documents.Files,
			init = icons.misc.ManUp,
			import = icons.documents.Import,
			keys = icons.ui.Keyboard,
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
				"editorconfig",
				"spellfile",
			},
		},
	},
})

vim.o.background = "dark"
vim.cmd.colorscheme "rose-pine"
