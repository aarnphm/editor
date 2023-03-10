local M = {}

local disabled_ft = { "gitcommit", "gitconfig", "gitignore" }
M.autoformat = true

M.toggle = function()
	if vim.b.autoformat == false then
		vim.b.autoformat = nil
		M.autoformat = true
	else
		M.autoformat = not M.autoformat
	end
	if M.autoformat then
		vim.notify("Enabled format on save", vim.log.levels.INFO, { title = "Format" })
	else
		vim.notify("Disabled format on save", vim.log.levels.WARN, { title = "Format" })
	end
end

M.format = function(opts)
	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
	local ft = vim.bo[bufnr].filetype

	if vim.tbl_contains(disabled_ft, ft) then return end

	local have_nls = #require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") > 0

	vim.lsp.buf.format(vim.tbl_deep_extend("force", {
		bufnr = bufnr,
		filter = function(client)
			if have_nls then return client.name == "null-ls" end
			return client.name ~= "null-ls"
		end,
	}, require("zox.utils").opts("nvim-lspconfig").format or {}))
end

M.on_attach = function(client, bufnr)
	-- don't format when client is disabled
	if
		client.config
		and client.config.capabilities
		and client.config.capabilities.documentFormattingProvider == false
	then
		return
	end
	if client.supports_method "textDocument/formatting" then
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {}),
			buffer = bufnr,
			callback = function()
				if M.autoformat then M.format {} end
			end,
		})
	end
end

return M
