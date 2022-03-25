local fn, uv, api = vim.fn, vim.loop, vim.api
local modules_dir = _G.__editor_global.vim_path .. "/lua/modules"
local packer_compiled = _G.__editor_global.data_dir .. "lua/_compiled.lua"
local checked_compiled = _G.__editor_global.vim_path .. "/_compiled.lua"

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
  use({ "nathom/filetype.nvim" })
  use({ "stevearc/dressing.nvim" })
  use({ "kyazdani42/nvim-web-devicons" })
  -- Needed while issue https://github.com/neovim/neovim/issues/12587 is still open
  use({ "antoinemadec/FixCursorHold.nvim" })
  use({
    "lewis6991/spaceless.nvim",
    config = function()
      require("spaceless").setup()
    end,
  })

  -- colorscheme
  require("themes.plugins").init(use)

  use({ "wbthomason/packer.nvim", opt = true })
  use({
    "rcarriga/nvim-notify",
    config = function()
      vim.defer_fn(function()
        local ok, notify = pcall(require, "notify")
        if not ok then
          return
        end
        local notify_config = {
          -- Animation style (see below for details)
          stages = "fade",

          -- Function called when a new window is opened, use for changing win settings/config
          on_open = nil,

          -- Function called when a window is closed
          on_close = nil,

          -- Render function for notifications. See notify-render()
          render = "default",

          -- Default timeout for notifications
          timeout = 5000,

          -- For stages that change opacity this is treated as the highlight behind the window
          -- Set this to either a highlight group, an RGB hex value e.g. "#000000" or a function returning an RGB code for dynamic values
          background_colour = "Normal",

          -- Minimum width for notification windows
          max_width = 50,
          minimum_width = 20,

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
      end, 2000)
    end,
    event = "BufEnter",
  })
  use({
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
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

function plugins.magic_compile()
  if vim.fn.filereadable(packer_compiled) == 1 then
    local _compiled_file = io.open(packer_compiled, "r")
    local pre_compiled = _compiled_file:read("*a")
    _compiled_file:close()
    local _compiled_cache = io.open(checked_compiled, "w")
    _compiled_cache:write(pre_compiled)
    _compiled_cache:close()
  end
  plugins.compile()
end

function plugins.auto_compile()
  local file = vim.fn.expand("%:p")
  if file:match(modules_dir) then
    plugins.clean()
    plugins.magic_compile()
  end
end

function plugins.load_compile()
  if vim.fn.filereadable(packer_compiled) == 1 then
    require("_compiled")
  else
    assert("Missing packer compile file, run PackerCompile Or PackerInstall to fix")
  end
  vim.cmd([[autocmd User PackerComplete lua require('core.pack').magic_compile()]])
  vim.cmd(
    [[command! -nargs=+ -complete=customlist,v:lua.require'packer.snapshot'.completion.create PackerSnapshot  lua require('packer').snapshot(<f-args>)]]
  )
  vim.cmd(
    [[command! -nargs=+ -complete=customlist,v:lua.require'packer.snapshot'.completion.rollback PackerSnapshotRollback  lua require('packer').rollback(<f-args>)]]
  )
  vim.cmd(
    [[command! -nargs=+ -complete=customlist,v:lua.require'packer.snapshot'.completion.snapshot PackerSnapshotDelete lua require('packer.snapshot').delete(<f-args>)]]
  )
  vim.cmd(
    [[command! -nargs=* -complete=customlist,v:lua.require'packer'.plugin_complete  PackerInstall lua require('packer').install(<f-args>)]]
  )
  vim.cmd(
    [[command! -nargs=* -complete=customlist,v:lua.require'packer'.plugin_complete PackerUpdate lua require('packer').update(<f-args>)]]
  )
  vim.cmd(
    [[command! -nargs=* -complete=customlist,v:lua.require'packer'.plugin_complete PackerSync lua require('packer').sync(<f-args>)]]
  )
  vim.cmd([[command! PackerClean             lua require('packer').clean()]])
  vim.cmd([[command! -nargs=* PackerCompile  lua require('packer').compile(<q-args>)]])
  vim.cmd([[command! PackerStatus            lua require('packer').status()]])
  vim.cmd([[command! PackerProfile           lua require('packer').profile_output()]])
  vim.cmd(
    [[command! -bang -nargs=+ -complete=customlist,v:lua.require'packer'.loader_complete PackerLoad lua require('packer').loader(<f-args>, '<bang>' == '!')]]
  )
end

return plugins
