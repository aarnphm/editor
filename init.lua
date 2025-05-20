--#region globals
---@generic T
---Pretty print a value for better inspect. Under the hood it uses vim.inspect
---@param v T any type
---@return T
_G.P = function(v)
  print(vim.inspect(v))
  return v
end

_G.TABWIDTH = 2

---@alias Mode "simple" | "lsp" | "docs" | "hover" | "git"

---@class SingleBorder
---@field none FloatBorderEdges
---@field single FloatBorderEdgesWithHl
---

---@class SingleBorder
local M = {
  none = { "", "", "", "", "", "", "", "" },
  single = {
    simple = {
      { "┌", "Comment" },
      { "─", "Comment" },
      { "┐", "Comment" },
      { "│", "Comment" },
      { "┘", "Comment" },
      { "─", "Comment" },
      { "└", "Comment" },
      { "│", "Comment" },
    },
    lsp = {
      { "󱐋", "WarningMsg" },
      { "─", "Comment" },
      { "┐", "Comment" },
      { "│", "Comment" },
      { "┘", "Comment" },
      { "─", "Comment" },
      { "└", "Comment" },
      { "│", "Comment" },
    },
    docs = {
      { "󰄾", "DiagnosticHint" },
      { "─", "Comment" },
      { "┐", "Comment" },
      { "│", "Comment" },
      { "┘", "Comment" },
      { "─", "Comment" },
      { "└", "Comment" },
      { "│", "Comment" },
    },
    hover = {
      { "󰀵", "MiniIconsGrey" },
      { "─", "Comment" },
      { "┐", "Comment" },
      { "│", "Comment" },
      { "┘", "Comment" },
      { "─", "Comment" },
      { "└", "Comment" },
      { "│", "Comment" },
    },
    git = {
      { "󰊢", "MiniIconsRed" },
      { "─", "Comment" },
      { "┐", "Comment" },
      { "│", "Comment" },
      { "┘", "Comment" },
      { "─", "Comment" },
      { "└", "Comment" },
      { "│", "Comment" },
    },
  },
}

M.none = setmetatable(M.none, {
  __call = function(...) return M.none end,
})
M.single = setmetatable(M.single, {
  __call = function(_, t, override, start)
    t = t or "lsp"
    local target = M.single[t]
    if target == nil then
      Util.warn("Given border type `" .. t .. "` not found, falling back to none.")
      return M.none
    end
    -- Override the highlight color starting from the second item
    for i = start, #target do
      if type(target[i]) == "table" then target[i][2] = override or target[i][2] end
    end
    return target
  end,
})

---@param type? Mode type of border to be use
---@param override? string override hl for given buffer
---@param start? integer whether to start from 1 or 2
---@return FloatBorder
M.impl = function(type, override, start) return M[vim.g.border or "none"](type, override, start or 2) end

_G.BORDER = setmetatable(M, { __index = function() return M.impl() end })

_G.augroup = function(name) return vim.api.nvim_create_augroup(("simple_%s"):format(name), { clear = true }) end
_G.hi = function(name, opts)
  opts.default = opts.default or true
  opts.force = opts.force or true
  vim.api.nvim_set_hl(0, name, opts)
end

_G.convert_avante_diff_to_qf = function()
  require("avante.diff").conflicts_to_qf_items(function(items)
    if #items > 0 then
      vim.fn.setqflist(items, "r")
      vim.cmd "copen"
    end
  end)
end

--#endregion
--#region options
if vim.uv.os_uname().sysname == "Darwin" then
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
    cache_enabled = 0,
  }
end

