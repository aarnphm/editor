local icons = {
	kind = require("icons").get "kind",
	documents = require("icons").get "documents",
	ui = require("icons").get "ui",
	ui_sep = require("icons").get("ui", true),
	misc = require("icons").get "misc",
}
local e = require "editor"

local lazy_path = e.global.data_dir .. e.global.path_sep .. "lazy" .. e.global.path_sep .. "lazy.nvim"

if not vim.loop.fs_stat(lazy_path) then
	vim.api.nvim_command(
		"!git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git " .. lazy_path
	)
end

vim.opt.rtp:prepend(lazy_path)

local concurrency = e.global.is_mac and 30 or nil

require("lazy").setup("plugins", {
	concurrency = concurrency,
	defaults = { lazy = true },
	install = { colorscheme = { "un" } },
	change_detection = { notify = false },
	checker = { enabled = true, concurrency = concurrency, notify = false },
	dev = {
		path = vim.NIL ~= vim.fn.getenv "WORKSPACE" and vim.env.WORKSPACE .. "/neovim-plugins/" or "~/",
	},
	ui = {
		icons = {
			ft = icons.documents.Files,
			init = icons.misc.ManUp,
			loaded = icons.ui.Check,
			not_loaded = icons.misc.Ghost,
			plugin = icons.ui.Package,
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
		rtp = {
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
