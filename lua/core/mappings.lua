local k = require "keybind"

k.nvim_load_mapping {
	["n|<S-Tab>"] = k.map_cr("normal za"):with_defaults():with_desc "editn: Toggle code fold",
	-- Insert
	["i|<C-u>"] = k.map_cmd("<C-G>u<C-U>"):with_noremap():with_desc "editi: Delete previous block",
	["i|<C-b>"] = k.map_cmd("<Left>"):with_noremap():with_desc "editi: Move cursor to left",
	["i|<C-a>"] = k.map_cmd("<ESC>^i"):with_noremap():with_desc "editi: Move cursor to line start",
	-- Visual
	["v|J"] = k.map_cmd(":m '>+1<CR>gv=gv"):with_desc "editv: Move this line down",
	["v|K"] = k.map_cmd(":m '<-2<CR>gv=gv"):with_desc "editv: Move this line up",
	["v|<"] = k.map_cmd("<gv"):with_desc "editv: Decrease indent",
	["v|>"] = k.map_cmd(">gv"):with_desc "editv: Increase indent",
	["n|<C-s>"] = k.map_cu("write"):with_noremap():with_desc "editn: Save file",
	["c|W!!"] = k.map_cmd("execute 'silent! write !sudo tee % >/dev/null' <bar> edit!")
		:with_desc "editc: Save file using sudo",
	-- yank to end of line
	["n|Y"] = k.map_cmd("y$"):with_desc "editn: Yank text to EOL",
	["n|D"] = k.map_cmd("d$"):with_desc "editn: Delete text to EOL",
	["n|sn"] = k.map_cmd("nzzzv"):with_noremap():with_desc "editn: Next search result",
	["n|sN"] = k.map_cmd("Nzzzv"):with_noremap():with_desc "editn: Prev search result",
	["n|J"] = k.map_cmd("mzJ`z"):with_noremap():with_desc "editn: Join next line",
	["n|<C-h>"] = k.map_cmd("<C-w>h"):with_noremap():with_desc "window: Focus left",
	["n|<C-l>"] = k.map_cmd("<C-w>l"):with_noremap():with_desc "window: Focus right",
	["n|<C-j>"] = k.map_cmd("<C-w>j"):with_noremap():with_desc "window: Focus down",
	["n|<C-k>"] = k.map_cmd("<C-w>k"):with_noremap():with_desc "window: Focus up",
	-- remap command key to ;
	["n|;"] = k.map_cmd(":"):with_noremap():with_desc "command: Enter command mode",
	["n|\\"] = k.map_cmd(":let @/=''<CR>:noh<CR>"):with_noremap():with_desc "editn: clean hightlight",
	["n|<LocalLeader>]"] = k.map_cr("vertical resize -10"):with_silent():with_desc "windows: resize right 10px",
	["n|<LocalLeader>["] = k.map_cr("vertical resize +10"):with_silent():with_desc "windows: resize left 10px",
	["n|<LocalLeader>-"] = k.map_cr("resize -5"):with_silent():with_desc "windows: resize down 5px",
	["n|<LocalLeader>="] = k.map_cr("resize +5"):with_silent():with_desc "windows: resize up 5px",
	["n|<LocalLeader>lcd"] = k.map_cmd(":lcd %:p:h<CR>")
		:with_noremap()
		:with_desc "editn: change directory to current file",
	["n|<LocalLeader>vs"] = k.map_cu("vsplit"):with_defaults():with_desc "editn: split window vertically",
	["n|<LocalLeader>hs"] = k.map_cu("split"):with_defaults():with_desc "editn: split window horizontally",
	["n|<Leader>o"] = k.map_cr("setlocal spell! spelllang=en_us"):with_desc "editn: toggle spell check",
	["n|<Leader>I"] = k.map_cmd(":set list!<CR>"):with_noremap():with_desc "editn: toggle invisible characters",
	["n|<Leader>p"] = k.map_cmd(":%s///g<CR>")
		:with_defaults()
		:with_desc "editn: replace all occurences of the word under cursor",
	["n|<Leader>i"] = k.map_cmd("gg=G<CR>"):with_defaults():with_desc "editn: indent file",
	["n|<Leader>l"] = k.map_cmd(":set list! list?<CR>"):with_noremap():with_desc "editn: toggle list",
	["n|<Leader>t"] = k.map_cmd(":%s/\\s\\+$//e<CR>"):with_noremap():with_desc "editn: trim trailing whitespace",
	["n|<LocalLeader>ft"] = k.map_cr("FormatToggle"):with_defaults():with_desc "lsp: toggle format",

	-- Lazy.nvim
	["n|<Space>ph"] = k.map_cr("Lazy"):with_defaults():with_nowait():with_desc "package: Show",
	["n|<Space>ps"] = k.map_cr("Lazy sync"):with_defaults():with_nowait():with_desc "package: Sync",
	["n|<Space>pu"] = k.map_cr("Lazy update"):with_defaults():with_nowait():with_desc "package: Update",
	["n|<Space>pi"] = k.map_cr("Lazy install"):with_defaults():with_nowait():with_desc "package: Install",
	["n|<Space>pl"] = k.map_cr("Lazy log"):with_defaults():with_nowait():with_desc "package: Log",
	["n|<Space>pc"] = k.map_cr("Lazy check"):with_defaults():with_nowait():with_desc "package: Check",
	["n|<Space>pd"] = k.map_cr("Lazy debug"):with_defaults():with_nowait():with_desc "package: Debug",
	["n|<Space>pp"] = k.map_cr("Lazy profile"):with_defaults():with_nowait():with_desc "package: Profile",
	["n|<Space>pr"] = k.map_cr("Lazy restore"):with_defaults():with_nowait():with_desc "package: Restore",
	["n|<Space>px"] = k.map_cr("Lazy clean"):with_defaults():with_nowait():with_desc "package: Clean",
}