-- map leader to <Space> and localeader to +
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = " "
vim.g.maplocalleader = ","
-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
-- autoformat on save
vim.g.autoformat = true
-- enable inline diagnostics
vim.g.inline_diagnostics = false
-- whether to enable ghost text for completions
vim.g.ghost_text = false
-- whether to render markdown, essentially changing toe conceallevel here
vim.g.enable_render = false
-- additional path root spec to determine for LSP root
vim.g.additional_path_root_spec = { "content" }
-- ignore lsp for certain root
vim.g.root_lsp_ignore = { "copilot" }
-- whether we set border for floating UI.
vim.g.border = "none"
-- markdown render backend
---@type "markview" | "render-markdown"
vim.g.markdown_render_backend = "render-markdown"
-- additional plugins to be used.
vim.g.extra_plugins = {
  -- lang
  "plugins.lang.go",
  "plugins.lang.nix",
  "plugins.lang.rust",
  "plugins.lang.yaml",
  "plugins.lang.json",
  "plugins.lang.clangd",
  "plugins.lang.python",
  "plugins.lang.zig",
  "plugins.lang.markdown",
  "plugins.lang.tailwind",
  "plugins.lang.typescript",
  -- formatters
  "plugins.formatters.prettier",
  -- linters
  "plugins.linters.eslint",
}
-- whether to enable RAG for avante
vim.g.avante_rag = false

-- window opts
vim.wo.scrolloff = 8
vim.wo.sidescrolloff = 8
vim.wo.wrap = false -- need to wrap chungus
vim.wo.cursorline = true
vim.wo.cursorcolumn = false

-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.confirm = true
vim.opt.winminwidth = 3 -- Minimum window width
vim.opt.termguicolors = true

-- Some defaults and don't question it
vim.o.writebackup = false -- whose needs backup btw (i do sometimes)
vim.o.autowrite = true -- sometimes I forget to save
vim.o.signcolumn = "yes" -- always show sign column
vim.o.undofile = true -- set undofile to infinite undo
vim.o.breakindent = true -- enable break indent
vim.o.breakindentopt = "shift:2,min:20" -- wrap two spaces, with min of 20 text width
vim.o.pumheight = 20 -- larger completion windows
vim.o.expandtab = true -- convert spaces to tabs
vim.o.mouse = "a" -- ugh who needs mouse (accept on SSH maybe)
vim.o.number = true -- number is good for nav
vim.o.swapfile = false -- I don't like swap files personally, found undofile to be better
vim.o.autowrite = true
vim.o.undofile = true -- better than swapfile
vim.o.undolevels = 9999 -- infinite undo
vim.o.showtabline = 0
-- Window blending configuration
vim.o.winblend = 0
vim.o.pumblend = 0 -- make completion window transparent

vim.opt.shortmess:append { W = true, c = true, C = true }
vim.o.formatexpr = "v:lua.require'utils'.format.formatexpr()"
vim.o.completeopt = "menu,menuone,noselect"
vim.o.formatoptions = "tcqjro1ln"

vim.o.diffopt = "filler,iwhite,internal,linematch:60,algorithm:patience"
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- searching and grep stuff
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.ignorecase = true
vim.o.infercase = true
vim.o.hlsearch = true
vim.o.grepformat = "%f:%l:%c:%m"
vim.o.grepprg = "rg --vimgrep"
vim.o.linebreak = true
vim.o.jumpoptions = "stack"
vim.o.list = true
vim.opt.listchars = {
  tab = "»·",
  lead = "·",
  leadmultispace = "»···",
  nbsp = "+",
  trail = "·",
  extends = "→",
  precedes = "←",
}
vim.o.inccommand = "split"
vim.o.foldenable = true
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
  vert = "│",
  horiz = "─",
  horizdown = "┬",
  horizup = "┴",
  verthoriz = "┼",
  vertleft = "┤",
  vertright = "├",
}
vim.o.smoothscroll = true
vim.o.foldexpr = "v:lua.require'utils'.ui.foldexpr()"
vim.o.foldmethod = "indent"
vim.o.foldtext = "v:lua.require'utils'.ui.foldtext()"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldopen = "block,mark,percent,quickfix,search,tag,undo"

-- Spaces and tabs config
vim.o.tabstop = TABWIDTH
vim.o.softtabstop = TABWIDTH
vim.o.shiftwidth = TABWIDTH
vim.o.shiftround = true

