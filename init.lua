require "aarnphm.globals"
require "aarnphm.options"
require "aarnphm.bindings"

---close some filetypes with <q>
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
    vim.b[event.buf].ministatusline_disable = true
    vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<cmd>close<cr>", { silent = true })
  end,
})
---Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup "checktime",
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd "checktime" end
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
vim.api.nvim_create_autocmd(
  "BufWritePre",
  { group = augroup "tempfile", pattern = { "/tmp/*", "*.tmp", "*.bak" }, command = "setlocal noundofile" }
)
---make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup "man_unlisted",
  pattern = { "man" },
  callback = function(event) vim.bo[event.buf].buflisted = false end,
})
---Fix conceallevel for json files
vim.api.nvim_create_autocmd("FileType", {
  group = augroup "json_conceal",
  pattern = { "json", "jsonc", "json5" },
  callback = function() vim.opt_local.conceallevel = 0 end,
})
---Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup "auto_create_dir",
  callback = function(event)
    if event.match:match "^%w%w+:[\\/][\\/]" then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
---Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup "highlight_yank",
  pattern = "*",
  callback = function() vim.highlight.on_yank { higroup = "IncSearch" } end,
})
---auto trim trailing whitespace
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup "trim_whitespace",
  callback = function()
    local ok, trailspace = pcall(require, "mini.trailspace")
    if ok then
      trailspace.trim()
    else
      ---Fallback to manual trim in case mini fails to load
      ---Save cursor position to later restore
      local curpos = vim.api.nvim_win_get_cursor(0)
      ---Search and replace trailing whitespace
      vim.cmd [[keeppatterns %s/\s\+$//e]]
      vim.api.nvim_win_set_cursor(0, curpos)
    end
  end,
})
---toggle number on focussed window
vim.cmd [[
  augroup simple_numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
  augroup END
]]
---Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup "custom_term_open",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.scrolloff = 0
  end,
})
---highlight URL
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
---add bigfile filetype and disable some defaults on bigfile
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
    vim.b.minianimate_disable = true
    vim.schedule(function() vim.bo[ev.buf].syntax = vim.filetype.match { buf = ev.buf } or "" end)
  end,
})
---add http filetype
vim.filetype.add {
  extension = {
    ["http"] = "http",
  },
}
---dotenv and tsconfig
vim.filetype.add {
  extension = {
    env = "dotenv",
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

local function get_hour() return tonumber(os.date "%H") end

---Set the background based on the hour
local function set_background()
  local hour = get_hour()
  if hour >= 6 and hour < 19 then
    vim.go.background = "light"
  else
    vim.go.background = "dark"
  end
  if vim.g.override_background ~= nil then vim.go.background = vim.g.override_background end
end

vim.api.nvim_create_autocmd("VimEnter", { callback = set_background })

set_background()

---bootstrap logics
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
  spec = {
    { import = "plugins" },
  },
  change_detection = { notify = false },
  checker = { enabled = true, frequency = 3600 * 24, notify = false },
  ui = { border = "single", backdrop = 100, wrap = false },
  dev = {
    path = "~/workspace/neovim-plugins/",
  },
}

if package.loaded["rose-pine"] then
  vim.cmd.colorscheme "rose-pine"
else
  vim.opt.termguicolors = true
  vim.cmd.colorscheme "habamax"
end

hi("HighlightURL", { default = true, underline = true })
hi("CmpGhostText", { link = "Comment", default = true })
---leap.nvim
hi("LeapBackdrop", { link = "Comment" }) ---or some grey
hi("LeapMatch", {
  ---For light themes, set to 'black' or similar.
  fg = vim.go.background == "dark" and "white" or "black",
  bold = true,
  nocombine = true,
})
