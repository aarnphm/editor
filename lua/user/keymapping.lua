local k = require "zox.keybind"

-- map leader to <Space> and localeader to +
vim.g.mapleader = " "
vim.g.maplocalleader = "+"
vim.api.nvim_set_keymap("n", " ", "", { noremap = true })
vim.api.nvim_set_keymap("x", " ", "", { noremap = true })

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
	["n|sn"] = k.cmd("nzzzv"):with_noremap():with_desc "edit: Next search result",
	["n|sN"] = k.cmd("Nzzzv"):with_noremap():with_desc "edit: Prev search result",
	["n|J"] = k.cmd("mzJ`z"):with_noremap():with_desc "edit: Join next line",
	["n|<C-h>"] = k.cmd("<C-w>h"):with_noremap():with_desc "window: Focus left",
	["n|<C-l>"] = k.cmd("<C-w>l"):with_noremap():with_desc "window: Focus right",
	["n|<C-j>"] = k.cmd("<C-w>j"):with_noremap():with_desc "window: Focus down",
	["n|<C-k>"] = k.cmd("<C-w>k"):with_noremap():with_desc "window: Focus up",
	["n|<C-x>"] = k.cr("BufDel"):with_defaults "buffer: Delete current buffer",
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
	["n|<LocalLeader>vs"] = k.cu("vsplit"):with_defaults "edit: split window vertically",
	["n|<LocalLeader>hs"] = k.cu("split"):with_defaults "edit: split window horizontally",
	["n|<LocalLeader>l"] = k.cmd(":set list! list?<CR>")
		:with_noremap()
		:with_desc "edit: toggle invisible characters",
	-- lsp
	["n|co"] = k.cr("Lspsaga outline"):with_defaults "lsp: Toggle outline",
	["n|ch"] = k.callback(vim.show_pos):with_defaults "lsp: Show hightlight",
	["n|c["] = k.callback(vim.diagnostic.goto_prev):with_defaults "lsp: Prev diagnostic",
	["n|c]"] = k.callback(vim.diagnostic.goto_next):with_defaults "lsp: Next diagnostic",
	["n|cr"] = k.callback(vim.lsp.buf.rename):with_defaults "lsp: Rename in file range",
	["n|cD"] = k.callback(vim.lsp.buf.type_definition):with_defaults "lsp: Type definition",
	["n|K"] = k.callback(vim.lsp.buf.signature_help):with_defaults "lsp: Signature help",
	["n|ca"] = k.callback(vim.lsp.buf.code_action):with_defaults "lsp: Code action for cursor",
	["v|ca"] = k.callback(vim.lsp.buf.code_action):with_defaults "lsp: Code action for range",
	["n|ce"] = k.callback(vim.diagnostic.open_float):with_defaults "lsp: Open current diagnostic",
}
