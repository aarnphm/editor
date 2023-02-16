require "zox.globals"
-- map leader to <Space> and localeader to +
vim.g.mapleader = " "
vim.g.maplocalleader = "+"
vim.api.nvim_set_keymap("n", " ", "", { noremap = true })
vim.api.nvim_set_keymap("x", " ", "", { noremap = true })

require "zil.package"
require "zil.options"
require "zil.keymapping"
require "zil.events"

require("lazy").setup("plugins", {
	install = { colorscheme = { "un" } },
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

vim.o.background = "dark"
vim.cmd.colorscheme "rose-pine"
