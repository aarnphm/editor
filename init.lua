require "simm.package"
require "simm.options"
require "simm.keymapping"

require("lazy").setup("plugins", {
	install = { colorscheme = { "un" } },
	change_detection = { notify = false },
}) -- loads and merges each lua/plugins/*
