-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/sumneko_lua.lua
-- call neodev before setup sumneko_lua
require("neodev").setup {
	library = {
		enabled = true,
		runtime = true,
		types = true,
		plugins = {
			"dap",
			"nvim-dap-ui",
			"lualine",
			"nvim-treesitter",
			"telescope.nvim",
			"efmls-configs",
			"mason.nvim",
			"mason-lspconfig.nvim",
			"cmp-nvim-lsp",
			"nvim-cmp",
			"copilot.lua",
			"lazy.nvim",
			"gitsigns.nvim",
			"crates.nvim",
			"toggleterm.nvim",
			"which-key.nvim",
			"better-escape.nvim",
			"alpha-nvim",
			"ssr.nvim",
			"catppuccin",
			"rose-pine",
			"efmls-configs-nvim",
			"toggleterm.nvim",
		},
	},
}
return {
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
			diagnostics = {
				globals = { "vim" },
			},
			runtime = {
				version = "LuaJIT",
				special = {
					reload = "require",
				},
			},
			workspace = {
				library = {
					vim.fn.expand "$VIMRUNTIME/lua",
					vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
					require("neodev.config").types(),
				},
				maxPreload = 100000,
				preloadFileSize = 10000,
			},
			telemetry = { enable = false },
			-- Do not override treesitter lua highlighting with sumneko lua highlighting
			semantic = { enable = false },
		},
	},
}
