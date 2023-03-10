return {
	flags = { debounce_text_changes = 500 },
	root_dir = function(fname)
		return require("lspconfig.util").root_pattern(
			"WORKSPACE",
			".git",
			"Pipfile",
			"pyrightconfig.json",
			"setup.py",
			"setup.cfg",
			"pyproject.toml",
			"requirements.txt"
		)(fname) or require("lspconfig.util").path.dirname(fname)
	end,
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
}
