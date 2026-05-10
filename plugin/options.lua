local wo = vim.wo
wo.scrolloff = 2
wo.sidescrolloff = 5
wo.wrap = true
wo.cursorline = true
wo.cursorcolumn = false

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
o.numberwidth = 1
o.signcolumn = "yes:1"
o.foldcolumn = "0"
o.statuscolumn = "%s%=%{v:relnum?v:relnum:v:lnum} "
o.swapfile = false
o.autowrite = true
o.undofile = true
o.undolevels = 9999
o.showtabline = 0
o.smoothscroll = true

o.shortmess = "ltTaoOcF"
o.formatexpr = "v:lua.vim.lsp.formatexpr()"
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

o.foldmethod = "expr"
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
o.showmode = false
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

o.wildchar = 9
o.wildignorecase = true
o.wildmode = "longest:full,full"
