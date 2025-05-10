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
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
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
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
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

vim.api.nvim_create_user_command("Quartz", function(opts)
  local state = {
    cwd = nil,
    height = 15,
    background = false,
    cmd = { "pnpm", "exec", "quartz/bootstrap-cli.mjs", "build", "--serve", "--verbose", "--bundleInfo" },
  }
  for _, arg in ipairs(opts.fargs) do
    if arg == "bg" then
      state.background = true
    else
      local value = arg:match "cwd=([^%s]+)"
      if value then
        state.cwd = value
      else
        table.insert(state.cmd, arg)
      end
    end
  end
  if state.cwd == nil then state.cwd = Util.root() end
  if state.background then
    local job_id = vim.fn.jobstart(state.cmd, {
      cwd = state.cwd,
      on_exit = function(_, code)
        if code == 0 then
          Util.info "Quartz can be accessed at http://localhost:8080"
        else
          Util.error("Quartz process exited with code " .. code)
        end
      end,
      on_stderr = function(_, data)
        if data and #data > 0 then vim.schedule(function() Util.error(table.concat(data, "\n")) end) end
      end,
    })

    if job_id <= 0 then
      Util.error "Failed to start Quartz process"
    else
      Util.info "Quartz process started in background"
    end
  else
    Util.terminal.bottom(state.cmd, { height = state.height, cwd = state.cwd })
  end
end, {
  desc = "quartz: start server",
  nargs = "*",
  complete = function(_, _, _)
    local candidates = {} ---@type string[]
    vim.list_extend(candidates, { "bg" })
    vim.list_extend(
      candidates,
      ---@param x string
      vim.tbl_map(function(x) return "cwd=" .. x end, { Util.root() })
    )
    return candidates
  end,
})

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
  dev = { path = "~/workspace/neovim-plugins/" },
}
