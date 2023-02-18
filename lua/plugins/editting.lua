return {
	{ "jghauser/mkdir.nvim" },
	{ "ojroques/nvim-bufdel" },
	{ "lewis6991/impatient.nvim" },
	{ "tpope/vim-repeat", event = "VeryLazy" },
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
		},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true,
			enable_check_bracket_line = false,
			fast_wrap = {
				map = "<C-b>",
				chars = { "{", "[", "(", "\"", "'" },
				pattern = [=[[%'%"%)%>%]%)%}%,]]=],
				end_key = "$",
				keys = "qwertyuiopzxcvbnmasdfghjkl",
				highlight = "LightspeedShortcut",
				highlight_grey = "LightspeedGreyWash",
			},
		},
	},
	{
		"numToStr/Comment.nvim",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = true,
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
