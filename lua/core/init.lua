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

-- plugins
require "editor"

local api = vim.api

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
		if vim.fn.isdirectory(v) == 0 then
			os.execute("mkdir -p " .. v)
		end
	end
end

-- quick hack for install sqlite with nix
vim.g.sqlite_clib_path = vim.env["SQLITE_PATH"]

-- map leader to , and localeader to +
vim.g.mapleader = ","
vim.g.maplocalleader = "+"
api.nvim_set_keymap("n", ",", "", { noremap = true })
api.nvim_set_keymap("x", ",", "", { noremap = true })

require "core.options"
require "core.mappings"
require "core.events"
require "core.lazy"

api.nvim_command("set background=" .. require("editor").config.background)
api.nvim_command("silent! colorscheme " .. require("editor").config.colorscheme)
