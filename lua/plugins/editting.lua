return {
	{ "jghauser/mkdir.nvim" },
	{
		"nmac427/guess-indent.nvim",
		event = { "CursorHold", "CursorHoldI" },
		config = function() require("guess-indent").setup {} end,
	},
	{
		"stevearc/dressing.nvim",
		event = "BufReadPost",
		config = function()
			require("dressing").setup {
				input = { enabled = true },
				select = {
					enabled = true,
					backend = "telescope",
					trim_prompt = true,
				},
			}
		end,
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
		"kylechui/nvim-surround",
		config = function() require("nvim-surround").setup() end,
	},
	{
		"numToStr/Comment.nvim",
		event = "BufReadPre",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			require("nvim-treesitter.configs").setup {
				context_commentstring = { enable = true, enable_autocmd = false },
			}

			require("Comment").setup {
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			}
		end,
	},
	{
		"max397574/better-escape.nvim",
		event = { "CursorHold", "CursorHoldI" },
		config = function() require("better_escape").setup { timeout = 200 } end,
	},
	{
		"echasnovski/mini.align",
		event = "BufReadPre",
		config = function() require("mini.align").setup() end,
	},
	{
		"gelguy/wilder.nvim",
		lazy = true,
		event = "CmdlineEnter",
		dependencies = { "romgrk/fzy-lua-native" },
		config = function()
			local wilder = require "wilder"
			wilder.setup { modes = { ":", "/", "?" } }
			wilder.set_option(
				"renderer",
				wilder.wildmenu_renderer {
					highlighter = wilder.basic_highlighter(),
					separator = " · ",
					left = { " ", wilder.wildmenu_spinner(), " " },
					right = { " ", wilder.wildmenu_index() },
				}
			)
		end,
	},
}
