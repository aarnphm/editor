vim.cmd.colorscheme "un"

-- custom python provider
local conda_prefix = os.getenv "CONDA_PREFIX"
if not conda_prefix == nil or conda_prefix == "" then
	vim.g.python_host_prog = conda_prefix .. "/bin/python"
	vim.g.python3_host_prog = conda_prefix .. "/bin/python"
elseif vim.fn.executable(vim.env.HOME .. "/.pyenv/shims/python") == 1 then
	vim.g.python_host_prog = vim.env.HOME .. "/.pyenv/shims/python"
	vim.g.python3_host_prog = vim.env.HOME .. "/.pyenv/shims/python"
elseif vim.NIL ~= vim.fn.getenv "PYTHON3_HOST_PROG" then
	-- get python host prog from env
	vim.g.python_host_prog = vim.env["PYTHON3_HOST_PROG"]
	vim.g.python3_host_prog = vim.env["PYTHON3_HOST_PROG"]
else
	vim.notify_once(
		"Failed to autodetect Python path. "
			.. "Either set PYTHON3_HOST_PROG or set 'vim.g.python3_host_prog' for plugins to work.",
		vim.log.levels.WARN,
		{ title = "zox: configuration" }
	)
end

if vim.loop.os_uname().sysname == "Darwin" then
	vim.g.clipboard = {
		name = "macOS-clipboard",
		copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
		paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
		cache_enabled = 0,
	}
end

-- quick hack for install sqlite with nix
vim.g.sqlite_clib_path = vim.NIL ~= vim.fn.getenv "SQLITE_PATH" and vim.env["SQLITE_PATH"]
	or print "SQLITE_PATH is not set. Telescope will not work"

vim.o.autoindent = true
vim.o.autoread = true
vim.o.autowrite = true
vim.o.backspace = "indent,eol,start"
vim.o.breakat = [[\ \	;:,!?]]
vim.opt.guicursor = ""
vim.opt.pumheight = 8
vim.opt.undofile = true
vim.opt.signcolumn = "yes"
vim.opt.breakindent = true
vim.o.breakindentopt = "shift:2,min:20"
vim.o.clipboard = "unnamedplus"
vim.o.cmdheight = 1 -- 0, 1,
vim.o.cmdwinheight = 5
vim.o.complete = ".,w,b,k"
vim.o.concealcursor = "niv"
vim.o.conceallevel = 0
vim.o.diffopt = "filler,iwhite,internal,algorithm:patience"
vim.o.equalalways = false
vim.o.expandtab = true
vim.o.fileformats = "unix,mac,dos"
vim.o.foldenable = true
vim.o.foldlevelstart = 99
vim.o.formatoptions = "1jcrql"
vim.o.grepformat = "%f:%l:%c:%m"
vim.o.grepprg = "rg --hidden --vimgrep --smart-case --"
vim.o.helpheight = 12
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.infercase = true
vim.o.jumpoptions = "stack"
vim.o.laststatus = 2
vim.o.statusline = "%= %l:%c ♥ "
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
vim.o.shiftround = true
vim.o.shiftwidth = 4
vim.opt.shortmess:append "c"
vim.o.showbreak = "↳  "
vim.o.showcmd = false
vim.o.showmode = false
vim.o.showtabline = 2
vim.o.sidescrolloff = 5
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.smarttab = true
vim.o.softtabstop = 4
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.startofline = false
vim.o.swapfile = false
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
vim.o.wildignore =
	".git,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**"
vim.o.wildchar = 9
vim.o.wildignorecase = true
vim.o.wildmode = "longest:full,full"
vim.o.winminwidth = 10
vim.o.winwidth = 30
vim.o.wrap = false
vim.o.wrapscan = true
vim.o.writebackup = false

vim.diagnostic.config { virtual_text = false }

local signs = { "Error", "Warn", "Hint", "Info" }
for _, type in pairs(signs) do
	local hl = string.format("DiagnosticSign%s", type)
	vim.fn.sign_define(hl, { text = "●", texthl = hl, numhl = hl })
end

-- Jump to last position. See :h last-position-jump
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function()
		local line = vim.fn.line "'\""
		if line >= 1 and line <= vim.fn.line "$" then vim.cmd "normal! g`\"" end
	end,
})
