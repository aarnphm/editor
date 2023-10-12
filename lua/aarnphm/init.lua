require('aarnphm.globals')
require('aarnphm.options')
require('aarnphm.bindings')

local autocmd = vim.api.nvim_create_autocmd

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup "filetype",
  pattern = {
    "qf",
    "help",
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
    "PlenaryTestPopup",
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
autocmd({"FocusGained", "TermClose", "TermLeave"}, {group = augroup "checktime", pattern = "*", command = "checktime"})
autocmd("VimResized", {group = augroup "resized", command = "tabdo wincmd ="})
autocmd("BufWritePre", {group = augroup "tempfile", pattern = {"/tmp/*", "*.tmp", "*.bak"}, command = "setlocal noundofile"})
autocmd({"BufNewFile", "BufRead"}, {group = augroup "cpp_headers", pattern = {"*.h", "*.hpp", "*.hxx", "*.hh"}, command = "setlocal filetype=c"})
autocmd({"BufNewFile", "BufRead", "FileType"}, {group = augroup "dockerfile", pattern = {"*.dockerfile", "Dockerfile-*", "Dockerfile.*", "Dockerfile.template"}, command = "setlocal filetype=dockerfile"})
-- Highlight on yank
autocmd("TextYankPost", {group = augroup "highlight_yank", pattern = "*", callback = function(_) vim.highlight.on_yank { higroup = "IncSearch", timeout = 100 } end})
