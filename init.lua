--- requires some globals
require "zox.globals"

--- Add custom filet+pe extension
vim.filetype.add {
	extension = {
		conf = "conf",
		mdx = "markdown",
		mjml = "html",
		sh = "bash",
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

-- Configuring native diagnostics
vim.diagnostic.config {
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = true,
	severity_sort = false,
}

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

	require("zox").setup()

	require("lazy").setup("plugins", {
		defaults = { lazy = true },
		install = { colorscheme = { "un" } },
		change_detection = { notify = false },
		checker = { enabled = true, notify = false },
		dev = {
			path = vim.NIL ~= vim.fn.getenv "WORKSPACE" and vim.env.WORKSPACE .. "/neovim-plugins/" or "~/",
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

	vim.go.background = zox.config.background
	vim.cmd.colorscheme(zox.config.colorscheme)
end
