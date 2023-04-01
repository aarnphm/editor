---@diagnostic disable: duplicate-set-field
--# selene: allow(global_usage,incorrect_standard_library_use)

-- NOTE: globals: START
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
-- NOTE: globals: END

-- NOTE: events: START
local api = vim.api
local autocmd = vim.api.nvim_create_autocmd
local augroup_name = function(name) return "simple_" .. name end
local augroup = function(name) return api.nvim_create_augroup(augroup_name(name), { clear = true }) end

_G.simple_augroup = augroup
_G.simple_augroup_name = augroup_name

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
	callback = function(_)
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

-- disable statusline for some filetypes
local disable_filetype = {
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
	"neo-tree",
	"nofile",
	"scratch",
	"",
}
autocmd({ "WinEnter, BufEnter" }, {
	group = augroup "disable_statusline_enter",
	pattern = disable_filetype,
	callback = function()
		vim.opt.laststatus = 0
		vim.opt.statusline = ""
	end,
})
autocmd({ "WinLeave, BufLeave" }, {
	group = augroup "disable_statusline_leave",
	pattern = disable_filetype,
	callback = function()
		vim.opt.laststatus = 2
		vim.opt.statusline = require("user.utils").statusline.build()
	end,
})

-- NOTE: events: END

-- NOTE: icons: START
local data = {
	kind = {
		Class = "ﴯ",
		Color = "",
		Constant = "",
		Constructor = "",
		Enum = "",
		EnumMember = "",
		Event = "",
		Field = "",
		File = "",
		Folder = "",
		Function = "",
		Interface = "",
		Keyword = "",
		Method = "",
		Module = "",
		Namespace = "",
		Number = "",
		Operator = "",
		Package = "",
		Property = "ﰠ",
		Reference = "",
		Snippet = "",
		Struct = "",
		Text = "",
		TypeParameter = "",
		Unit = "",
		Value = "",
		Variable = "",
		-- ccls-specific icons.
		TypeAlias = "",
		Parameter = "",
		StaticMethod = "",
		Macro = "",
	},
	type = {
		Array = "",
		Boolean = "",
		Null = "ﳠ",
		Number = "",
		Object = "",
		String = "",
	},
	documents = {
		Default = "",
		File = "",
		Files = "",
		FileTree = "פּ",
		Import = "",
		Symlink = "",
	},
	git = {
		Add = "",
		Branch = "",
		Diff = "",
		Git = "",
		Ignore = "",
		Mod = "M",
		ModHolo = "",
		Remove = "",
		Rename = "",
		Repo = "",
		Unmerged = "שׂ",
		Untracked = "ﲉ",
		Unstaged = "",
		Staged = "",
		Conflict = "",
	},
	ui = {
		ArrowClosed = "",
		ArrowOpen = "",
		BigCircle = "",
		BigUnfilledCircle = "",
		BookMark = "",
		Bug = "",
		Calendar = "",
		Check = "",
		ChevronRight = "",
		Circle = "",
		Close = "",
		CloseHolo = "",
		CloudDownload = "",
		Comment = "",
		CodeAction = "",
		Dashboard = "",
		Emoji = "",
		EmptyFolder = "",
		EmptyFolderOpen = "",
		File = "",
		Fire = "",
		Folder = "",
		FolderOpen = "",
		Gear = "",
		History = "",
		Incoming = "",
		Indicator = "",
		Keyboard = "",
		Left = "",
		List = "",
		Square = "",
		SymlinkFolder = "",
		Lock = "",
		Modified = "✥",
		ModifiedHolo = "",
		NewFile = "",
		Newspaper = "",
		Note = "",
		Outgoing = "",
		Package = "",
		Pencil = "",
		Perf = "",
		Play = "",
		Project = "",
		Right = "",
		RootFolderOpened = "",
		Search = "",
		Separator = "",
		DoubleSeparator = "",
		SignIn = "",
		SignOut = "",
		Sort = "",
		Spell = "暈",
		Symlink = "",
		Table = "",
		Telescope = "",
	},
	diagnostics = {
		Error = "",
		Warning = "",
		Information = "",
		Question = "",
		Hint = "",
		-- Holo version
		ErrorHolo = "",
		WarningHolo = "",
		InformationHolo = "",
		QuestionHolo = "",
		HintHolo = "",
	},
	misc = {
		Campass = "",
		Code = "",
		EscapeST = "✺",
		Gavel = "",
		Glass = "",
		PyEnv = "",
		Squirrel = "",
		Tag = "",
		Tree = "",
		Watch = "",
		Lego = "",
		Vbar = "│",
		Add = "+",
		Added = "",
		Ghost = "",
		ManUp = "",
		Vim = "",
		SimpleVim = "",
		SingleWheel = "",
		MultipleWheels = "",
		FindFile = "",
		WordFind = "",
		Rocket = "",
		BentoBox = "🍱",
		Love = "♥",
	},
	cmp = {
		Copilot = "",
		CopilotHolo = "",
		nvim_lsp = "",
		nvim_lua = "",
		path = "",
		buffer = "",
		spell = "暈",
		luasnip = "",
		treesitter = "",
	},
	dap = {
		Breakpoint = "",
		BreakpointCondition = "ﳁ",
		BreakpointRejected = "",
		LogPoint = "",
		Pause = "",
		Play = "",
		RunLast = "↻",
		StepBack = "",
		StepInto = "",
		StepOut = "",
		StepOver = "",
		Stopped = "",
		Terminate = "ﱢ",
	},
}

local icons = {
	kind = {},
	kind_space = {},
	type = {},
	type_space = {},
	documents = {},
	documents_space = {},
	git = {},
	git_space = {},
	ui = {},
	ui_space = {},
	diagnostics = {},
	diagnostics_space = {},
	misc = {},
	misc_space = {},
	cmp = {},
	cmp_space = {},
	dap = {},
	dap_space = {},
}

for key, table in pairs(data) do
	icons[key] = setmetatable({}, {
		__index = function(_, k) return table[k] end,
	})
	icons[key .. "_space"] = setmetatable({}, {
		__index = function(_, k) return table[k] .. " " end,
	})
end

_G.icons = icons

-- NOTE: icons: END
