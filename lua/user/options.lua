local k = require "keybind"

-- default vim options
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
vim.o.showmode = false
vim.o.showcmd = false
vim.o.showbreak = "↳  "
vim.o.sidescrolloff = 5
vim.o.signcolumn = "yes:1"
vim.o.smartcase = true
vim.o.softtabstop = 4
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 4
vim.o.timeout = true
vim.o.timeoutlen = 200
vim.o.undofile = true
vim.o.undolevels = 9999
vim.o.updatetime = 250
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

for _, type in pairs { "Error", "Warn", "Hint", "Info" } do
	local hl = string.format("DiagnosticSign%s", type)
	vim.fn.sign_define(hl, { text = "●", texthl = hl, numhl = hl })
end

vim.diagnostic.config {
	-- NOTE: on a sunny day where I feel like enable virtual text use { spacing = 4, prefix = "●" }
	virtual_text = false,
	underline = false,
	update_in_insert = false,
	severity_sort = true,
}

-- NOTE: diagnostic on hover
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	callback = function() vim.diagnostic.open_float(nil, { focus = false }) end,
})

-- map leader to <Space> and localeader to +
vim.g.mapleader = " "
vim.g.maplocalleader = "+"
vim.keymap.set({ "n", "x" }, " ", "", { noremap = true })

k.nvim_register_mapping {
	["n|<S-Tab>"] = k.cr("normal za"):with_defaults "edit: Toggle code fold",
	-- Visual
	["v|J"] = k.cmd(":m '>+1<CR>gv=gv"):with_desc "edit: Move this line down",
	["v|K"] = k.cmd(":m '<-2<CR>gv=gv"):with_desc "edit: Move this line up",
	["v|<"] = k.cmd("<gv"):with_desc "edit: Decrease indent",
	["v|>"] = k.cmd(">gv"):with_desc "edit: Increase indent",
	["c|W!!"] = k.cmd("execute 'silent! write !sudo tee % >/dev/null' <bar> edit!")
		:with_desc "editc: Save file using sudo",
	-- yank to end of line
	["n|Y"] = k.cmd("y$"):with_desc "edit: Yank text to EOL",
	["n|D"] = k.cmd("d$"):with_desc "edit: Delete text to EOL",
	["n|J"] = k.cmd("mzJ`z"):with_noremap():with_desc "edit: Join next line",
	-- window movement
	["n|<C-h>"] = k.cmd("<C-w>h"):with_noremap():with_desc "window: Focus left",
	["n|<C-l>"] = k.cmd("<C-w>l"):with_noremap():with_desc "window: Focus right",
	["n|<C-j>"] = k.cmd("<C-w>j"):with_noremap():with_desc "window: Focus down",
	["n|<C-k>"] = k.cmd("<C-w>k"):with_noremap():with_desc "window: Focus up",
	["n|<LocalLeader>sw"] = k.cmd("<C-w>r"):with_noremap():with_desc "window: swap position",
	["n|<LocalLeader>vs"] = k.cmd("<C-w>v"):with_defaults "edit: split window vertically",
	["n|<LocalLeader>hs"] = k.cmd("<C-w>s"):with_defaults "edit: split window horizontally",
	["n|<leader>qq"] = k.cr("wqa"):with_defaults "editor: write quit all",
	["n|<Leader>."] = k.cr("bnext"):with_defaults "buffer: next",
	["n|<Leader>,"] = k.cr("bprevious"):with_defaults "buffer: previous",
	-- quickfix
	["n|<Leader>q"] = k.cr("copen"):with_defaults "quickfix: Open quickfix",
	["n|<Leader>Q"] = k.cr("cclose"):with_defaults "quickfix: Close quickfix",
	["n|<Leader>l"] = k.cr("lopen"):with_defaults "quickfix: Open location list",
	["n|<Leader>L"] = k.cr("lclose"):with_defaults "quickfix: Close location list",
	-- remap command key to ;
	["n|;"] = k.cmd(":"):with_noremap():with_desc "command: Enter command mode",
	["n|\\"] = k.cmd(":let @/=''<CR>:noh<CR>"):with_noremap():with_desc "edit: clean hightlight",
	["n|<LocalLeader>]"] = k.cr("vertical resize -10")
		:with_silent()
		:with_desc "windows: resize right 10px",
	["n|<LocalLeader>["] = k.cr("vertical resize +10")
		:with_silent()
		:with_desc "windows: resize left 10px",
	["n|<LocalLeader>-"] = k.cr("resize -5"):with_silent():with_desc "windows: resize down 5px",
	["n|<LocalLeader>="] = k.cr("resize +5"):with_silent():with_desc "windows: resize up 5px",
	["n|<LocalLeader>l"] = k.cmd(":set list! list?<CR>")
		:with_noremap()
		:with_desc "edit: toggle invisible characters",
	["n|<LocalLeader>ft"] = k.callback(require("lsp").toggle):with_defaults "lsp: Toggle formatter",
	["n|<LocalLeader>p"] = k.cr("Lazy"):with_defaults "package: show manager",
	-- telescope
	["n|<Leader>f"] = k.callback(
		function()
			require("telescope.builtin").find_files {
				find_command = {
					"fd",
					"-H",
					"-tf",
					"-E",
					"lazy-lock.json",
					"--strip-cwd-prefix",
				},
				theme = "dropdown",
				previewer = false,
			}
		end
	):with_defaults "find: file in current directory",
	["n|<Leader>r"] = k.callback(
		function()
			require("telescope.builtin").git_files {

				find_command = {
					"fd",
					"-H",
					"-tf",
					"-E",
					"lazy-lock.json",
					"--strip-cwd-prefix",
				},
				theme = "dropdown",
				previewer = false,
			}
		end
	):with_defaults "find: files in git repository",
	["n|<Leader>'"] = k.callback(function() require("telescope.builtin").live_grep {} end)
		:with_defaults "find: words",
	["n|<Leader>w"] = k.callback(
		function() require("telescope").extensions.live_grep_args.live_grep_args() end
	):with_defaults "find: live grep args",
	["n|<Leader>/"] = k.cr("Telescope grep_string"):with_defaults "find: Current word under cursor.",
	["n|<Leader>b"] = k.cr("Telescope buffers show_all_buffers=true previewer=false")
		:with_defaults "find: Current buffers",
	["n|<Leader>n"] = k.cr("enew"):with_defaults "buffer: new",
	["n|<C-p>"] = k.callback(function()
		require("telescope.builtin").keymaps {
			lhs_filter = function(lhs) return not string.find(lhs, "Þ") end,
			layout_config = {
				width = 0.6,
				height = 0.6,
				prompt_position = "top",
			},
		}
	end):with_defaults "tools: Show keymap legends",
	-- NOTE: toggleterm
	["n|<C-\\>"] = k.cr([[execute v:count . "ToggleTerm direction=horizontal"]])
		:with_defaults "terminal: Toggle horizontal",
	["i|<C-\\>"] = k.cmd("<Esc><Cmd>ToggleTerm direction=horizontal<CR>")
		:with_defaults "terminal: Toggle horizontal",
	["t|<C-\\>"] = k.cmd("<Esc><Cmd>ToggleTerm<CR>"):with_defaults "terminal: Toggle horizontal",
	["n|<C-t>"] = k.cr([[execute v:count . "ToggleTerm direction=vertical"]])
		:with_defaults "terminal: Toggle vertical",
	["i|<C-t>"] = k.cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>")
		:with_defaults "terminal: Toggle vertical",
	["t|<C-t>"] = k.cmd("<Esc><Cmd>ToggleTerm<CR>"):with_defaults "terminal: Toggle vertical",
}
