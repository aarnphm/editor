require "aarnphm" -- default setup

if vim.g.vscode then return end -- NOTE: compatible block with vscode

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

require("lazy").setup("plugins", {
  install = { colorscheme = { "rose-pine" } },
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
  ui = { border = "single" },
})

vim.o.background = vim.NIL ~= vim.env.SIMPLE_BACKGROUND and vim.env.SIMPLE_BACKGROUND or "light"
vim.cmd.colorscheme(vim.NIL ~= vim.env.SIMPLE_COLORSCHEME and vim.env.SIMPLE_COLORSCHEME or "rose-pine")

require("mini.colors").get_colorscheme():add_cterm_attributes():apply()
-- vim.opt.termguicolors = false -- NOTE: this should only be run on Terminal.app
