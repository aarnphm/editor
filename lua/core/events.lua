local api = vim.api

-- set better diagnostics icons
local diagnostics = require("icons").get("diagnostics", true)
local diagnostic_icons = {
	Error = diagnostics.ErrorHolo,
	Warn = diagnostics.WarningHolo,
	Info = diagnostics.InformationHolo,
	Hint = diagnostics.HintHolo,
}
for type, icon in pairs(diagnostic_icons) do
	local hl = string.format("DiagnosticSign%s", type)
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local misc_id = api.nvim_create_augroup("MiscBufs", { clear = true })
-- Fix fold issue of files opened by telescope
api.nvim_create_autocmd("BufRead", {
	group = misc_id,
	callback = function()
		api.nvim_create_autocmd("BufWinEnter", {
			once = true,
			command = "normal! zx",
		})
	end,
})

-- close some filetypes with <q>
api.nvim_create_autocmd("FileType", {
	group = misc_id,
	pattern = {
		"qf",
		"help",
		"man",
		"notify",
		"lspinfo",
		"terminal",
		"prompt",
		"toggleterm",
		"copilot",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"PlenaryTestPopup",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<CMD>close<CR>", { silent = true })
	end,
})

-- Makes switching between buffer and termmode feels like normal mode
api.nvim_create_autocmd("TermOpen", {
	group = misc_id,
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

-- auto close NvimTree
api.nvim_create_autocmd("BufEnter", {
	group = api.nvim_create_augroup("NvimTreeClose", { clear = true }),
	pattern = "NvimTree_*",
	callback = function()
		local layout = api.nvim_call_function("winlayout", {})
		if
			layout[1] == "leaf"
			and api.nvim_buf_get_option(api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree"
			and layout[3] == nil
		then
			vim.cmd "confirm quit"
		end
	end,
})

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
-- auto change directory
api.nvim_create_autocmd("BufEnter", {
	group = bufs_id,
	pattern = "*",
	command = "silent! lcd %:p:h",
})
-- auto place to last edit
api.nvim_create_autocmd("BufReadPost", {
	group = bufs_id,
	pattern = "*",
	command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif]],
})

local wins_id = api.nvim_create_augroup("EditorWins", { clear = true })
-- Highlight current line only on focused window
api.nvim_create_autocmd({ "WinEnter", "BufEnter", "InsertLeave" }, {
	group = wins_id,
	pattern = "*",
	callback = function(_)
		if not vim.o.cursorline and not vim.bo.filetype ~= "^(dashboard|alpha)" and not vim.o.pvw then
			vim.o.cursorline = true
		end
	end,
})
-- Disable cursorline on unfocused windows
api.nvim_create_autocmd({ "WinLeave", "BufLeave", "InsertEnter" }, {
	group = wins_id,
	pattern = "*",
	callback = function(_)
		if not vim.o.cursorline and not vim.bo.filetype ~= "^(dashboard|alpha)" and not vim.o.pvw then
			vim.o.cursorline = false
		end
	end,
})
-- Force write shada on leaving nvim
api.nvim_create_autocmd("VimLeave", {
	group = wins_id,
	pattern = "*",
	callback = function(_)
		if vim.fn.has "nvim" == 1 then
			api.nvim_command [[wshada!]]
		else
			api.nvim_command [[wviminfo!]]
		end
	end,
})
-- Check if we need to reload the file when it changed
api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = wins_id,
	pattern = "*",
	command = "checktime",
})
-- Equalize window dimensions when resizing vim window
api.nvim_create_autocmd("VimResized", {
	group = wins_id,
	pattern = "*",
	command = "tabdo wincmd =",
})

local ft_id = api.nvim_create_augroup("EditorFt", { clear = true })
-- set local to all filetypes to have formatoptions-=cro
api.nvim_create_autocmd("FileType", {
	group = ft_id,
	pattern = "*",
	command = "setlocal formatoptions-=cro",
})
-- attach repl to send command to terminal
-- Disable statusline in dashboard
api.nvim_create_autocmd("FileType", {
	group = ft_id,
	pattern = "alpha",
	callback = function(_)
		vim.opt.laststatus = 0
		vim.opt.showtabline = 0
	end,
})
api.nvim_create_autocmd("FileType", {
	group = ft_id,
	pattern = "markdown",
	command = "set wrap",
})
api.nvim_create_autocmd("FileType", {
	group = ft_id,
	pattern = "dap-repl",
	callback = function(_) require("dap.ext.autocompl").attach() end,
})
-- Google tab style for C/C++
api.nvim_create_autocmd("FileType", {
	group = ft_id,
	pattern = "c,cpp",
	callback = function(_)
		api.nvim_buf_set_keymap(0, "n", "<Leader><Leader>h", ":ClangdSwitchSourceHeaderVSplit<CR>", { noremap = true })
	end,
})
-- set filetype for bazel files
api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	group = ft_id,
	pattern = { "*.bazel", "WORKSPACE" },
	command = "setf bzl",
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
-- set shiftwidth and tabstop for lua and nix files
api.nvim_create_autocmd("FileType", {
	group = ft_id,
	pattern = { "lua", "nix" },
	command = "set noexpandtab shiftwidth=2 tabstop=2",
})
vim.api.nvim_create_autocmd("FileType", {
	group = ft_id,
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

local yank_id = api.nvim_create_augroup("yank", { clear = true })
-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
	group = yank_id,
	pattern = "*",
	callback = function(_) vim.highlight.on_yank { higroup = "IncSearch", timeout = 300 } end,
})
