-- close some filetypes with <q> and make it unlisted by buf
vim.api.nvim_create_autocmd("FileType", {
  group = augroup "filetype_q",
  pattern = {
    "checkhealth",
    "gitsigns-blame",
    "minigit",
    "grug-far",
    "nvim-pack",
    "help",
    "lspinfo",
    "qf",
    "startuptime",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd "close"
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "buffer: delete",
      })
    end)
  end,
})
-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
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
-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup "man_unlisted",
  pattern = { "man" },
  callback = function(event) vim.bo[event.buf].buflisted = false end,
})
-- correct resized tabs
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup "resized",
  callback = function()
    local current = vim.fn.tabpagenr()
    vim.cmd "tabdo wincmd ="
    vim.cmd("tabnext  " .. current)
  end,
})
-- filetype stuff
vim.api.nvim_create_autocmd("FileType", {
  group = augroup "spell",
  pattern = { "text", "plaintex", "typst", "gitcommit" },
  callback = function() vim.opt_local.spell = true end,
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
  callback = function() vim.hl.on_yank { higroup = "IncSearch" } end,
})
-- Clear search highlights once the cursor leaves the current match.
vim.api.nvim_create_autocmd("CursorMoved", {
  group = augroup "clear_search_highlight",
  callback = function()
    local ok, count = pcall(vim.fn.searchcount, { recompute = 1, maxcount = 0 })
    if not ok or count.exact_match ~= 0 then return end

    vim.schedule(function()
      if vim.v.hlsearch ~= 0 then vim.cmd.nohlsearch() end
    end)
  end,
})
-- auto trim trailing whitespace
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup "trim_whitespace",
  callback = function()
    if vim.bo.buftype ~= "" or not vim.bo.modifiable then return end

    -- basically the same as mini.trailspace
    local curpos = vim.api.nvim_win_get_cursor(0)
    ---Search and replace trailing whitespace
    vim.cmd [[keeppatterns %s/\s\+$//e]]
    vim.api.nvim_win_set_cursor(0, curpos)
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = augroup "bigfile",
  callback = function(ev)
    if not Util.is_bigfile(ev.buf) then return end
    Util.bigfile.apply(ev.buf)
  end,
})

local numbercolumn = augroup "numbercolumn"
local file_statuscolumn = "%s%=%{v:relnum?v:relnum:v:lnum} "
local editor_focused = true

local function file_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then return false end

  local name = vim.api.nvim_buf_get_name(buf)
  return name:sub(1, 1) == "/" or name:match "^%a:[/\\]" ~= nil
end

local function set_winopt(win, name, value) pcall(vim.api.nvim_set_option_value, name, value, { win = win }) end

local function refresh_numbercolumn()
  local current_win = vim.api.nvim_get_current_win()
  local mode = vim.fn.mode()

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local enabled = file_buffer(buf)
    local bigfile = enabled and Util.is_bigfile(buf)

    set_winopt(win, "number", enabled)
    set_winopt(win, "relativenumber", enabled and editor_focused and win == current_win and mode ~= "i")
    set_winopt(win, "signcolumn", enabled and "yes:1" or "no")
    set_winopt(win, "statuscolumn", enabled and not bigfile and file_statuscolumn or "")
  end
end

vim.api.nvim_create_autocmd(
  { "BufEnter", "BufWinEnter", "FileType", "InsertEnter", "InsertLeave", "TermOpen", "WinEnter", "WinLeave" },
  {
    group = numbercolumn,
    callback = refresh_numbercolumn,
  }
)

vim.api.nvim_create_autocmd("FocusGained", {
  group = numbercolumn,
  callback = function()
    editor_focused = true
    refresh_numbercolumn()
  end,
})

vim.api.nvim_create_autocmd("FocusLost", {
  group = numbercolumn,
  callback = function()
    editor_focused = false
    refresh_numbercolumn()
  end,
})

local term_group = augroup "terminal_io"
vim.api.nvim_create_autocmd({ "BufEnter", "TermOpen", "TermEnter" }, {
  group = term_group,
  callback = function(ev)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) and vim.bo[ev.buf].buftype == "terminal" then vim.cmd.startinsert() end
    end)
  end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "TermLeave" }, {
  group = term_group,
  callback = function(ev)
    if vim.fn.mode() == "t" and vim.bo[ev.buf].buftype == "terminal" then vim.cmd.stopinsert() end
  end,
})
-- highlight URL
if vim.g.enable_highlighturl then
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
end
-- automatically setup frontmatter for markdown files
_G.VAULTS = {
  { root = vim.fn.expand "~" .. "/workspace/garden/content", tags = { "garden" }, new_note_dir = "thoughts" },
  { root = vim.fn.expand "~" .. "/workspace/capstone/manuals/content", tags = { "capstone" } },
  { root = vim.fn.expand "~" .. "/workspace/capstone/docs/content", tags = { "capstone-docs" } },
}
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup "markdown_frontmatter",
  pattern = "*.md",
  desc = "markdown: update frontmatter before format",
  callback = function(ev) Util.markdown.update_frontmatter(ev.buf) end,
})
