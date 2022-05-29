local M = {}

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

local setup_global_envars = function()
  -- quick hack for install sqlite with nix
  vim.g.sqlite_clib_path = vim.env["SQLITE_PATH"]
end

local disable_distribution_plugins = function()
  vim.g.did_load_filetypes = 1
  vim.g.did_load_fzf = 1
  vim.g.did_load_gtags = 1
  vim.g.did_load_gzip = 1
  vim.g.did_load_tar = 1
  vim.g.did_load_tarPlugin = 1
  vim.g.did_load_zip = 1
  vim.g.did_load_zipPlugin = 1
  vim.g.did_load_getscript = 1
  vim.g.did_load_getscriptPlugin = 1
  vim.g.did_load_vimball = 1
  vim.g.did_load_vimballPlugin = 1
  vim.g.did_load_matchit = 1
  vim.g.did_load_matchparen = 1
  vim.g.did_load_2html_plugin = 1
  vim.g.did_load_logiPat = 1
  vim.g.did_load_rrhelper = 1
  vim.g.did_load_netrw = 1
  vim.g.did_load_netrwPlugin = 1
  vim.g.did_load_netrwSettings = 1
  vim.g.did_load_netrwFileHandlers = 1
end

local check_conda = function()
  local venv = os.getenv("CONDA_PREFIX")
  if venv then
    vim.g.python3_host_prog = venv .. "/bin/python"
  elseif __editor_config.global.python3_host_prog then
    vim.g.python3_host_prog = __editor_config.global.python3_host_prog
  end
end

M.setup = function()
  setup_global_envars()
  create_dir()
  disable_distribution_plugins()
  check_conda()

  vim.g.mapleader = ","
  vim.api.nvim_set_keymap("n", ",", "", { noremap = true })
  vim.api.nvim_set_keymap("x", ",", "", { noremap = true })

  vim.g.maplocalleader = "+"

  -- Add Packer commands because we are not loading it at startup
  vim.cmd("silent! command PackerClean lua require 'plugins' require('packer').clean()")
  vim.cmd("silent! command PackerCompile lua require 'plugins' require('packer').compile()")
  vim.cmd("silent! command PackerInstall lua require 'plugins' require('packer').install()")
  vim.cmd("silent! command PackerStatus lua require 'plugins' require('packer').status()")
  vim.cmd("silent! command PackerSync lua require 'plugins' require('packer').sync()")
  vim.cmd("silent! command PackerUpdate lua require 'plugins' require('packer').update()")

  require("core.options")
  require("core.mappings")
  require("core.events")
end

return M
