local os_name = vim.loop.os_uname().sysname

local is_mac = os_name == "Darwin"
local is_linux = os_name == "Linux"
local is_windows = os_name == "Windows_NT"
local vim_path = vim.fn.stdpath "config"
local path_sep = is_windows and "\\" or "/"
local home = is_windows and os.getenv "USERPROFILE" or os.getenv "HOME"
local local_config_path = home .. path_sep .. ".editor.lua"

---@class Editor: table<str, any>
---@field debug boolean: Enable debug mode
---@field format_on_save boolean: Enable format on save
---@field reset_cache boolean: Reset cache
---@field background string: Set background type, "light" or "dark"
---@field colorscheme string: Set colorscheme
---@field repos string: Set repos
---@field load_big_files_faster boolean: Load big files faster using LunarVim/bigfile.nvim
---@field use_ssh boolean: Use ssh to clone repos
---@field plugins table<string, table|any>: Set plugins
---@field palette_overwrite table<string, string>: Set palette overwrite
local _config = nil

return {
	global = {
		os_name = os_name,
		is_mac = is_mac,
		is_linux = is_linux,
		is_windows = is_windows,
		vim_path = vim_path,
		path_sep = path_sep,
		home = home,
		data_dir = string.format("%s/site/", vim.fn.stdpath "data"),
		cache_dir = home .. path_sep .. ".cache" .. path_sep .. "nvim" .. path_sep,
		modules_dir = vim_path .. path_sep .. "lua" .. path_sep .. "modules",
		local_config_path = local_config_path,
	},
	config = (function()
		if _config then return _config end
		local ok, __config = pcall(dofile, local_config_path)

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
			local default_config_file = io.open(vim_path .. path_sep .. ".editor.lua", "r")
			if default_config_file then
				default_config = default_config_file:read "*a"
				default_config_file:close()
			end
			local local_config_file = io.open(local_config_path, "w")
			assert(
				local_config_file ~= nil,
				vim.notify(
					"Could not create local config file",
					vim.log.levels.ERROR,
					{ title = "editor: configuration" }
				)
			)
			assert(default_config ~= nil, "Could not find default config file")
			local_config_file:write(default_config)
			local_config_file:close()
			local_config_file = nil
			__config = dofile(local_config_path)
		end

		_config = vim.deepcopy(__config)
		return _config
	end)(),
}
