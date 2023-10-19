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
    "%{%luaeval('statusline.mode {trunc_width = 75}')%}",
    "%{%luaeval('statusline.git {trunc_width = 120}')%}",
    "%<",
    "%{%luaeval('statusline.filename {trunc_width = 75}')%}",
    "%=",
    "%{%luaeval('statusline.diagnostic {trunc_width = 90}')%}",
    "%{%luaeval('statusline.filetype {trunc_width = 75}')%}",
    "%{%luaeval('statusline.location {trunc_width = 90}')%}",
  }, " ")
end

require("lazy").setup("plugins", { change_detection = { notify = false } })

vim.o.background = vim.g.simple_background
vim.cmd.colorscheme(vim.g.simple_colorscheme)

require("mini.colors").get_colorscheme():add_cterm_attributes():apply()
-- vim.opt.termguicolors = false -- NOTE: this should only be run on Terminal.app
