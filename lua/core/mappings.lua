local k = require "keybind"

k.nvim_load_mapping {
	["n|<S-Tab>"] = k.map_cr("normal za"):with_defaults():with_desc "edit: Toggle code fold",
	-- Insert
	["i|<C-u>"] = k.map_cmd("<C-G>u<C-U>"):with_noremap():with_desc "editi: Delete previous block",
	["i|<C-b>"] = k.map_cmd("<Left>"):with_noremap():with_desc "editi: Move cursor to left",
	["i|<C-a>"] = k.map_cmd("<ESC>^i"):with_noremap():with_desc "editi: Move cursor to line start",
	-- Visual
	["v|J"] = k.map_cmd(":m '>+1<CR>gv=gv"):with_desc "edit: Move this line down",
	["v|K"] = k.map_cmd(":m '<-2<CR>gv=gv"):with_desc "edit: Move this line up",
	["v|<"] = k.map_cmd("<gv"):with_desc "edit: Decrease indent",
	["v|>"] = k.map_cmd(">gv"):with_desc "edit: Increase indent",
	["n|<C-s>"] = k.map_cu("write"):with_noremap():with_desc "edit: Save file",
	["c|W!!"] = k.map_cmd("execute 'silent! write !sudo tee % >/dev/null' <bar> edit!")
		:with_desc "editc: Save file using sudo",
	-- yank to end of line
	["n|Y"] = k.map_cmd("y$"):with_desc "edit: Yank text to EOL",
	["n|D"] = k.map_cmd("d$"):with_desc "edit: Delete text to EOL",
	["n|sn"] = k.map_cmd("nzzzv"):with_noremap():with_desc "edit: Next search result",
	["n|sN"] = k.map_cmd("Nzzzv"):with_noremap():with_desc "edit: Prev search result",
	["n|J"] = k.map_cmd("mzJ`z"):with_noremap():with_desc "edit: Join next line",
	["n|<C-h>"] = k.map_cmd("<C-w>h"):with_noremap():with_desc "window: Focus left",
	["n|<C-l>"] = k.map_cmd("<C-w>l"):with_noremap():with_desc "window: Focus right",
	["n|<C-j>"] = k.map_cmd("<C-w>j"):with_noremap():with_desc "window: Focus down",
	["n|<C-k>"] = k.map_cmd("<C-w>k"):with_noremap():with_desc "window: Focus up",
	-- remap command key to ;
	["n|;"] = k.map_cmd(":"):with_noremap():with_desc "command: Enter command mode",
	["n|\\"] = k.map_cmd(":let @/=''<CR>:noh<CR>"):with_noremap():with_desc "edit: clean hightlight",
	["n|<LocalLeader>]"] = k.map_cr("vertical resize -10"):with_silent():with_desc "windows: resize right 10px",
	["n|<LocalLeader>["] = k.map_cr("vertical resize +10"):with_silent():with_desc "windows: resize left 10px",
	["n|<LocalLeader>-"] = k.map_cr("resize -5"):with_silent():with_desc "windows: resize down 5px",
	["n|<LocalLeader>="] = k.map_cr("resize +5"):with_silent():with_desc "windows: resize up 5px",
	["n|<LocalLeader>lcd"] = k.map_cmd(":lcd %:p:h<CR>")
		:with_noremap()
		:with_desc "edit: change directory to current file",
	["n|<LocalLeader>vs"] = k.map_cu("vsplit"):with_defaults():with_desc "edit: split window vertically",
	["n|<LocalLeader>hs"] = k.map_cu("split"):with_defaults():with_desc "edit: split window horizontally",
	["n|<Leader>o"] = k.map_cr("setlocal spell! spelllang=en_us"):with_desc "edit: toggle spell check",
	["n|<Leader>I"] = k.map_cmd(":set list!<CR>"):with_noremap():with_desc "edit: toggle invisible characters",
	["n|<Leader>p"] = k.map_cmd(":%s///g<CR>")
		:with_defaults()
		:with_desc "edit: replace all occurences of the word under cursor",
	["n|<Leader>i"] = k.map_cmd("gg=G<CR>"):with_defaults():with_desc "edit: indent file",
	["n|<Leader>l"] = k.map_cmd(":set list! list?<CR>"):with_noremap():with_desc "edit: toggle list",
	["n|<Leader>t"] = k.map_cmd(":%s/\\s\\+$//e<CR>"):with_noremap():with_desc "edit: trim trailing whitespace",
	["n|<LocalLeader>ft"] = k.map_cr("FormatToggle"):with_defaults():with_desc "lsp: toggle format",
}
