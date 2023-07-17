local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
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
	-- NOTE: here so that we can call M.format in vim.keymap.set
	opts = opts or {}
	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
	local ft = vim.bo[bufnr].filetype

	if vim.tbl_contains(disabled_ft, ft) then return end

	local have_nls = package.loaded["null-ls"]
		and (#require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") > 0)

	vim.lsp.buf.format(vim.tbl_deep_extend("force", {
		bufnr = bufnr,
		filter = function(client)
			if have_nls then return client.name == "null-ls" end
			return client.name ~= "null-ls"
		end,
	}, require("user.utils").opts("nvim-lspconfig").format or {}))
end

M.diagnostic_goto = function(next, severity)
	local goto_impl = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function() goto_impl { severity = severity } end
end

M._keys = nil

M.setup_keymaps = function()
	if not M._keys then
		---@class PluginLspKeys
        -- stylua: ignore
		M._keys = {
			{ "<leader>d", vim.diagnostic.open_float, desc = "lsp: show line diagnostics" },
			{ "<leader>i", "<cmd>LspInfo<cr>", desc = "lsp: info" },
			{ "go", "<cmd>AerialToggle!<cr>", desc = "lsp: outline" },
			{ "gh", vim.show_pos, desc = "lsp: current position" },
			{ "gR", "<cmd>TroubleToggle lsp_references<cr>", desc = "lsp: references" },
			{ "gd", "<cmd>Glance definitions<cr>", desc = "lsp: Peek definition", has = "definition" },
			{ "gD", vim.lsp.buf.declaration, desc = "lsp: Goto declaration", has = "declaration" },
			{ "gI", "<cmd>Telescope lsp_implementations<cr>", desc = "lsp: Goto implementation" },
			{ "gt", "<cmd>Telescope lsp_type_definitions<cr>", desc = "lsp: Goto type definition" },
			{ "]d", M.diagnostic_goto(true), desc = "lsp: Next diagnostic" },
			{ "[d", M.diagnostic_goto(false), desc = "lsp: Prev diagnostic" },
			{ "]e", M.diagnostic_goto(true, "ERROR"), desc = "lsp: Next error" },
			{ "[e", M.diagnostic_goto(false, "ERROR"), desc = "lsp: Prev error" },
			{ "]w", M.diagnostic_goto(true, "WARN"), desc = "lsp: Next warning" },
			{ "[w", M.diagnostic_goto(false, "WARN"), desc = "lsp: Prev warning" },
			{ "<leader><leader>", M.format, desc = "lsp: Format document", has = "documentFormatting" },
			{ "<leader><leader>", M.format, desc = "lsp: Format range", mode = "v", has = "documentRangeFormatting" },
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
            -- incoming call hierarchy
            {"<leader>ci", vim.lsp.buf.incoming_calls, desc = "lsp: incoming calls", has = "callHierarchy" },
            {"<leader>co", vim.lsp.buf.outgoing_calls, desc = "lsp: incoming calls", has = "callHierarchy" },
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

		-- use hover.nvim if available
		if require("user.utils").has "hover.nvim" then
			M._keys[#M._keys + 1] = { "K", require("hover").hover, desc = "lsp: Hover doc" }
			M._keys[#M._keys + 1] = {
				"gK",
				require("hover").hover_select,
				desc = "lsp: Signature help",
				has = "signatureHelp",
			}
		else
			M._keys[#M._keys + 1] = { "K", vim.lsp.buf.hover, desc = "lsp: hover doc" }
			M._keys[#M._keys + 1] = {
				"gK",
				vim.lsp.buf.signature_help,
				desc = "lsp: signature help",
				has = "signatureHelp",
			}
		end
	end
	return M._keys
end

M.ui = vim.NIL ~= vim.env.SIMPLE_UI and vim.env.SIMPLE_UI == "true" or false

M.on_attach = function(client, bufnr)
	-- NOTE: setup format
	if
		client.config
		and client.config.capabilities
		and client.config.capabilities.documentFormattingProvider == false
	then
		return
	end
	if client.supports_method "textDocument/formatting" then
		autocmd("BufWritePre", {
			group = augroup("LspFormat." .. bufnr, {}),
			buffer = bufnr,
			callback = function()
				if M.autoformat then M.format { bufnr = bufnr } end
			end,
		})
	end

	if not M.ui and client.supports_method "textDocument/hover" then
		vim.lsp.handlers["textDocument/hover"] =
			vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
	end
	if not M.ui and client.supports_method "textDocument/signatureHelp" then
		vim.lsp.handlers["textDocument/signatureHelp"] =
			vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })
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

	if client.server_capabilities["documentSymbolProvider"] then
		require("nvim-navic").attach(client, bufnr)
	end

	-- NOTE: setup keymaps
	local LazyKeys = require "lazy.core.handler.keys"
	local keymaps = {} ---@type table<string,LazyKeys|{has?:string}>

	for _, value in ipairs(M.setup_keymaps()) do
		local keys = LazyKeys.parse(value)
		if keys[2] == vim.NIL or keys[2] == false then
			keymaps[keys.id] = nil
		else
			keymaps[keys.id] = keys
		end
	end

	for _, keys in pairs(keymaps) do
		if not keys.has or client.server_capabilities[keys.has .. "Provider"] then
			local opts = LazyKeys.opts(keys)
			---@diagnostic disable-next-line: no-unknown
			opts.has = nil
			opts.silent = opts.silent ~= false
			opts.buffer = bufnr
			vim.keymap.set(keys.mode or "n", keys[1], keys[2], opts)
		end
	end

	-- Create a command `:Format` local to the LSP buffer
	vim.api.nvim_buf_create_user_command(
		bufnr,
		"Format",
		function(_) M.format { bufnr = bufnr } end,
		{ desc = "format: current buffer (alt for <Leader><Leader>)" }
	)
end

M.gen_capabilities = function()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	local ok, cmp = pcall(require, "cmp_nvim_lsp")
	if ok then
		capabilities = cmp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
	end

	-- NOTE: some custom completion options
	capabilities.textDocument.completion.completionItem = {
		documentationFormat = { "markdown", "plaintext" },
		snippetSupport = true,
		preselectSupport = true,
		insertReplaceSupport = true,
		labelDetailsSupport = true,
		deprecatedSupport = true,
		commitCharactersSupport = true,
		tagSupport = { valueSet = { 1 } },
		resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits" } },
	}
	return capabilities
end

return M
