local o, opt, g, wo = vim.o, vim.opt, vim.g, vim.wo

-- Don't use defer it because it affects start screen appearance
if vim.fn.exists "syntax_on" ~= 1 then vim.cmd [[syntax enable]] end

if vim.loop.os_uname().sysname == "Darwin" then
  g.clipboard = {
    name = "macOS-clipboard",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
    cache_enabled = 0,
  }
end

wo.scrolloff = 8
wo.sidescrolloff = 8
wo.wrap = false
wo.cursorline = true

-- Some defaults and don't question it
o.wrap = false -- egh i don't like wrap
o.writebackup = false -- whos needs backup btw (i do sometimes)
o.autowrite = true -- sometimes I forget to save
o.guicursor = "" -- no gui cursor
o.cursorline = false -- show cursor line
o.cursorcolumn = false -- show cursor column
o.undofile = true -- set undofile to infinite undo
o.breakindent = true -- enable break indent
o.breakindentopt = "shift:2,min:20" -- wrap two spaces, with min of 20 text width
o.clipboard = "unnamedplus" -- sync system clipboard
o.pumheight = 8 -- larger completion windows
o.autoindent = true -- auto indent
o.expandtab = true -- convert spaces to tabs
o.mouse = "a" -- ugh who needs mouse (accept on SSH maybe)
o.number = true -- number is good for nav
o.swapfile = false -- I don't like swap files personally, found undofile to be better
o.undofile = true -- better than swapfile
o.undolevels = 9999 -- infinite undo
o.formatoptions = "rqnl1j" -- NOTE: "1jcroql"
o.laststatus = 2 -- show statusline on buffer

if vim.fn.has "nvim-0.9" == 1 then
  opt.shortmess:append "C" -- Don't show "Scanning..." messages
  o.splitkeep = "screen" -- Reduce scroll during window split
end

o.diffopt = "filler,iwhite,internal,linematch:60,algorithm:patience" -- better diff
o.sessionoptions = "buffers,curdir,help,tabpages,winsize" -- session options

o.statusline = table.concat({
  "%{%luaeval('statusline.git()')%}",
  "%m",
  "%=",
  "%=",
  "%{%luaeval('statusline.diagnostic()')%}",
  "%y",
  "%l:%c",
  "♥",
}, " ")

opt.pumblend = 17 -- make completion window transparent
opt.completeopt = { "menuone", "noselect" } -- better completion menu

-- searching and grep stuff
o.smartcase = true
o.ignorecase = true
o.infercase = true
o.grepprg = "rg --vimgrep" -- also its 2023 use rg
o.linebreak = true
o.jumpoptions = "stack"
o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"

-- Spaces and tabs config
local TABWIDTH = 2
o.tabstop = TABWIDTH
o.softtabstop = TABWIDTH
o.shiftwidth = TABWIDTH
o.shiftround = true

-- UI config
opt.smartindent = true
o.cmdheight = 1
o.showcmd = false
o.showmode = true
o.showbreak = "↳  "
o.sidescrolloff = 5
o.signcolumn = "yes:1"
o.splitbelow = true
o.splitright = true
o.timeout = true
o.timeoutlen = 200
o.updatetime = 200
o.virtualedit = "block"
o.whichwrap = "h,l,<,>,[,],~"

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- last but def not least, wildmenu
o.wildchar = 9
o.wildignorecase = true
o.wildmode = "longest:full,full"
opt.wildignore = { "__pycache__", "*.o", "*~", "*.pyc", "*pycache*", "Cargo.lock", "lazy-lock.json" }

-- map leader to <Space> and localeader to +
g.mapleader = " "
g.maplocalleader = ","

vim.keymap.set({ "n", "x" }, " ", "", { noremap = true })

-- NOTE: diagnostic config
for _, type in pairs { { "Error", "✖" }, { "Warn", "▲" }, { "Hint", "⚑" }, { "Info", "●" } } do
  local hl = string.format("DiagnosticSign%s", type[1])
  vim.fn.sign_define(hl, { text = type[2], texthl = hl, numhl = hl })
end

vim.diagnostic.config {
  severity_sort = true,
  underline = false,
  update_in_insert = false,
  virtual_text = false, -- { prefix = "", spacing = 4 }
  float = {
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    focusable = false,
    focus = false,
    format = function(diagnostic) return string.format("%s (%s)", diagnostic.message, diagnostic.source) end,
    source = "if_many",
    border = "single",
  },
}
