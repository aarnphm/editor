local editor = {}

--- NOTE: add stablize.nvim if you are not using nvim-nightly
editor["tpope/vim-repeat"] = { lazy = true }
editor["jinh0/eyeliner.nvim"] = { lazy = true, event = "BufReadPost" }
editor["junegunn/vim-easy-align"] = { lazy = true, cmd = "EasyAlign" }
editor["ojroques/nvim-bufdel"] = { lazy = true, event = "BufReadPost" }
editor["dstein64/vim-startuptime"] = { lazy = true, cmd = "StartupTime" }
editor["romainl/vim-cool"] = { lazy = true, event = { "CursorMoved", "InsertEnter" } }
editor["tpope/vim-fugitive"] = { lazy = false, command = { "Git", "G", "Ggrep", "GBrowse" } }
editor["sindrets/diffview.nvim"] = {
	lazy = true,
	cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
	dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
}
editor["nmac427/guess-indent.nvim"] = {
	lazy = true,
	event = "BufEnter",
	config = function() require("guess-indent").setup {} end,
}
editor["max397574/better-escape.nvim"] = {
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
}
editor["cshuaimin/ssr.nvim"] = {
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
}
editor["stevearc/dressing.nvim"] = {
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
}

editor["RRethy/vim-illuminate"] = { lazy = true, event = "BufReadPost", config = require "editor.vim-illuminate" }
editor["LunarVim/bigfile.nvim"] =
	{ lazy = true, config = require "editor.bigfile", cond = __editor_config.load_big_files_faster }
editor["akinsho/nvim-toggleterm.lua"] = { lazy = true, event = "UIEnter", config = require "editor.nvim-toggleterm" }
editor["folke/which-key.nvim"] = { event = "VeryLazy", config = require "editor.which-key" }
editor["folke/trouble.nvim"] = {
	lazy = true,
	cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
	config = require "editor.trouble",
}
editor["gelguy/wilder.nvim"] = {
	lazy = true,
	event = "CmdlineEnter",
	config = require "editor.wilder",
	dependencies = { { "romgrk/fzy-lua-native" } },
}
editor["kylechui/nvim-surround"] = {
	lazy = false,
	config = function() require("nvim-surround").setup() end,
}
editor["phaazon/hop.nvim"] = {
	lazy = true,
	branch = "v2",
	event = "BufRead",
	config = function() require("hop").setup() end,
}
editor["pwntester/octo.nvim"] = {
	lazy = true,
	config = function() require("octo").setup { default_remote = { "upstream", "origin" } } end,
	cmd = "Octo",
}
editor["numToStr/Comment.nvim"] = {
	lazy = true,
	event = { "BufNewFile", "BufReadPre" },
	config = require "editor.comment",
}

editor["michaelb/sniprun"] = {
	lazy = true,
	-- You need to cd to `~/.local/share/nvim/site/lazy/sniprun/` and execute `bash ./install.sh`,
	-- if you encountered error about no executable sniprun found.
	build = "bash ./install.sh",
	cmd = { "SnipRun" },
	config = require "editor.sniprun",
}

editor["nvim-treesitter/nvim-treesitter"] = {
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
}

editor["mfussenegger/nvim-dap"] = {
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
	dependencies = {
		{
			"rcarriga/nvim-dap-ui",
			config = require "editor.nvim-dap.nvim-dap-ui",
		},
	},
}

editor["nvim-telescope/telescope.nvim"] = {
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
	},
}

return editor