-- UI config
vim.o.showmode = true
vim.o.showcmd = true
vim.o.showbreak = "↳  "
vim.o.sidescrolloff = 8
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.timeout = true
vim.o.timeoutlen = vim.g.vscode and 1000 or 300
vim.o.updatetime = 250
vim.o.virtualedit = "block"
vim.o.laststatus = 3
vim.o.whichwrap = "h,l,<,>,[,],~"
vim.go.background = os.getenv "XDG_SYSTEM_THEME" or "dark"

-- For neovide
vim.o.guifont = "BerkeleyMono Nerd Font Mono:h16"

-- last but def not least, wildmenu
vim.o.wildchar = 9
vim.o.wildignorecase = true
vim.o.wildmode = "longest:full,full"
vim.opt.wildignore = { "__pycache__", "*.o", "*~", "*.pyc", "*pycache*", "Cargo.lock", "lazy-lock.json" }
vim.opt.wildmode = "longest:full,full" -- Command-line completion mode

vim.o.cmdheight = 1
vim.o.guicursor = "" -- "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
vim.o.conceallevel = vim.g.enable_render and 2 or 0

if vim.g.neovide then
  vim.g.neovide_show_border = true
  vim.g.neovide_no_idle = true
  vim.g.neovide_padding_top = 5
  vim.g.neovide_cursor_animation_length = 0.08
  vim.g.neovide_cursor_trail_length = 0.05
  vim.g.neovide_input_macos_option_key_is_meta = "only_left"

  -- shortcuts
  vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
  vim.keymap.set("v", "<D-c>", '"+y') -- Copy
  vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
  vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "<D-w>", ":q<CR>", { noremap = true, silent = true })
end

-- respect local venv instead of nix setup
local venv = os.getenv "VIRTUAL_ENV"
if venv ~= nil then vim.g.python3_host_prog = venv .. "/bin/python3" end

vim.keymap.set({ "n", "x" }, " ", "", { noremap = true })
--#endregion
--#region bindings
local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Open a terminal at the bottom of the screen with a fixed height.
map(
  "n",
  "<leader>st",
  function() Util.terminal.bottom(nil, { startinsert = true }) end,
  { desc = "terminal: attach new process" }
)
map("n", "<leader>sq", function() vim.cmd.Quartz() end, { desc = "terminal: attach new quartz" })
map("t", "<C-w><C-q>", "<C-\\><C-n><C-w>q", { desc = "terminal: close" })
map("t", "<C-w>", "<C-\\><C-n>", { desc = "terminal: change to normal mode" })
map("n", "<leader>aq", function() convert_avante_diff_to_qf() end, { desc = "avante: convert diff to quickfix" })

map("n", "<C-x>", function() Snacks.bufdelete() end, { desc = "buffer: delete" })
map("n", "<C-q>", "<cmd>:bd<cr>", { desc = "buffer: delete" })
map("i", "<M-BS>", "<C-W>", { desc = "insert: delete word", remap = false })

map("n", "<Leader>v", "gcc", { desc = "comment: visual line", remap = true, silent = true })
map("x", "<Leader>v", "gc", { desc = "comment: visual line", remap = true, silent = true })
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "terminal: enter normal mode" })
map("t", "<C-w>h", "<cmd>wincmd h<cr>", { desc = "terminal: go to left window" })
map("t", "<C-w>j", "<cmd>wincmd j<cr>", { desc = "terminal: go to lower window" })
map("t", "<C-w>k", "<cmd>wincmd k<cr>", { desc = "terminal: go to upper window" })
map("t", "<C-w>l", "<cmd>wincmd l<cr>", { desc = "terminal: go to right window" })
map("i", "jj", "<Esc>", { desc = "normal: escape" })
map("i", "jk", "<Esc>", { desc = "normal: escape" })

