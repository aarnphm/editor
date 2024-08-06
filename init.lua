require "aarnphm.globals"
require "aarnphm.options"
require "aarnphm.bindings"

-- NOTE: Loading shada is slow, so we load it manually after UIEnter
local shada = vim.o.shada
local autocmd = vim.api.nvim_create_autocmd

vim.o.shada = ""
autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.o.shada = shada
    pcall(vim.api.nvim_exec2, "rshada", {})
  end,
})

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup "filetype",
  pattern = {
    "PlenaryTestPopup",
    "help",
    "grug-far",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "man",
    "gitsigns.blame",
    "nowrite", -- fugitive
    "fugitive",
    "prompt",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neorepl",
    "alpha",
    "health",
    "nofile",
    "scratch",
    "starter",
    "",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<cmd>close<cr>", { silent = true })
  end,
})
-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup "checktime",
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd "checktime" end
  end,
})
autocmd("VimResized", {
  group = augroup "resized",
  callback = function()
    local current = vim.fn.tabpagenr()
    vim.cmd "tabdo wincmd ="
    vim.cmd("tabnext  " .. current)
  end,
})
-- go to last loc when opening a buffer
autocmd("BufReadPost", {
  group = augroup "last_loc",
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].simple_last_loc then return end
    vim.b[buf].simple_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})
autocmd(
  "BufWritePre",
  { group = augroup "tempfile", pattern = { "/tmp/*", "*.tmp", "*.bak" }, command = "setlocal noundofile" }
)
-- wrap and check for spell in text filetypes
autocmd("FileType", {
  group = augroup "wrap_spell",
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
autocmd(
  { "BufNewFile", "BufRead" },
  { group = augroup "cpp_headers", pattern = { "*.h", "*.hpp", "*.hxx", "*.hh" }, command = "setlocal filetype=c" }
)
autocmd({ "BufNewFile", "BufRead", "FileType" }, {
  group = augroup "dockerfile",
  pattern = { "*.dockerfile", "Dockerfile-*", "Dockerfile.*", "Dockerfile.template" },
  command = "setlocal filetype=dockerfile",
})
-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup "highlight_yank",
  pattern = "*",
  callback = function(_) vim.highlight.on_yank { higroup = "IncSearch", timeout = 100 } end,
})

autocmd("BufWritePost", {
  group = augroup "trim_whitespace",
  callback = function() require("mini.trailspace").trim() end,
})

vim.cmd [[
  augroup simple_numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
  augroup END
]]

-- Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("custom-term-open", {}),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.scrolloff = 0
    vim.bo.filetype = "terminal"
  end,
})

if vim.g.vscode then return end -- NOTE: compatible block with vscode

-- bootstrap logics
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

Util.plugin.setup()
Util.root.setup()
Util.format.setup()

local get_lockfile = function()
  -- local workspace = os.getenv "WORKSPACE"
  -- return workspace ~= nil and workspace .. "/editor/lazy-lock.json" or vim.fn.stdpath "config" .. "/lazy-lock.json"
  return vim.fn.stdpath "config" .. "/lazy-lock.json"
end

require("lazy").setup {
  spec = {
    { import = "plugins" },
  },
  lockfile = get_lockfile(),
  change_detection = { notify = false },
  checker = { enabled = true, frequency = 3600 * 24, notify = false },
  colorscheme = { "rose-pine" },
  ui = {
    border = "none",
    backdrop = 100,
    wrap = false,
  },
}

-- vim.opt.termguicolors = true
vim.cmd.colorscheme "rose-pine-dawn"
-- TODO: refactor this one day
local hi = function(name, opts)
  opts.default = opts.default or true
  opts.force = opts.force or true
  vim.api.nvim_set_hl(0, name, opts)
end
-- vim.cmd.colorscheme "habamax"
hi("MiniFilesBorder", { link = "Normal" })
hi("MiniFilesNormal", { link = "Normal" })
hi("VertSplit", { fg = "NONE", bg = "NONE", bold = false })
hi("StatusLine", { link = "Normal" })
