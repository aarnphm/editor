local fn, uv, api = vim.fn, vim.loop, vim.api
local modules_dir = _G.__editor_global.vim_path .. "/lua/modules"
local packer_compiled = _G.__editor_global.data_dir .. "lua/_compiled.lua"

local packer = nil

local Packer = {}
Packer.__index = Packer

function Packer:load_plugins()
  self.repos = {}

  local get_plugins_list = function()
    local list = {}
    local tmp = vim.split(fn.globpath(modules_dir, "*/plugins.lua"), "\n")
    for _, f in ipairs(tmp) do
      list[#list + 1] = f:sub(#modules_dir - 6, -1)
    end
    return list
  end

  local plugins_file = get_plugins_list()
  for _, m in ipairs(plugins_file) do
    local repos = require(m:sub(0, #m - 4))
    for repo, conf in pairs(repos) do
      self.repos[#self.repos + 1] = vim.tbl_extend("force", { repo }, conf)
    end
  end
end

function Packer:load_preflight_plugins(use)
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

  -- colorscheme
  require("themes.plugins").init(use)

  -- notify
  use({
    "rcarriga/nvim-notify",
    config = function()
      local ok, notify = pcall(require, "notify")
      if not ok then
        return
      end
      local notify_config = {
        -- Animation style (see below for details)
        stages = "fade",
        -- Default timeout for notifications
        timeout = 5000,
        -- Minimum width for notification windows
        max_width = 100,
        minimum_width = 50,

        -- Icons for the different levels
        icons = {
          ERROR = "",
          WARN = "",
          INFO = "",
          DEBUG = "",
          TRACE = "✎",
        },
      }
      notify.setup(notify_config)
      vim.notify = notify
    end,
  })
  use({
    "glepnir/dashboard-nvim",
    event = { "BufWinEnter", "BufNewFile" },
    after = "impatient.nvim",
  })
end

function Packer:load_packer()
  if not packer then
    vim.cmd([[packadd packer.nvim]])
    packer = require("packer")
  end

  local use = packer.use

  local packer_config = {
    compile_path = packer_compiled,
    git = { clone_timeout = 60, default_url_format = "git@github.com:%s" },
    disable_commands = true,
    auto_clean = true,
    compile_on_sync = true,
    auto_reload_compiled = true,
    autoremove = true,
    display = {
      open_fn = function()
        return require("packer.util").float({ border = "single" })
      end,
    },
  }
  if _G.__editor_global.is_mac then
    packer_config.max_jobs = 20
  end

  packer.init(packer_config)

  packer.reset()

  self:load_plugins()
  self:load_preflight_plugins(use)
  for _, repo in ipairs(self.repos) do
    use(repo)
  end
end

function Packer:init_ensure_plugins()
  local packer_dir = _G.__editor_global.data_dir .. "pack/packer/opt/packer.nvim"
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = "!git clone https://github.com/wbthomason/packer.nvim " .. packer_dir
    api.nvim_command(cmd)
    uv.fs_mkdir(_G.__editor_global.data_dir .. "lua", 511, function()
      assert("make compile path dir failed")
    end)
    self:load_packer()
    packer.install()
  end
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if not packer then
      Packer:load_packer()
    end
    return packer[key]
  end,
})

function plugins.ensure_plugins()
  Packer:init_ensure_plugins()
end

function plugins.load_compile()
  if vim.fn.filereadable(packer_compiled) == 1 then
    require("_compiled")
  else
    assert("Missing packer compile file, run PackerCompile Or PackerInstall to fix")
  end

  vim.cmd([[autocmd User PackerComplete lua require('core.pack').compile()]])

  if _G.__editor_config.debug then
    if not packer then
      vim.cmd([[packadd packer.nvim]])
      packer = require("packer")
    end

    packer.make_commands()
    vim.cmd([[command! PackerCompile lua require('core.pack').compile()]])
    vim.cmd([[command! PackerInstall lua require('core.pack').install()]])
    vim.cmd([[command! PackerUpdate lua require('core.pack').update()]])
    vim.cmd([[command! PackerSync lua require('core.pack').sync()]])
    vim.cmd([[command! PackerClean lua require('core.pack').clean()]])
    vim.cmd([[command! PackerStatus lua require('packer').status()]])
  end
end

return plugins
