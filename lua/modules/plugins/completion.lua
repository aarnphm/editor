local completion = {}

local disabled_filetypes = { "gitcommit", "gitrebase", "gitconfig" }

-- lspconfig
completion["neovim/nvim-lspconfig"] = {
	lazy = true,
	event = { "BufReadPost", "BufAdd", "BufNewFile" },
	config = require "completion.nvim-lspconfig",
	cond = function() return not vim.tbl_contains(disabled_filetypes, vim.bo.filetype) end,
	dependencies = {
		{ "creativenull/efmls-configs-nvim" },
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
		{
			"glepnir/lspsaga.nvim",
			config = require "completion.lspsaga",
			event = "BufRead",
			dependencies = { "nvim-tree/nvim-web-devicons" },
		},
		{ "WhoIsSethDaniel/mason-tool-installer.nvim", config = require "completion.mason-tool-installer" },
		{ "ray-x/lsp_signature.nvim" },
	},
}

completion["hrsh7th/nvim-cmp"] = {
	config = require "completion.nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			config = require "completion.luasnip",
			dependencies = { "rafamadriz/friendly-snippets" },
		},
		{ "onsails/lspkind.nvim" },
		{ "lukas-reineke/cmp-under-comparator" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-nvim-lua" },
		{ "hrsh7th/cmp-path" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-emoji" },
		{ "kdheepak/cmp-latex-symbols" },
		{ "f3fora/cmp-spell" },
		{ "windwp/nvim-autopairs", config = require "completion.nvim-autopairs" },
	},
}

completion["zbirenbaum/copilot.lua"] = {
	cmd = "Copilot",
	event = "InsertEnter",
	config = require "completion.copilot",
}

return completion
