-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/lua_ls.lua
-- NOTE: call neodev before setup lua_ls
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
			"mason.nvim",
			"mason-lspconfig.nvim",
			"nvim-cmp",
			"copilot.lua",
			"lazy.nvim",
			"gitsigns.nvim",
			"toggleterm.nvim",
			"better-escape.nvim",
			"alpha-nvim",
			"rose-pine",
			"lspsaga.nvim",
			"null-ls.nvim",
			"nvim-bufferline.lua",
			"lsp-setup.nvim",
			"rust-tools.nvim",
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
				enable = true,
				globals = { "vim" },
			},
			hint = { enable = true },
			runtime = {
				version = "LuaJIT",
				path = vim.split(package.path, ";"),
				special = { reload = "require" },
			},
			workspace = {
				library = {
					vim.env.VIMRUNTIME,
					vim.fn.expand "$VIMRUNTIME/lua",
					require("neodev.config").types(),
					vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
					require("editor").global.modules_dir .. "/configs",
				},
				checkThirdParty = false,
				maxPreload = 100000,
				preloadFileSize = 10000,
			},
			telemetry = { enable = false },
		},
	},
}
