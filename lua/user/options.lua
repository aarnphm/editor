vim.o.autowrite = true
vim.o.breakat = [[\ \	;:,!?]]
vim.o.guicursor = ""
vim.o.undofile = true
vim.o.breakindent = true
vim.o.breakindentopt = "shift:2,min:20"
vim.o.clipboard = "unnamedplus"
vim.o.complete = ".,w,b,k"
vim.o.completeopt = "menuone,noselect"
vim.o.expandtab = true
vim.o.formatoptions = "1jcroql"
vim.o.grepformat = "%f:%l:%c:%m"
vim.o.grepprg = "rg --hidden --vimgrep --smart-case --"
-- Better folding using tree-sitter
vim.o.foldlevelstart = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.ignorecase = true
vim.o.infercase = true
vim.o.jumpoptions = "stack"
vim.o.statusline = "%f %m %= %=%y %l:%c ♥ "
vim.o.swapfile = false
vim.o.linebreak = true
vim.o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
vim.o.mouse = "a"
vim.o.number = true
vim.o.pumheight = 15
vim.o.relativenumber = true
vim.o.shiftround = true
vim.o.shiftwidth = 4
vim.o.shortmess = "aoOTIcF"
vim.o.showbreak = "↳  "
vim.o.sidescrolloff = 5
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.softtabstop = 4
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 4
vim.o.timeoutlen = 300
vim.o.undofile = true
vim.o.undolevels = 9999
vim.o.updatetime = 50
vim.o.viewoptions = "folds,cursor,curdir,slash,unix"
vim.o.virtualedit = "block"
vim.o.whichwrap = "h,l,<,>,[,],~"
vim.o.wildchar = 9
vim.o.wildignorecase = true
vim.o.wildmode = "longest:full,full"
vim.o.winminwidth = 10
vim.o.wrap = false
vim.o.writebackup = false

if vim.loop.os_uname().sysname == "Darwin" then
	vim.g.clipboard = {
		name = "macOS-clipboard",
		copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
		paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
		cache_enabled = 0,
	}
end

vim.diagnostic.config { virtual_text = false }

local signs = { "Error", "Warn", "Hint", "Info" }
for _, type in pairs(signs) do
	local hl = string.format("DiagnosticSign%s", type)
	vim.fn.sign_define(hl, { text = "●", texthl = hl, numhl = hl })
end

-- map leader to <Space> and localeader to +
vim.g.mapleader = " "
vim.g.maplocalleader = "+"
vim.api.nvim_set_keymap("n", " ", "", { noremap = true })
vim.api.nvim_set_keymap("x", " ", "", { noremap = true })
