pcall(require, "impatient")

require "zox.globals"

require "user.options"
require "user.keymapping"
require "user.events"

-- Bootstrap lazy.nvim plugin manager.
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

require("lazy").setup("plugins", {
	install = { colorscheme = { "un" } },
	change_detection = { notify = false },
	checker = { enable = true },
	performance = {
		rtp = {
			disabled_plugins = {
				"2html_plugin",
				"getscript",
				"getscriptPlugin",
				"gzip",
				"logipat",
				"netrw",
				"netrwPlugin",
				"netrwSettings",
				"netrwFileHandlers",
				"matchit",
				"matchparen",
				"tar",
				"tarPlugin",
				"tohtml",
				"tutor",
				"rrhelper",
				"spellfile_plugin",
				"vimball",
				"vimballPlugin",
				"zip",
				"zipPlugin",
			},
		},
	},
})
