require "aarnphm.globals"
require "aarnphm.options"
require "aarnphm.bindings"

-- NOTE: Loading shada is slow, so we load it manually after UIEnter
local shada = vim.o.shada
local autocmd = vim.api.nvim_create_autocmd

-- NOTE: local items
local M = {
  disable = {
    filetypes = { "ministarter", "dashboard", "qf", "help", "grug-far", "TelescopePrompt" },
    buftypes = { "quickfix", "prompt", "scratch", "ministarter" },
  },
}

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
  group = augroup "filetype_q",
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
    "trouble",
    "",
  },
  callback = function(event)
    vim.o.laststatus = 0
    vim.bo[event.buf].buflisted = false
    vim.b[event.buf].ministatusline_disable = true
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
-- correct resized tabs
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
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})
-- make it easier to close man-files when opened inline
autocmd("FileType", {
  group = augroup "man_unlisted",
  pattern = { "man" },
  callback = function(event) vim.bo[event.buf].buflisted = false end,
})
-- Fix conceallevel for json files
autocmd("FileType", {
  group = augroup "json_conceal",
  pattern = { "json", "jsonc", "json5" },
  callback = function() vim.opt_local.conceallevel = 0 end,
})
-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd("BufWritePre", {
  group = augroup "auto_create_dir",
  callback = function(event)
    if event.match:match "^%w%w+:[\\/][\\/]" then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
-- Set additional filetype for dockerfile
autocmd({ "BufNewFile", "BufRead", "FileType" }, {
  group = augroup "dockerfile",
  pattern = { "*.dockerfile", "Dockerfile-*", "Dockerfile.*", "Dockerfile.template" },
  command = "setlocal filetype=dockerfile",
})
-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup "highlight_yank",
  pattern = "*",
  callback = function() vim.highlight.on_yank { higroup = "IncSearch" } end,
})
-- auto trim trailing whitespace
autocmd("BufWritePost", {
  group = augroup "trim_whitespace",
  callback = function() require("mini.trailspace").trim() end,
})
-- toggle number on focussed window
vim.cmd [[
  augroup simple_numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
  augroup END
]]
-- setup laststatus when entering
M.should_hide = function(bufnr)
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
  local is_filetype_disabled = vim.tbl_contains(M.disable.filetypes, filetype)
  local is_buftype_disabled = vim.tbl_contains(M.disable.buftypes, buftype)

  local function is_floating()
    local winids = vim.fn.win_findbuf(bufnr)
    for _, winid in ipairs(winids) do
      if vim.api.nvim_win_get_config(winid).relative ~= "" then return true end
    end
    return false
  end

  return is_floating() or is_buftype_disabled or is_filetype_disabled
end
autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = augroup "last_status",
  pattern = "*",
  callback = function(ev) vim.o.laststatus = M.should_hide(ev.buf) and 0 or vim.g.laststatus end,
})
-- Set local settings for terminal buffers
autocmd("TermOpen", {
  group = augroup "custom_term_open",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.scrolloff = 0
  end,
})
-- highlight URL
local highlighturl_group = augroup "highlighturl"
autocmd("ColorScheme", {
  group = highlighturl_group,
  callback = function() hi("HighlightURL", { default = true, underline = true }) end,
})
autocmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
  group = highlighturl_group,
  callback = function(args)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == args.buf and not vim.w[win].highlighturl_enabled then
        Util.set_url_match(win)
      end
    end
  end,
})
-- add bigfile filetype and disable some defaults on bigfile
vim.filetype.add {
  pattern = {
    [".*"] = {
      function(path, buf)
        return vim.bo[buf]
            and vim.bo[buf].filetype ~= "bigfile"
            and path
            and vim.fn.getfsize(path) > vim.g.bigfile_size
            and "bigfile"
          or nil
      end,
    },
  },
}
autocmd("FileType", {
  group = augroup "bigfile",
  pattern = "bigfile",
  callback = function(ev)
    vim.b.minianimate_disable = true
    P(available)
    vim.schedule(function() vim.bo[ev.buf].syntax = vim.filetype.match { buf = ev.buf } or "" end)
  end,
})

local function get_hour() return tonumber(os.date "%H") end

-- Set the background based on the hour
local function set_background()
  local hour = get_hour()
  if hour >= 6 and hour < 21 then
    vim.go.background = "light"
  else
    vim.go.background = "dark"
  end
end

autocmd("VimEnter", { callback = set_background })

set_background()

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

Util.setup()

require("lazy").setup {
  spec = {
    { import = "plugins" },
  },
  lockfile = vim.fn.stdpath "config" .. "/lazy-lock.json",
  change_detection = { notify = false },
  checker = { enabled = true, frequency = 3600 * 24, notify = false },
  ui = { border = BORDER.get(), backdrop = 100, wrap = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
}

Util.toggle.setup()

if package.loaded["rose-pine"] then
  vim.cmd.colorscheme "rose-pine"
else
  vim.opt.termguicolors = true
  vim.cmd.colorscheme "habamax"
end

hi("HighlightURL", { default = true, underline = true })
hi("MiniFilesBorder", { link = "Normal" })
hi("MiniFilesNormal", { link = "Normal" })
hi("VertSplit", { fg = "NONE", bg = "NONE", bold = false })
hi("CmpGhostText", { link = "Comment", default = true })
