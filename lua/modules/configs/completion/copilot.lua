return function()
	vim.defer_fn(function()
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
				markdown = true, -- overrides default
				sh = function()
					if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
						-- disable for .env files
						return false
					end
					return true
				end,
			},
		}
	end, 100)
end
