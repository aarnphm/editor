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

		-- if set to true this will check each tool for updates. If updates
		-- are available the tool will be updated. This setting does not
		-- affect :MasonToolsUpdate or :MasonToolsInstall.
		-- Default: false
		auto_update = true,

		-- automatically install / update on startup. If set to false nothing
		-- will happen on startup. You can use :MasonToolsInstall or
		-- :MasonToolsUpdate to install tools and check for updates.
		-- Default: true
		run_on_start = true,
	}
end
