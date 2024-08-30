local o, opt, g, wo, go = vim.o, vim.opt, vim.g, vim.wo, vim.go

if vim.uv.os_uname().sysname == "Darwin" then
  g.clipboard = {
    name = "macOS-clipboard",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
    cache_enabled = 0,
  }
end

local enable_ui = true

-- window opts
wo.scrolloff = 8
wo.sidescrolloff = 8
wo.wrap = false
wo.cursorline = false
wo.cursorcolumn = false

-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true
opt.winminwidth = 5 -- Minimum window width

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
o.cmdheight = enable_ui and 0 or 1
o.showcmd = false
o.showbreak = "↳  "
o.sidescrolloff = 8
o.splitbelow = true
o.splitright = true
o.timeout = true
o.timeoutlen = 300
o.updatetime = 250
o.virtualedit = "block"
o.laststatus = 3
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

-- map leader to <Space> and localeader to +
g.mapleader = " "
g.maplocalleader = ","

-- Fix markdown indentation settings
g.markdown_recommended_style = 0

-- options
g.autoformat = true
g.bigfile_size = 1024 * 1024 * 1.5 -- 1.5 MB mini.animate will also be disabled.
g.inline_diagnostics = false
g.picker = "mini.pick" -- mini.pick | telescope
g.ghost_text = false
g.additional_path_root_spec = { "content" }
g.vault = vim.fn.expand "~" .. "/workspace/garden/content"
g.border = "single"
g.enable_agent_inlay = false
g.enable_ui = enable_ui

if vim.g.neovide then
  vim.g.neovide_no_idle = true
  vim.g.neovide_refresh_rate = 120
  vim.g.neovide_cursor_animation_length = 0.03
  vim.g.neovide_cursor_trail_length = 0.05
  vim.g.neovide_input_macos_option_key_is_meta = "only_left"
end

vim.keymap.set({ "n", "x" }, " ", "", { noremap = true })
