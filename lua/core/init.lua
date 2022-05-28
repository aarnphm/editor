-- Create cache dir and subs dir
local create_dir = function()
  local data_dir = {
    __editor_global.cache_dir .. "backup",
    __editor_global.cache_dir .. "session",
    __editor_global.cache_dir .. "swap",
    __editor_global.cache_dir .. "tags",
    __editor_global.cache_dir .. "undo",
  }
  -- There only check once that If cache_dir exists
  -- Then I don't want to check subs dir exists
  if vim.fn.isdirectory(__editor_global.cache_dir) == 0 then
    os.execute("mkdir -p " .. __editor_global.cache_dir)
    for _, v in pairs(data_dir) do
      if vim.fn.isdirectory(v) == 0 then
        os.execute("mkdir -p " .. v)
      end
    end
  end
end

local preflight = function()
  create_dir()

  -- disable some builtin vim plugins
  local disabled_built_ins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "matchit",
    "tar",
    "tarPlugin",
    "rrhelper",
    "spellfile_plugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
  }

  for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
  end

  vim.g.mapleader = ","
  vim.api.nvim_set_keymap("n", ",", "", { noremap = true })
  vim.api.nvim_set_keymap("x", ",", "", { noremap = true })

  vim.g.maplocalleader = "+"

  vim.opt.background = __editor_config.background

  -- Add Packer commands because we are not loading it at startup
  vim.cmd("silent! command PackerClean lua require 'plugins' require('packer').clean()")
  vim.cmd("silent! command PackerCompile lua require 'plugins' require('packer').compile()")
  vim.cmd("silent! command PackerInstall lua require 'plugins' require('packer').install()")
  vim.cmd("silent! command PackerStatus lua require 'plugins' require('packer').status()")
  vim.cmd("silent! command PackerSync lua require 'plugins' require('packer').sync()")
  vim.cmd("silent! command PackerUpdate lua require 'plugins' require('packer').update()")
end

local setup_global_envars = function()
  -- quick hack for install sqlite with nix
  vim.g.sqlite_clib_path = vim.env["SQLITE_PATH"]
end

local M = {}

M.setup = function()
  setup_global_envars()
  preflight()

  require("core.events")
  require("core.options")
  require("core.mappings")
  vim.cmd("colorscheme " .. __editor_config.colorscheme)
end

return M
