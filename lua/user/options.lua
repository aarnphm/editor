vim.filetype.add {
	extension = {
		conf = "conf",
		mdx = "markdown",
		mjml = "html",
		cjs = "javascript",
	},
	pattern = {
		["%.(%a+)"] = function(_, _, ext)
			if vim.tbl_contains({ "Dockerfile", "dockerfile" }, ext) then
				return "dockerfile"
			elseif vim.tbl_contains({ "j2", "jinja", "tpl", "template" }, ext) then
				return "html"
			elseif vim.tbl_contains({ "bazel", "bzl" }, ext) then
				return "bzl"
			end
		end,
		["Dockerfile.(%a+)$"] = function(_, _, ext)
			if vim.tbl_contains({ "template", "tpl", "tmpl" }, ext) then return "dockerfile" end
		end,
		[".*%.env.*"] = "sh",
		["ignore$"] = "conf",
		["gitconfig"] = "gitconfig",
	},
	filename = {
		["yup.lock"] = "yaml",
		["WORKSPACE"] = "bzl",
	},
}

vim.o.autoindent = true
vim.o.autoread = true
vim.o.autowrite = true
vim.o.backspace = "indent,eol,start"
vim.o.breakat = [[\ \	;:,!?]]
vim.o.guicursor = ""
vim.o.pumheight = 8
vim.o.undofile = true
vim.o.signcolumn = "yes"
vim.o.breakindent = true
vim.o.breakindentopt = "shift:2,min:20"
vim.o.clipboard = "unnamedplus"
vim.o.cmdwinheight = 5
vim.o.complete = ".,w,b,k"
vim.o.completeopt = "menuone,noselect"
vim.o.concealcursor = "niv"
vim.o.conceallevel = 0
vim.o.equalalways = true
vim.o.expandtab = true
vim.o.fileformats = "unix,mac,dos"
vim.o.foldenable = true
vim.o.formatoptions = "1jcroql"
vim.o.grepformat = "%f:%l:%c:%m"
vim.o.grepprg = "rg --hidden --vimgrep --smart-case --"
-- Better folding using tree-sitter
vim.o.helpheight = 12
vim.o.foldlevelstart = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.infercase = true
vim.o.jumpoptions = "stack"
-- vim.o.statusline = "%f %m %= %=%y %P %l:%c ♥ "
vim.o.linebreak = true
vim.o.list = true
vim.o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
vim.o.magic = true
vim.o.mouse = "a"
vim.o.mousescroll = "ver:3,hor:6"
vim.o.number = true
vim.o.previewheight = 12
vim.o.pumheight = 15
vim.o.redrawtime = 1500
vim.o.relativenumber = true
vim.o.ruler = true
vim.o.scrolloff = 3
vim.o.shada = "!,'300,<50,@100,s10,h"
vim.o.shiftround = true
vim.o.shiftwidth = 4
vim.opt.shortmess:append "Ic"
vim.o.showbreak = "↳  "
vim.o.showcmd = false
vim.o.showmode = false
vim.o.showtabline = 0
vim.o.sidescrolloff = 5
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smarttab = true
vim.o.softtabstop = 4
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.startofline = false
vim.o.switchbuf = "usetab,uselast"
vim.o.synmaxcol = 2500
vim.o.tabstop = 4
vim.o.timeoutlen = 200
vim.o.undofile = true
vim.o.undolevels = 9999
vim.o.updatetime = 250
vim.o.viewoptions = "folds,cursor,curdir,slash,unix"
vim.o.virtualedit = "block"
vim.o.visualbell = true
vim.o.whichwrap = "h,l,<,>,[,],~"
vim.o.wildchar = 9
vim.o.wildignorecase = true
vim.o.wildmode = "longest:full,full"
vim.o.winminwidth = 10
vim.o.winwidth = 30
vim.o.wrap = false
vim.o.wrapscan = true
vim.o.writebackup = false

if vim.loop.os_uname().sysname == "Darwin" then
	vim.g.clipboard = {
		name = "macOS-clipboard",
		copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
		paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
		cache_enabled = 0,
	}
end

vim.diagnostic.config { virtual_text = false, underline = false }

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
