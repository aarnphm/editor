return function()
	require("gitsigns").setup {
		numhl = true,
		---@diagnostic disable-next-line: undefined-global
		word_diff = require("editor").config.plugins.gitsigns.word_diff,
		current_line_blame = true,
		current_line_blame_opts = { virtual_text_pos = "eol" },
		diff_opts = { internal = true },
		signs = {
			add = {
				hl = "GitSignsAdd",
				text = "│",
				numhl = "GitSignsAddNr",
				linehl = "GitSignsAddLn",
			},
			change = {
				hl = "GitSignsChange",
				text = "│",
				numhl = "GitSignsChangeNr",
				linehl = "GitSignsChangeLn",
			},
			delete = {
				hl = "GitSignsDelete",
				text = "_",
				numhl = "GitSignsDeleteNr",
				linehl = "GitSignsDeleteLn",
			},
			topdelete = {
				hl = "GitSignsDelete",
				text = "‾",
				numhl = "GitSignsDeleteNr",
				linehl = "GitSignsDeleteLn",
			},
			changedelete = {
				hl = "GitSignsChange",
				text = "~",
				numhl = "GitSignsChangeNr",
				linehl = "GitSignsChangeLn",
			},
		},
		on_attach = function(bufnr)
			local k = require "keybind"
			k.nvim_register_mapping {
				["n|]g"] = k.callback(function()
					if vim.wo.diff then return "]g" end
					vim.schedule(function() require("gitsigns.actions").next_hunk() end)
					return "<Ignore>"
				end)
					:with_buffer(bufnr)
					:with_expr()
					:with_desc "git: Goto next hunk",
				["n|[g"] = k.callback(function()
					if vim.wo.diff then return "[g" end
					vim.schedule(function() require("gitsigns.actions").prev_hunk() end)
					return "<Ignore>"
				end)
					:with_buffer(bufnr)
					:with_expr()
					:with_desc "git: Goto prev hunk",
				["n|<Leader>hs"] = k.callback(function() require("gitsigns.actions").stage_hunk() end)
					:with_buffer(bufnr)
					:with_desc "git: Stage hunk",
				["v|<Leader>hs"] = k.callback(
					function() require("gitsigns.actions").stage_hunk { vim.fn.line ".", vim.fn.line "v" } end
				)
					:with_buffer(bufnr)
					:with_desc "git: Stage hunk",
				["n|<Leader>hu"] = k.callback(function() require("gitsigns.actions").undo_stage_hunk() end)
					:with_buffer(bufnr)
					:with_desc "git: Undo stage hunk",
				["n|<Leader>hr"] = k.callback(function() require("gitsigns.actions").reset_hunk() end)
					:with_buffer(bufnr)
					:with_desc "git: Reset hunk",
				["v|<Leader>hr"] = k.callback(
					function() require("gitsigns.actions").reset_hunk { vim.fn.line ".", vim.fn.line "v" } end
				)
					:with_buffer(bufnr)
					:with_desc "git: Reset hunk",
				["n|<Leader>hR"] = k.callback(function() require("gitsigns.actions").reset_buffer() end)
					:with_buffer(bufnr)
					:with_desc "git: Reset buffer",
				["n|<Leader>hp"] = k.callback(function() require("gitsigns.actions").preview_hunk() end)
					:with_buffer(bufnr)
					:with_desc "git: Preview hunk",
				["n|<Leader>hb"] = k.callback(function() require("gitsigns.actions").blame_line { full = true } end)
					:with_buffer(bufnr)
					:with_desc "git: Blame line",
				["n|<Leader>hbl"] = k.callback(function() require("gitsigns.actions").toggle_current_line_blame() end)
					:with_buffer(bufnr)
					:with_desc "git: Toggle current line blame",
				["n|<Leader>hwd"] = k.callback(function() require("gitsigns.actions").toggle_word_diff() end)
					:with_buffer(bufnr)
					:with_desc "git: Toogle word diff",
				["n|<Leader>hd"] = k.callback(function() require("gitsigns.actions").toggle_deleted() end)
					:with_buffer(bufnr)
					:with_desc "git: Toggle deleted diff",
				-- Text objects
				["o|ih"] = k.callback(function() require("gitsigns.actions").text_object() end):with_buffer(bufnr),
				["x|ih"] = k.callback(function() require("gitsigns.actions").text_object() end):with_buffer(bufnr),
			}
		end,
	}
end
