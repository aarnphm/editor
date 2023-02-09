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
	__editor_global.cache_dir .. "backup",
	__editor_global.cache_dir .. "session",
	__editor_global.cache_dir .. "swap",
	__editor_global.cache_dir .. "tags",
	__editor_global.cache_dir .. "undo",
}
-- There only check once that If cache_dir exists
-- Then I don't want to check subs dir exists
if vim.fn.isdirectory(__editor_global.cache_dir) == 0 then
	os.execute("mkdir -p " .. __editor_global.cache_dir)
	for _, v in pairs(data_dir) do
		if vim.fn.isdirectory(v) == 0 then
			os.execute("mkdir -p " .. v)
		end
	end
end

-- neovide config
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

-- quick hack for install sqlite with nix
vim.g.sqlite_clib_path = vim.env["sqlite_path"]

-- disable menu loading
vim.g.did_install_default_menus = 1
vim.g.did_install_syntax_menu = 1

-- Do not load native syntax completion
vim.g.loaded_syntax_completion = 1

-- Disable sql omni completion.
vim.g.loaded_sql_completion = 1

-- map leader to , and localeader to +
vim.g.mapleader = ","
vim.g.maplocalleader = "+"
api.nvim_set_keymap("n", ",", "", { noremap = true })
api.nvim_set_keymap("x", ",", "", { noremap = true })

require "core.options"
require "core.mappings"
require "core.events"
require "core.lazy"

api.nvim_command("set background=" .. __editor_config.background)
api.nvim_command("silent! colorscheme " .. __editor_config.colorscheme)
