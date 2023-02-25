local M = {}

local disabled_workspaces = {}
local disabled_ft = { "gitcommit", "gitconfig", "gitignore" }
local format_on_save = true

--- Formatting capabilities for the following server will be disabled and use null-ls instead.
--- @type string[]
local disabled_server_formatting = { "lua_ls", "tsserver", "clangd" }

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
		callback = function() require("zox.formatting").format { timeout_ms = opts.timeout } end,
	})
	if not is_configured then
		vim.notify(
			"Successfully enabled format-on-save",
			vim.log.levels.INFO,
			{ title = "Settings modification success!" }
		)
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

M.configure_format_on_save = function()
	if format_on_save then
		M.enable_format_on_save(true)
	else
		M.disable_format_on_save()
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
	local cwd = vim.fn.getcwd()

	for i = 1, #disabled_workspaces do
		if cwd.find(cwd, disabled_workspaces[i]) ~= nil then return end
	end
	if vim.tbl_contains(disabled_ft, vim.bo.filetype) then return end

	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
	local clients = {}
	for _, client in ipairs(vim.lsp.get_active_clients { bufnr = bufnr }) do
		if
			client.supports_method "textDocument/formatting"
			and not vim.tbl_contains(disabled_server_formatting, client.name)
		then
			table.insert(clients, client.id, client)
		end
	end

	if #clients == 0 then
		vim.notify(
			"[LSP] Format request failed, no matching language servers.",
			vim.log.levels.DEBUG
		)
	end

	local timeout_ms = opts.timeout_ms
	for _, client in pairs(clients) do
		if block_list[vim.bo.filetype] == true then
			vim.notify(
				string.format(
					"[LSP][%s] formatter for [%s] has been disabled. This file was not processed.",
					client.name,
					vim.bo.filetype
				),
				vim.log.levels.WARN,
				{ title = "LSP Formatter Warning!" }
			)
			return
		end
		local params = vim.lsp.util.make_formatting_params(opts.formatting_options)
		local result, err =
			client.request_sync("textDocument/formatting", params, timeout_ms, bufnr)
		if result and result.result then
			vim.lsp.util.apply_text_edits(result.result, bufnr, client.offset_encoding)
		elseif err then
			vim.notify(
				string.format("[LSP][%s] %s", client.name, err),
				vim.log.levels.ERROR,
				{ title = "LSP Format Error!" }
			)
		end
	end
end

return M
