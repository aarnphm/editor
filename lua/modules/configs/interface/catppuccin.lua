return function()
	local transparent_background = false -- Set background transparency here!

	require("catppuccin").setup {
		-- Can be one of: latte, frappe, macchiato, mocha
		flavour = vim.o.background == "dark" and require("editor").config.plugins.catppuccin.dark_variant
			or require("editor").config.plugins.catppuccin.light_variant,
		background = {
			light = require("editor").config.plugins.catppuccin.light_variant,
			dark = require("editor").config.plugins.catppuccin.dark_variant,
		},
		term_colors = true,
		styles = {
			comments = { "italic" },
			properties = { "italic" },
			functions = { "italic", "bold" },
			keywords = { "italic" },
			operators = { "bold" },
			conditionals = { "bold" },
			loops = { "bold" },
			booleans = { "bold", "italic" },
		},
		integrations = {
			dap = { enabled = true, enable_ui = true },
			fidget = true,
			hop = true,
			illuminate = true,
			indent_blankline = { enabled = true, colored_indent_levels = false },
			lsp_saga = true,
			lsp_trouble = true,
			markdown = true,
			mason = true,
			notify = true,
			nvimtree = true,
			treesitter_context = true,
			which_key = true,
		},
	}
end
