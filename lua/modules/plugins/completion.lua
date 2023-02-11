local k = require "keybind"
local disabled_filetypes = { "gitcommit", "gitrebase", "gitconfig" }

return {
	-- lspconfig
	["neovim/nvim-lspconfig"] = {
		lazy = true,
		event = { "BufReadPre", "BufReadPost", "BufNewFile" },
		config = require "completion.nvim-lspconfig",
		cond = function() return not vim.tbl_contains(disabled_filetypes, vim.bo.filetype) end,
		dependencies = {
			{ "creativenull/efmls-configs-nvim" },
			{
				"williamboman/mason.nvim",
				init = function()
					k.nvim_load_mapping {
						["n|<LocalLeader>lp"] = k.map_cr("Mason")
							:with_defaults()
							:with_nowait()
							:with_desc "lsp: Open Mason",
					}
				end,
			},
			{
				"williamboman/mason-lspconfig.nvim",
				init = function()
					k.nvim_load_mapping {
						["n|<LocalLeader>li"] = k.map_cr("LspInfo"):with_defaults():with_nowait():with_desc "lsp: Info",
						["n|<LocalLeader>lr"] = k.map_cr("LspRestart")
							:with_defaults()
							:with_nowait()
							:with_desc "lsp: Restart",
					}
				end,
			},
			{
				"glepnir/lspsaga.nvim",
				config = require "completion.lspsaga",
				event = "BufRead",
				dependencies = { "nvim-tree/nvim-web-devicons" },
				init = function()
					k.nvim_load_mapping {
						["n|go"] = k.map_cr("Lspsaga outline"):with_defaults():with_desc "lsp: Toggle outline",
						["n|g["] = k.map_cr("Lspsaga diagnostic_jump_prev")
							:with_defaults()
							:with_desc "lsp: Prev diagnostic",
						["n|g]"] = k.map_cr("Lspsaga diagnostic_jump_next")
							:with_defaults()
							:with_desc "lsp: Next diagnostic",
						["n|<LocalLeader>sl"] = k.map_cr("Lspsaga show_line_diagnostics")
							:with_defaults()
							:with_desc "lsp: Line diagnostic",
						["n|<LocalLeader>sc"] = k.map_cr("Lspsaga show_cursor_diagnostics")
							:with_defaults()
							:with_desc "lsp: Cursor diagnostic",
						["n|gs"] = k.map_callback(vim.lsp.buf.signature_help)
							:with_defaults()
							:with_desc "lsp: Signature help",
						["n|gr"] = k.map_cr("Lspsaga rename"):with_defaults():with_desc "lsp: Rename in file range",
						["n|K"] = k.map_cr("Lspsaga hover_doc"):with_defaults():with_desc "lsp: Show doc",
						["n|ga"] = k.map_cr("Lspsaga code_action")
							:with_defaults()
							:with_desc "lsp: Code action for cursor",
						["v|ga"] = k.map_cu("Lspsaga code_action")
							:with_defaults()
							:with_desc "lsp: Code action for range",
						["n|gd"] = k.map_cr("Lspsaga peek_definition")
							:with_defaults()
							:with_desc "lsp: Preview definition",
						["n|gD"] = k.map_cr("Lspsaga goto_definition"):with_defaults():with_desc "lsp: Goto definition",
						["n|gh"] = k.map_cr("Lspsaga lsp_finder"):with_defaults():with_desc "lsp: Show reference",
						["n|<LocalLeader>ci"] = k.map_cr("Lspsaga incoming_calls")
							:with_defaults()
							:with_desc "lsp: Show incoming calls",
						["n|<LocalLeader>co"] = k.map_cr("Lspsaga outgoing_calls")
							:with_defaults()
							:with_desc "lsp: Show outgoing calls",
					}
				end,
			},
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				config = require "completion.mason-tool-installer",
				cmd = { "MasonToolInstall", "MasonToolUpdate" },
			},
			{ "ray-x/lsp_signature.nvim" },
		},
	},

	["hrsh7th/nvim-cmp"] = {
		lazy = true,
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
			{ "windwp/nvim-autopairs", branch = "master", config = require "completion.nvim-autopairs" },
		},
	},

	["zbirenbaum/copilot.lua"] = {
		lazy = true,
		cmd = "Copilot",
		event = "InsertEnter",
		config = require "completion.copilot",
		init = function()
			k.nvim_load_mapping {
				["n|<LocalLeader>cp"] = k.map_cr("Copilot panel")
					:with_defaults()
					:with_nowait()
					:with_desc "copilot: Open panel",
			}
		end,
	},
}
