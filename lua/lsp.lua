local M = {}

M.diagnostic_goto = function(next, severity)
	local goto_impl = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function() goto_impl { severity = severity } end
end

M._keys = nil

M.get = function()
	local format = function() require("user.format").format { force = true } end
	if not M._keys then
        --@class PluginLspKeys
        -- stylua: ignore
		M._keys = {
			{ "<leader>d", vim.diagnostic.open_float, desc = "lsp: show line diagnostics" },
			{ "<leader>i", "<cmd>LspInfo<cr>", desc = "lsp: info" },
			{ "gh", vim.show_pos, desc = "lsp: current position" },
			{ "gR", "<cmd>Telescope lsp_references<cr>", desc = "lsp: references" },
			{ "gd", "<cmd>Glance definitions<cr>", desc = "lsp: Peek definition", has = "definition" },
			{ "gD", vim.lsp.buf.declaration, desc = "lsp: Goto declaration" },
            { "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, desc = "Goto Implementation" },
            { "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, desc = "Goto T[y]pe Definition" },
            { "]d", M.diagnostic_goto(true), desc = "lsp: Next diagnostic" },
			{ "[d", M.diagnostic_goto(false), desc = "lsp: Prev diagnostic" },
			{ "]e", M.diagnostic_goto(true, "ERROR"), desc = "lsp: Next error" },
			{ "[e", M.diagnostic_goto(false, "ERROR"), desc = "lsp: Prev error" },
			{ "]w", M.diagnostic_goto(true, "WARN"), desc = "lsp: Next warning" },
			{ "[w", M.diagnostic_goto(false, "WARN"), desc = "lsp: Prev warning" },
			{ "<leader><leader>", format, desc = "lsp: Format document", has = "documentFormatting" },
			{ "<leader><leader>", format, desc = "lsp: Format range", mode = "v", has = "documentRangeFormatting" },
            { "K", vim.lsp.buf.hover, desc = "Hover" },
			{ "<leader>ca", vim.lsp.buf.code_action, desc = "lsp: Code action", mode = { "n", "v" }, has = "codeAction" },
			{ "<leader>cA",
				function()
					vim.lsp.buf.code_action {
						context = {
							only = { "source" },
							diagnostics = {},
						},
					}
				end,
				desc = "lsp: see source action",
				has = "codeAction",
			},
            -- document symbols
            {"ds", vim.lsp.buf.document_symbol, desc = "lsp: document symbols", has = "documentSymbol" },
            {"<localleader>ws", vim.lsp.buf.workspace_symbol, desc = "lsp: workspace symbols", has = "workspaceSymbol" },
		}
		if require("user.utils").has "inc-rename.nvim" then
			M._keys[#M._keys + 1] = {
				"gr",
				function()
					require "inc_rename"
					return ":IncRename " .. vim.fn.expand "<cword>"
				end,
				expr = true,
				desc = "lsp: rename",
				has = "rename",
				silent = true,
			}
		else
            -- stylua: ignore
			M._keys[#M._keys + 1] = { "gr", vim.lsp.buf.rename, desc = "lsp: rename", has = "rename" }
		end
	end
	return M._keys
end

M.ui = vim.NIL ~= vim.env.SIMPLE_UI and vim.env.SIMPLE_UI == "true" or false

M.resolve = function(buffer)
	local Keys = require "lazy.core.handler.keys"
	local keymaps = {} ---@type table<string,LazyKeys|{has?:string}>

	local function add(keymap)
		local keys = Keys.parse(keymap)
		if keys[2] == false then
			keymaps[keys.id] = nil
		else
			keymaps[keys.id] = keys
		end
	end
	for _, keymap in ipairs(M.get()) do
		add(keymap)
	end

	local opts = require("user.utils").opts "nvim-lspconfig"
	local clients = vim.lsp.get_active_clients { bufnr = buffer }
	for _, client in ipairs(clients) do
		local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
		for _, keymap in ipairs(maps) do
			add(keymap)
		end
	end
	return keymaps
end

---@param method string
M.has = function(buffer, method)
	method = method:find "/" and method or "textDocument/" .. method
	local clients = vim.lsp.get_active_clients { bufnr = buffer }
	for _, client in ipairs(clients) do
		if client.supports_method(method) then return true end
	end
	return false
end

M.on_attach = function(client, bufnr)
	local Keys = require "lazy.core.handler.keys"
	local keymaps = M.resolve(bufnr)

	for _, keys in pairs(keymaps) do
		if not keys.has or M.has(bufnr, keys.has) then
			local opts = Keys.opts(keys)
			---@diagnostic disable-next-line: no-unknown
			opts.has = nil
			opts.silent = opts.silent ~= false
			opts.buffer = bufnr
			vim.keymap.set(keys.mode or "n", keys[1], keys[2], opts)
		end
	end

	if client.supports_method "textDocument/publishDiagnostics" then
		vim.lsp.handlers["textDocument/publishDiagnostics"] =
			vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
				signs = true,
				underline = true,
				virtual_text = require("user.options").diagnostic.use_virtual_text and {
					severity_limit = require("users.options").diagnostic.diagnostics_level,
				} or false,
				update_in_insert = true,
			})
	end

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(
		bufnr,
		"Format",
		function(_) require("user.format").format { force = true } end,
		{ desc = "format: current buffer (alt for <Leader><Leader>)" }
	)
end

return M
