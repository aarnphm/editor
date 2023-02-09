local ui = {}

ui["nathom/filetype.nvim"] = { lazy = false }
ui["lewis6991/gitsigns.nvim"] = { lazy = true, event = { "BufRead", "BufNewFile" }, config = require "ui.gitsigns" }
ui["lukas-reineke/indent-blankline.nvim"] = { lazy = true, event = "BufRead", config = require "ui.indent-blankline" }
ui["akinsho/nvim-bufferline.lua"] =
	{ lazy = true, event = { "BufReadPost", "BufAdd", "BufNewFile" }, config = require "ui.nvim-bufferline" }

ui["zbirenbaum/neodim"] = {
	lazy = true,
	event = "LspAttach",
	config = require "ui.neodim",
}

ui["goolord/alpha-nvim"] = {
	lazy = true,
	event = "BufWinEnter",
	config = require "ui.alpha-nvim",
	cond = function() return #vim.api.nvim_list_uis() > 0 end,
}

ui["nvim-lualine/lualine.nvim"] = {
	lazy = true,
	event = "VeryLazy",
	config = require "ui.lualine",
}

ui["kyazdani42/nvim-tree.lua"] = {
	cmd = {
		"NvimTreeToggle",
		"NvimTreeOpen",
		"NvimTreeFindFile",
		"NvimTreeFindFileToggle",
		"NvimTreeRefresh",
	},
	config = require "ui.nvim-tree",
}
ui["rcarriga/nvim-notify"] = {
	lazy = true,
	event = "VeryLazy",
	config = require "ui.nvim-notify",
	cond = function() return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype) end,
}

ui["j-hui/fidget.nvim"] = {
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
}

ui["catppuccin/nvim"] = {
	as = "catppuccin",
	lazy = false,
	name = "catppuccin",
	config = require "ui.catppuccin",
	cond = function() return __editor_config.colorscheme == "catppuccin" end,
}
ui["rose-pine/neovim"] = {
	as = "rose-pine",
	lazy = false,
	name = "rose-pine",
	config = require "ui.rose-pine",
	cond = function() return __editor_config.colorscheme == "rose-pine" end,
}

return ui
