local k = require "keybind"

---@class ToogleTermCmd toggleterm command cache object
---@field lazygit Terminal | nil
---@field btop Terminal | nil
---@field ipython Terminal | nil
local cmd = {
	lazygit = nil,
	btop = nil,
	ipython = nil,
}

return {
	--- NOTE: add stablize.nvim if you are not using nvim-nightly
	["tpope/vim-repeat"] = { lazy = true },
	["jinh0/eyeliner.nvim"] = { lazy = true, event = "BufReadPost" },
	["dstein64/vim-startuptime"] = { lazy = true, cmd = "StartupTime" },
	["romainl/vim-cool"] = { lazy = true, event = { "CursorMoved", "InsertEnter" } },
	["junegunn/vim-easy-align"] = {
		lazy = true,
		cmd = "EasyAlign",
		init = function()
			k.nvim_load_mapping {
				["n|gea"] = k.map_callback(function() return k.t "<Plug>(EasyAlign)" end)
					:with_expr()
					:with_desc "editn: Align by char",
				["x|gea"] = k.map_callback(function() return k.t "<Plug>(EasyAlign)" end)
					:with_expr()
					:with_desc "editn: Align by char",
			}
		end,
	},
	["tpope/vim-fugitive"] = {
		lazy = false,
		command = { "Git", "G", "Ggrep", "GBrowse" },
		init = function()
			k.nvim_load_mapping {
				["n|<LocalLeader>G"] = k.map_cr("G"):with_defaults():with_desc "git: Open git-fugitive",
				["n|<LocalLeader>gaa"] = k.map_cr("G add ."):with_defaults():with_desc "git: Add all files",
				["n|<LocalLeader>gcm"] = k.map_cr("G commit"):with_defaults():with_desc "git: Commit",
				["n|<LocalLeader>gps"] = k.map_cr("G push"):with_defaults():with_desc "git: push",
				["n|<LocalLeader>gpl"] = k.map_cr("G pull"):with_defaults():with_desc "git: pull",
			}
		end,
	},
	["sindrets/diffview.nvim"] = {
		lazy = true,
		cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
		init = function()
			k.nvim_load_mapping {
				["n|<LocalLeader>D"] = k.map_cr("DiffviewOpen"):with_defaults():with_desc "git: Show diff view",
				["n|<LocalLeader><LocalLeader>D"] = k.map_cr("DiffviewClose")
					:with_defaults()
					:with_desc "git: Close diff view",
			}
		end,
	},

	-- plugins with simple setup
	["ojroques/nvim-bufdel"] = {
		lazy = true,
		event = "BufReadPost",
		init = function()
			k.nvim_load_mapping {
				["n|<C-x>"] = k.map_cr("BufDel"):with_defaults():with_desc "bufdel: Delete current buffer",
			}
		end,
	},
	["nmac427/guess-indent.nvim"] = {
		lazy = true,
		event = "BufEnter",
		config = function() require("guess-indent").setup {} end,
	},
	["max397574/better-escape.nvim"] = {
		lazy = true,
		event = { "BufReadPost", "BufEnter" },
		config = function()
			require("better_escape").setup {
				mapping = { "jj", "jk" }, -- a table with mappings to use
				timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
				clear_empty_lines = true, -- clear line after escaping if there is only whitespace
				keys = "<Esc>", -- the keys to use for escaping
			}
		end,
	},
	["cshuaimin/ssr.nvim"] = {
		lazy = true,
		module = "ssr",
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
		end,
		init = function()
			k.nvim_load_mapping {
				["n|<LocalLeader>sr"] = k.map_callback(function() require("ssr").open() end)
					:with_defaults()
					:with_desc "edit: search and replace",
			}
		end,
	},
	["stevearc/dressing.nvim"] = {
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

	["RRethy/vim-illuminate"] = { lazy = true, event = "BufReadPost", config = require "editor.vim-illuminate" },
	["LunarVim/bigfile.nvim"] = {
		lazy = true,
		config = require "editor.bigfile",
		cond = __editor_config.load_big_files_faster,
	},
	["akinsho/toggleterm.nvim"] = {
		lazy = true,
		event = "UIEnter",
		config = require "editor.toggleterm",
		init = function()
			local program_term = function(name, opts)
				opts = opts or {}
				local path = require("utils").get_binary_path(name)

				if vim.tbl_contains(cmd, name) then
					if not cmd[name] then
						cmd[name] = require("toggleterm.terminal").Terminal:new(vim.tbl_extend("keep", opts, {
							cmd = path and path or name,
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
						string.format("[%s] not found!. Make sure to include it in PATH.", name),
						vim.log.levels.ERROR,
						{ title = "toggleterm.nvim" }
					)
				end
			end

			k.nvim_load_mapping {
				["n|<C-\\>"] = k.map_cr([[execute v:count . "ToggleTerm direction=horizontal"]])
					:with_defaults()
					:with_desc "terminal: Toggle horizontal",
				["i|<C-\\>"] = k.map_cmd("<Esc><Cmd>ToggleTerm direction=horizontal<CR>")
					:with_defaults()
					:with_desc "terminal: Toggle horizontal",
				["t|<C-\\>"] = k.map_cmd("<Esc><Cmd>ToggleTerm<CR>")
					:with_defaults()
					:with_desc "terminal: Toggle horizontal",
				["n|<C-w>t"] = k.map_cr([[execute v:count . "ToggleTerm direction=vertical"]])
					:with_defaults()
					:with_desc "terminal: Toggle vertical",
				["i|<C-w>t"] = k.map_cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>")
					:with_defaults()
					:with_desc "terminal: Toggle vertical",
				["t|<C-w>t"] = k.map_cmd("<Esc><Cmd>ToggleTerm<CR>")
					:with_defaults()
					:with_desc "terminal: Toggle vertical",
				["n|slg"] = k.map_callback(function() program_term "lazygit" end)
					:with_defaults()
					:with_desc "git: Toggle lazygit",
				["t|slg"] = k.map_callback(function() program_term "lazygit" end)
					:with_defaults()
					:with_desc "git: Toggle lazygit",
				["n|sbt"] = k.map_callback(function() program_term "btop" end)
					:with_defaults()
					:with_desc "git: Toggle btop",
				["t|sbt"] = k.map_callback(function() program_term "btop" end)
					:with_defaults()
					:with_desc "git: Toggle btop",
				["n|sipy"] = k.map_callback(function() program_term "ipython" end)
					:with_defaults()
					:with_desc "git: Toggle ipython",
				["t|sipy"] = k.map_callback(function() program_term "ipython" end)
					:with_defaults()
					:with_desc "git: Toggle ipython",
			}
		end,
	},
	["folke/which-key.nvim"] = { event = "VeryLazy", config = require "editor.which-key" },
	["folke/trouble.nvim"] = {
		lazy = true,
		cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
		config = require "editor.trouble",
		init = function()
			k.nvim_load_mapping {
				["n|gt"] = k.map_cr("TroubleToggle"):with_defaults():with_desc "lsp: Toggle trouble list",
				["n|gR"] = k.map_cr("TroubleToggle lsp_references"):with_defaults():with_desc "lsp: Show lsp references",
				["n|<LocalLeader>td"] = k.map_cr("TroubleToggle document_diagnostics")
					:with_defaults()
					:with_desc "lsp: Show document diagnostics",
				["n|<LocalLeader>tw"] = k.map_cr("TroubleToggle workspace_diagnostics")
					:with_defaults()
					:with_desc "lsp: Show workspace diagnostics",
				["n|<LocalLeader>tq"] = k.map_cr("TroubleToggle quickfix")
					:with_defaults()
					:with_desc "lsp: Show quickfix list",
				["n|<LocalLeader>tl"] = k.map_cr("TroubleToggle loclist"):with_defaults():with_desc "lsp: Show loclist",
			}
		end,
	},
	["gelguy/wilder.nvim"] = {
		lazy = true,
		event = "CmdlineEnter",
		config = require "editor.wilder",
		dependencies = { { "romgrk/fzy-lua-native" } },
	},
	["kylechui/nvim-surround"] = {
		lazy = false,
		config = function() require("nvim-surround").setup() end,
	},
	["phaazon/hop.nvim"] = {
		lazy = true,
		branch = "v2",
		event = "BufRead",
		config = function() require("hop").setup() end,
		init = function()
			k.nvim_load_mapping {
				["n|<LocalLeader>w"] = k.map_cu("HopWord"):with_noremap():with_desc "jump: Goto word",
				["n|<LocalLeader>j"] = k.map_cu("HopLine"):with_noremap():with_desc "jump: Goto line",
				["n|<LocalLeader>k"] = k.map_cu("HopLine"):with_noremap():with_desc "jump: Goto line",
				["n|<LocalLeader>c"] = k.map_cu("HopChar1"):with_noremap():with_desc "jump: Goto one char",
				["n|<LocalLeader>cc"] = k.map_cu("HopChar2"):with_noremap():with_desc "jump: Goto two chars",
			}
		end,
	},
	["pwntester/octo.nvim"] = {
		lazy = true,
		cmd = "Octo",
		config = function() require("octo").setup { default_remote = { "upstream", "origin" } } end,
		init = function()
			k.nvim_load_mapping {
				["n|<LocalLeader>ocpr"] = k.map_cr("Octo pr list"):with_noremap():with_desc "octo: List pull request",
			}
		end,
	},
	["numToStr/Comment.nvim"] = {
		lazy = true,
		event = { "BufNewFile", "BufReadPre" },
		config = require "editor.comment",
		init = function()
			k.nvim_load_mapping {
				["n|gcc"] = k.map_callback(
					function()
						return vim.v.count == 0 and k.t "<Plug>(comment_toggle_linewise_current)"
							or k.t "<Plug>(comment_toggle_linewise_count)"
					end
				)
					:with_defaults()
					:with_expr()
					:with_desc "editn: Toggle comment for line",
				["n|gbc"] = k.map_callback(
					function()
						return vim.v.count == 0 and k.t "<Plug>(comment_toggle_blockwise_current)"
							or k.t "<Plug>(comment_toggle_blockwise_count)"
					end
				)
					:with_defaults()
					:with_expr()
					:with_desc "editn: Toggle comment for block",
				["n|gc"] = k.map_cmd("<Plug>(comment_toggle_linewise)")
					:with_defaults()
					:with_desc "editn: Toggle comment for line with operator",
				["n|gb"] = k.map_cmd("<Plug>(comment_toggle_blockwise)")
					:with_defaults()
					:with_desc "editn: Toggle comment for block with operator",
				["x|gc"] = k.map_cmd("<Plug>(comment_toggle_linewise_visual)")
					:with_defaults()
					:with_desc "editx: Toggle comment for line with selection",
				["x|gb"] = k.map_cmd("<Plug>(comment_toggle_blockwise_visual)")
					:with_defaults()
					:with_desc "editx: Toggle comment for block with selection",
			}
		end,
	},
	["michaelb/sniprun"] = {
		lazy = true,
		-- You need to cd to `~/.local/share/nvim/site/lazy/sniprun/` and execute `bash ./install.sh`,
		-- if you encountered error about no executable sniprun found.
		build = "bash ./install.sh",
		cmd = { "SnipRun" },
		config = require "editor.sniprun",
		init = function()
			k.nvim_load_mapping {
				["v|<Leader>r"] = k.map_cr("SnipRun"):with_defaults():with_desc "tool: Run code by range",
				["n|<Leader>r"] = k.map_cu([[%SnipRun]]):with_defaults():with_desc "tool: Run code by file",
			}
		end,
	},
	["nvim-treesitter/nvim-treesitter"] = {
		lazy = true,
		build = ":TSUpdate",
		event = "BufReadPost",
		config = require "editor.nvim-treesitter",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects" },
			{ "romgrk/nvim-treesitter-context" },
			{ "JoosepAlviste/nvim-ts-context-commentstring" },
			{ "mfussenegger/nvim-treehopper" },
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
							-- Available modes: foreground, background
							-- Available modes for `mode`: foreground, background,  virtualtext
							mode = "background", -- Set the display mode.
							virtualtext = "■",
						},
					}
				end,
			},
		},
	},
	["mfussenegger/nvim-dap"] = {
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
		config = require "editor.nvim-dap",
		dependencies = { { "rcarriga/nvim-dap-ui", config = require "editor.nvim-dap-ui" } },
		init = function()
			k.nvim_load_mapping {
				["n|<F6>"] = k.map_callback(function() require("dap").continue() end)
					:with_defaults()
					:with_desc "debug: Run/Continue",
				["n|<F7>"] = k.map_callback(function()
					require("dap").terminate()
					require("dapui").close()
				end)
					:with_defaults()
					:with_desc "debug: Stop",
				["n|<F8>"] = k.map_callback(function() require("dap").toggle_breakpoint() end)
					:with_defaults()
					:with_desc "debug: Toggle breakpoint",
				["n|<F9>"] = k.map_callback(function() require("dap").step_into() end)
					:with_defaults()
					:with_desc "debug: Step into",
				["n|<F10>"] = k.map_callback(function() require("dap").step_out() end)
					:with_defaults()
					:with_desc "debug: Step out",
				["n|<F11>"] = k.map_callback(function() require("dap").step_over() end)
					:with_defaults()
					:with_desc "debug: Step over",
				["n|<Space>db"] = k.map_callback(
					function() require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ") end
				)
					:with_defaults()
					:with_desc "debug: Set breakpoint with condition",
				["n|<Space>dc"] = k.map_callback(function() require("dap").run_to_cursor() end)
					:with_defaults()
					:with_desc "debug: Run to cursor",
				["n|<Space>dl"] = k.map_callback(function() require("dap").run_last() end)
					:with_defaults()
					:with_desc "debug: Run last",
				["n|<Space>do"] = k.map_callback(function() require("dap").repl.open() end)
					:with_defaults()
					:with_desc "debug: Open REPL",
				["o|m"] = k.map_callback(function() require("tsht").nodes() end):with_silent(),
			}
		end,
	},
	["nvim-telescope/telescope.nvim"] = {
		cmd = "Telescope",
		lazy = true,
		event = "VeryLazy",
		config = require "editor.nvim-telescope",
		dependencies = {
			{ "nvim-tree/nvim-web-devicons" },
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-lua/popup.nvim" },
			{ "debugloop/telescope-undo.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "jvgrootveld/telescope-zoxide" },
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
		},
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

			k.nvim_load_mapping {
				["n|<Space>fo"] = k.map_cu("Telescope oldfiles"):with_defaults():with_desc "find: File by history",
				["n|<LocalLeader>fw"] = k.map_callback(require("utils").safegit_live_grep)
					:with_defaults()
					:with_desc "find: Word in current directory",
				["n|<Space>fw"] = k.map_callback(
					function() require("telescope").extensions.live_grep_args.live_grep_args {} end
				)
					:with_defaults()
					:with_desc "find: Word in project",
				["n|<Space>fb"] = k.map_cu("Telescope buffers"):with_defaults():with_desc "find: Buffer opened",
				["n|<Space>ff"] = k.map_cu("Telescope find_files"):with_defaults():with_desc "find: File in project",
				["n|<LocalLeader>ff"] = k.map_callback(require("utils").safegit_find_files)
					:with_defaults()
					:with_desc "find: file in git project",
				["n|<Space>fz"] = k.map_cu("Telescope zoxide list")
					:with_defaults()
					:with_desc "editn: Change current direrctory by zoxide",
				["n|<Space>fu"] = k.map_callback(function() require("telescope").extensions.undo.undo() end)
					:with_defaults()
					:with_desc "editn: Show undo history",
				["n|<Space>fc"] = k.map_cu("Telescope colorscheme")
					:with_defaults()
					:with_desc "ui: Change colorscheme for current session",
				["n|<Space>fs"] = k.map_cu("Telescope grep_string")
					:with_noremap()
					:with_silent()
					:with_desc "find: Current word",
				["n|<LocalLeader>fn"] = k.map_cu("enew"):with_defaults():with_desc "buffer: New",
				["n|<C-p>"] = k.map_callback(command_panel):with_defaults():with_desc "tools: Show keymap legends",
			}
		end,
	},
}
