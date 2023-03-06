return {
	{ "nvim-lua/plenary.nvim" },
	{ "ojroques/nvim-bufdel", cmd = { "BufDel" } },
	{ "tpope/vim-repeat", event = "VeryLazy" },
	{ "tpope/vim-fugitive", event = "VeryLazy", cmd = { "Git", "G" } },
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
		"windwp/nvim-autopairs",
		lazy = true,
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
		cmd = { "HopWord", "HopLine", "HopChar1", "HopChar2" },
		config = function()
			local h = require "hop"
			local hh = require "hop.hint"
			local k = require "zox.keybind"

			h.setup()

			k.nvim_register_mapping {
				["n|<LocalLeader>w"] = k.cr("HopWord"):with_defaults "jump: Goto word",
				["n|<LocalLeader>j"] = k.cr("HopLine"):with_defaults "jump: Goto line",
				["n|<LocalLeader>k"] = k.cr("HopLine"):with_defaults "jump: Goto line",
				["n|<LocalLeader>c"] = k.cr("HopChar1"):with_defaults "jump: one char",
				["n|<LocalLeader>cc"] = k.cr("HopChar2"):with_defaults "jump: two chars",
				["n|f"] = k.callback(
					function()
						h.hint_char1 {
							direction = hh.HintDirection.AFTER_CURSOR,
							current_line_only = true,
						}
					end
				):with_defaults "motion: forward inline to char",
				["n|<LocalLeader>f"] = k.cr("HopChar1AC")
					:with_defaults "jump: one char after cursor to eol",
				["n|F"] = k.callback(
					function()
						h.hint_char1 {
							direction = hh.HintDirection.BEFORE_CURSOR,
							current_line_only = true,
						}
					end
				):with_defaults "motion: backward inline to char",
				["n|<LocalLeader>F"] = k.cr("HopChar1BC")
					:with_defaults "jump: one char after cursor to eol",
				["n|t"] = k.callback(
					function()
						h.hint_char1 {
							direction = hh.HintDirection.AFTER_CURSOR,
							current_line_only = true,
							hint_offset = -1,
						}
					end
				):with_defaults "motion: forward inline one char before requested",
				["n|T"] = k.callback(
					function()
						h.hint_char1 {
							direction = hh.HintDirection.BEFORE_CURSOR,
							current_line_only = true,
							hint_offset = -1,
						}
					end
				):with_defaults "motion: backward inline one char before requested",
			}
		end,
	},
}
