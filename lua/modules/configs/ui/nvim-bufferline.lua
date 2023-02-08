return function()
	local icons = { ui = require("utils.icons").get "ui" }

	local options = {
		options = {
			number = nil,
			modified_icon = icons.ui.Modified,
			buffer_close_icon = icons.ui.Close,
			left_trunc_marker = icons.ui.Left,
			right_trunc_marker = icons.ui.Right,
			max_name_length = 14,
			max_prefix_length = 13,
			tab_size = 19,
			show_buffer_close_icons = true,
			show_buffer_icons = true,
			show_tab_indicators = true,
			diagnostics = "nvim_lsp",
			always_show_bufferline = true,
			separator_style = "thick",
			offsets = {
				{
					filetype = "NvimTree",
					text = "File Explorer",
					text_align = "center",
					padding = 1,
				},
				{
					filetype = "undotree",
					text = "Undo Tree",
					text_align = "center",
					highlight = "Directory",
					separator = true,
				},
			},
			diagnostics_indicator = function(count) return "(" .. count .. ")" end,
		},
		-- Change bufferline's highlights here! See `:h bufferline-highlights` for detailed explanation.
		highlights = {},
	}

	if vim.g.colors_name == "catppuccin" then
		local cp = require("utils").get_palette()
		cp.none = "NONE" -- Special setting for complete transparent fg/bg.

		options = vim.tbl_deep_extend("force", options, {
			highlights = require("catppuccin.groups.integrations.bufferline").get {
				styles = { "italic", "bold" },
				custom = {
					mocha = {
						-- Hint
						hint = { fg = cp.rosewater },
						hint_visible = { fg = cp.rosewater },
						hint_selected = { fg = cp.rosewater },
						hint_diagnostic = { fg = cp.rosewater },
						hint_diagnostic_visible = { fg = cp.rosewater },
						hint_diagnostic_selected = { fg = cp.rosewater },
					},
				},
			},
		})
	elseif vim.g.colors_name == "rose-pine" then
		options = vim.tbl_deep_extend("force", options, {
			highlights = require "rose-pine.plugins.bufferline",
		})
	end

	require("bufferline").setup(options)
end
