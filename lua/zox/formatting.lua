local M = {}

local disabled_ft = { "gitcommit", "gitconfig", "gitignore" }
local format_on_save = true

vim.api.nvim_create_user_command("FormatToggle", function() M.toggle_format_on_save() end, {})

local block_list = {}
vim.api.nvim_create_user_command("FormatterToggle", function(opts)
	if block_list[opts.args] == nil then
		vim.notify(
			string.format(
				"[LSP]Formatter for [%s] has been recorded in list and disabled.",
				opts.args
			),
			vim.log.levels.WARN,
			{ title = "LSP Formatter Warning!" }
		)
		block_list[opts.args] = true
	else
		block_list[opts.args] = not block_list[opts.args]
		vim.notify(
			string.format(
				"[LSP] Formatter for [%s] has been %s.",
				opts.args,
				not block_list[opts.args] and "enabled" or "disabled"
			),
			not block_list[opts.args] and vim.log.levels.INFO or vim.log.levels.WARN,
			{
				title = string.format(
					"LSP Formatter %s",
					not block_list[opts.args] and "Info" or "Warning"
				),
			}
		)
	end
end, { nargs = 1, complete = "filetype" })

M.enable_format_on_save = function(is_configured)
	local opts = { pattern = "*", timeout = 1000 }
	vim.api.nvim_create_augroup("format_on_save", {})
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = "format_on_save",
		pattern = opts.pattern,
		callback = function() M.format { timeout_ms = opts.timeout } end,
	})
	if not is_configured then
		vim.notify(
			"Successfully enabled format-on-save",
			vim.log.levels.INFO,
			{ title = "Settings modification success!" }
		)
	end
end

M.configure_format_on_save = function()
	if format_on_save then
		M.enable_format_on_save(true)
	else
		M.disable_format_on_save()
	end
end

M.disable_format_on_save = function()
	pcall(vim.api.nvim_del_augroup_by_name, "format_on_save")
	if format_on_save then
		vim.notify(
			"Disabled format-on-save",
			vim.log.levels.INFO,
			{ title = "Settings modification success!" }
		)
	end
end

M.toggle_format_on_save = function()
	local status = pcall(vim.api.nvim_get_autocmds, {
		group = "format_on_save",
		event = "BufWritePre",
	})
	if not status then
		M.enable_format_on_save(false)
	else
		M.disable_format_on_save()
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
				if format_on_save then M.format {} end
			end,
		})
	end
end

return M
