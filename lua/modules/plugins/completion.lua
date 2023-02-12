local k = require "keybind"
local disabled_filetypes = { "gitcommit", "gitrebase", "gitconfig" }

return {
	-- lspconfig
	["neovim/nvim-lspconfig"] = {
		lazy = true,
		event = { "BufAdd", "BufReadPost", "BufNewFile" },
		config = require "completion.nvim-lspconfig",
		cond = function() return not vim.tbl_contains(disabled_filetypes, vim.bo.filetype) end,
		dependencies = {
			{ "williamboman/mason.nvim" },
			{ "ray-x/lsp_signature.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			{
				"jose-elias-alvarez/null-ls.nvim",
				dependencies = { "nvim-lua/plenary.nvim", "jayp0521/mason-null-ls.nvim" },
				config = require "completion.null-ls",
			},
			{
				"glepnir/lspsaga.nvim",
				config = require "completion.lspsaga",
				event = { "BufRead", "BufReadPost" },
				dependencies = { "nvim-tree/nvim-web-devicons" },
				init = function()
					k.nvim_load_mapping {
						["n|go"] = k.map_cr("Lspsaga outline"):with_defaults "lsp: Toggle outline",
						["n|g["] = k.map_cr("Lspsaga diagnostic_jump_prev")
							:with_defaults "lsp: Prev diagnostic",
						["n|g]"] = k.map_cr("Lspsaga diagnostic_jump_next")
							:with_defaults "lsp: Next diagnostic",
						["n|gs"] = k.map_callback(vim.lsp.buf.signature_help)
							:with_defaults "lsp: Signature help",
						["n|gr"] = k.map_cr("Lspsaga rename")
							:with_defaults "lsp: Rename in file range",
						["n|K"] = k.map_cr("Lspsaga hover_doc"):with_defaults "lsp: Show doc",
						["n|ga"] = k.map_cr("Lspsaga code_action")
							:with_defaults "lsp: Code action for cursor",
						["v|ga"] = k.map_cu("Lspsaga code_action")
							:with_defaults "lsp: Code action for range",
						["n|gd"] = k.map_cr("Lspsaga peek_definition")
							:with_defaults "lsp: Preview definition",
						["n|gD"] = k.map_cr("Lspsaga goto_definition")
							:with_defaults "lsp: Goto definition",
						["n|gh"] = k.map_cr("Lspsaga lsp_finder")
							:with_defaults "lsp: Show reference",
						["n|<LocalLeader>ci"] = k.map_cr("Lspsaga incoming_calls")
							:with_defaults "lsp: Show incoming calls",
						["n|<LocalLeader>co"] = k.map_cr("Lspsaga outgoing_calls")
							:with_defaults "lsp: Show outgoing calls",
					}
				end,
			},
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				config = require "completion.mason-tool-installer",
				cmd = { "MasonToolInstall", "MasonToolUpdate" },
			},
		},
	},

	["hrsh7th/nvim-cmp"] = {
		lazy = true,
		config = require "completion.nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				lazy = true,
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
			{
				"windwp/nvim-autopairs",
				branch = "master",
				config = require "completion.nvim-autopairs",
			},
		},
	},

	["zbirenbaum/copilot.lua"] = {
		lazy = true,
		cmd = "Copilot",
		event = "InsertEnter",
		config = require "completion.copilot",
	},
}
