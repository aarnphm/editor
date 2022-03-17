local global = require("core.global")
local vim = vim
local g = vim.g
local api = vim.api

local M = {}

-- Create cache dir and subs dir
local init_dir = function()
  local data_dir = {
    global.cache_dir .. "backup",
    global.cache_dir .. "session",
    global.cache_dir .. "swap",
    global.cache_dir .. "tags",
    global.cache_dir .. "undo",
  }
  -- There only check once that If cache_dir exists
  -- Then I don't want to check subs dir exists
  if vim.fn.isdirectory(global.cache_dir) == 0 then
    os.execute("mkdir -p " .. global.cache_dir)
    for _, v in pairs(data_dir) do
      if vim.fn.isdirectory(v) == 0 then
        os.execute("mkdir -p " .. v)
      end
    end
  end
end

local disable_distribution_plugins = function()
  g.loaded_fzf = 1
  g.loaded_gtags = 1
  g.loaded_gzip = 1
  g.loaded_tar = 1
  g.loaded_tarPlugin = 1
  g.loaded_zip = 1
  g.loaded_zipPlugin = 1
  g.loaded_getscript = 1
  g.loaded_getscriptPlugin = 1
  g.loaded_vimball = 1
  g.loaded_vimballPlugin = 1
  g.loaded_matchit = 1
  g.loaded_matchparen = 1
  g.loaded_2html_plugin = 1
  g.loaded_logiPat = 1
  g.loaded_rrhelper = 1
  g.loaded_netrw = 1
  g.loaded_netrwPlugin = 1
  g.loaded_netrwSettings = 1
  g.loaded_netrwFileHandlers = 1
end

local function minimap_config()
  g.minimap_auto_start = 0
  g.minimap_block_filetypes = { "aerial", "NvimTree" }
  g.minimap_git_colors = 1
end

function M:preflight()
  init_dir()
  disable_distribution_plugins()
  minimap_config()

  g.mapleader = ","
  api.nvim_set_keymap("n", " ", "", { noremap = true })
  api.nvim_set_keymap("x", " ", "", { noremap = true })
end

function M:setup()
  local pack = require("core.pack")
  M.preflight()
  pack.setup_plugins()
  pack.dashboard_config()
  require("core.options")
  require("core.mapping")
  require("core.event")
  require("core.keymap")
  pack.load_compile()

  vim.cmd([[colorscheme catppuccin]])
end

return M
