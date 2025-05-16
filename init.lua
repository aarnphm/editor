local o, opt, g, wo, go, api, fmt = vim.o, vim.opt, vim.g, vim.wo, vim.go, vim.api, string.format

local H = {}

-- For more information see ":h buftype"
H.isnt_normal_buffer = function() return vim.bo.buftype ~= "" end

---@type fun(filetype?: string): string
H.get_icon = nil

H.ensure_get_icon = function()
  if H.get_icon ~= nil then
    -- Cache only once
    return
  elseif _G.MiniIcons ~= nil then
    -- Prefer 'mini.icons'
    H.get_icon = function(filetype) return _G.MiniIcons.get("filetype", filetype) end
  else
    -- Try falling back to 'nvim-web-devicons'
    local has_devicons, devicons = pcall(require, "nvim-web-devicons")
    if not has_devicons then return end
    H.get_icon = function() return (devicons.get_icon(vim.fn.expand "%:t", nil, { default = true })) end
  end
end

H.is_truncated = function(trunc_width)
  -- Use -1 to default to 'not truncated'
  local cur_width = vim.o.laststatus == 3 and vim.o.columns or api.nvim_win_get_width(0)
  return cur_width < (trunc_width or -1)
end

-- Custom `^V` and `^S` symbols to make this file appropriate for copy-paste
-- (otherwise those symbols are not displayed).
local CTRL_S = api.nvim_replace_termcodes("<C-S>", true, true, true)
local CTRL_V = api.nvim_replace_termcodes("<C-V>", true, true, true)
H.modes = setmetatable({
  ["n"] = { long = "NORMAL", short = "N", hl = "MiniStatuslineModeNormal" },
  ["v"] = { long = "VISUAL", short = "V", hl = "MiniStatuslineModeVisual" },
  ["V"] = { long = "V-LINE", short = "V-L", hl = "MiniStatuslineModeVisual" },
  [CTRL_V] = { long = "V-BLOCK", short = "V-B", hl = "MiniStatuslineModeVisual" },
  ["s"] = { long = "SELECT", short = "S", hl = "MiniStatuslineModeVisual" },
  ["S"] = { long = "S-LINE", short = "S-L", hl = "MiniStatuslineModeVisual" },
  [CTRL_S] = { long = "S-BLOCK", short = "S-B", hl = "MiniStatuslineModeVisual" },
  ["i"] = { long = "INSERT", short = "I", hl = "MiniStatuslineModeInsert" },
  ["R"] = { long = "REPLACE", short = "R", hl = "MiniStatuslineModeReplace" },
  ["c"] = { long = "COMMAND", short = "C", hl = "MiniStatuslineModeCommand" },
  ["r"] = { long = "PROMPT", short = "P", hl = "MiniStatuslineModeOther" },
  ["!"] = { long = "SHELL", short = "SH", hl = "MiniStatuslineModeOther" },
  ["t"] = { long = "TERMINAL", short = "T", hl = "MiniStatuslineModeOther" },
}, {
  -- By default return 'Unknown' but this shouldn't be needed
  __index = function() return { long = "UNKNOWN", short = "U", hl = "%#MiniStatuslineModeOther#" } end,
})

-- diagnostic levels

-- Showed diagnostic levels
H.diagnostic_levels = {
  { name = "ERROR", sign = "✖" },
  { name = "WARN", sign = "▲" },
  { name = "INFO", sign = "●" },
  { name = "HINT", sign = "⚑" },
}

H.diagnostic_get_count = function()
  ---@type table<vim.diagnostic.Severity?, integer>
  local res = {}
  for _, d in
    ipairs(vim.tbl_filter(
      ---@param d vim.Diagnostic
      function(d) return d.severity ~= nil end,
      vim.diagnostic.get(0)
    ))
  do
    res[d.severity] = (res[d.severity] or 0) + 1
  end
  return res
end

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

_G.augroup = function(name) return api.nvim_create_augroup(("simple_%s"):format(name), { clear = true }) end
_G.hi = function(name, opts)
  opts.default = opts.default or true
  opts.force = opts.force or true
  api.nvim_set_hl(0, name, opts)
end

