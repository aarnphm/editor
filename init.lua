require "aarnphm" -- default setup

require("lazy").setup("plugins", { change_detection = { notify = false }, ui = { border = BORDER } })

vim.o.background = vim.g.simple_background
vim.cmd.colorscheme(vim.g.simple_colorscheme)
