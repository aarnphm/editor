local uv = vim.loop
local fn = vim.fn

local packer_dir = _G.__editor_global.data_dir .. "pack/packer/opt/packer.nvim"
local packer_compiled = _G.__editor_global.data_dir .. "lua/_compiled.lua"

local packer = nil
local packer_bootstrap = nil

local M = {}

M.init_packer = function()
  if not packer then
    vim.cmd([[packadd packer.nvim]])
    packer = require("packer")
  end

  local packer_config = {
    compile_path = packer_compiled,
    git = { clone_timeout = 60, default_url_format = "git@github.com:%s" },
    auto_clean = true,
    compile_on_sync = true,
    auto_reload_compiled = true,
    display = {
      open_fn = function()
        return require("packer.util").float({ border = "single" })
      end,
    },
    profile = {
      enable = true,
    },
  }
  if _G.__editor_global.is_mac then
    packer_config.max_jobs = 20
  end

  packer.init(packer_config)
end

local get_plugins_list = function()
  local list = {}
  local tmp = vim.split(fn.globpath(_G.__editor_global.modules_dir, "*/plugins.lua"), "\n")
  for _, f in ipairs(tmp) do
    list[#list + 1] = f:sub(#_G.__editor_global.modules_dir - 6, -1)
  end
  return list
end

local get_plugins_mapping = function()
  local plugins = {}

  for _, m in ipairs(get_plugins_list()) do
    local repos = require(m:sub(0, #m - 4))
    for repo, conf in pairs(repos) do
      plugins[#plugins + 1] = vim.tbl_extend("force", { repo }, conf)
    end
  end
  return plugins
end

local required_plugins = function(use)
  use({ "lewis6991/impatient.nvim" })
  use({
    "nathom/filetype.nvim",
    config = function()
      require("filetype").setup({})
    end,
  })
  use({ "kyazdani42/nvim-web-devicons" })
  -- Needed while issue https://github.com/neovim/neovim/issues/12587 is still open
  use({ "antoinemadec/FixCursorHold.nvim" })
  use({ "stevearc/dressing.nvim" })

  use({ "wbthomason/packer.nvim", opt = true })

  -- tpope
  use({ "tpope/vim-sleuth" })
  use({ "tpope/vim-surround" })
  use({ "tpope/vim-commentary" })

  -- notify
  use({
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      local notify_config = {
        -- Animation style (see below for details)
        stages = "static",
        -- Default timeout for notifications
        timeout = 3000,
        -- Minimum width for notification windows
        minimum_width = 50,

        -- Icons for the different levels
        icons = {
          ERROR = " ",
          WARN = " ",
          INFO = " ",
          DEBUG = " ",
          TRACE = "✎ ",
        },
      }
      notify.setup(notify_config)
      vim.notify = notify
    end,
  })
  use({
    "glepnir/dashboard-nvim",
    event = { "BufWinEnter", "BufNewFile" },
  })

  -- colorscheme
  require("themes").setup(use)
end

M.setup_plugins = function()
  M.init_packer()

  packer.startup(function(use)
    required_plugins(use)
    for _, repo in ipairs(get_plugins_mapping()) do
      use(repo)
    end
  end)
end

M.install_packer = function()
  local state = uv.fs_stat(packer_dir)
  if not state then
    packer_bootstrap = fn.system({
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      packer_dir,
    })
    uv.fs_mkdir(_G.__editor_global.data_dir .. "lua", 511, function()
      assert("make compile path dir failed")
    end)
    M.setup_plugins()
  end
  if packer_bootstrap then
    require("packer").sync()
  end
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if not packer then
      M.setup_plugins()
    end
    return packer[key]
  end,
})

plugins.load = function()
  M.install_packer()

  if vim.fn.filereadable(packer_compiled) == 1 then
    require("_compiled")
  else
    assert("Missing packer compile file, run PackerCompile Or PackerInstall to fix")
  end

  vim.cmd([[autocmd User PackerComplete lua require('core.pack').compile()]])

  vim.opt.background = _G.__editor_config.background
  if _G.__editor_config.debug then
    vim.cmd([[command! PackerCompile lua require('core.pack').compile()]])
    vim.cmd([[command! PackerInstall lua require('core.pack').install()]])
    vim.cmd([[command! PackerUpdate lua require('core.pack').update()]])
    vim.cmd([[command! PackerSync lua require('core.pack').sync()]])
    vim.cmd([[command! PackerClean lua require('core.pack').clean()]])
    vim.cmd([[command! PackerStatus lua require('packer').status()]])
  end
end

return plugins
