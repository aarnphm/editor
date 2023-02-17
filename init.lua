require "zox.globals"
-- map leader to <Space> and localeader to +
vim.g.mapleader = " "
vim.g.maplocalleader = "+"
vim.api.nvim_set_keymap("n", " ", "", { noremap = true })
vim.api.nvim_set_keymap("x", " ", "", { noremap = true })

require "user.package"
require "user.options"
require "user.keymapping"
require "user.events"

require("lazy").setup("plugins", {
	install = { colorscheme = { "un" } },
	defaults = { lazy = true },
	change_detection = { notify = false },
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
				"rplugin",
				"shada",
				"spellfile",
				"editorconfig",
			},
		},
	},
})

vim.o.background = "light"
vim.cmd.colorscheme "rose-pine"
