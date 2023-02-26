---@param options table<string, any>
return function(options)
	-- NOTE: call neodev before setup lua_ls
	require("neodev").setup {
		library = {
			plugins = {
				"lazy",
				"lualine.nvim",
				"nvim-lspconfig",
				"nvim-treesitter",
				"telescope.nvim",
				"lspsaga.nvim",
			},
		},
	}

	-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/lua_ls.lua
	require("lspconfig").lua_ls.setup(vim.tbl_deep_extend("force", options, {
		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
				},
				diagnostics = {
					enable = true,
					globals = { "vim" },
					disable = { "different-requires" },
				},
				hint = { enable = true },
				runtime = {
					version = "LuaJIT",
					special = { reload = "require" },
				},
				workspace = {
					library = { vim.env.VIMRUNTIME, require("neodev.config").types() },
					checkThirdParty = false,
					maxPreload = 100000,
					preloadFileSize = 10000,
				},
				telemetry = { enable = false },
				semantic = { enable = false },
			},
		},
	}))
end
