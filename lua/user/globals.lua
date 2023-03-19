---@diagnostic disable: duplicate-set-field
--# selene: allow(global_usage,incorrect_standard_library_use)
local api = vim.api
local autocmd = vim.api.nvim_create_autocmd

local ok, plenary_reload = pcall(require, "plenary.reload")
local reloader = require
if ok then reloader = plenary_reload.reload_module end

_G.P = function(v)
	print(vim.inspect(v))
	return v
end

_G.RELOAD = function(...) return reloader(...) end

_G.R = function(name)
	_G.RELOAD(name)
	return require(name)
end

local getlocals = function(l)
	local i = 0
	local direction = 1
	return function()
		i = i + direction
		local k, v = debug.getlocal(l, i)
		if direction == 1 and (k == nil or k.sub(k, 1, 1) == "(") then
			i = -1
			direction = -1
			k, v = debug.getlocal(l, i)
		end
		return k, v
	end
end

_G.GS = function(f)
	assert(type(f) == "function", "bad argument #1 to 'dumpsig' (function expected)")
	local p = {}
	pcall(function()
		local oldhook
		local hook = function(_, _)
			for k, _ in getlocals(3) do
				if k == "(*vararg)" then
					table.insert(p, "...")
					break
				end
				table.insert(p, k)
			end
			debug.sethook(oldhook)
			error "aborting the call"
		end
		oldhook = debug.sethook(hook, "c")
		-- To test for vararg must pass a least one vararg parameter
		f(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20)
	end)
	return "function(" .. table.concat(p, ",") .. ")"
end

-- default augroup
local augroup = function(name) return api.nvim_create_augroup("simple_" .. name, { clear = true }) end

_G.simple_augroup = augroup

-- diagnostic on hover
autocmd({ "CursorHold", "CursorHoldI" }, {
	group = augroup "diagnostic_show_float",
	pattern = "*",
	callback = function() vim.diagnostic.open_float(nil, { focus = false }) end,
})

-- auto place to last edit
autocmd("BufReadPost", {
	group = augroup "last_edit",
	pattern = "*",
	command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif]],
})

-- close some filetypes with <q>
autocmd("FileType", {
	group = augroup "filetype",
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
		"scratch",
		"",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<cmd>close<cr>", { silent = true })
	end,
})

-- Makes switching between buffer and termmode feels like normal mode
autocmd("TermOpen", {
	group = augroup "term",
	pattern = "term://*",
	callback = function()
		local opts = { noremap = true, silent = true }
		api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
	end,
})

-- Force write shada on leaving nvim
autocmd("VimLeave", {
	group = augroup "write_shada",
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
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup "checktime",
	pattern = "*",
	command = "checktime",
})
autocmd("VimResized", { group = augroup "resized", command = "tabdo wincmd =" })

-- Set noundofile for temporary files
autocmd("BufWritePre", {
	group = augroup "tempfile",
	pattern = { "/tmp/*", "*.tmp", "*.bak" },
	command = "setlocal noundofile",
})
-- set filetype for header files
autocmd({ "BufNewFile", "BufRead" }, {
	group = augroup "cpp_headers",
	pattern = { "*.h", "*.hpp", "*.hxx", "*.hh" },
	command = "setlocal filetype=c",
})

-- Set mapping for switching header and source file
autocmd("FileType", {
	group = augroup "cpp",
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

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup "highlight_yank",
	pattern = "*",
	callback = function(_) vim.highlight.on_yank { higroup = "IncSearch", timeout = 100 } end,
})
