--- requires some globals
require "zox.globals"

-- map leader to <Space> and localeader to +
vim.g.mapleader = " "
vim.g.maplocalleader = "+"
vim.api.nvim_set_keymap("n", " ", "", { noremap = true })
vim.api.nvim_set_keymap("x", " ", "", { noremap = true })

if not vim.g.vscode then
	local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
	if not vim.loop.fs_stat(lazypath) then
		vim.fn.system {
			"git",
			"clone",
			"--filter=blob:none",
			"--single-branch",
			"https://github.com/folke/lazy.nvim.git",
			lazypath,
		}
	end
	vim.opt.runtimepath:prepend(lazypath)

	package.path = package.path .. ";" .. vim.fn.stdpath "config" .. "/lua/zox/?.lua"

	require("zox").configure()
	require "options"
	require "mappings"
	require "events"

	require("lazy").setup("plugins", {
		defaults = { lazy = true },
		install = { colorscheme = { "un" } },
		change_detection = { notify = false },
		checker = { enabled = true, notify = false },
		dev = { path = vim.NIL ~= vim.fn.getenv "WORKSPACE" and vim.env.WORKSPACE .. "/neovim-plugins/" or "~/" },
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
					"editorconfig",
				},
			},
		},
	})

	vim.go.background = require("zox").background
	vim.cmd.colorscheme(require("zox").colorscheme)
end
