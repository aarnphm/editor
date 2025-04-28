local o, opt, g, wo, go = vim.o, vim.opt, vim.g, vim.wo, vim.go

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
-- backend for autocomplete
---@type "copilot" | "supermaven"
g.agent_backend = "copilot"
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
g.border = "single"
-- markdown render backend
---@type "markview" | "render-markdown"
g.markdown_render_backend = "render-markdown"
-- additional plugins to be used.
g.extra_plugins = {
  -- lang
  "plugins.lang.go",
  "plugins.lang.sql",
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
  vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "<D-w>", ":q<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "<D-t>", ":enew<CR>", { noremap = true, silent = true })
end

-- respect local venv instead of nix setup
local venv = os.getenv "VIRTUAL_ENV"
if venv ~= nil then g.python3_host_prog = venv .. "/bin/python3" end

vim.keymap.set({ "n", "x" }, " ", "", { noremap = true })
