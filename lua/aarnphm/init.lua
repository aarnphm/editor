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

require "aarnphm.globals"
require "aarnphm.options"
require "aarnphm.bindings"

local colorscheme = vim.NIL ~= vim.env.SIMPLE_COLORSCHEME and vim.env.SIMPLE_COLORSCHEME or "rose-pine"
local background = vim.NIL ~= vim.env.SIMPLE_BACKGROUND and vim.env.SIMPLE_BACKGROUND or "light"

vim.g.simple_colorscheme = colorscheme
vim.g.simple_background = background

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup "filetype",
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "man",
    "nowrite", -- fugitive
    "prompt",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neorepl",
    "alpha",
    "toggleterm",
    "health",
    "nofile",
    "scratch",
    "",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<cmd>close<cr>", { silent = true })
  end,
})
-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, { group = augroup "checktime", command = "checktime" })
autocmd("VimResized", {
  group = augroup "resized",
  callback = function()
    local current = vim.fn.tabpagenr()
    vim.cmd "tabdo wincmd ="
    vim.cmd("tabnext  " .. current)
  end,
})
autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "CmdwinEnter" }, {
  group = augroup "disable_statusline",
  command = [[if match(bufname('%'), 'neo-tree') != -1 || match(bufname('%'), 'nofile') != -1 || bufname('%') == '' | set laststatus=0 | else | set laststatus=2 | endif]],
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

if vim.g.vscode then return end -- NOTE: compatible block with vscode
