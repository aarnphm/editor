return {
	{ "jghauser/mkdir.nvim" },
	{
		"nmac427/guess-indent.nvim",
		event = { "CursorHold", "CursorHoldI" },
		config = true,
		lazy = true,
	},
	{
		"max397574/better-escape.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		opts = { timeout = 200 },
	},
	{
		"folke/which-key.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		opts = {
			plugins = {
				presets = {
					operators = false,
					motions = false,
					text_objects = false,
					windows = false,
					nav = false,
					z = false,
					g = false,
				},
			},
			icons = {
				breadcrumb = require("zox").ui.Separator,
				separator = require("zox").misc.Vbar,
				group = require("zox").misc.Add,
			},
			key_labels = {
				["<space>"] = "SPC",
				["<cr>"] = "RET",
				["<tab>"] = "TAB",
			},
			hidden = {
				"<silent>",
				"<Cmd>",
				"<cmd>",
				"<Plug>",
				"call",
				"lua",
				"^:",
				"^ ",
			}, -- hide mapping boilerplate
			disable = { filetypes = { "help", "lspsagaoutine", "_sagaoutline" } },
		},
	},
	{
		"stevearc/dressing.nvim",
		lazy = true,
		event = "BufReadPost",
		opts = {
			input = { enabled = true },
			select = {
				enabled = true,
				backend = "telescope",
				trim_prompt = true,
			},
		},
	},
	{
		"ojroques/nvim-bufdel",
		event = "BufReadPost",
		config = function()
			local k = require "zox.keybind"
			k.nvim_register_mapping {
				["n|<C-x>"] = k.cr("BufDel"):with_defaults "bufdel: Delete current buffer",
			}
		end,
	},
	{
		"numToStr/Comment.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			require("Comment").setup {
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			}
		end,
	},
	{
		"echasnovski/mini.align",
		lazy = true,
		event = "BufReadPre",
		config = function() require("mini.align").setup() end,
	},
	{
		"echasnovski/mini.surround",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = function() require("mini.surround").setup() end,
	},
}
