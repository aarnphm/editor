local M = {}
local global = require("core.global")

-- Ref: https://github.com/tjdevries/lazy.nvim
local function require_on_exported_call(mod)
  return setmetatable({}, {
    __index = function(_, picker)
      return function(...)
        return require(mod)[picker](...)
      end
    end,
  })
end

function M.edit_root()
  local files = require_on_exported_call("telescope.builtin.git").files
  files({ cwd = vim.fn.stdpath("config") })
end

function M.reload()
  require("core.pack").magic_compile()
  require("packer").sync()
  vim.notify("Config reloaded and compiled.")
end

local status_config = {
  -- hide, show on specific filetypes
  hidden = {
    "help",
    "NvimTree",
    "terminal",
    "dashboard",
    "alpha",
  },
  shown = {},
}

M.hide_statusline = function()
  local hidden = status_config.hidden
  local shown = status_config.shown
  local api = vim.api
  local buftype = api.nvim_buf_get_option(0, "ft")

  -- shown table from config has the highest priority
  if vim.tbl_contains(shown, buftype) then
    api.nvim_set_option("laststatus", 2)
    return
  end

  if vim.tbl_contains(hidden, buftype) then
    api.nvim_set_option("laststatus", 0)
    return
  end

  api.nvim_set_option("laststatus", 2)
end

local _config

function M.get_local_config()
  if _config then
    return _config
  end
  local config_path = global.local_config_path
  local ok, __config = pcall(dofile, config_path)

  if not ok then
    if not string.find(__config, "No such file or directory") then
      vim.notify("WARNING: user config file is invalid")
      vim.notify(__config)
    end
    local default_config_file = io.open(global.vim_path .. global.path_sep .. ".editor.lua", "r")
    local default_config = default_config_file:read("*a")
    default_config_file:close()
    local local_config_file = io.open(config_path, "w")
    local_config_file:write(default_config)
    local_config_file:close()
    __config = dofile(config_path)
  end

  _config = vim.deepcopy(__config)
  return _config
end

function M.reset_local_config()
  _config = nil
end

return M
