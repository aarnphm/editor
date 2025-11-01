vim.loader.enable()

_G.augroup = function(name) return vim.api.nvim_create_augroup(("simple_%s"):format(name), { clear = true }) end

_G.hi = function(name, opts)
  opts.default = opts.default or true
  opts.force = opts.force or true
  vim.api.nvim_set_hl(0, name, opts)
end

---@param mode string|string[]
---@param lhs string
---@param rhs string|(fun(...): any)
---@param opts? vim.keymap.set.LazyOpts
local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

local g = vim.g
if vim.uv.os_uname().sysname == "Darwin" then
  g.clipboard = {
    name = "macOS-clipboard",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
    cache_enabled = 0,
  }
end

g.loaded_gzip = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1

g.loaded_getscript = 1
g.loaded_getscriptPlugin = 1
g.loaded_vimball = 1
g.loaded_vimballPlugin = 1
g.loaded_2html_plugin = 1

g.loaded_matchit = 1
g.loaded_matchparen = 1
g.loaded_logiPat = 1
g.loaded_rrhelper = 1

g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_netrwSettings = 1

g.mapleader = vim.keycode "<space>"
g.maplocalleader = vim.keycode ","
-- Fix markdown indentation settings
g.markdown_recommended_style = 0
-- autoformat on save
g.autoformat = true
g.markdown_frontmatter = true
-- additional plugins to be used.
g.extra_plugins = {
  -- lang
  "plugins.lang.go",
  "plugins.lang.nix",
  "plugins.lang.rust",
  "plugins.lang.yaml",
  "plugins.lang.json",
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
g.enable_highlighturl = true
g.enable_autowrap = false

local wo = vim.wo
wo.scrolloff = 2
wo.sidescrolloff = 5
wo.wrap = false
wo.cursorline = true
wo.cursorcolumn = false
wo.foldexpr = "v:lua.require'utils'.ui.foldexpr()"

local bo = vim.bo
bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

local o = vim.o
o.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
o.confirm = true
o.winminwidth = 3
o.termguicolors = true -- false if on MacOS Terminal

o.writebackup = false
o.autowrite = true
o.undofile = true
o.breakindent = true
o.breakindentopt = "shift:2,min:20"
o.pumheight = 20
o.expandtab = true
o.mouse = "a"
o.number = true
o.swapfile = false
o.autowrite = true
o.undofile = true
o.undolevels = 9999
o.showtabline = 0
o.smoothscroll = true

o.shortmess = "ltTaoOIcF"
o.formatexpr = "v:lua.require'utils'.format.formatexpr()"
o.cot = "menu,menuone,noinsert,fuzzy,popup"
o.cia = "kind,abbr,menu"
o.formatoptions = "tcqjron"
o.diffopt = "filler,iwhite,internal,linematch:60,algorithm:patience"

o.smartcase = true
o.smartindent = true
o.ignorecase = true
o.infercase = true
o.hlsearch = true

o.linebreak = true
o.jumpoptions = "stack"
o.list = true
o.listchars = "tab:»·,lead:·,leadmultispace:»···,nbsp:+,trail:·,extends:→,precedes:←"
o.inccommand = "split"
o.foldenable = true
o.fcs = "foldopen:,foldclose:,fold: ,trunc:…,foldsep: ,diff:╱,eob: "

o.foldmethod = "indent"
o.foldtext = "v:lua.require'utils'.ui.foldtext()"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldopen = "block,mark,percent,quickfix,search,tag,undo"

local TABWIDTH = 2

o.tabstop = TABWIDTH
o.softtabstop = TABWIDTH
o.shiftwidth = TABWIDTH
o.shiftround = true

-- UI config
o.showmode = true
o.showcmd = true
o.showbreak = "↳  "
o.splitbelow = true
o.splitright = true
o.timeout = true
o.timeoutlen = vim.g.vscode and 1000 or 200
o.updatetime = 200
o.virtualedit = "block"

o.ls = 3
o.whichwrap = "b,s,<,>,[,],~"
o.guifont = "Berkeley Mono:h16"
o.cmdheight = 1
o.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"
o.conceallevel = 0

local background = os.getenv "XDG_SYSTEM_THEME"
vim.go.background = background ~= nil and background or "dark"

o.wildchar = 9
o.wildignorecase = true
o.wildmode = "longest:full,full"

if vim.g.neovide then
  vim.g.neovide_show_border = true
  vim.g.neovide_no_idle = true
  vim.g.neovide_padding_top = 5
  vim.g.neovide_cursor_animation_length = 0.08
  vim.g.neovide_cursor_trail_length = 0.05
  vim.g.neovide_input_macos_option_key_is_meta = "only_left"

  -- shortcuts
  vim.keymap.set("n", "<D-s>", ":w<CR>")
  vim.keymap.set("v", "<D-c>", '"+y')
  vim.keymap.set("n", "<D-v>", '"+P')
  vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "<D-w>", ":q<CR>", { noremap = true, silent = true })
