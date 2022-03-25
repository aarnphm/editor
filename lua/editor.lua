local M = {}

local _config = nil

function M:editor_variables()
  local os_name = vim.loop.os_uname().sysname

  self.is_mac = os_name == "Darwin"
  self.is_linux = os_name == "Linux"
  self.is_windows = os_name == "Windows_NT"
  self.vim_path = vim.fn.stdpath("config")

  local path_sep = self.is_windows and "\\" or "/"
  self.path_sep = path_sep

  local home = self.is_windows and os.getenv("USERPROFILE") or os.getenv("HOME")

  self.cache_dir = home .. path_sep .. ".cache" .. path_sep .. "nvim" .. path_sep
  self.modules_dir = self.vim_path .. path_sep .. "modules"
  self.home = home
  self.data_dir = string.format("%s/site/", vim.fn.stdpath("data"))
  self.local_config_path = vim.fn.expand("$HOME/.editor.lua")
end

local function editor_config()
  if _config then
    return _config
  end
  local config_path = M.local_config_path
  local ok, __config = pcall(dofile, config_path)

  if not ok then
    if not string.find(__config, "No such file or directory") then
      vim.notify("WARNING: user config file is invalid")
      vim.notify(__config)
    end
    local default_config_file = io.open(M.vim_path .. M.path_sep .. ".editor.lua", "r")
    local default_config = default_config_file:read("*a")
    default_config_file:close()
    local local_config_file = io.open(config_path, "w")
    local_config_file:write(default_config)
    local_config_file:close()
    __config = dofile(config_path)
  end

  _config = vim.deepcopy(__config)
end

M:editor_variables()

editor_config()

_G.__editor_global = M

_G.__editor_config = _config

return M
