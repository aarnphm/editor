--- Add custom filetype extension
vim.filetype.add {
	extension = {
		conf = "conf",
		mdx = "markdown",
		mjml = "html",
	},
	pattern = {
		[".*%.env.*"] = "sh",
		["ignore$"] = "conf",
	},
	filename = {
		["yup.lock"] = "yaml",
		["WORKSPACE"] = "bzl",
	},
}

-- Create cache dir and subs dir
local data_dir = {
	require("editor").global.cache_dir .. "backup",
	require("editor").global.cache_dir .. "session",
	require("editor").global.cache_dir .. "swap",
	require("editor").global.cache_dir .. "tags",
	require("editor").global.cache_dir .. "undo",
}
-- There only check once that If cache_dir exists
-- Then I don't want to check subs dir exists
if vim.fn.isdirectory(require("editor").global.cache_dir) == 0 then
	os.execute("mkdir -p " .. require("editor").global.cache_dir)
	for _, v in pairs(data_dir) do
		if vim.fn.isdirectory(v) == 0 then os.execute("mkdir -p " .. v) end
	end
end

-- quick hack for install sqlite with nix
vim.g.sqlite_clib_path = vim.env["SQLITE_PATH"]

-- map leader to , and localeader to +
vim.g.mapleader = ","
vim.g.maplocalleader = "+"
vim.api.nvim_set_keymap("n", ",", "", { noremap = true })
vim.api.nvim_set_keymap("x", ",", "", { noremap = true })

require "core.options"
require "core.mappings"
require "core.events"
require "core.lazy"

-- set background in lua

vim.go.background = require("editor").config.background
local ok, _ = pcall(require, require("editor").config.colorscheme)
if not ok then
	vim.notify(
		"WARNING: colorscheme " .. require("editor").config.colorscheme .. " not found",
		vim.log.levels.ERROR,
		{ title = "editor: configuration" }
	)
	vim.cmd.colorscheme "un"
else
	vim.cmd.colorscheme(require("editor").config.colorscheme)
end