_G.convert_avante_diff_to_qf = function()
  require("avante.diff").conflicts_to_qf_items(function(items)
    if #items > 0 then
      vim.fn.setqflist(items, "r")
      vim.cmd "copen"
    end
  end)
end

---@class SimpleStatuslineArgs
---@field icon string|nil
---@field trunc_width number|nil

-- I refuse to have a complex statusline, *proceeds to have a complex statusline* PepeLaugh (lualine is cool though.)
-- [hunk] [branch] [modified]  --------- [diagnostic] [filetype] [line:col] [heart]
---@return table<string, fun(args: SimpleStatuslineArgs): string | table<string, any>>
_G.make_statusline = function()
  return {
    lint = function(args)
      ---@module "lint"
      local lint
      ---@type boolean
      local ok

      if H.isnt_normal_buffer() then return "" end

      ok, lint = pcall(require, "lint")
      if not ok then return "" end

      local linters = lint.get_running()
      local names = lint._resolve_linter_by_ft(vim.bo.filetype)

      if H.is_truncated(args.trunc_width) then return #linters == 0 and "󰦕" or "󱉶" end

      if #linters == 0 then return "󰦕" .. " " .. string.rep("+", vim.tbl_count(names)) end
      return "󱉶 [" .. table.concat(linters, "|") .. "]"
    end,
    diagnostic = function(args)
      if H.is_truncated(args.trunc_width) or not vim.diagnostic.is_enabled { bufnr = 0 } then return "" end

      local count = H.diagnostic_get_count()
      local severity, t = vim.diagnostic.severity, {}
      -- construct diagnostic info
      for _, level in ipairs(H.diagnostic_levels) do
        local n = count[severity[level.name]] or 0
        -- Add level info only if diagnostic is present
        if n > 0 then table.insert(t, fmt("%s %s", level.sign, n)) end
      end

      local icon = args.icon or ""
      if vim.tbl_count(t) == 0 then return ("%s -"):format(icon) end
      return fmt("[%s %s]", icon, table.concat(t, " "))
    end,
    fileinfo = function(args)
      local filetype = vim.bo.filetype
      -- Don't show anything if can't detect file type or not inside a "normal buffer"
      if (filetype == "") or H.isnt_normal_buffer() then return "" end

      -- Add filetype icon
      H.ensure_get_icon()
      if H.get_icon ~= nil then filetype = H.get_icon(filetype) .. " " .. filetype end

      -- Construct output string if truncated or buffer is not normal
      if H.is_truncated(args.trunc_width) or vim.bo.buftype ~= "" then return filetype end

      -- Construct output string with extra file info
      return fmt("%s", filetype)
    end,
    location = function(_) return "%l:%v" end,
    ---@return {md:string, hl:string}
    mode = function(args)
      local mi = H.modes[vim.fn.mode()]
      return { md = mi.short, hl = mi.hl }
    end,
  }
end
--#endregion
--#region options
if vim.uv.os_uname().sysname == "Darwin" then
  g.clipboard = {
    name = "macOS-clipboard",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
    cache_enabled = 0,
  }
end

