local api = vim.api
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
  vim.g.did_install_default_menus = 1
  vim.g.did_install_syntax_menu = 1

  vim.g.did_load_filetypes = 1

  -- Do not load native syntax completion
  vim.g.loaded_syntax_completion = 1

  -- Do not load spell files
  vim.g.loaded_spellfile_plugin = 1
  -- newtrw liststyle: https://medium.com/usevim/the-netrw-style-options-3ebe91d42456
  vim.g.netrw_liststyle = 3

  -- Do not load tohtml.vim
  vim.g.loaded_2html_plugin = 1

  -- Do not load zipPlugin.vim, gzip.vim and tarPlugin.vim (all these plugins are
  -- related to checking files inside compressed files)
  vim.g.loaded_gzip = 1
  vim.g.loaded_tar = 1
  vim.g.loaded_tarPlugin = 1
  vim.g.loaded_vimball = 1
  vim.g.loaded_vimballPlugin = 1
  vim.g.loaded_zip = 1
  vim.g.loaded_zipPlugin = 1

  -- Do not use builtin matchit.vim and matchparen.vim since the use of vim-matchup
  vim.g.loaded_matchit = 1
  vim.g.loaded_matchparen = 1

  -- Disable sql omni completion.
  vim.g.loaded_sql_completion = 1
end

M.setup = function()
  setup_global_envars()
  create_dir()
  disable_distribution_plugins()

  vim.g.mapleader = ","
  vim.api.nvim_set_keymap("n", ",", "", { noremap = true })
  vim.api.nvim_set_keymap("x", ",", "", { noremap = true })

  vim.g.maplocalleader = "+"

  -- Add Packer commands because we are not loading it at startup
  api.nvim_command("silent! command PackerClean lua require 'plugins' require('packer').clean()")
  api.nvim_command("silent! command PackerCompile lua require 'plugins' require('packer').compile()")
  api.nvim_command("silent! command PackerInstall lua require 'plugins' require('packer').install()")
  api.nvim_command("silent! command PackerStatus lua require 'plugins' require('packer').status()")
  api.nvim_command("silent! command PackerSync lua require 'plugins' require('packer').sync()")
  api.nvim_command("silent! command PackerUpdate lua require 'plugins' require('packer').update()")
  api.nvim_create_autocmd("User", {
    pattern = "PackerComplete",
    callback = function()
      require("plugins")
      require("packer").compile()
    end,
  })

  require("core.options")
  require("core.mappings")
  require("core.events")

  -- plugins
  require("trimwhite")

  vim.api.nvim_command("silent! colorscheme " .. __editor_config.colorscheme)
end

return M
