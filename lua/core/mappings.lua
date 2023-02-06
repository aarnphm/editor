local k = require "keybind"
-- a local reference for ToggleTerm
local _lazygit = nil

local mapping = {
	["n|nza"] = k.map_cr("normal za"):with_defaults():with_desc "editn: Toggle code fold",
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
	["n|n"] = k.map_cmd("nzzzv"):with_noremap():with_desc "editn: Next search result",
	["n|N"] = k.map_cmd("Nzzzv"):with_noremap():with_desc "editn: Prev search result",
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

	-- Start mapping for plugins
	["n|ft"] = k.map_cr("FormatToggle"):with_defaults():with_desc "lsp: toggle format",
	-- jupyter_ascending
	["n|<LocalLeader><LocalLeader>x"] = k.map_cr(":call jupyter_ascending#execute()<CR>")
		:with_desc "jupyter_ascending: Execute notebook shell",
	["n|<LocalLeader><LocalLeader>X"] = k.map_cr(":call jupyter_ascending#execute_all()<CR>")
		:with_desc "jupyter_ascending: Exceute all notebook shells",
	-- ojroques/nvim-bufdel
	["n|<C-x>"] = k.map_cr("BufDel"):with_defaults():with_desc "bufdel: Delete current buffer",
	-- Bufferline
	["n|<Space>bp"] = k.map_cr("BufferLinePick"):with_defaults():with_desc "buffer: Pick",
	["n|<Space>bc"] = k.map_cr("BufferLinePickClose"):with_defaults():with_desc "buffer: Close",
	["n|<Space>be"] = k.map_cr("BufferLineSortByExtension"):with_noremap():with_desc "buffer: Sort by extension",
	["n|<Space>bd"] = k.map_cr("BufferLineSortByDirectory"):with_noremap():with_desc "buffer: Sort by direrctory",
	["n|<Space>."] = k.map_cr("BufferLineCycleNext"):with_defaults():with_desc "buffer: Cycle to next buffer",
	["n|<Space>n"] = k.map_cr("BufferLineCyclePrev"):with_defaults():with_desc "buffer: Cycle to previous buffer",
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
	-- Copilot
	["n|<LocalLeader>cp"] = k.map_cr("Copilot panel"):with_defaults():with_nowait():with_desc "copilot: Open panel",
	-- Lsp mapping (lspsaga, nvim-lspconfig, nvim-lsp, mason-lspconfig)
	["n|<LocalLeader>li"] = k.map_cr("LspInfo"):with_defaults():with_nowait():with_desc "lsp: Info",
	["n|<LocalLeader>lr"] = k.map_cr("LspRestart"):with_defaults():with_nowait():with_desc "lsp: Restart",
	["n|go"] = k.map_cr("Lspsaga outline"):with_defaults():with_desc "lsp: Toggle outline",
	["n|g["] = k.map_cr("Lspsaga diagnostic_jump_prev"):with_defaults():with_desc "lsp: Prev diagnostic",
	["n|g]"] = k.map_cr("Lspsaga diagnostic_jump_next"):with_defaults():with_desc "lsp: Next diagnostic",
	["n|<LocalLeader>sl"] = k.map_cr("Lspsaga show_line_diagnostics"):with_defaults():with_desc "lsp: Line diagnostic",
	["n|<LocalLeader>sc"] = k.map_cr("Lspsaga show_cursor_diagnostics")
		:with_defaults()
		:with_desc "lsp: Cursor diagnostic",
	["n|gs"] = k.map_callback(function() vim.lsp.buf.signature_help() end)
		:with_defaults()
		:with_desc "lsp: Signature help",
	["n|gr"] = k.map_cr("Lspsaga rename"):with_defaults():with_desc "lsp: Rename in file range",
	["n|gR"] = k.map_cr("Lspsaga rename ++project"):with_defaults():with_desc "lsp: Rename in project range",
	["n|K"] = k.map_cr("Lspsaga hover_doc"):with_defaults():with_desc "lsp: Show doc",
	["n|ga"] = k.map_cr("Lspsaga code_action"):with_defaults():with_desc "lsp: Code action for cursor",
	["v|ga"] = k.map_cu("Lspsaga code_action"):with_defaults():with_desc "lsp: Code action for range",
	["n|gd"] = k.map_cr("Lspsaga peek_definition"):with_defaults():with_desc "lsp: Preview definition",
	["n|gD"] = k.map_cr("Lspsaga goto_definition"):with_defaults():with_desc "lsp: Goto definition",
	["n|gh"] = k.map_cr("Lspsaga lsp_finder"):with_defaults():with_desc "lsp: Show reference",
	["n|<LocalLeader>ci"] = k.map_cr("Lspsaga incoming_calls"):with_defaults():with_desc "lsp: Show incoming calls",
	["n|<LocalLeader>co"] = k.map_cr("Lspsaga outgoing_calls"):with_defaults():with_desc "lsp: Show outgoing calls",
	-- toggleterm
	["n|<C-\\>"] = k.map_cr([[execute v:count . "ToggleTerm direction=horizontal"]])
		:with_defaults()
		:with_desc "terminal: Toggle horizontal",
	["i|<C-\\>"] = k.map_cmd("<Esc><Cmd>ToggleTerm direction=horizontal<CR>")
		:with_defaults()
		:with_desc "terminal: Toggle horizontal",
	["t|<C-\\>"] = k.map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_defaults():with_desc "terminal: Toggle horizontal",
	["n|<C-w>t"] = k.map_cr([[execute v:count . "ToggleTerm direction=vertical"]])
		:with_defaults()
		:with_desc "terminal: Toggle vertical",
	["i|<C-w>t"] = k.map_cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>")
		:with_defaults()
		:with_desc "terminal: Toggle vertical",
	["t|<C-w>t"] = k.map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_defaults():with_desc "terminal: Toggle vertical",
	["n|slg"] = k.map_callback(function()
		if not _lazygit then
			local config = {
				cmd = require("utils").get_binary_path "lazygit",
				hidden = true,
				direction = "float",
				float_opts = {
					border = "double",
				},
				on_open = function(term)
					vim.api.nvim_command [[startinsert!]]
					vim.api.nvim_buf_set_keymap(
						term.bufnr,
						"n",
						"q",
						"<cmd>close<CR>",
						{ noremap = true, silent = true }
					)
				end,
			}
			_lazygit = require("toggleterm.terminal").Terminal:new(config)
		end
		_lazygit:toggle()
	end)
		:with_defaults()
		:with_desc "git: Toggle lazygit",
	-- tpope/vim-fugitive
	["n|<LocalLeader>G"] = k.map_cr("G"):with_defaults():with_desc "git: Open git-fugitive",
	["n|<LocalLeader>gaa"] = k.map_cr("G add ."):with_defaults():with_desc "git: Add all files",
	["n|<LocalLeader>gcm"] = k.map_cr("G commit"):with_defaults():with_desc "git: Commit",
	["n|<LocalLeader>gps"] = k.map_cr("G push"):with_defaults():with_desc "git: push",
	["n|<LocalLeader>gpl"] = k.map_cr("G pull"):with_defaults():with_desc "git: pull",
	-- nvim-tree
	["n|<C-n>"] = k.map_cr("NvimTreeToggle"):with_defaults():with_desc "file-explorer: Toggle",
	["n|<Leader>nf"] = k.map_cr("NvimTreeFindFile"):with_defaults():with_desc "file-explorer: Find file",
	["n|<Leader>nr"] = k.map_cr("NvimTreeRefresh"):with_defaults():with_desc "file-explorer: Refresh",
	-- octo
	["n|<LocalLeader>ocpr"] = k.map_cr("Octo pr list"):with_noremap():with_desc "octo: List pull request",
	-- trouble
	["n|gt"] = k.map_cr("TroubleToggle"):with_defaults():with_desc "lsp: Toggle trouble list",
	["n|<LocalLeader>tr"] = k.map_cr("TroubleToggle lsp_references")
		:with_defaults()
		:with_desc "lsp: Show lsp references",
	["n|<LocalLeader>td"] = k.map_cr("TroubleToggle document_diagnostics")
		:with_defaults()
		:with_desc "lsp: Show document diagnostics",
	["n|<LocalLeader>tw"] = k.map_cr("TroubleToggle workspace_diagnostics")
		:with_defaults()
		:with_desc "lsp: Show workspace diagnostics",
	["n|<LocalLeader>tq"] = k.map_cr("TroubleToggle quickfix"):with_defaults():with_desc "lsp: Show quickfix list",
	["n|<LocalLeader>tl"] = k.map_cr("TroubleToggle loclist"):with_defaults():with_desc "lsp: Show loclist",
	-- Telescope
	["n|fo"] = k.map_cu("Telescope oldfiles"):with_defaults():with_desc "find: File by history",
	["n|fr"] = k.map_callback(function() require("telescope").extensions.frecency.frecency() end)
		:with_defaults()
		:with_desc "find: File by frecency",
	["n|fw"] = k.map_callback(function() require("telescope").extensions.live_grep_args.live_grep_args {} end)
		:with_defaults()
		:with_desc "find: Word in project",
	["n|fb"] = k.map_cu("Telescope buffers"):with_defaults():with_desc "find: Buffer opened",
	["n|ff"] = k.map_cu("Telescope find_files"):with_defaults():with_desc "find: File in project",
	["n|fz"] = k.map_cu("Telescope zoxide list"):with_defaults():with_desc "editn: Change current direrctory by zoxide",
	["n|<LocalLeader>ff"] = k.map_cu("Telescope git_files"):with_defaults():with_desc "find: file in git project",
	["n|<LocalLeader>fw"] = k.map_cu("Telescope live_grep"):with_defaults():with_desc "find: Word in current directory",
	["n|fp"] = k.map_callback(function() require("telescope").extensions.projects.projects {} end)
		:with_defaults()
		:with_desc "find: Project",
	["n|<LocalLeader>fu"] = k.map_callback(function() require("telescope").extensions.undo.undo() end)
		:with_defaults()
		:with_desc "editn: Show undo history",
	["n|<LocalLeader>fc"] = k.map_cu("Telescope colorscheme")
		:with_defaults()
		:with_desc "ui: Change colorscheme for current session",
	["n|<LocalLeader>fn"] = k.map_cu("enew"):with_defaults():with_desc "buffer: New",
	["n|<C-p>"] = k.map_cr("Telescope keymaps"):with_defaults():with_desc "tools: Show keymap legends",
	-- cheatsheet
	["n|<LocalLeader>km"] = k.map_cr("Cheatsheet"):with_defaults():with_desc "cheatsheet: open",
	-- SnipRun
	["v|<Leader>r"] = k.map_cr("SnipRun"):with_defaults():with_desc "tool: Run code by range",
	["n|<Leader>r"] = k.map_cu([[%SnipRun]]):with_defaults():with_desc "tool: Run code by file",
	-- spectre
	["n|<Leader>s"] = k.map_callback(function() require("spectre").open_visual() end)
		:with_defaults()
		:with_desc "replace: Open visual replace",
	["n|<Leader>so"] = k.map_callback(function() require("spectre").open() end)
		:with_defaults()
		:with_desc "replace: Open panel",
	["n|<Leader>sw"] = k.map_callback(function() require("spectre").open_visual { select_word = true } end)
		:with_defaults()
		:with_desc "replace: Replace word under cursor",
	["n|<Leader>sp"] = k.map_callback(function() require("spectre").open_file_search { select_word = true } end)
		:with_defaults()
		:with_desc "replace: Replace word under file search",
	-- Hop
	["n|<LocalLeader>w"] = k.map_cu("HopWord"):with_noremap():with_desc "jump: Goto word",
	["n|<LocalLeader>j"] = k.map_cu("HopLine"):with_noremap():with_desc "jump: Goto line",
	["n|<LocalLeader>k"] = k.map_cu("HopLine"):with_noremap():with_desc "jump: Goto line",
	["n|<LocalLeader>c"] = k.map_cu("HopChar1"):with_noremap():with_desc "jump: Goto one char",
	["n|<LocalLeader>cc"] = k.map_cu("HopChar2"):with_noremap():with_desc "jump: Goto two chars",
	-- EasyAlign
	["n|gea"] = k.map_callback(
		function() return vim.api.nvim_replace_termcodes("<Plug>(EasyAlign)", true, true, true) end
	)
		:with_expr()
		:with_desc "editn: Align by char",
	["x|gea"] = k.map_callback(
		function() return vim.api.nvim_replace_termcodes("<Plug>(EasyAlign)", true, true, true) end
	)
		:with_expr()
		:with_desc "editn: Align by char",
	-- MarkdownPreview
	["n|mpt"] = k.map_cr("MarkdownPreviewToggle"):with_defaults():with_desc "markdown: preview",
	-- zen-mode
	["n|zm"] = k.map_callback(function() require("zen-mode").toggle { window = { width = 0.75 } } end)
		:with_defaults()
		:with_desc "zenmode: Toggle",
	-- refactoring
	["v|<LocalLeader>re"] = k.map_callback(function() require("refactoring").refactor "Extract Function" end)
		:with_defaults()
		:with_desc "refactor: Extract Function",
	["v|<LocalLeader>rf"] = k.map_callback(function() require("refactoring").refactor "Extract Function To File" end)
		:with_defaults()
		:with_desc "refactor: Extract Function To File",
	["v|<LocalLeader>rv"] = k.map_callback(function() require("refactoring").refactor "Extract Variable" end)
		:with_defaults()
		:with_desc "refactor: Extract Variable",
	["v|<LocalLeader>ri"] = k.map_callback(function() require("refactoring").refactor "Inline Variable" end)
		:with_defaults()
		:with_desc "refactor: Inline Variable",
	["n|<LocalLeader>rb"] = k.map_callback(function() require("refactoring").refactor "Extract Block" end)
		:with_defaults()
		:with_desc "refactor: Extract Block",
	["n|<LocalLeader>rbf"] = k.map_callback(function() require("refactoring").refactor "Extract Block To File" end)
		:with_defaults()
		:with_desc "refactor: Extract Block to File",
	-- dap
	["n|<F6>"] = k.map_callback(function() require("dap").continue() end)
		:with_defaults()
		:with_desc "debug: Run/Continue",
	["n|<F7>"] = k.map_callback(function()
		require("dap").terminate()
		require("dapui").close()
	end)
		:with_defaults()
		:with_desc "debug: Stop",
	["n|<F8>"] = k.map_callback(function() require("dap").toggle_breakpoint() end)
		:with_defaults()
		:with_desc "debug: Toggle breakpoint",
	["n|<F9>"] = k.map_callback(function() require("dap").step_into() end):with_defaults():with_desc "debug: Step into",
	["n|<F10>"] = k.map_callback(function() require("dap").step_out() end):with_defaults():with_desc "debug: Step out",
	["n|<F11>"] = k.map_callback(function() require("dap").step_over() end)
		:with_defaults()
		:with_desc "debug: Step over",
	["n|<leader>db"] = k.map_callback(
		function() require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ") end
	)
		:with_defaults()
		:with_desc "debug: Set breakpoint with condition",
	["n|<leader>dc"] = k.map_callback(function() require("dap").run_to_cursor() end)
		:with_defaults()
		:with_desc "debug: Run to cursor",
	["n|<leader>dl"] = k.map_callback(function() require("dap").run_last() end)
		:with_defaults()
		:with_desc "debug: Run last",
	["n|<leader>do"] = k.map_callback(function() require("dap").repl.open() end)
		:with_defaults()
		:with_desc "debug: Open REPL",
	-- Diffview
	["n|<LocalLeader>D"] = k.map_cr("DiffviewOpen"):with_defaults():with_desc "git: Show diff view",
	["n|<LocalLeader><LocalLeader>D"] = k.map_cr("DiffviewClose"):with_defaults():with_desc "git: Close diff view",
}

k.nvim_load_mapping(mapping)
