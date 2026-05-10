_G.Util = require "utils"
_G.augroup = function(name) return vim.api.nvim_create_augroup(("simple_%s"):format(name), { clear = true }) end

_G.hi = function(name, opts)
  opts.default = opts.default or true
  opts.force = opts.force or true
  vim.api.nvim_set_hl(0, name, opts)
end

for _, provider in ipairs { "node", "perl", "python3", "ruby" } do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end

for _, plugin in ipairs {
  "gzip",
  "netrw",
  "netrwPlugin",
  "rplugin",
  "tarPlugin",
  "tutor",
  "zipPlugin",
} do
  vim.g["loaded_" .. plugin] = 1
end

local background = os.getenv "XDG_SYSTEM_THEME"
vim.go.background = background ~= nil and background or "dark"

if vim.uv.os_uname().sysname == "Darwin" then
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
    cache_enabled = 0,
  }
end

vim.g.mapleader = vim.keycode "<space>"
vim.g.maplocalleader = vim.keycode ","
vim.g.markdown_recommended_style = 0
vim.g.autoformat = true
vim.g.enable_highlighturl = true

hi("HighlightURL", { default = true, underline = true })
hi("CmpGhostText", { link = "Comment", default = true })
hi("LeapBackdrop", { link = "Comment" })
hi("LeapMatch", { fg = vim.go.background == "dark" and "white" or "black", bold = true, nocombine = true })

Util.pack.setup()
