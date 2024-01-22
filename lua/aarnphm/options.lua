local o, opt, g, wo = vim.o, vim.opt, vim.g, vim.wo

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
wo.cursorcolumn = false

-- Some defaults and don't question it
o.writebackup = false -- whos needs backup btw (i do sometimes)
o.autowrite = true -- sometimes I forget to save
o.guicursor = "" -- no gui cursor
o.signcolumn = "yes" -- always show sign column
o.undofile = true -- set undofile to infinite undo
o.breakindent = true -- enable break indent
o.breakindentopt = "shift:2,min:20" -- wrap two spaces, with min of 20 text width
o.clipboard = "unnamedplus" -- sync system clipboard
o.pumheight = 15 -- larger completion windows
o.expandtab = true -- convert spaces to tabs
o.mouse = "a" -- ugh who needs mouse (accept on SSH maybe)
o.number = true -- number is good for nav
o.swapfile = false -- I don't like swap files personally, found undofile to be better
o.autowrite = true
o.undofile = true -- better than swapfile
o.undolevels = 9999 -- infinite undo
o.showtabline = 0
o.laststatus = 3 -- show statusline on buffer
o.statusline = table.concat({
  "%{%luaeval('statusline.mode {trunc_width = 75}')%}",
  "%{%luaeval('statusline.git {trunc_width = 120}')%}",
  "%=",
  "%{%luaeval('statusline.diagnostic {trunc_width = 90}')%}",
  "%{%luaeval('statusline.filetype {trunc_width = 75}')%}",
  "%{%luaeval('statusline.location {trunc_width = 90}')%}",
}, " ")

opt.shortmess:append { W = true, I = true, c = true, C = true }
opt.formatexpr = "v:lua.Util.format.formatexpr()"
o.formatoptions = "jcroqlnt" -- NOTE: "1jcroql"

o.diffopt = "filler,iwhite,internal,linematch:60,algorithm:patience" -- better diff
o.sessionoptions = "buffers,curdir,help,tabpages,winsize" -- session options
opt.pumblend = 8 -- make completion window transparent

-- searching and grep stuff
o.smartcase = true
o.ignorecase = true
o.infercase = true
o.grepformat = "%f:%l:%c:%m"
o.grepprg = "rg --vimgrep" -- also its 2023 use rg
o.linebreak = true
o.jumpoptions = "stack"
o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"

-- fold with nvim-ufo
o.foldenable = true
opt.conceallevel = 2
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
o.foldmethod = "expr"
o.foldlevel = 99
-- o.foldtext = "v:lua.Util.ui.foldtext()"
o.foldlevelstart = 99
o.foldopen = "block,mark,percent,quickfix,search,tag,undo"

-- Spaces and tabs config
o.tabstop = TABWIDTH
o.softtabstop = TABWIDTH
o.shiftwidth = TABWIDTH

-- UI config
opt.showmode = false -- This is set with mini.statusline
opt.smartindent = true
o.cmdheight = 1
o.showcmd = false
o.showbreak = "↳  "
o.sidescrolloff = 5
o.splitbelow = true
o.splitright = true
o.timeout = true
o.timeoutlen = 200
o.updatetime = 250
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

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
