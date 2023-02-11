return function()
	require("mason-tool-installer").setup {

		-- a list of all tools you want to ensure are installed upon
		-- start; they should be the names Mason uses for each tool
		ensure_installed = {
			-- Linters
			"eslint_d",
			"prettierd",
			"stylua",
			"selene",
			"luacheck",
			"shellcheck",
			"shfmt",
			"black",
			"flake8",
			"isort",
			"buildifier",
			"buf",
			"ruff",
			"tflint",
			"yamllint",
			"yamlfmt",
			"vulture",
			"jq",
			"rustfmt",
			"vale",
			"vint",
		},
	}
	vim.api.nvim_create_autocmd("User", {
		pattern = "MasonToolsUpdateCompleted",
		callback = function()
			vim.schedule(function()
				print "mason-tool-installer has finished"
				vim.notify(
					"mason-tool-installer has finished!",
					vim.log.levels.DEBUG,
					{ title = "MasonToolsInstaller" }
				)
			end)
		end,
	})
end
