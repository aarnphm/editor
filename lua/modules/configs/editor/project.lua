return function()
	require("project_nvim").setup {
		manual_mode = false,
		detection_methods = { "lsp", "pattern" },
		patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
		ignore_lsp = { "null-ls", "copilot" },
		exclude_dirs = {},
		show_hidden = true,
		silent_chdir = true,
		scope_chdir = "global",
		datapath = vim.fn.stdpath "data",
	}
end
