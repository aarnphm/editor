local ok, plenary_reload = pcall(require, "plenary.reload")
local reloader = require
if ok then reloader = plenary_reload.reload_module end

P = function(v)
	print(vim.inspect(v))
	return v
end

RELOAD = function(...) return reloader(...) end

R = function(name)
	RELOAD(name)
	return require(name)
end

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

icons = {
	Kind = data.kind,
	KindSpace = setmetatable({}, { __index = function(_, key) return data.kind[key] .. " " end }),
	Type = data.type,
	TypeSpace = setmetatable({}, { __index = function(_, key) return data.type[key] .. " " end }),
	Documents = data.documents,
	DocumentsSpace = setmetatable({}, { __index = function(_, key) return data.documents[key] .. " " end }),
	Git = data.git,
	GitSpace = setmetatable({}, { __index = function(_, key) return data.git[key] .. " " end }),
	Ui = data.ui,
	UiSpace = setmetatable({}, { __index = function(_, key) return data.ui[key] .. " " end }),
	Diagnostics = data.diagnostics,
	DiagnosticsSpace = setmetatable({}, { __index = function(_, key) return data.diagnostics[key] .. " " end }),
	Misc = data.misc,
	MiscSpace = setmetatable({}, { __index = function(_, key) return data.misc[key] .. " " end }),
	Cmp = data.cmp,
	CmpSpace = setmetatable({}, { __index = function(_, key) return data.cmp[key] .. " " end }),
	Dap = data.dap,
	DapSpace = setmetatable({}, { __index = function(_, key) return data.dap[key] .. " " end }),
}
