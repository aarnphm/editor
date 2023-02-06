local editor_variables = function()
	local os_name = vim.loop.os_uname().sysname

	local is_mac = os_name == "Darwin"
	local is_linux = os_name == "Linux"
	local is_windows = os_name == "Windows_NT"
	local vim_path = vim.fn.stdpath "config"

	local path_sep = is_windows and "\\" or "/"

	local home = is_windows and os.getenv "USERPROFILE" or os.getenv "HOME"
	local data_dir = string.format("%s/site/", vim.fn.stdpath "data")

	local cache_dir = home .. path_sep .. ".cache" .. path_sep .. "nvim" .. path_sep
	local modules_dir = vim_path .. path_sep .. "lua" .. path_sep .. "modules"

	local local_config_path = home .. path_sep .. ".editor.lua"

	local zettel_home = vim_path .. path_sep .. "zettelkasten"

	return {
		os_name = os_name,
		is_mac = is_mac,
		is_linux = is_linux,
		is_windows = is_windows,
		vim_path = vim_path,
		path_sep = path_sep,
		home = home,
		data_dir = data_dir,
		cache_dir = cache_dir,
		modules_dir = modules_dir,
		local_config_path = local_config_path,
		zettel_home = zettel_home,
		use_ssh = true,
		---Change the colors of the global palette here.
		---Settings will complete their replacement at initialization.
		---Parameters will be automatically completed as you type.
		---Example: { sky = "#04A5E5" }
		---@type palette
		palette_overwrite = {},
	}
end

---@class Editor: table<str, any>
---@field debug boolean: Enable debug mode
---@field format_on_save boolean: Enable format on save
---@field reset_cache boolean: Reset cache
---@field background string: Set background type, "light" or "dark"
---@field colorscheme string: Set colorscheme
---@field repos string: Set repos
---@field load_big_files_faster boolean: Load big files faster using LunarVim/bigfile.nvim
---@field plugins table<string, table|any>: Set plugins
local _config = nil

local M = editor_variables()

local editor_config = function()
	if _config then
		return _config
	end
	local config_path = M.local_config_path
	local ok, __config = pcall(dofile, config_path)

	if not ok then
		if not string.find(__config, "No such file or directory") then
			vim.notify(
				"WARNING: user config file is invalid",
				vim.log.levels.ERROR,
				{ title = "editor: configuration" }
			)
			vim.notify(__config)
		end
		local default_config = nil
		local default_config_file = io.open(M.vim_path .. M.path_sep .. ".editor.lua", "r")
		if default_config_file then
			default_config = default_config_file:read "*a"
			default_config_file:close()
		end
		local local_config_file = io.open(config_path, "w")
		assert(
			local_config_file ~= nil,
			vim.notify("Could not create local config file", vim.log.levels.ERROR, { title = "editor: configuration" })
		)
		assert(default_config ~= nil, "Could not find default config file")
		local_config_file:write(default_config)
		local_config_file:close()
		local_config_file = nil
		__config = dofile(config_path)
	end

	_config = vim.deepcopy(__config)
	return _config
end

_G.__editor_global = M

_G.__editor_config = editor_config()

return M
