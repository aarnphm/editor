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
local icons = {
	ui = require("icons").get "ui",
	ui_space = require("icons").get("ui", true),
	misc = require("icons").get "misc",
	diagnostics = require("icons").get "diagnostics",
	dap = require("icons").get "dap",
}

return {
	--- NOTE: add stablize.nvim if you are not using nvim-nightly
	["jghauser/mkdir.nvim"] = { lazy = false },
	["dstein64/vim-startuptime"] = { lazy = true, cmd = "StartupTime" },
	["romainl/vim-cool"] = { lazy = true, event = { "CursorMoved", "InsertEnter" } },
	["nmac427/guess-indent.nvim"] = {
		lazy = true,
		event = "BufEnter",
		config = function() require("guess-indent").setup {} end,
	},
	["folke/which-key.nvim"] = {
		lazy = true,
		event = "VeryLazy",
		config = function()
			require("which-key").setup {
				plugins = {
					presets = { operators = false, motions = true, text_objects = false, windows = false, nav = false },
				},
				icons = { breadcrumb = icons.ui.Separator, separator = icons.misc.Vbar, group = icons.misc.Add },
				window = {
					border = "none",
					position = "bottom",
					margin = { 1, 0, 1, 0 },
					padding = { 1, 1, 1, 1 },
					winblend = 0,
				},
				disable = {
					filetypes = { "help", "lspsagaoutine", "_sagaoutline" },
				},
			}
		end,
	},
	["ibhagwan/smartyank.nvim"] = {
		lazy = true,
		event = "BufReadPost",
		config = function()
			require("smartyank").setup {
				highlight = { enabled = false },
				tmux = { enabled = false },
				osc52 = { enabled = false },
			}
		end,
	},
	["gelguy/wilder.nvim"] = {
		lazy = true,
		event = "CmdlineEnter",
		config = require "editting.wilder",
		dependencies = { "romgrk/fzy-lua-native" },
	},
	["kylechui/nvim-surround"] = {
		lazy = true,
		event = "InsertEnter",
		config = function() require("nvim-surround").setup() end,
	},
	["nvim-pack/nvim-spectre"] = {
		module = "spectre",
		build = "./build.sh",
		config = function()
			require("spectre").setup {
				live_update = true,
				default = {
					replace = { cmd = not require("editor").global.is_mac and "oxi" or "sed" },
				},
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
		end,
		init = function()
			k.nvim_register_mapping {
				["n|<Leader>sv"] = k.callback(function() require("spectre").open_visual() end)
					:with_defaults "replace: Open visual replace",
				["n|<Leader>so"] = k.callback(function() require("spectre").open() end)
					:with_defaults "replace: Open panel",
				["n|<Leader>sw"] = k.callback(function() require("spectre").open_visual { select_word = true } end)
					:with_defaults "replace: Replace word under cursor",
				["n|<Leader>sp"] = k.callback(function() require("spectre").open_file_search() end)
					:with_defaults "replace: Replace word under file search",
			}
		end,
	},
	["junegunn/vim-easy-align"] = {
		cmd = "EasyAlign",
		init = function()
			k.nvim_register_mapping {
				["n|gea"] = k.callback(function() return k.replace_termcodes "<Plug>(EasyAlign)" end)
					:with_expr()
					:with_desc "edit: Align by char",
				["x|gea"] = k.callback(function() return k.replace_termcodes "<Plug>(EasyAlign)" end)
					:with_expr()
					:with_desc "edit: Align by char",
			}
		end,
	},
	["tpope/vim-fugitive"] = {
		command = { "Git", "G", "Ggrep", "GBrowse" },
		init = function()
			k.nvim_register_mapping {
				["n|<LocalLeader>G"] = k.cr("G"):with_defaults "git: Open git-fugitive",
				["n|<LocalLeader>gaa"] = k.cr("G add ."):with_defaults "git: Add all files",
				["n|<LocalLeader>gcm"] = k.cr("G commit"):with_defaults "git: Commit",
				["n|<LocalLeader>gps"] = k.cr("G push"):with_defaults "git: push",
				["n|<LocalLeader>gpl"] = k.cr("G pull"):with_defaults "git: pull",
			}
		end,
	},
	["sindrets/diffview.nvim"] = {
		lazy = true,
		cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
		init = function()
			k.nvim_register_mapping {
				["n|<LocalLeader>D"] = k.cr("DiffviewOpen"):with_defaults "git: Show diff view",
				["n|<LocalLeader><LocalLeader>D"] = k.cr("DiffviewClose"):with_defaults "git: Close diff view",
			}
		end,
	},
	-- plugins with simple setup
	["ojroques/nvim-bufdel"] = {
		lazy = true,
		event = "BufReadPost",
		init = function()
			k.nvim_register_mapping {
				["n|<C-x>"] = k.cr("BufDel"):with_defaults "bufdel: Delete current buffer",
			}
		end,
	},
	["max397574/better-escape.nvim"] = {
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = function()
			require("better_escape").setup {
				mapping = { "jj", "jk" }, -- a table with mappings to use
				timeout = 200, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
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
			k.nvim_register_mapping {
				["n|<LocalLeader>sr"] = k.callback(function() require("ssr").open() end)
					:with_defaults "edit: search and replace",
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
	["RRethy/vim-illuminate"] = {
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = function()
			require("illuminate").configure {
				filetypes_denylist = {
					"alpha",
					"dashboard",
					"DoomInfo",
					"startuptime",
					"fugitive",
					"help",
					"norg",
					"NvimTree",
					"Outline",
					"lspsagafinder",
					"toggleterm",
				},
			}
		end,
	},
	["LunarVim/bigfile.nvim"] = {
		lazy = true,
		config = function()
			require("bigfile").config {
				filesize = 1, -- size of the file in MiB
				pattern = { "*" }, -- autocmd pattern
				features = { -- features to disable
					"indent_blankline",
					"lsp",
					"illuminate",
					"treesitter",
					"syntax",
					"vimopts",
					{
						name = "ftdetect",
						opts = { defer = true },
						disable = function()
							vim.api.nvim_set_option_value("filetype", "big_file_disabled_ft", { scope = "local" })
						end,
					},
					{
						name = "nvim-cmp",
						opts = { defer = true },
						disable = function() require("cmp").setup.buffer { enabled = false } end,
					},
				},
			}
		end,
		cond = require("editor").config.load_big_files_faster,
	},
	["akinsho/toggleterm.nvim"] = {
		lazy = true,
		cmd = {
			"ToggleTerm",
			"ToggleTermSetName",
			"ToggleTermToggleAll",
			"ToggleTermSendVisualLines",
			"ToggleTermSendCurrentLine",
			"ToggleTermSendVisualSelection",
		},
		config = function()
			require("toggleterm").setup {
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
				open_mapping = false, -- [[<C-t>]],
				shade_terminals = false,
				shading_factor = vim.o.background == "dark" and "1" or "3",
				direction = "horizontal",
			}
		end,
		init = function()
			local program_term = function(name, opts)
				opts = opts or {}
				local path = require("utils").get_binary_path(name)

				if path then
					if not cmd[name] then
						cmd[name] = require("toggleterm.terminal").Terminal:new(vim.tbl_extend("keep", opts, {
							cmd = path,
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
						string.format("'%s' not found!. Make sure to include it in PATH.", name),
						vim.log.levels.ERROR,
						{ title = "toggleterm.nvim" }
					)
				end
			end

			k.nvim_register_mapping {
				["n|<C-\\>"] = k.cr([[execute v:count . "ToggleTerm direction=horizontal"]])
					:with_defaults "terminal: Toggle horizontal",
				["i|<C-\\>"] = k.cmd("<Esc><Cmd>ToggleTerm direction=horizontal<CR>")
					:with_defaults "terminal: Toggle horizontal",
				["t|<C-\\>"] = k.cmd("<Esc><Cmd>ToggleTerm<CR>"):with_defaults "terminal: Toggle horizontal",
				["n|<C-t>"] = k.cr([[execute v:count . "ToggleTerm direction=vertical"]])
					:with_defaults "terminal: Toggle vertical",
				["i|<C-t>"] = k.cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>")
					:with_defaults "terminal: Toggle vertical",
				["t|<C-t>"] = k.cmd("<Esc><Cmd>ToggleTerm<CR>"):with_defaults "terminal: Toggle vertical",
				["n|slg"] = k.callback(function() program_term "lazygit" end):with_defaults "git: Toggle lazygit",
				["t|slg"] = k.callback(function() program_term "lazygit" end):with_defaults "git: Toggle lazygit",
				["n|sbt"] = k.callback(function() program_term "btop" end):with_defaults "git: Toggle btop",
				["t|sbt"] = k.callback(function() program_term "btop" end):with_defaults "git: Toggle btop",
				["n|sipy"] = k.callback(function() program_term "ipython" end):with_defaults "git: Toggle ipython",
				["t|sipy"] = k.callback(function() program_term "ipython" end):with_defaults "git: Toggle ipython",
			}
		end,
	},
	["folke/trouble.nvim"] = {
		lazy = true,
		cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
		config = function()
			require("trouble").setup {
				position = "left", -- position of the list can be: bottom, top, left, right
				mode = "document_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
				fold_open = icons.ui.ArrowOpen, -- icon used for open folds
				fold_closed = icons.ui.ArrowClosed, -- icon used for closed folds
				auto_close = true, -- automatically close the list when you have no diagnostics
				auto_fold = false, -- automatically fold a file trouble list at creation
				auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
				signs = {
					-- icons / text used for a diagnostic
					error = icons.diagnostics.ErrorHolo,
					warning = icons.diagnostics.WarningHolo,
					hint = icons.diagnostics.HintHolo,
					information = icons.diagnostics.InformationHolo,
					other = icons.diagnostics.QuestionHolo,
				},
				use_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
			}
		end,
		init = function()
			k.nvim_register_mapping {
				["n|gt"] = k.cr("TroubleToggle"):with_defaults "lsp: Toggle trouble list",
				["n|gR"] = k.cr("TroubleToggle lsp_references"):with_defaults "lsp: Show lsp references",
				["n|<LocalLeader>td"] = k.cr("TroubleToggle document_diagnostics")
					:with_defaults "lsp: Show document diagnostics",
				["n|<LocalLeader>tw"] = k.cr("TroubleToggle workspace_diagnostics")
					:with_defaults "lsp: Show workspace diagnostics",
				["n|<LocalLeader>tq"] = k.cr("TroubleToggle quickfix"):with_defaults "lsp: Show quickfix list",
				["n|<LocalLeader>tl"] = k.cr("TroubleToggle loclist"):with_defaults "lsp: Show loclist",
			}
		end,
	},
	["phaazon/hop.nvim"] = {
		lazy = true,
		branch = "v2",
		event = "BufRead",
		config = function() require("hop").setup() end,
		cond = function() return not vim.tbl_contains({ "nofile" }, vim.bo.filetype) end,
		init = function()
			-- set f/F to use hop
			local hop = require "hop"
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
				["n|<LocalLeader>c"] = k.cu("HopChar1"):with_noremap():with_desc "jump: Goto one char",
				["n|<LocalLeader>cc"] = k.cu("HopChar2"):with_noremap():with_desc "jump: Goto two chars",
			}
		end,
	},
	["pwntester/octo.nvim"] = {
		lazy = true,
		cmd = "Octo",
		config = function() require("octo").setup { default_remote = { "upstream", "origin" } } end,
		init = function()
			k.nvim_register_mapping {
				["n|<Leader>o"] = k.args("Octo"):with_defaults "octo: List pull request",
			}
		end,
	},
	["numToStr/Comment.nvim"] = {
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = function()
			require("Comment").setup {
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			}
		end,
		init = function()
			k.nvim_register_mapping {
				["n|gcc"] = k.callback(
					function()
						return vim.v.count == 0 and k.replace_termcodes "<Plug>(comment_toggle_linewise_current)"
							or k.replace_termcodes "<Plug>(comment_toggle_linewise_count)"
					end
				)
					:with_expr()
					:with_defaults "edit: Toggle comment for line",
				["n|gbc"] = k.callback(
					function()
						return vim.v.count == 0 and k.replace_termcodes "<Plug>(comment_toggle_blockwise_current)"
							or k.replace_termcodes "<Plug>(comment_toggle_blockwise_count)"
					end
				)
					:with_expr()
					:with_defaults "edit: Toggle comment for block",
				["n|gc"] = k.cmd("<Plug>(comment_toggle_linewise)")
					:with_defaults "edit: Toggle comment for line with operator",
				["n|gb"] = k.cmd("<Plug>(comment_toggle_blockwise)")
					:with_defaults "edit: Toggle comment for block with operator",
				["x|gc"] = k.cmd("<Plug>(comment_toggle_linewise_visual)")
					:with_defaults "edit: Toggle comment for line with selection",
				["x|gb"] = k.cmd("<Plug>(comment_toggle_blockwise_visual)")
					:with_defaults "edit: Toggle comment for block with selection",
			}
		end,
	},
	["nvim-treesitter/nvim-treesitter"] = {
		lazy = true,
		build = function()
			if #vim.api.nvim_list_uis() ~= 0 then vim.api.nvim_command "TSUpdate" end
		end,
		event = { "CursorHold", "CursorHoldI" },
		config = require "editting.nvim-treesitter",
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects" },
			{ "romgrk/nvim-treesitter-context" },
			{ "mrjones2014/nvim-ts-rainbow" },
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
		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				config = function()
					require("dapui").setup {
						icons = {
							expanded = icons.ui.ArrowOpen,
							collapsed = icons.ui.ArrowClosed,
							current_frame = icons.ui.Indicator,
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
								pause = icons.dap.Pause,
								play = icons.dap.Play,
								step_into = icons.dap.StepInto,
								step_over = icons.dap.StepOver,
								step_out = icons.dap.StepOut,
								step_back = icons.dap.StepBack,
								run_last = icons.dap.RunLast,
								terminate = icons.dap.Terminate,
							},
						},
						windows = { indent = 1 },
					}
				end,
			},
		},
		config = function()
			local dap = require "dap"
			local dapui = require "dapui"

			dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
			dap.listeners.after.event_terminated["dapui_config"] = function() dapui.close() end
			dap.listeners.after.event_exited["dapui_config"] = function() dapui.close() end

			-- We need to override nvim-dap's default highlight groups, AFTER requiring nvim-dap for catppuccin.
			-- vim.api.nvim_set_hl(0, "DapStopped", { fg = colors.green })

			for _, v in ipairs { "Breakpoint", "BreakpointRejected", "BreakpointCondition", "LogPoint", "DapStopped" } do
				vim.fn.sign_define("Dap" .. v, { text = icons.dap[v], texthl = "Dap" .. v, line = "", numhl = "" })
			end

			-- Config lang adaptors
			for _, dbg in ipairs { "lldb", "debugpy", "dlv" } do
				local ok, _ = pcall(require, "editting.lang-adapters.dap-" .. dbg)
				if not ok then
					vim.notify_once("Failed to load dap-" .. dbg, vim.log.levels.ERROR, { title = "dap.nvim" })
				end
			end
		end,
		init = function()
			k.nvim_register_mapping {
				["n|<F6>"] = k.callback(function() require("dap").continue() end):with_defaults "debug: Run/Continue",
				["n|<F7>"] = k.callback(function()
					require("dap").terminate()
					require("dapui").close()
				end):with_defaults "debug: Stop",
				["n|<F8>"] = k.callback(function() require("dap").toggle_breakpoint() end)
					:with_defaults "debug: Toggle breakpoint",
				["n|<F9>"] = k.callback(function() require("dap").step_into() end):with_defaults "debug: Step into",
				["n|<F10>"] = k.callback(function() require("dap").step_out() end):with_defaults "debug: Step out",
				["n|<F11>"] = k.callback(function() require("dap").step_over() end):with_defaults "debug: Step over",
				["n|<Leader>db"] = k.callback(
					function() require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ") end
				):with_defaults "debug: Set breakpoint with condition",
				["n|<Leader>dc"] = k.callback(function() require("dap").run_to_cursor() end)
					:with_defaults "debug: Run to cursor",
				["n|<Leader>dl"] = k.callback(function() require("dap").run_last() end):with_defaults "debug: Run last",
				["n|<Leader>do"] = k.callback(function() require("dap").repl.open() end)
					:with_defaults "debug: Open REPL",
				["o|m"] = k.callback(function() require("tsht").nodes() end):with_silent(),
			}
		end,
	},
	["nvim-telescope/telescope.nvim"] = {
		cmd = "Telescope",
		lazy = true,
		dependencies = {
			{ "nvim-tree/nvim-web-devicons" },
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-lua/popup.nvim" },
			{ "debugloop/telescope-undo.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "jvgrootveld/telescope-zoxide" },
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
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
			{ "nvim-telescope/telescope-frecency.nvim", dependencies = { "kkharji/sqlite.lua" } },
		},
		config = function()
			require("telescope").setup(vim.tbl_deep_extend("keep", require("editor").config.plugins.telescope, {
				defaults = {
					prompt_prefix = " " .. icons.ui_space.Telescope .. " ",
					selection_caret = icons.ui_space.ChevronRight,
					borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
					scroll_strategy = "limit",
					layout_strategy = "horizontal",
					path_display = { "absolute" },
					results_title = false,
					mappings = {
						i = {
							["<C-a>"] = { "<esc>0i", type = "command" },
							["<Esc>"] = require("telescope.actions").close,
						},
						n = { ["q"] = require("telescope.actions").close },
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
					generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
				},
				extensions = {
					undo = { side_by_side = true },
					fzf = {
						fuzzy = false,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
					frecency = {
						show_scores = true,
						show_unindexed = true,
						ignore_patterns = { "*.git/*", "*/tmp/*", "*/lazy-lock.json" },
					},
					live_grep_args = {
						auto_quoting = true,
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
			}))

			for _, v in ipairs { "fzf", "projects", "frecency", "live_grep_args", "zoxide", "notify", "undo" } do
				require("telescope").load_extension(v)
			end
		end,
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

			k.nvim_register_mapping {
				["n|<Leader>w"] = k.callback(
					function() require("telescope").extensions.live_grep_args.live_grep_args {} end
				)
					:with_defaults "find: Word in project",
				["n|<Leader>r"] = k.callback(function() require("telescope").extensions.frecency.frecency() end)
					:with_defaults "find: File by frecency",
				["n|<Leader>b"] = k.cu("Telescope buffers"):with_defaults "find: Buffer opened",
				["n|<Leader>\\"] = k.callback(function() require("telescope").extensions.projects.projects {} end)
					:with_defaults "find: Project",
				["n|<Leader>f"] = k.callback(function() require("utils").find_files(false) end)
					:with_defaults "find: file in project",
				["n|<Leader>'"] = k.cu("Telescope zoxide list")
					:with_defaults "edit: Change current direrctory by zoxide",
				["n|<Leader>u"] = k.callback(function() require("telescope").extensions.undo.undo() end)
					:with_defaults "edit: Show undo history",
				["n|<Leader>/"] = k.cu("Telescope grep_string"):with_defaults "find: Current word",
				["n|<Leader>n"] = k.cu("enew"):with_defaults "buffer: New",
				["n|<C-p>"] = k.callback(command_panel):with_defaults "tools: Show keymap legends",
				["n|<LocalLeader>e"] = k.callback(
					function() require("utils").find_files { cwd = vim.fn.stdpath "config" } end
				)
					:with_defaults "tools: edit NVIM config",
			}
		end,
	},
}
