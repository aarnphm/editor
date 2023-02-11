return function()
	require("rose-pine").setup {
		--- @usage 'main' | 'moon'
		dark_variant = require("editor").config.plugins["rose-pine"].dark_variant,
		disable_background = true,
		disable_float_background = true,
		disable_italics = false,
		highlight_groups = {
			Comment = { fg = "muted", italic = true },
			StatusLine = { fg = "iris", bg = "iris", blend = 10 },
			StatusLineNC = { fg = "subtle", bg = "surface" },
		},
	}
end
