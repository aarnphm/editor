local o, opt, g, wo = vim.o, vim.opt, vim.g, vim.wo

if vim.uv.os_uname().sysname == "Darwin" then
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

-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true

-- Some defaults and don't question it
o.writebackup = false -- whos needs backup btw (i do sometimes)
o.autowrite = true -- sometimes I forget to save
o.guicursor = "" -- no gui cursor
o.signcolumn = "yes" -- always show sign column
o.undofile = true -- set undofile to infinite undo
o.breakindent = true -- enable break indent
o.breakindentopt = "shift:2,min:20" -- wrap two spaces, with min of 20 text width
o.pumheight = 10 -- larger completion windows
o.expandtab = true -- convert spaces to tabs
o.mouse = "a" -- ugh who needs mouse (accept on SSH maybe)
o.number = true -- number is good for nav
o.swapfile = false -- I don't like swap files personally, found undofile to be better
o.autowrite = true
o.undofile = true -- better than swapfile
o.undolevels = 9999 -- infinite undo
o.showtabline = 0
o.statuscolumn = [[%!v:lua.require'utils'.ui.statuscolumn()]]
-- Window blending configuration
o.winblend = 0
o.pumblend = 0 -- make completion window transparent

opt.shortmess:append { W = true, c = true, C = true }
o.formatexpr = "v:lua.require'utils'.format.formatexpr()"
o.completeopt = "menu,menuone,noselect"
o.formatoptions = "1jqlnt" -- NOTE: "tqjcro"

o.diffopt = "filler,iwhite,internal,linematch:60,algorithm:patience" -- better diff
o.sessionoptions = "buffers,curdir,help,tabpages,winsize" -- session options

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
o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
o.inccommand = "split"

-- fold with nvim-ufo
o.foldenable = true
o.conceallevel = 2
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
o.foldmethod = "expr"
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
o.cmdheight = 0
o.showcmd = false
o.showbreak = "↳  "
o.sidescrolloff = 8
o.splitbelow = true
o.splitright = true
o.timeout = true
o.timeoutlen = 300
o.updatetime = 200
o.virtualedit = "block"
o.laststatus = 2
o.whichwrap = "h,l,<,>,[,],~"

-- last but def not least, wildmenu
o.wildchar = 9
o.wildignorecase = true
o.wildmode = "longest:full,full"
opt.wildignore = { "__pycache__", "*.o", "*~", "*.pyc", "*pycache*", "Cargo.lock", "lazy-lock.json" }

-- map leader to <Space> and localeader to +
g.mapleader = " "
g.maplocalleader = ","

-- Fix markdown indentation settings
g.markdown_recommended_style = 0

-- options
g.autoformat = true
g.bigfile_size = 1024 * 1024 * 1.5 -- 1.5 MB mini.animate will also be disabled.
g.inline_diagnostics = false
g.picker = "mini.pick"
g.ghost_text = false
g.additional_path_root_spec = { "content" }
g.vault = vim.fn.expand "~" .. "/workspace/garden/content"
g.cmp_widths = { abbr = 30, menu = 30 }
g.cmp_format = "symbol" -- "symbol" | "text_symbol" | "text"
g.border = "single"
g.enable_agent_inlay = false
g.override_background = os.getenv "XDG_SYSTEM_THEME" or "dark"

vim.keymap.set({ "n", "x" }, " ", "", { noremap = true })
