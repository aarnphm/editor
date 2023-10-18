require "aarnphm" -- default setup

-- bootstrap logics
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  }
end
vim.opt.runtimepath:prepend(lazypath)

-- setup statusline line here
if not Util.has "mini.statusline" then
  vim.o.statusline = table.concat({
    "%{%luaeval('statusline.mode {}')%}",
    "%{%luaeval('statusline.git {}')%}",
    "%m",
    "%=",
    "%=",
    "%{%luaeval('statusline.diagnostic {}')%}",
    "%y",
    "%l:%c",
    "♥",
  }, " ")
end

require("lazy").setup("plugins", {
  install = { colorscheme = { vim.g.simple_colorscheme } },
  defaults = { lazy = false, version = false },
  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {
      reset = true,
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "man",
      },
    },
  },
  change_detection = { notify = false },
  concurrency = vim.loop.os_uname() == "Darwin" and 30 or nil,
  checker = { enable = true },
})

vim.o.background = vim.g.simple_background
vim.cmd.colorscheme(vim.g.simple_colorscheme)

require("mini.colors").get_colorscheme():add_cterm_attributes():apply()
-- vim.opt.termguicolors = false -- NOTE: this should only be run on Terminal.app
