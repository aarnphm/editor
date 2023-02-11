local k = require "keybind"
local icons = {
	kind = require("utils.icons").get "kind",
	documents = require("utils.icons").get "documents",
	ui = require("utils.icons").get "ui",
	ui_sep = require("utils.icons").get("ui", true),
	misc = require("utils.icons").get "misc",
}

local modules = {}
local lazy_path = require("editor").global.data_dir
	.. "lazy"
	.. require("editor").global.path_sep
	.. "lazy.nvim"

if not vim.loop.fs_stat(lazy_path) then
	local lazy_repo = require("editor").config.use_ssh and "git@github.com:folke/lazy.nvim.git "
		or "https://github.com/folke/lazy.nvim.git "
	vim.api.nvim_command("!git clone --filter=blob:none --branch=stable " .. lazy_repo .. lazy_path)
end

---@return table<string, table> list of plugins
local get_plugins_list = function()
	local list = {}
	local plugins_list =
		vim.split(vim.fn.glob(require("editor").global.modules_dir .. "/plugins/*.lua"), "\n")
	if type(plugins_list) == "table" then
		for _, f in ipairs(plugins_list) do
			-- fill list with `plugins/*.lua`'s path used for later `require` like this:
			-- list[#list + 1] = "plugins/completion.lua"
			list[#list + 1] = f:sub(#require("editor").global.modules_dir - 6, -1)
		end
	end
	return list
end

package.path = package.path
	.. string.format(
		";%s;%s",
		require("editor").global.modules_dir .. "/configs/?.lua",
		require("editor").global.modules_dir .. "/configs/?/init.lua"
	)

for _, m in ipairs(get_plugins_list()) do
	-- require modules which returned in previous operation like this:
	-- local modules = require("modules/plugins/completion.lua")
	local config_modules = require(m:sub(0, #m - 4))
	if type(config_modules) == "table" then
		for name, conf in pairs(config_modules) do
			modules[#modules + 1] = vim.tbl_extend("force", { name }, conf)
		end
	end
end

vim.opt.rtp:prepend(lazy_path)

require("lazy").setup(modules, {
	root = require("editor").global.data_dir .. "lazy", -- directory where plugins will be installed
	defaults = { lazy = true },
	concurrency = require("editor").global.is_mac and 30 or nil,
	git = {
		log = { "-10" }, -- show the last 10 commits
		timeout = 300,
		url_format = require("editor").config.use_ssh and "git@github.com:%s.git"
			or "https://github.com/%s.git",
	},
	install = {
		-- install missing plugins on startup. This doesn't increase startup time.
		missing = true,
		colorscheme = { "un" },
	},
	checker = {
		enabled = true, -- automatically check for updates
		concurrency = require("editor").global.is_mac and 30 or nil,
		frequency = 3600 * 24, -- check for updates every day
	},
	dev = {
		path = vim.env.WORKSPACE .. "/neovim-plugins/",
	},
	ui = {
		-- a number <1 is a percentage., >1 is a fixed size
		size = { width = 0.88, height = 0.8 },
		wrap = true, -- wrap the lines in the ui
		-- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
		border = "rounded",
		icons = {
			cmd = icons.misc.Code,
			config = icons.ui.Gear,
			event = icons.kind.Event,
			ft = icons.documents.Files,
			init = icons.misc.ManUp,
			import = icons.documents.Import,
			keys = icons.ui.Keyboard,
			loaded = icons.ui.Check,
			not_loaded = icons.misc.Ghost,
			plugin = icons.ui.Package,
			runtime = icons.misc.Vim,
			source = icons.kind.StaticMethod,
			start = icons.ui.Play,
			list = {
				icons.ui_sep.BigCircle,
				icons.ui_sep.BigUnfilledCircle,
				icons.ui_sep.Square,
				icons.ui_sep.ChevronRight,
			},
		},
	},
	performance = {
		cache = {
			enabled = true,
			path = vim.fn.stdpath "cache"
				.. require("editor").global.path_sep
				.. "lazy"
				.. require("editor").global.path_sep
				.. "cache",
			-- Once one of the following events triggers, caching will be disabled.
			-- To cache all modules, set this to `{}`, but that is not recommended.
			disable_events = {},
			ttl = 3600 * 24 * 2, -- keep unused modules for up to 2 days
		},
		reset_packpath = true, -- reset the package path to improve startup time
		defaults = { lazy = true },
		rtp = {
			reset = true, -- reset the runtime path to $VIMRUNTIME and the config directory
			---@type string[]
			paths = {}, -- add any custom paths here that you want to include in the rtp
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"rplugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

k.nvim_load_mapping {
	["n|<Space>ph"] = k.map_cr("Lazy"):with_defaults():with_nowait():with_desc "package: Show",
	["n|<Space>ps"] = k.map_cr("Lazy sync"):with_defaults():with_nowait():with_desc "package: Sync",
	["n|<Space>pu"] = k.map_cr("Lazy update")
		:with_defaults()
		:with_nowait()
		:with_desc "package: Update",
	["n|<Space>pi"] = k.map_cr("Lazy install")
		:with_defaults()
		:with_nowait()
		:with_desc "package: Install",
	["n|<Space>pl"] = k.map_cr("Lazy log"):with_defaults():with_nowait():with_desc "package: Log",
	["n|<Space>pc"] = k.map_cr("Lazy check")
		:with_defaults()
		:with_nowait()
		:with_desc "package: Check",
	["n|<Space>pd"] = k.map_cr("Lazy debug")
		:with_defaults()
		:with_nowait()
		:with_desc "package: Debug",
	["n|<Space>pp"] = k.map_cr("Lazy profile")
		:with_defaults()
		:with_nowait()
		:with_desc "package: Profile",
	["n|<Space>pr"] = k.map_cr("Lazy restore")
		:with_defaults()
		:with_nowait()
		:with_desc "package: Restore",
	["n|<Space>px"] = k.map_cr("Lazy clean")
		:with_defaults()
		:with_nowait()
		:with_desc "package: Clean",
}
