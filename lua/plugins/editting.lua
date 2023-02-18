return {
	{ "jghauser/mkdir.nvim" },
	{ "ojroques/nvim-bufdel", cmd = { "BufDel" } },
	{ "lewis6991/impatient.nvim" },
	{ "nacro90/numb.nvim", config = true },
	{ "tpope/vim-repeat", event = "VeryLazy" },
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
		event = { "CursorHold", "CursorHoldI" },
		keys = { "gc", "gb" },
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
		"phaazon/hop.nvim",
		lazy = true,
		branch = "v2",
		event = { "CursorHold", "CursorHoldI" },
		config = true,
		keys = {
			{
				"<LocalLeader>w",
				"<cmd><C-u>HopWord<CR>",
				"jump: Goto word",
				noremap = true,
			},
			{
				"<LocalLeader>j",
				"<cmd><C-u>HopLine<CR>",
				"jump: Goto line",
				noremap = true,
			},
			{
				"<LocalLeader>k",
				"<cmd><C-u>HopLine<CR>",
				"jump: Goto line",
				noremap = true,
			},
			{
				"<LocalLeader>c",
				"<cmd><C-u>HopChar1<CR>",
				"jump: one char",
				noremap = true,
			},
			{
				"<LocalLeader>cc",
				"<cmd><C-u>HopChar2<CR>",
				"jump: one char",
				noremap = true,
			},
			{
				"f",
				function()
					local h = require "hop"
					local d = require("hop.hint").HintDirection
					h.hint_char1 { direction = d.AFTER_CURSOR, current_line_only = true }
				end,
				mode = "",
				remap = true,
				desc = "motion: f 1 char",
			},
			{
				"F",
				function()
					local h = require "hop"
					local d = require("hop.hint").HintDirection
					h.hint_char1 { direction = d.BEFORE_CURSOR, current_line_only = true }
				end,
				mode = "",
				remap = true,
				desc = "motion: F 1 char",
			},
			{
				"t",
				function()
					local h = require "hop"
					local d = require("hop.hint").HintDirection
					h.hint_char1 {
						direction = d.AFTER_CURSOR,
						current_line_only = true,
						hint_offset = -1,
					}
				end,
				mode = "",
				remap = true,
				desc = "motion: t 1 char",
			},
			{
				"T",
				function()
					local h = require "hop"
					local d = require("hop.hint").HintDirection
					h.hint_char1 {
						direction = d.BEFORE_CURSOR,
						current_line_only = true,
						hint_offset = 1,
					}
				end,
				mode = "",
				remap = true,
				desc = "motion: T 1 char",
			},
		},
	},
}
