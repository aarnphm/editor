local k = require "keybind"
return {
	-- Colorscheme
	["catppuccin/nvim"] = {
		as = "catppuccin",
		lazy = false,
		name = "catppuccin",
		config = require "ui.catppuccin",
	},
	["rose-pine/neovim"] = {
		as = "rose-pine",
		lazy = false,
		branch = "canary",
		name = "rose-pine",
		config = require "ui.rose-pine",
	},

	["nathom/filetype.nvim"] = { lazy = false },

	["akinsho/nvim-bufferline.lua"] = {
		lazy = true,
		branch = "main",
		event = { "BufReadPost", "BufAdd", "BufRead", "BufNewFile" },
		config = require "ui.nvim-bufferline",
		init = function()
			k.nvim_load_mapping {
				["n|<LocalLeader>p"] = k.map_cr("BufferLinePick"):with_defaults "buffer: Pick",
				["n|<Space>c"] = k.map_cr("BufferLinePickClose"):with_defaults "buffer: Close",
				["n|<Space>."] = k.map_cr("BufferLineCycleNext")
					:with_defaults "buffer: Cycle to next buffer",
				["n|<Space>,"] = k.map_cr("BufferLineCyclePrev")
					:with_defaults "buffer: Cycle to previous buffer",
				["n|<Space>1"] = k.map_cr("BufferLineGoToBuffer 1")
					:with_defaults "buffer: Goto buffer 1",
				["n|<Space>2"] = k.map_cr("BufferLineGoToBuffer 2")
					:with_defaults "buffer: Goto buffer 2",
				["n|<Space>3"] = k.map_cr("BufferLineGoToBuffer 3")
					:with_defaults "buffer: Goto buffer 3",
				["n|<Space>4"] = k.map_cr("BufferLineGoToBuffer 4")
					:with_defaults "buffer: Goto buffer 4",
				["n|<Space>5"] = k.map_cr("BufferLineGoToBuffer 5")
					:with_defaults "buffer: Goto buffer 5",
				["n|<Space>6"] = k.map_cr("BufferLineGoToBuffer 6")
					:with_defaults "buffer: Goto buffer 6",
				["n|<Space>7"] = k.map_cr("BufferLineGoToBuffer 7")
					:with_defaults "buffer: Goto buffer 7",
				["n|<Space>8"] = k.map_cr("BufferLineGoToBuffer 8")
					:with_defaults "buffer: Goto buffer 8",
				["n|<Space>9"] = k.map_cr("BufferLineGoToBuffer 9")
					:with_defaults "buffer: Goto buffer 9",
			}
		end,
	},
	["j-hui/fidget.nvim"] = {
		lazy = true,
		event = "BufRead",
		config = function()
			require("fidget").setup {
				text = {
					spinner = "dots",
				},
				window = { blend = 0 },
			}
		end,
	},

	["folke/todo-comments.nvim"] = {
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "BufRead",
		config = function() require("todo-comments").setup {} end,
		init = function()
			k.nvim_load_mapping {
				["n|<Space>tqf"] = k.map_cr("TodoQuickFix")
					:with_defaults "todo-comments: Open quickfix",
				["n|]t"] = k.map_callback(function() require("todo-comments").jump_next() end)
					:with_defaults "todo-comments: Next",
				["n|[t"] = k.map_callback(function() require("todo-comments").jump_prev() end)
					:with_defaults "todo-comments: Previous",
				["n|<Space>tt"] = k.map_cr("TodoTelescope"):with_defaults "todo-comments: Telescope",
			}
		end,
	},
	["lukas-reineke/indent-blankline.nvim"] = {
		lazy = true,
		event = "BufRead",
		config = require "ui.indent-blankline",
	},
	["zbirenbaum/neodim"] = { lazy = true, event = "LspAttach", config = require "ui.neodim" },
	["lewis6991/gitsigns.nvim"] = {
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = require "ui.gitsigns",
	},
	["goolord/alpha-nvim"] = {
		lazy = true,
		event = "BufWinEnter",
		config = require "ui.alpha-nvim",
		cond = function() return #vim.api.nvim_list_uis() > 0 end,
	},
	["nvim-lualine/lualine.nvim"] = {
		lazy = true,
		event = "VeryLazy",
		config = require "ui.lualine",
	},
	["kyazdani42/nvim-tree.lua"] = {
		cmd = {
			"NvimTreeToggle",
			"NvimTreeOpen",
			"NvimTreeFindFile",
			"NvimTreeFindFileToggle",
			"NvimTreeRefresh",
		},
		config = require "ui.nvim-tree",
		init = function()
			k.nvim_load_mapping {
				["n|<C-n>"] = k.map_cr("NvimTreeToggle"):with_defaults "file-explorer: Toggle",
				["n|<Leader>nf"] = k.map_cr("NvimTreeFindFile")
					:with_defaults "file-explorer: Find file",
				["n|<Leader>nr"] = k.map_cr("NvimTreeRefresh")
					:with_defaults "file-explorer: Refresh",
			}
		end,
	},
	["rcarriga/nvim-notify"] = {
		lazy = true,
		event = "VeryLazy",
		config = require "ui.nvim-notify",
		cond = function()
			return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype)
		end,
	},
}
