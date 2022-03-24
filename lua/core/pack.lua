local fn, uv, api = vim.fn, vim.loop, vim.api
local is_mac = require("core.global").is_mac
local vim_path = require("core.global").vim_path
local data_dir = require("core.global").data_dir
local sep = require("core.global").path_sep
local modules_dir = vim_path .. "/lua/modules"
local packer_compiled = data_dir .. "packer_compiled.vim"
local compile_to_lua = data_dir .. "lua/_compiled.lua"

local packer = nil

local Packer = {}
Packer.__index = Packer

function Packer:config()
  return require("core.global").load_config()
end

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
  use({ "kyazdani42/nvim-web-devicons" })

  -- colorscheme
  require("themes.plugins").init(use, Packer:config())

  use({ "wbthomason/packer.nvim", opt = true })
  use({
    "rcarriga/nvim-notify",
    config = function()
      vim.defer_fn(function()
        require("notify").setup({
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
        })
        vim.notify = require("notify")
      end, 2000)
    end,
    event = "BufEnter",
  })
  use({ "stevearc/dressing.nvim" })
  -- Needed while issue https://github.com/neovim/neovim/issues/12587 is still open
  use({ "antoinemadec/FixCursorHold.nvim" })
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
    display = {
      open_fn = function()
        return require("packer.util").float({ border = "single" })
      end,
    },
  }
  if is_mac then
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
  local packer_dir = data_dir .. "pack/packer/opt/packer.nvim"
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = "!git clone https://github.com/wbthomason/packer.nvim " .. packer_dir
    api.nvim_command(cmd)
    uv.fs_mkdir(data_dir .. "lua", 511, function()
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

function plugins.convert_compile_file()
  local state = uv.fs_stat(packer_compiled)
  if not state then
    -- first time compiling
    local pre_compiled_file = io.open(vim_path .. sep .. "_pre_compiled.lua", "r")
    local pre_compiled = pre_compiled_file:read("*a")
    pre_compiled_file:close()
    local _compiled_cache = io.open(compile_to_lua, "w")
    _compiled_cache:write(pre_compiled)
    _compiled_cache:close()
  else
    local lines = {}
    local lnum = 1
    lines[#lines + 1] = "vim.cmd [[packadd packer.nvim]]\n"

    for line in io.lines(packer_compiled) do
      lnum = lnum + 1
      if lnum > 15 then
        lines[#lines + 1] = line .. "\n"
        if line == "END" then
          break
        end
      end
    end
    table.remove(lines, #lines)

    if vim.fn.isdirectory(data_dir .. "lua") ~= 1 then
      os.execute("mkdir -p " .. data_dir .. "lua")
    end

    if vim.fn.filereadable(compile_to_lua) == 1 then
      os.remove(compile_to_lua)
    end

    local file = io.open(compile_to_lua, "w")
    for _, line in ipairs(lines) do
      file:write(line)
    end
    file:close()

    os.remove(packer_compiled)
  end
end

function plugins.magic_compile()
  plugins.compile()
  plugins.convert_compile_file()
end

function plugins.auto_compile()
  local file = vim.fn.expand("%:p")
  if file:match(modules_dir) then
    plugins.clean()
    plugins.compile()
    plugins.convert_compile_file()
  end
end

function plugins.load_compile()
  if vim.fn.filereadable(compile_to_lua) == 1 then
    require("_compiled")
  else
    assert("Missing packer compile file, run PackerCompile Or PackerInstall to fix")
  end

  vim.cmd([[command! PackerCompile lua require('core.pack').magic_compile()]])
  vim.cmd([[command! PackerInstall lua require('core.pack').install()]])
  vim.cmd([[command! PackerUpdate lua require('core.pack').update()]])
  vim.cmd([[command! PackerSync lua require('core.pack').sync()]])
  vim.cmd([[command! PackerClean lua require('core.pack').clean()]])
  vim.cmd([[autocmd User PackerComplete lua require('core.pack').magic_compile()]])
  vim.cmd([[command! PackerStatus  lua require('packer').status()]])
end

return plugins
