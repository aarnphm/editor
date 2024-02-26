require "aarnphm.disabled_builtin"
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

-- local colorscheme = vim.NIL ~= vim.env.SIMPLE_COLORSCHEME and vim.env.SIMPLE_COLORSCHEME or "rose-pine"
-- local background = vim.NIL ~= vim.env.SIMPLE_BACKGROUND and vim.env.SIMPLE_BACKGROUND or "light"
-- vim.g.simple_colorscheme = colorscheme
-- vim.g.simple_background = background

Util.format.setup()

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
    "fugitive",
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

autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "CmdwinEnter" }, {
  group = augroup "disable_statusline",
  command = [[if match(bufname('%'), 'starter') != -1 || match(bufname('%'), 'nofile') != -1 || match(bufname('%'), 'toggleterm') != -1 || bufname('%') == '' | set laststatus=0 | else | set laststatus=3 | endif]],
})

autocmd("BufWinEnter", {
  group = augroup "Fugitive",
  pattern = "*",
  callback = function()
    if vim.bo.ft ~= "fugitive" then return end
    local bufnr = vim.api.nvim_get_current_buf()
    vim.keymap.set(
      "n",
      "<leader>p",
      "<CMD>Git pull --rebase<CR>",
      { desc = "git: pull rebase", buffer = bufnr, remap = false }
    )
    vim.keymap.set(
      "n",
      "<leader>P",
      function() vim.cmd.Git "push" end,
      { desc = "git: push", buffer = bufnr, remap = false }
    )
    vim.keymap.set(
      "n",
      "<leader>cc",
      "<CMD>Git commit -S --signoff -sv<CR>",
      { desc = "git: commit", buffer = bufnr, remap = false }
    )
    vim.keymap.set(
      "n",
      "<leader>t",
      ":Git push -u origin ",
      { desc = "git: push to specific branch", buffer = bufnr, remap = false }
    )
  end,
})

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

require("lazy").setup("plugins", { change_detection = { notify = false }, ui = { border = BORDER } })
