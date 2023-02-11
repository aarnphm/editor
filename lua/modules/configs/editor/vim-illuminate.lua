return function()
	require("illuminate").configure {
		providers = {
			"lsp",
			"treesitter",
			"regex",
		},
		delay = 100,
		filetypes_denylist = {
			"alpha",
			"dashboard",
			"DoomInfo",
			"startuptime",
			"fugitive",
			"help",
			"norg",
			"NvimTree",
			"Outline",
			"toggleterm",
		},
		under_cursor = false,
	}
end