-- map leader to <Space> and localeader to +
g.mapleader = " "
g.maplocalleader = ","
-- Fix markdown indentation settings
g.markdown_recommended_style = 0
-- autoformat on save
g.autoformat = true
-- enable inline diagnostics
g.inline_diagnostics = false
-- whether to enable ghost text for completions
g.ghost_text = false
-- boxy or none
g.enable_ui = true
-- whether to render markdown
g.enable_render = false
-- whether to enable autocomplete (if disabled, then manual trigger with <C-Space>)
g.enable_autocomplete = true
-- whether to set cursor in insert mode to be block or lines
g.block_cursor = true
-- configure whether prettier will requires configuration. If true, then prettier won't be run for compatible files if configuration is missing
g.prettier_needs_config = false
-- additional path root spec to determine for LSP root
g.additional_path_root_spec = { "content" }
-- ignore lsp for certain root
g.root_lsp_ignore = { "copilot" }
-- set pickers (can support telescope.nvim or mini.pick)
---@type "mini.pick" | "telescope"
g.picker = "mini.pick"
-- whether we set border for floating UI.
g.border = "none"
-- markdown render backend
---@type "markview" | "render-markdown"
g.markdown_render_backend = "render-markdown"
-- additional plugins to be used.
g.extra_plugins = {
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
g.avante_rag = false

-- window opts
wo.scrolloff = 8
wo.sidescrolloff = 8
wo.wrap = false -- need to wrap chungus
wo.cursorline = true
wo.cursorcolumn = false

-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true
opt.winminwidth = 5 -- Minimum window width

-- Some defaults and don't question it
o.writebackup = false -- whose needs backup btw (i do sometimes)
o.autowrite = true -- sometimes I forget to save
o.signcolumn = "yes" -- always show sign column
o.undofile = true -- set undofile to infinite undo
o.breakindent = true -- enable break indent
o.breakindentopt = "shift:2,min:20" -- wrap two spaces, with min of 20 text width
o.pumheight = 20 -- larger completion windows
o.expandtab = true -- convert spaces to tabs
o.mouse = "a" -- ugh who needs mouse (accept on SSH maybe)
o.number = true -- number is good for nav
o.swapfile = false -- I don't like swap files personally, found undofile to be better
o.autowrite = true
o.undofile = true -- better than swapfile
o.undolevels = 9999 -- infinite undo
o.showtabline = 0
-- Window blending configuration
o.winblend = 0
o.pumblend = 20 -- make completion window transparent

opt.shortmess:append { W = true, c = true, C = true }
o.formatexpr = "v:lua.require'utils'.format.formatexpr()"
o.completeopt = "menu,menuone,noselect"
o.formatoptions = "1jqlnt" -- NOTE: "tqjcro"

o.diffopt = "filler,iwhite,internal,linematch:60,algorithm:patience" -- better diff
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- searching and grep stuff
o.smartcase = true
o.smartindent = true
o.ignorecase = true
o.infercase = true
o.hlsearch = true
o.grepformat = "%f:%l:%c:%m"
o.grepprg = "rg --vimgrep" -- also its 2023 use rg
o.linebreak = true
o.jumpoptions = "stack"
o.list = true
opt.listchars = {
  tab = "»·",
  lead = "·",
  leadmultispace = "»···",
  nbsp = "+",
  trail = "·",
  extends = "→",
  precedes = "←",
}
o.inccommand = "split"

o.foldenable = true
opt.fillchars = {
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
o.smoothscroll = true
o.foldexpr = "v:lua.require'utils'.ui.foldexpr()"
o.foldmethod = "indent"
o.foldtext = "v:lua.require'utils'.ui.foldtext()"
o.foldlevel = 99
o.foldlevelstart = 99
o.foldopen = "block,mark,percent,quickfix,search,tag,undo"

-- Spaces and tabs config
o.tabstop = TABWIDTH
o.softtabstop = TABWIDTH
o.shiftwidth = TABWIDTH
o.shiftround = true

-- UI config
o.showmode = false -- This is set with mini.statusline
o.showcmd = false
o.showbreak = "↳  "
o.sidescrolloff = 8
o.splitbelow = true
o.splitright = true
o.timeout = true
o.timeoutlen = vim.g.vscode and 1000 or 300
o.updatetime = 250
o.virtualedit = "block"
o.laststatus = 3 -- set local statusline for more context information
o.whichwrap = "h,l,<,>,[,],~"
go.background = os.getenv "XDG_SYSTEM_THEME" or "dark"

-- For neovide
o.guifont = "BerkeleyMono Nerd Font Mono:h16"

-- last but def not least, wildmenu
o.wildchar = 9
o.wildignorecase = true
o.wildmode = "longest:full,full"
opt.wildignore = { "__pycache__", "*.o", "*~", "*.pyc", "*pycache*", "Cargo.lock", "lazy-lock.json" }
opt.wildmode = "longest:full,full" -- Command-line completion mode

o.cmdheight = g.enable_ui and 0 or 1
o.guicursor = g.block_cursor and "" or "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20" -- make cursor to be block
o.conceallevel = g.enable_render and 2 or 0

if g.neovide then
  g.neovide_show_border = true
  g.neovide_no_idle = true
  g.neovide_padding_top = 5
  g.neovide_cursor_animation_length = 0.08
  g.neovide_cursor_trail_length = 0.05
  g.neovide_input_macos_option_key_is_meta = "only_left"

  -- shortcuts
  vim.keymap.set("n", "<D-s>", ":w<CR>") -- Save
  vim.keymap.set("v", "<D-c>", '"+y') -- Copy
  vim.keymap.set("n", "<D-v>", '"+P') -- Paste normal mode
  api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
  api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  api.nvim_set_keymap("n", "<D-w>", ":q<CR>", { noremap = true, silent = true })
  api.nvim_set_keymap("n", "<D-t>", ":enew<CR>", { noremap = true, silent = true })
end

-- respect local venv instead of nix setup
local venv = os.getenv "VIRTUAL_ENV"
if venv ~= nil then g.python3_host_prog = venv .. "/bin/python3" end

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
api.nvim_create_autocmd("FileType", {
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
        pcall(api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "buffer: delete",
      })
    end)
  end,
})
-- go to last loc when opening a buffer
api.nvim_create_autocmd("BufReadPost", {
  group = augroup "last_loc",
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].simple_last_loc then return end
    vim.b[buf].simple_last_loc = true
    local mark = api.nvim_buf_get_mark(buf, '"')
    local lcount = api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then pcall(api.nvim_win_set_cursor, 0, mark) end
  end,
})
-- make it easier to close man-files when opened inline
api.nvim_create_autocmd("FileType", {
  group = augroup "man_unlisted",
  pattern = { "man" },
  callback = function(event) vim.bo[event.buf].buflisted = false end,
})
-- correct resized tabs
api.nvim_create_autocmd("VimResized", {
  group = augroup "resized",
  callback = function()
    local current = vim.fn.tabpagenr()
    vim.cmd "tabdo wincmd ="
    vim.cmd("tabnext  " .. current)
  end,
})
-- filetype stuff
api.nvim_create_autocmd("FileType", {
  group = augroup "spell",
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function() vim.opt_local.spell = true end,
})
-- Check if we need to reload the file when it changed
api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup "checktime",
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd "checktime" end
  end,
})
-- Auto create dir when saving a file, in case some intermediate directory does not exist
api.nvim_create_autocmd("BufWritePre", {
  group = augroup "auto_create_dir",
  callback = function(event)
    if event.match:match "^%w%w+:[\\/][\\/]" then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
  group = augroup "highlight_yank",
  pattern = "*",
  callback = function() vim.hl.on_yank { higroup = "IncSearch" } end,
})
-- auto trim trailing whitespace
api.nvim_create_autocmd("BufWritePost", {
  group = augroup "trim_whitespace",
  callback = function()
    -- basically the same as mini.trailspace
    local curpos = api.nvim_win_get_cursor(0)
    ---Search and replace trailing whitespace
    vim.cmd [[keeppatterns %s/\s\+$//e]]
    api.nvim_win_set_cursor(0, curpos)
  end,
})
-- toggle number on focussed window
local numtoggle = augroup "numtoggle"
api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
  group = numtoggle,
  callback = function()
    if vim.wo.number and vim.fn.mode() ~= "i" then vim.wo.relativenumber = true end
  end,
})
api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
  group = numtoggle,
  callback = function()
    if vim.wo.number then vim.wo.relativenumber = false end
  end,
})
-- highlight URL
local highlighturl_group = augroup "highlighturl"
api.nvim_create_autocmd("ColorScheme", {
  group = highlighturl_group,
  callback = function() hi("HighlightURL", { default = true, underline = true }) end,
})
api.nvim_create_autocmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
  group = highlighturl_group,
  callback = function(args)
    for _, win in ipairs(api.nvim_list_wins()) do
      if api.nvim_win_get_buf(win) == args.buf and not vim.w[win].highlighturl_enabled then Util.set_url_match(win) end
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

api.nvim_create_user_command("Quartz", function(opts)
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

require("utils").setup {
  spec = { { import = "plugins" } },
  change_detection = { notify = false },
  checker = { enabled = true, frequency = 3600 * 24, notify = false },
  ui = { border = vim.g.border, backdrop = 100, wrap = false },
  dev = { path = "~/workspace/neovim-plugins/" },
}
