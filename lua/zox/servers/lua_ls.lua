---@param options table<string, any>
return function(options)
	-- NOTE: call neodev before setup lua_ls
	require("neodev").setup {
		library = {
			enabled = true,
			runtime = true,
			types = true,
			plugins = {
				"nvim-dap",
				"obsidian",
				"nvim-dap-ui",
				"lualine",
				"nvim-lspconfig",
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
				"rust-tools.nvim",
			},
		},
	}
	-- Make runtime files discoverable to the server
	local runtime_path = vim.split(package.path, ";")
	table.insert(runtime_path, "lua/?.lua")
	table.insert(runtime_path, "lua/?/init.lua")

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
					path = runtime_path,
					special = { reload = "require" },
				},
				workspace = {
					library = {
						vim.env.VIMRUNTIME,
						vim.fn.stdpath "config" .. "/lua/zox",
						vim.fn.expand "$VIMRUNTIME/lua",
						require("neodev.config").types(),
						vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
					},
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
