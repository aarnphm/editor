local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local util = require "vim.lsp.util"
local clients = {}
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

	local have_nls = #require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") > 0

	vim.lsp.buf.format(vim.tbl_deep_extend("force", {
		bufnr = bufnr,
		filter = function(client)
			if have_nls then return client.name == "null-ls" end
			return client.name ~= "null-ls"
		end,
		async = true,
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
			{ "<leader>cd", vim.diagnostic.open_float, desc = "lsp: show line diagnostics" },
			{ "<leader>ci", "<cmd>LspInfo<cr>", desc = "lsp: info" },
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

-- thx to https://gitlab.com/ranjithshegde/dotbare/-/blob/master/.config/nvim/lua/lsp/init.lua
M.signature_window = function(_, result, ctx, config)
	local bufnr, winner = vim.lsp.handlers.signature_help(_, result, ctx, config)
	local current_cursor_line = vim.api.nvim_win_get_cursor(0)[1]

	if winner then
		if current_cursor_line > 3 then
			vim.api.nvim_win_set_config(winner, {
				anchor = "SW",
				relative = "cursor",
				row = 0,
				col = -1,
			})
		end
	end

	if bufnr and winner then return bufnr, winner end
end

-- thx to https://github.com/seblj/dotfiles/blob/0542cae6cd9a2a8cbddbb733f4f65155e6d20edf/nvim/lua/config/lspconfig/init.lua
local check_trigger_char = function(line_to_cursor, triggers)
	if not triggers then return false end

	for _, trigger_char in ipairs(triggers) do
		local current_char = line_to_cursor:sub(#line_to_cursor, #line_to_cursor)
		local prev_char = line_to_cursor:sub(#line_to_cursor - 1, #line_to_cursor - 1)
		if current_char == trigger_char then return true end
		if current_char == " " and prev_char == trigger_char then return true end
	end
	return false
end

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

	if client.server_capabilities["documentSymbolProvider"] then
		require("nvim-navic").attach(client, bufnr)
	end

	-- NOTE: setup signatures
	local group = augroup("LspSignature", { clear = false })
	vim.api.nvim_clear_autocmds { group = group, pattern = "<buffer>" }

	autocmd("TextChangedI", {
		group = group,
		pattern = "<buffer>",
		callback = function()
			-- Guard against spamming of method not supported after
			-- stopping a language serer with LspStop
			local active_clients = vim.lsp.get_active_clients()
			if #active_clients < 1 then return end

			local triggered = false

			for _, client_ in pairs(clients) do
				local triggers = client_.server_capabilities.signatureHelpProvider.triggerCharacters

				local pos = vim.api.nvim_win_get_cursor(0)
				local line = vim.api.nvim_get_current_line()
				local line_to_cursor = line:sub(1, pos[2])

				if not triggered then triggered = check_trigger_char(line_to_cursor, triggers) end
			end

			if triggered then
				local params = util.make_position_params()
				vim.lsp.buf_request(
					0,
					"textDocument/signatureHelp",
					params,
					vim.lsp.with(M.signature_window, {
						border = "none",
						focusable = false,
					})
				)
			end
		end,
	})

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

return M
