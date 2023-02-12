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
	["jghauser/mkdir.nvim"] = { lazy = false },
	["tpope/vim-repeat"] = { lazy = true },
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
		config = require "editor.which-key",
	},
	["gelguy/wilder.nvim"] = {
		lazy = true,
		event = "CmdlineEnter",
		config = require "editor.wilder",
		dependencies = { "romgrk/fzy-lua-native" },
	},
	["ibhagwan/smartyank.nvim"] = {
		lazy = true,
		event = "BufReadPost",
		config = require "editor.smartyank",
	},
	["kylechui/nvim-surround"] = {
		lazy = false,
		config = function() require("nvim-surround").setup() end,
	},
	["nvim-pack/nvim-spectre"] = {
		lazy = true,
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
		lazy = true,
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
		lazy = false,
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
		config = require "editor.vim-illuminate",
	},
	["LunarVim/bigfile.nvim"] = {
		lazy = true,
		config = require "editor.bigfile",
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
		config = require "editor.toggleterm",
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
		config = require "editor.trouble",
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
		config = function() require("hop").setup { keys = "etovxqpdygfblzhckisuran" } end,
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
		config = require "editor.comment",
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
		config = require "editor.nvim-treesitter",
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
		config = require "editor.nvim-dap",
		dependencies = { { "rcarriga/nvim-dap-ui", config = require "editor.nvim-dap-ui" } },
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
		config = require "editor.nvim-telescope",
		dependencies = {
			{ "nvim-tree/nvim-web-devicons" },
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-lua/popup.nvim" },
			{ "debugloop/telescope-undo.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			{ "jvgrootveld/telescope-zoxide" },
			{ "nvim-telescope/telescope-live-grep-args.nvim" },
			{ "ahmedkhalf/project.nvim", event = "BufReadPost", config = require "editor.project" },
			{ "nvim-telescope/telescope-frecency.nvim", dependencies = { "kkharji/sqlite.lua" } },
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
				["n|<Leader>f"] = k.callback(
					function()
						require("telescope.builtin").find_files {
							previewer = false,
							shorten_path = true,
							layout_strategy = "horizontal",
							find_command = 1 == vim.fn.executable "fd"
									and { "fd", "-t", "f", "-H", "-E", ".git", "--strip-cwd-prefix" }
								or nil,
						}
					end
				):with_defaults "find: file in project",
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
