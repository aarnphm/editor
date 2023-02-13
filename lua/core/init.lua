--- requires some globals
require "core.globals"
--- Light REPL for convenience
require "core.repl"

--- Add custom filet+pe extension
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
vim.g.sqlite_clib_path = vim.NIL ~= vim.fn.getenv "SQLITE_PATH" and vim.env["SQLITE_PATH"]
	or print "SQLITE_PATH is not set. Telescope will not work"

-- neovide config
if vim.g.neovide then
	vim.api.nvim_set_option_value("guifont", "JetBrainsMono Nerd Font:h15", {})
	vim.g.neovide_refresh_rate = 120
	vim.g.neovide_cursor_vfx_mode = "railgun"
	vim.g.neovide_no_idle = true
	vim.g.neovide_cursor_animation_length = 0.03
	vim.g.neovide_cursor_trail_length = 0.05
	vim.g.neovide_cursor_antialiasing = true
	vim.g.neovide_cursor_vfx_opacity = 200.0
	vim.g.neovide_cursor_vfx_particle_lifetime = 1.2
	vim.g.neovide_cursor_vfx_particle_speed = 20.0
	vim.g.neovide_cursor_vfx_particle_density = 5.0
end

-- map leader to <Space> and localeader to +
vim.g.mapleader = " "
vim.g.maplocalleader = "+"
vim.api.nvim_set_keymap("n", " ", "", { noremap = true })
vim.api.nvim_set_keymap("x", " ", "", { noremap = true })

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
		vim.log.levels.WARN,
		{ title = "editor: configuration" }
	)
	vim.cmd.colorscheme "un"
else
	vim.cmd.colorscheme(require("editor").config.colorscheme)
end
