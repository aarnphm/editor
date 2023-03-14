local api = vim.api
local autocmd = vim.api.nvim_create_autocmd

-- close some filetypes with <q>
autocmd("FileType", {
	pattern = {
		"qf",
		"help",
		"man",
		"nowrite", -- fugitive
		"prompt",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neorepl",
		"alpha",
		"toggleterm",
		"health",
		"PlenaryTestPopup",
		"nofile",
		"Scratch",
		"",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<cmd>close<cr>", { silent = true })
	end,
})

-- Makes switching between buffer and termmode feels like normal mode
autocmd("TermOpen", {
	pattern = "term://*",
	callback = function()
		local opts = { noremap = true, silent = true }
		api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
	end,
})

-- no comments on new line
autocmd({ "BufWinEnter", "BufRead", "BufNewFile" }, {
	command = "setlocal formatoptions-=cro",
})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	pattern = "*",
	command = "checktime",
})
autocmd("VimResized", { command = "tabdo wincmd =" })

local bufs_id = api.nvim_create_augroup("EditorBufs", { clear = true })
-- Set noundofile for temporary files
autocmd("BufWritePre", {
	group = bufs_id,
	pattern = { "/tmp/*", "*.tmp", "*.bak" },
	command = "setlocal noundofile",
})
-- set filetype for header files
autocmd({ "BufNewFile", "BufRead" }, {
	group = bufs_id,
	pattern = { "*.h", "*.hpp", "*.hxx", "*.hh" },
	command = "setlocal filetype=c",
})

local ft_id = api.nvim_create_augroup("EditorFt", { clear = true })
-- Set mapping for switching header and source file
autocmd("FileType", {
	group = ft_id,
	pattern = "c,cpp",
	callback = function(event)
		api.nvim_buf_set_keymap(
			event.buf,
			"n",
			"<Leader><Leader>h",
			":ClangdSwitchSourceHeaderVSplit<CR>",
			{ noremap = true }
		)
		api.nvim_buf_set_keymap(
			event.buf,
			"n",
			"<Leader><Leader>v",
			":ClangdSwitchSourceHeaderSplit<CR>",
			{ noremap = true }
		)
		api.nvim_buf_set_keymap(
			event.buf,
			"n",
			"<Leader><Leader>oh",
			":ClangdSwitchSourceHeader<CR>",
			{ noremap = true }
		)
	end,
})

local yank_id = api.nvim_create_augroup("yank", { clear = true })
-- Highlight on yank
autocmd("TextYankPost", {
	group = yank_id,
	pattern = "*",
	callback = function(_) vim.highlight.on_yank { higroup = "IncSearch", timeout = 40 } end,
})