end

map({ "n", "x" }, " ", "", { noremap = true })
-- Open a terminal at the bottom of the screen with a fixed height.
map(
  "n",
  "<leader>st",
  function() Util.terminal.bottom(nil, { height = 10, startinsert = true }) end,
  { desc = "terminal: attach new process" }
)
map(
  "n",
  "<LocalLeader>st",
  function() Util.terminal.side(nil, { startinsert = true }) end,
  { desc = "terminal: attach new process" }
)
map("t", "<C-w><C-q>", "<C-\\><C-n><C-w>q", { desc = "terminal: close" })
map("t", "<C-w>", "<C-\\><C-n>", { desc = "terminal: change to normal mode" })

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
map("n", "<leader><leader>a", "<CMD>normal za<CR>", { desc = "edit: Toggle code fold" })
map("n", "Y", "y$", { desc = "edit: Yank text to EOL" })
map("n", "D", "d$", { desc = "edit: Delete text to EOL" })
map("n", "J", "mzJ`z", { desc = "edit: Join next line" })
map("n", "<leader><leader>l", ":lua ", { noremap = true, silent = true, desc = "cmdline: enter lua command" })
map("n", "<LocalLeader>g", ":grep ", { noremap = false, desc = "edit: grep pattern" })
map("n", "<LocalLeader>l", ":lgrep ", { noremap = false, desc = "edit: grep pattern (window)" })
map("n", "\\", ":let @/=''<CR>:noh<CR>", { silent = true, desc = "window: Clean highlight" })
map("n", ";", ":", { silent = false, desc = "command: Enter command mode" })
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
map("n", "<LocalLeader>sw", "<C-w>r", { desc = "window: swap position" })
map("n", "<LocalLeader>vs", "<C-w>v", { desc = "edit: split window vertically" })
map("n", "<LocalLeader>hs", "<C-w>s", { desc = "edit: split window horizontally" })
map("n", "<LocalLeader>cd", ":lcd %:p:h<cr>", { desc = "misc: change directory to current file buffer" })
map("n", "<LocalLeader>]", "<cmd>vertical resize -5<cr>", { noremap = false, desc = "windows: resize right 10px" })
map("n", "<LocalLeader>[", "<cmd>vertical resize +5<cr>", { noremap = false, desc = "windows: resize left 10px" })
map("n", "<LocalLeader>-", "<cmd>resize -5<cr>", { noremap = false, desc = "windows: resize down 10px" })
map("n", "<LocalLeader>=", "<cmd>resize +5<cr>", { noremap = false, desc = "windows: resize up 10px" })
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

