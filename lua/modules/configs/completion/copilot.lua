return function()
	vim.defer_fn(
		function()
			require("copilot").setup {
				panel = {
					enabled = true,
					auto_refresh = true,
				},
				suggestion = {
					enabled = true,
					auto_trigger = true,
				},
				filetypes = {
					["TelescopePrompt"] = false,
					["dap-repl"] = false,
					["big_file_disabled_ft"] = false,
				},
			}
		end,
		100
	)
end
