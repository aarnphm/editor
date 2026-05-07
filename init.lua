_G.augroup = function(name) return vim.api.nvim_create_augroup(("simple_%s"):format(name), { clear = true }) end

_G.hi = function(name, opts)
  opts.default = opts.default or true
  opts.force = opts.force or true
  vim.api.nvim_set_hl(0, name, opts)
end

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

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
-- leader
vim.g.mapleader = vim.keycode "<space>"
vim.g.maplocalleader = vim.keycode ","
-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
-- autoformat on save
vim.g.autoformat = true
vim.g.markdown_frontmatter = true
-- additional plugins to be used.
vim.g.extra_plugins = {
  -- lang
  "plugins.lang.clangd",
  "plugins.lang.json",
  "plugins.lang.go",
  "plugins.lang.nix",
  "plugins.lang.rust",
  "plugins.lang.yaml",
  "plugins.lang.python",
  "plugins.lang.ocaml",
  "plugins.lang.markdown",
  "plugins.lang.mojo",
  "plugins.lang.tailwind",
  "plugins.lang.typescript",
  "plugins.lang.zig",
  -- "plugins.lang.sql",
}
-- underscore URL
vim.g.enable_highlighturl = true

hi("HighlightURL", { default = true, underline = true })
hi("CmpGhostText", { link = "Comment", default = true })
hi("LeapBackdrop", { link = "Comment" })
hi("LeapMatch", { fg = vim.go.background == "dark" and "white" or "black", bold = true, nocombine = true })

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

require("utils").setup {
  spec = { { import = "plugins" } },
  rocks = { enabled = false },
  change_detection = { notify = false },
  ui = { border = "single", backdrop = 100, wrap = false },
  dev = { path = "~/workspace/neovim-plugins/" },
}
