return function()
	require("mason-tool-installer").setup {

		-- a list of all tools you want to ensure are installed upon
		-- start; they should be the names Mason uses for each tool
		ensure_installed = {
			-- Linters
			"prettier",
			"stylua",
			"selene",
			"luacheck",
			"shellcheck",
			"shfmt",
			"black",
			"isort",
			"pylint",
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
end
