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
	["n|<Leader>p"] = k.cr("Lazy"):with_nowait():with_desc "package: Show",
	["n|<LocalLeader>ft"] = k.cr("FormatToggle"):with_defaults "lsp: Toggle formatter",
	-- nvim-tree
	["n|<C-n>"] = k.cr("NvimTreeToggle"):with_defaults "file-explorer: Toggle",
	-- telescope
	["n|<Leader>f"] = k.callback(
		function()
			require("telescope.builtin").find_files {
				find_command = { "fd", "-H", "-tf", "--strip-cwd-prefix" },
				theme = "dropdown",
				previewer = false,
			}
		end
	):with_defaults "find: file in current directory",
	["n|<Leader>r"] = k.callback(
		function()
			require("telescope.builtin").git_files {

				find_command = { "fd", "-H", "-tf", "--strip-cwd-prefix" },
				theme = "dropdown",
				previewer = false,
			}
		end
	):with_defaults "find: files in git repository",
	["n|<Leader>w"] = k.callback(
		function() require("telescope").extensions.live_grep_args.live_grep_args() end
	):with_defaults "find: live grep args",
	["n|<Leader>/"] = k.cr("Telescope grep_string"):with_defaults "find: Current word under cursor.",
	["n|<Leader>b"] = k.cr("Telescope buffers previewer=false")
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
}
