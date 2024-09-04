require "aarnphm.globals"
require "aarnphm.options"
require "aarnphm.bindings"

hi("HighlightURL", { default = true, underline = true })
hi("CmpGhostText", { link = "Comment", default = true })
-- leap.nvim
hi("LeapBackdrop", { link = "Comment" }) ---or some grey
hi("LeapMatch", {
  ---For light themes, set to 'black' or similar.
  fg = vim.go.background == "dark" and "white" or "black",
  bold = true,
  nocombine = true,
})

-- close some filetypes with <q> and make it unlisted by buf
vim.api.nvim_create_autocmd("FileType", {
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
    "gitsigns.blame",
    "nowrite", ---fugitive
    "fugitive",
    "prompt",
    "tsplayground",
    "neorepl",
    "health",
    "nofile",
    "scratch",
    "starter",
    "trouble",
    "",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<cmd>close<cr>", { silent = true })
  end,
})
---correct resized tabs
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup "resized",
  callback = function()
    local current = vim.fn.tabpagenr()
    vim.cmd "tabdo wincmd ="
    vim.cmd("tabnext  " .. current)
  end,
})
-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup "checktime",
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd "checktime" end
  end,
})
-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup "auto_create_dir",
  callback = function(event)
    if event.match:match "^%w%w+:[\\/][\\/]" then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup "highlight_yank",
  pattern = "*",
  callback = function() vim.highlight.on_yank { higroup = "IncSearch" } end,
})
-- auto trim trailing whitespace
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup "trim_whitespace",
  callback = function()
    -- basically the same as mini.trailspace
    local curpos = vim.api.nvim_win_get_cursor(0)
    ---Search and replace trailing whitespace
    vim.cmd [[keeppatterns %s/\s\+$//e]]
    vim.api.nvim_win_set_cursor(0, curpos)
  end,
})
-- toggle number on focussed window
local numtoggle = augroup "numtoggle"
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = numtoggle,
  callback = function()
    if vim.wo.number and vim.fn.mode() ~= "i" then vim.wo.relativenumber = true end
  end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = numtoggle,
  callback = function()
    if vim.wo.number then vim.wo.relativenumber = false end
  end,
})
-- highlight URL
local highlighturl_group = augroup "highlighturl"
vim.api.nvim_create_autocmd("ColorScheme", {
  group = highlighturl_group,
  callback = function() hi("HighlightURL", { default = true, underline = true }) end,
})
vim.api.nvim_create_autocmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
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
vim.api.nvim_create_autocmd("FileType", {
  group = augroup "bigfile",
  pattern = "bigfile",
  callback = function(ev)
    vim.schedule(function() vim.bo[ev.buf].syntax = vim.filetype.match { buf = ev.buf } or "" end)
  end,
})
-- add http, dotenv, tsconfig
vim.filetype.add {
  extension = {
    ["http"] = "http",
    env = "dotenv",
    h = "c",
    ["j2"] = "jinja",
  },
  filename = {
    [".env"] = "dotenv",
    ["env"] = "dotenv",
  },
  pattern = {
    ["[jt]sconfig.*.json"] = "jsonc",
    ["%.env%.[%w_.-]+"] = "dotenv",
  },
}

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

Util.setup {
  spec = { { import = "plugins" } },
  change_detection = { notify = false },
  checker = { enabled = true, frequency = 3600 * 24, notify = false },
  ui = { border = vim.g.border, backdrop = 100, wrap = false },
  dev = {
    path = "~/workspace/neovim-plugins/",
  },
}
