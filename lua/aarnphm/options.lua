local o, opt, g = vim.o, vim.opt, vim.g

if vim.loop.os_uname().sysname == "Darwin" then
  g.clipboard = {
    name = "macOS-clipboard",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
    cache_enabled = 0,
  }
end

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
o.expandtab = true -- convert spaces to tabs
o.mouse = "a" -- ugh who needs mouse (accept on SSH maybe)
o.number = true -- number is good for nav
o.relativenumber = true -- relativenumber is useful, grow up
o.swapfile = false -- I don't like swap files personally, found undofile to be better
o.undofile = true -- better than swapfile
o.undolevels = 9999 -- infinite undo
o.shortmess = "aoOTIcF" -- insanely complex shortmess, but its cleannn
o.laststatus = 2 -- show statusline on buffer
o.diffopt = "filler,iwhite,internal,linematch:60,algorithm:patience" -- better diff
o.sessionoptions = "buffers,curdir,help,tabpages,winsize" -- session options
o.shada = "!,'500,<50,@100,s10,h" -- shada options
o.statusline = _G.statusline.build()

opt.pumblend = 17 -- make completion window transparent
opt.completeopt = { "menuone", "noselect" } -- better completion menu
-- NOTE: "1jcroql"
opt.formatoptions = opt.formatoptions
  - "a" -- Auto formatting is BAD.
  - "t" -- Don't auto format my code. I got linters for that.
  + "c" -- In general, I like it when comments respect textwidth
  + "q" -- Allow formatting comments w/ gq
  - "o" -- O and o, don't continue comments
  + "r" -- But do continue when pressing enter.
  + "n" -- Indent past the formatlistpat, not underneath it.
  + "j" -- Auto-remove comments if possible.
  - "2" -- I'm not in gradeschool anymore

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
    border = "none",
  },
}
