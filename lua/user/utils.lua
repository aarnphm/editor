local M = {}

local cached_autocmds = {}

M.toggle_autocmds = function(name)
	local has, commands = pcall(vim.api.nvim_get_autocmds, { name = name })
	if has and type(commands) == "table" then
		cached_autocmds[name] = commands
		vim.api.nvim_del_augroup_by_name(name)
		vim.notify("Disabled autocmds: " .. name, vim.log.levels.INFO)
	else
		commands = cached_autocmds[name] or commands
		vim.api.nvim_create_augroup(name, { clear = true })
		for _, command in pairs(commands) do
			local opts = {}
			opts.desc = command.desc or ""
			opts.group = command.group_name or name

			if command.pattern ~= nil then
				opts.pattern = command.pattern
			elseif command.buffer ~= nil then
				opts.buffer = command.buffer
			end
			if command.callback ~= nil then
				opts.callback = command.callback
			elseif command.command ~= nil then
				opts.command = command.command
			end

			vim.api.nvim_create_autocmd(command.event, opts)
		end
		vim.notify("Enabled autocmds: " .. name, vim.log.levels.INFO)
	end
end

---@param on_attach fun(client, buffer)
M.on_attach = function(on_attach)
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local buffer = args.buf
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			on_attach(client, buffer)
		end,
	})
end

M.has = function(plugin) return require("lazy.core.config").plugins[plugin] ~= nil end

---@param name string
M.opts = function(name)
	local plugin = require("lazy.core.config").plugins[name]
	if not plugin then return {} end
	return require("lazy.core.plugin").values(plugin, "opts", false)
end

M.root_patterns = { ".git", "lua" }

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
M.get_root = function()
	---@type string?
	local path = vim.api.nvim_buf_get_name(0)
	path = path ~= "" and vim.loop.fs_realpath(path) or nil
	---@type string[]
	local roots = {}
	if path then
		for _, client in pairs(vim.lsp.get_active_clients { bufnr = 0 }) do
			local workspace = client.config.workspace_folders
			local paths = workspace
					and vim.tbl_map(function(ws) return vim.uri_to_fname(ws.uri) end, workspace)
				or client.config.root_dir and { client.config.root_dir }
				or {}
			for _, p in ipairs(paths) do
				local r = vim.loop.fs_realpath(p)
				if path:find(r, 1, true) then roots[#roots + 1] = r end
			end
		end
	end
	table.sort(roots, function(a, b) return #a > #b end)
	---@type string?
	local root = roots[1]
	if not root then
		path = path and vim.fs.dirname(path) or vim.loop.cwd()
		---@type string?
		root = vim.fs.find(M.root_patterns, { path = path, upward = true })[1]
		root = root and vim.fs.dirname(root) or vim.loop.cwd()
	end
	---@cast root string
	return root
end

return M