hi("HighlightURL", { default = true, underline = true })
hi("CmpGhostText", { link = "Comment", default = true })
hi("LeapBackdrop", { link = "Comment" })
hi("LeapMatch", { fg = vim.go.background == "dark" and "white" or "black", bold = true, nocombine = true })

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
    "fugitive",
    "fugitiveblame",
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
-- disable number on terminal buffer
vim.api.nvim_create_autocmd("TermOpen", {
  group = numtoggle,
  pattern = { "terminal" },
  callback = function()
    if vim.bo.number then
      vim.bo.number = false
      vim.bo.relativenumber = false
    end
  end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = numtoggle,
  callback = function()
    if vim.wo.number then vim.wo.relativenumber = false end
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
if g.enable_highlighturl then
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
-- auto wrap based on column width
if g.enable_autowrap then
  vim.api.nvim_create_autocmd({ "VimEnter", "VimResized", "WinEnter", "BufEnter", "FocusLost" }, {
    group = augroup "auto_wrap",
    callback = function()
      if vim.bo.filetype == "minifiles" then return end
      local columns = vim.api.nvim_win_get_width(0)
      if columns < 120 then
        vim.wo.wrap = true
        vim.wo.linebreak = true
      else
        vim.wo.wrap = false
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
  callback = function(ev)
    if not vim.g.markdown_frontmatter then return end
    local buf_dir = vim.fs.dirname(ev.match)

    local is_vault_note = false
    local matching_root = nil
    for _, vault in ipairs(VAULTS) do
      if buf_dir:sub(1, #vault.root) == vault.root then
        is_vault_note = true
        matching_root = vault.root
        break
      end
    end

    if not matching_root then return end

    local is_tag_note = false
    if matching_root and ev.match:sub(1, #matching_root) == matching_root then
      if ev.match:find(matching_root .. "/tags/") then is_tag_note = true end
    end

    local buf = ev.buf
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local filename = vim.fs.basename(ev.match)
    local id = filename:gsub("%.md$", "")

    local fm_start, fm_end
    if lines[1] and lines[1]:match "^---%s*$" then
      fm_start = 1
      for i = 2, #lines do
        if lines[i]:match "^---%s*$" then
          fm_end = i
          break
        end
      end
    end

    local existing = {}
    if fm_start and fm_end and fm_end > fm_start + 1 then
      local yaml_body = table.concat(vim.list_slice(lines, fm_start + 1, fm_end - 1), "\n")
      local json_str = vim.fn.system({ "yq", "eval", "-o=json", "-" }, yaml_body)
      local ok, parsed = pcall(vim.fn.json_decode, json_str)
      if ok and type(parsed) == "table" then existing = parsed end
    end

    local defaults
    if is_vault_note and not is_tag_note then
      defaults = { date = os.date "%Y-%m-%d", id = id, tags = { "seed" }, title = id }
    else
      defaults = { title = id }
    end

    local frontmatter = vim.tbl_deep_extend("force", defaults, existing)
    if frontmatter.title == nil then frontmatter.title = id end
    if frontmatter.aliases and #frontmatter.aliases == 0 then frontmatter.aliases = nil end

    if is_vault_note and not is_tag_note then
      local raw_offset = os.date "%z" -- timezone offset
      ---@cast raw_offset string
      local tz = string.format("%s%s:%s", raw_offset:sub(1, 1), raw_offset:sub(2, 3), raw_offset:sub(4, 5))
      frontmatter.modified = os.date "%Y-%m-%d %H:%M:%S" .. " GMT" .. tz
    end

    local encode_yaml = function(tbl)
      local json = vim.fn.json_encode(tbl)
      local yaml_str = vim.fn.system({ "yq", "eval", "sort_keys(..)", "-P", "-p=json", "-" }, json)
      local results = {}
      for line in yaml_str:gmatch "[^\r\n]+" do
        table.insert(results, line)
      end
      return results
    end

    local new_fm = { "---" }
    vim.list_extend(new_fm, encode_yaml(frontmatter))
    table.insert(new_fm, "---")

    if fm_start and fm_end then
      vim.api.nvim_buf_set_lines(buf, fm_start - 1, fm_end, false, new_fm)
    else
      vim.api.nvim_buf_set_lines(buf, 0, 0, false, vim.list_extend(new_fm, { "" }))
    end
  end,
})
vim.api.nvim_create_user_command("ObsidianNew", function(opts)
  local name = table.concat(opts.fargs, " ")
  if name == "" then
    Util.error "ObsidianNew: provide a note name"
    return
  end
  if not name:match "%.md$" then name = name .. ".md" end
  local cur = vim.api.nvim_buf_get_name(0)
  local vault = nil
  for _, v in ipairs(VAULTS) do
    if cur:sub(1, #v.root) == v.root then
      vault = v
      break
    end
  end
  if not vault then vault = VAULTS[1] end
  local dir = vault.root
  if vault.new_note_dir and vault.new_note_dir ~= "" then dir = dir .. "/" .. vault.new_note_dir end
  local path = dir .. "/" .. name
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end, { nargs = "+", complete = "file", desc = "obsidian: new note" })
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
    height = 7, -- Reduced from 15 to 8 lines for unfocused terminal
    background = false,
    cmd = { "pnpm", "exec", "tsx", "quartz/scripts/dev.ts" },
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
      env = { NODE_ENV = "development" },
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
    -- Create terminal with unfocused settings
    Util.terminal.bottom(state.cmd, {
      height = state.height,
      cwd = state.cwd,
      startinsert = false, -- Don't auto-focus the terminal
      focus = false, -- Don't move focus to the terminal
    })
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
