local switch_source_header_splitcmd = function(bufnr, splitcmd)
	local ok, lspconfig = pcall(require, "lspconfig")
	if not ok then
		vim.notify(
			"nvim-lspconfig is not loaded properly",
			vim.log.levels.ERROR,
			{ title = "LSP Error!" }
		)
		return
	end
	bufnr = lspconfig.util.validate_bufnr(bufnr)
	local clangd_client = lspconfig.util.get_active_client_by_name(bufnr, "clangd")
	local params = { uri = vim.uri_from_bufnr(bufnr) }
	if clangd_client then
		clangd_client.request("textDocument/switchSourceHeader", params, function(err, result)
			if err then error(tostring(err)) end
			if not result then
				vim.notify(
					"Corresponding file can’t be determined",
					vim.log.levels.ERROR,
					{ title = "LSP Error!" }
				)
				return
			end
			vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
		end)
	else
		vim.notify(
			"Method textDocument/switchSourceHeader is not supported by any active server on this buffer",
			vim.log.levels.ERROR,
			{ title = "LSP Error!" }
		)
	end
end

local get_binary_path_list = function(binaries)
	local path_list = {}
	for _, binary in ipairs(binaries) do
		local path = require("zox.utils").get_binary_path(binary)
		if path then table.insert(path_list, path) end
	end
	return table.concat(path_list, ",")
end

return function(options)
	options.capabilities.offsetEncoding = { "utf-16", "utf-8" }

	require("clangd_extensions").setup {
		-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/clangd.lua
		server = {
			on_attach = options.on_attach,
			capabilities = options.capabilities,
			single_file_support = true,
			cmd = {
				"clangd",
				"--background-index",
				"--pch-storage=memory",
				-- You MUST set this arg ↓ to your c/cpp compiler location (if not included)!
				"--query-driver=" .. get_binary_path_list { "clang++", "clang", "gcc", "g++" },
				"--clang-tidy",
				"--all-scopes-completion",
				"--completion-style=detailed",
				"--header-insertion-decorators",
				"--header-insertion=never",
			},
			filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
			commands = {
				ClangdSwitchSourceHeader = {
					function() switch_source_header_splitcmd(0, "edit") end,
					description = "cpp: Open source/header in current buffer",
				},
				ClangdSwitchSourceHeaderVSplit = {
					function() switch_source_header_splitcmd(0, "vsplit") end,
					description = "cpp: Open source/header in a new vsplit",
				},
				ClangdSwitchSourceHeaderSplit = {
					function() switch_source_header_splitcmd(0, "split") end,
					description = "cpp: Open source/header in a new split",
				},
			},
		},
		extensions = { other_hints_prefix = ":: ", show_parameter_hints = false },
	}
end