-- NOTE: normal mode
map("n", "<leader><leader>a", "<CMD>normal za<CR>", { desc = "edit: Toggle code fold" })
map("n", "Y", "y$", { desc = "edit: Yank text to EOL" })
map("n", "D", "d$", { desc = "edit: Delete text to EOL" })
map("n", "J", "mzJ`z", { desc = "edit: Join next line" })
map("n", "<leader><leader>l", ":lua ", { noremap = true, silent = true, desc = "cmdline: enter lua command" })
map("n", "<leader><leader>lP", ":lua P(", { noremap = true, silent = true, desc = "cmdline: enter lua command" })
map("n", "<LocalLeader>g", ":grep ", { noremap = false, desc = "edit: grep pattern" })
map("n", "<LocalLeader>l", ":lgrep ", { noremap = false, desc = "edit: grep pattern (window)" })
map("n", "\\", ":let @/=''<CR>:noh<CR>", { silent = true, desc = "window: Clean highlight" })
map("n", ";", ":", { silent = false, desc = "command: Enter command mode" })
map("n", ";;", ";", { silent = false, desc = "normal: Enter Ex mode" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "edit: Move this line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "edit: Move this line up" })
map("v", "<", "<gv", { desc = "edit: Decrease indent" })
map("v", ">", ">gv", { desc = "edit: Increase indent" })
map("c", "W!!", "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!", { desc = "edit: Save file using sudo" })
map("n", "<C-h>", "<C-w>h", { desc = "window: Focus left", silent = true, noremap = true })
map("n", "<C-l>", "<C-w>l", { desc = "window: Focus right", silent = true, noremap = true })
map("n", "<C-j>", "<C-w>j", { desc = "window: Focus down", silent = true, noremap = true })
map("n", "<C-k>", "<C-w>k", { desc = "window: Focus up", silent = true, noremap = true })
map("n", "<LocalLeader>|", "<C-w>|", { desc = "window: Maxout width" })
map("n", "<LocalLeader>-", "<C-w>_", { desc = "window: Maxout width" })
map("n", "<LocalLeader>0", "<C-w>=", { desc = "window: Equal size" })
map("n", "<Leader>qq", "<cmd>wqa!<cr>", { desc = "editor: write quit all" })
map("n", "<Leader>`", "<cmd>e #<cr>", { desc = "buffer: switch to other buffer" })
map("n", "<Leader>n", "<cmd>enew<cr>", { desc = "buffer: new" })
map("n", "<LocalLeader>sw", "<C-w>r", { desc = "window: swap position" })
map("n", "<LocalLeader>vs", "<C-w>v", { desc = "edit: split window vertically" })
map("n", "<LocalLeader>hs", "<C-w>s", { desc = "edit: split window horizontally" })
map("n", "<LocalLeader>cd", ":lcd %:p:h<cr>", { desc = "misc: change directory to current file buffer" })
map("n", "<LocalLeader>]", "<cmd>vertical resize -10<cr>", { noremap = false, desc = "windows: resize right 10px" })
map("n", "<LocalLeader>[", "<cmd>vertical resize +10<cr>", { noremap = false, desc = "windows: resize left 10px" })
map("n", "<LocalLeader>-", "<cmd>resize -10<cr>", { noremap = false, desc = "windows: resize down 10px" })
map("n", "<LocalLeader>+", "<cmd>resize +10<cr>", { noremap = false, desc = "windows: resize up 10px" })
map("n", "<leader><leader>b", "<cmd>wincmd =<cr>", { noremap = true, silent = true, desc = "windows: balance" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "search: next" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "search: next" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "search: next" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "search: prev" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "search: prev" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "search: prev" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "inspect: position" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "inspect: tree" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

map("n", "<LocalLeader>p", "<cmd>Lazy<cr>", { desc = "package: show manager" })
--#endregion

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
  change_detection = { notify = false },
  checker = { enabled = true, frequency = 3600 * 24, notify = false },
  ui = { border = vim.g.border, backdrop = 100, wrap = false },
  dev = { path = "~/workspace/neovim-plugins/" },
}
