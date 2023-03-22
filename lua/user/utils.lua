---@diagnostic disable: undefined-field
--# selene: allow(global_usage)
local M = {}

---@param on_attach fun(client, buffer)
M.on_attach = function(on_attach)
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			on_attach(vim.lsp.get_client_by_id(args.data.client_id), args.buf)
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
				---@diagnostic disable-next-line: param-type-mismatch
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

-- statusline and simple
local fmt = string.format

-- NOTE: git
local concat_hunks = function(hunks)
	return vim.tbl_isempty(hunks) and ""
		or table.concat({
			fmt("+%d", hunks[1]),
			fmt("~%d", hunks[2]),
			fmt("-%d", hunks[3]),
		}, " ")
end

local get_hunks = function()
	local hunks = {}
	if vim.g.loaded_gitgutter then
		hunks = vim.fn.GitGutterGetHunkSummary()
	elseif vim.b.gitsigns_status_dict then
		hunks = {
			vim.b.gitsigns_status_dict.added,
			vim.b.gitsigns_status_dict.changed,
			vim.b.gitsigns_status_dict.removed,
		}
	end
	return concat_hunks(hunks)
end

local get_branch = function()
	local branch = ""
	if vim.g.loaded_fugitive then
		branch = vim.fn.FugitiveHead()
	elseif vim.g.loaded_gitbranch then
		branch = vim.fn["gitbranch#name"]()
	elseif vim.b.gitsigns_head ~= nil then
		branch = vim.b.gitsigns_head
	end
	return branch ~= "" and fmt("(b: %s)", branch) or ""
end

-- I refuse to have a complex statusline, *proceeds to have a complex statusline* PepeLaugh (lualine is cool though.)
-- [hunk] [branch] [modified]  --------- [diagnostic] [filetype] [line:col] [heart]
M.statusline = {
	git = function()
		local hunks, branch = get_hunks(), get_branch()
		if hunks == concat_hunks { 0, 0, 0 } and branch == "" then hunks = "" end
		if hunks ~= "" and branch ~= "" then branch = branch .. " " end
		return fmt("%s", table.concat { branch, hunks })
	end,
	diagnostic = function() -- NOTE: diagnostic
		local buf = vim.api.nvim_get_current_buf()
		return fmt(
			"[W:%d | E:%d]",
			#vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.WARN }),
			#vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR })
		)
	end,
	build = function()
		local spacer = "%="
		return table.concat({
			"%f | %{%luaeval('require(\"user.utils\").statusline.git()')%}",
			"%m",
			spacer,
			spacer,
			"%{%luaeval('require(\"user.utils\").statusline.diagnostic()')%}",
			"%y",
			"%l:%c",
			_G.icons.misc_space.Love,
		}, " ")
	end,
}

return M
