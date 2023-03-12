local M = {}

local k = require "keybind"

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
	}, require("user.utils").opts("nvim-lspconfig").format or {}))
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

	k.nvim_register_mapping {
		-- lsp
		["n|K"] = k.cr("Lspsaga hover_doc"):with_buffer(bufnr):with_defaults "lsp: Signature help",
		["n|gh"] = k.callback(vim.show_pos):with_buffer(bufnr):with_defaults "lsp: Show hightlight",
		["n|g["] = k.cr("Lspsaga diagnostic_jump_prev")
			:with_buffer(bufnr)
			:with_defaults "lsp: Prev diagnostic",
		["n|g]"] = k.cr("Lspsaga diagnostic_jump_next")
			:with_buffer(bufnr)
			:with_defaults "lsp: Next diagnostic",
		["n|gr"] = k.callback(vim.lsp.buf.rename)
			:with_buffer(bufnr)
			:with_defaults "lsp: Rename in file range",
		["n|gd"] = k.cr("Glance definitions")
			:with_buffer(bufnr)
			:with_defaults "lsp: Peek definition",
		["n|gD"] = k.cr("Lspsaga goto_definition")
			:with_buffer(bufnr)
			:with_defaults "lsp: Goto definition",
		["n|ca"] = k.callback(vim.lsp.buf.code_action)
			:with_buffer(bufnr)
			:with_defaults "lsp: Code action for cursor",
		["v|ca"] = k.callback(vim.lsp.buf.code_action)
			:with_buffer(bufnr)
			:with_defaults "lsp: Code action for range",
		["n|go"] = k.cr("Lspsaga outline"):with_buffer(bufnr):with_defaults "lsp: Show outline",
		["n|gR"] = k.cr("TroubleToggle lsp_references")
			:with_buffer(bufnr)
			:with_defaults "lsp: Show references",
	}
end

return M
