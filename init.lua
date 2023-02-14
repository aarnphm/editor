require "zox.globals"
-- map leader to <Space> and localeader to +
vim.g.mapleader = " "
vim.g.maplocalleader = "+"
vim.api.nvim_set_keymap("n", " ", "", { noremap = true })
vim.api.nvim_set_keymap("x", " ", "", { noremap = true })

require "simm.package"
require "simm.options"
require "simm.keymapping"
require "simm.events"

require("lazy").setup("plugins", {
	install = { colorscheme = { "un" } },
	change_detection = { notify = false },
}) -- loads and merges each lua/plugins/*
