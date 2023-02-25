local api = vim.api

-- disable laststatus on non-file buffers
api.nvim_create_autocmd({ "VimEnter" }, {
	callback = function(event)
		local real_file = vim.fn.filereadable(event.file) == 1
		local no_name = event.file == "" and vim.bo[event.buf].buftype == ""
		if not real_file and not no_name then return end
		vim.opt.laststatus = 0
	end,
})
api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function() vim.opt.laststatus = 3 end,
})

vim.api.nvim_create_autocmd("WinClosed", {
	callback = function()
		local winnr = tonumber(vim.fn.expand "<amatch>")
		local tab_win_closed = function(winnr)
			local api = require "nvim-tree.api"
			local tabnr = vim.api.nvim_win_get_tabpage(winnr)
			local bufnr = vim.api.nvim_win_get_buf(winnr)
			local buf_info = vim.fn.getbufinfo(bufnr)[1]
			local tab_wins = vim.tbl_filter(
				function(w) return w ~= winnr end,
				vim.api.nvim_tabpage_list_wins(tabnr)
			)
			local tab_bufs = vim.tbl_map(vim.api.nvim_win_get_buf, tab_wins)
			if buf_info.name:match ".*NvimTree_%d*$" then -- close buffer was nvim tree
				-- Close all nvim tree on :q
				if not vim.tbl_isempty(tab_bufs) then -- and was not the last window (not closed automatically by code below)
					api.tree.close()
				end
			else -- else closed buffer was normal buffer
				if #tab_bufs == 1 then -- if there is only 1 buffer left in the tab
					local last_buf_info = vim.fn.getbufinfo(tab_bufs[1])[1]
					if last_buf_info.name:match ".*NvimTree_%d*$" then -- and that buffer is nvim tree
						vim.schedule(function()
							if #vim.api.nvim_list_wins() == 1 then -- if its the last buffer in vim
								vim.cmd "quit" -- then close all of vim
							else -- else there are more tabs open
								vim.api.nvim_win_close(tab_wins[1], true) -- then close only the tab
							end
						end)
					end
				end
			end
		end

		vim.schedule_wrap(tab_win_closed(winnr))
	end,
	nested = true,
})

-- close some filetypes with <q>
api.nvim_create_autocmd("FileType", {
	pattern = {
		"qf",
		"help",
		"man",
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
		"",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<CMD>close<CR>", { silent = true })
	end,
})

-- Makes switching between buffer and termmode feels like normal mode
api.nvim_create_autocmd("TermOpen", {
	pattern = "term://*",
	callback = function()
		local opts = { noremap = true, silent = true }
		api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
		api.nvim_buf_set_keymap(0, "t", "kk", [[<C-\><C-n>]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
	end,
})

-- Fix fold issue of files opened by telescope
vim.api.nvim_create_autocmd("BufRead", {
	callback = function()
		vim.api.nvim_create_autocmd("BufWinEnter", {
			once = true,
			command = "normal! zx",
		})
	end,
})

-- no comments on new line
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufRead", "BufNewFile" }, {
	command = "setlocal formatoptions-=c",
})

-- Check if we need to reload the file when it changed
api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	pattern = "*",
	command = "checktime",
})
vim.api.nvim_create_autocmd("VimResized", { command = "tabdo wincmd =" })

local bufs_id = api.nvim_create_augroup("EditorBufs", { clear = true })
-- source vimrc on save
api.nvim_create_autocmd("BufWritePost", {
	group = bufs_id,
	pattern = "$VIM_PATH/{*.vim,*.yaml,vimrc}",
	command = "source $MYVIMRC | redraw",
	nested = true,
})
-- Reload Vim script automatically if setlocal autoread
api.nvim_create_autocmd({ "BufWritePost", "FileWritePost" }, {
	group = bufs_id,
	pattern = "*.vim",
	command = "if &l:autoread > 0 | source <afile> | echo 'source ' . bufname('%') | endif",
	nested = true,
})
-- Set noundofile for temporary files
api.nvim_create_autocmd("BufWritePre", {
	group = bufs_id,
	pattern = { "/tmp/*", "*.tmp", "*.bak" },
	command = "setlocal noundofile",
})
-- set filetype for header files
api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	group = bufs_id,
	pattern = { "*.h", "*.hpp", "*.hxx", "*.hh" },
	command = "setlocal filetype=c",
})

local ft_id = api.nvim_create_augroup("EditorFt", { clear = true })
-- Set mapping for switching header and source file
api.nvim_create_autocmd("FileType", {
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
-- set filetype for docker files
api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	group = ft_id,
	pattern = { "Dockerfile-*", "Dockerfile.{tpl,template,tmpl}", "*.{Dockerfile,dockerfile}" },
	command = "setf dockerfile",
})
api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	group = ft_id,
	pattern = { "*.{tpl,template,tmpl,j2,jinja}" },
	command = "setf html",
})

local yank_id = api.nvim_create_augroup("yank", { clear = true })
-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
	group = yank_id,
	pattern = "*",
	callback = function(_) vim.highlight.on_yank { higroup = "IncSearch", timeout = 300 } end,
})
