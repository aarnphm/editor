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
		name = "rose-pine",
		config = require "ui.rose-pine",
	},

	["nathom/filetype.nvim"] = { lazy = false },

	["akinsho/nvim-bufferline.lua"] = {
		lazy = true,
		event = { "BufReadPost", "BufAdd", "BufNewFile" },
		config = require "ui.nvim-bufferline",
		init = function()
			k.nvim_load_mapping {
				["n|<Space>bp"] = k.map_cr("BufferLinePick"):with_defaults():with_desc "buffer: Pick",
				["n|<Space>bc"] = k.map_cr("BufferLinePickClose"):with_defaults():with_desc "buffer: Close",
				["n|<Space>be"] = k.map_cr("BufferLineSortByExtension")
					:with_noremap()
					:with_desc "buffer: Sort by extension",
				["n|<Space>bd"] = k.map_cr("BufferLineSortByDirectory")
					:with_noremap()
					:with_desc "buffer: Sort by direrctory",
				["n|<Space>."] = k.map_cr("BufferLineCycleNext")
					:with_defaults()
					:with_desc "buffer: Cycle to next buffer",
				["n|<Space>n"] = k.map_cr("BufferLineCyclePrev")
					:with_defaults()
					:with_desc "buffer: Cycle to previous buffer",
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

	["lukas-reineke/indent-blankline.nvim"] = { lazy = true, event = "BufRead", config = require "ui.indent-blankline" },
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
	["nvim-lualine/lualine.nvim"] = { lazy = true, event = "VeryLazy", config = require "ui.lualine" },
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
				["n|<C-n>"] = k.map_cr("NvimTreeToggle"):with_defaults():with_desc "file-explorer: Toggle",
				["n|<Leader>nf"] = k.map_cr("NvimTreeFindFile"):with_defaults():with_desc "file-explorer: Find file",
				["n|<Leader>nr"] = k.map_cr("NvimTreeRefresh"):with_defaults():with_desc "file-explorer: Refresh",
			}
		end,
	},
	["rcarriga/nvim-notify"] = {
		lazy = true,
		event = "VeryLazy",
		config = require "ui.nvim-notify",
		cond = function() return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype) end,
	},
}
