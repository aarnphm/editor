local fn, api = vim.fn, vim.api
local is_mac = __editor_global.is_mac
local vim_path = __editor_global.vim_path
local data_dir = __editor_global.data_dir
local lazy_path = data_dir .. "lazy/lazy.nvim"
local modules_dir = vim_path .. "/lua/modules"

local use_ssh = __editor_config.use_ssh

local icons = {
  kind = require("modules.ui.icons").get("kind"),
  documents = require("modules.ui.icons").get("documents"),
  ui = require("modules.ui.icons").get("ui"),
  ui_sep = require("modules.ui.icons").get("ui", true),
  misc = require("modules.ui.icons").get("misc"),
}

local Lazy = {}
Lazy.__index = Lazy

function Lazy:load_plugins()
  self.repos = {}

  local get_plugins_list = function()
    local list = {}
    local tmp = vim.split(fn.globpath(modules_dir, "*/plugins.lua"), "\n")
    local subtmp = vim.split(fn.globpath(modules_dir, "*/user/plugins.lua"), "\n")
    for _, v in ipairs(subtmp) do
      if v ~= "" then
        table.insert(tmp, v)
      end
    end
    for _, f in ipairs(tmp) do
      -- fill list with `plugins.lua`'s path used for later `require` like this:
      -- list[#list + 1] = "modules/completion/plugins.lua"
      list[#list + 1] = f:sub(#modules_dir - 6, -1)
    end
    return list
  end

  local plugins_file = get_plugins_list()
  for _, m in ipairs(plugins_file) do
    -- require repos which returned in `plugins.lua` like this:
    -- local repos = require("modules/completion/plugins")
    local repos = require(m:sub(0, #m - 4))
    for repo, conf in pairs(repos) do
      self.repos[#self.repos + 1] = vim.tbl_extend("force", { repo }, conf)
    end
  end
end

function Lazy:load_lazy()
  if not vim.loop.fs_stat(lazy_path) then
    local lazy_repo = use_ssh and "git@github.com:folke/lazy.nvim.git" or "https://github.com/folke/lazy.nvim.git"
    fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      lazy_repo,
      "--branch=stable",
      lazy_path,
    })
  end
  self:load_plugins()
  local clone_prefix = use_ssh and "git@github.com:%s.git" or "https://github.com/%s.git"
  local lazy_settings = {
    root = data_dir .. "lazy",
    git = {
      log = { "-10" },
      timeout = 300,
      url_format = clone_prefix,
    },
    install = {
      missing = true,
      colorscheme = { "catppuccin" },
    },
    ui = {
      border = "rounded",
    },
  }
  if is_mac then
    lazy_settings.concurrency = 20
  end
  vim.opt.rtp:prepend(lazy_path)
  require("lazy").setup(self.repos, lazy_settings)
end

Lazy:load_lazy()
