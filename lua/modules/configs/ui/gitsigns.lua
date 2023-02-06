return function()
	require("gitsigns").setup {
		numhl = true,
		word_diff = true,
		watch_gitdir = { interval = 1000, follow_files = true },
		sign_priority = 6,
		update_debounce = 100,
		current_line_blame = true,
		current_line_blame_opts = { delay = 1000, virtual_text_pos = "eol" },
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

			k.nvim_load_mapping {
				["n|]g"] = k.map_callback(function()
					if vim.wo.diff then
						return "]g"
					end
					vim.schedule(function() require("gitsigns.actions").next_hunk() end)
					return "<Ignore>"
				end)
					:with_buffer(bufnr)
					:with_expr()
					:with_desc "git: Goto next hunk",
				["n|[g"] = k.map_callback(function()
					if vim.wo.diff then
						return "[g"
					end
					vim.schedule(function() require("gitsigns.actions").prev_hunk() end)
					return "<Ignore>"
				end)
					:with_buffer(bufnr)
					:with_expr()
					:with_desc "git: Goto prev hunk",
				["n|<Space>hs"] = k.map_callback(function() require("gitsigns.actions").stage_hunk() end)
					:with_buffer(bufnr)
					:with_desc "git: Stage hunk",
				["v|<Space>hs"] = k.map_callback(
					function() require("gitsigns.actions").stage_hunk { vim.fn.line ".", vim.fn.line "v" } end
				)
					:with_buffer(bufnr)
					:with_desc "git: Stage hunk",
				["n|<Space>hu"] = k.map_callback(function() require("gitsigns.actions").undo_stage_hunk() end)
					:with_buffer(bufnr)
					:with_desc "git: Undo stage hunk",
				["n|<Space>hr"] = k.map_callback(function() require("gitsigns.actions").reset_hunk() end)
					:with_buffer(bufnr)
					:with_desc "git: Reset hunk",
				["v|<Space>hr"] = k.map_callback(
					function() require("gitsigns.actions").reset_hunk { vim.fn.line ".", vim.fn.line "v" } end
				)
					:with_buffer(bufnr)
					:with_desc "git: Reset hunk",
				["n|<Space>hR"] = k.map_callback(function() require("gitsigns.actions").reset_buffer() end)
					:with_buffer(bufnr)
					:with_desc "git: Reset buffer",
				["n|<Space>hp"] = k.map_callback(function() require("gitsigns.actions").preview_hunk() end)
					:with_buffer(bufnr)
					:with_desc "git: Preview hunk",
				["n|<Space>hb"] = k.map_callback(function() require("gitsigns.actions").blame_line { full = true } end)
					:with_buffer(bufnr)
					:with_desc "git: Blame line",
				["n|<Space>hbl"] = k.map_callback(
					function() require("gitsigns.actions").toggle_current_line_blame() end
				)
					:with_buffer(bufnr)
					:with_desc "git: Toggle current line blame",
				["n|<Space>hwd"] = k.map_callback(function() require("gitsigns.actions").toggle_word_diff() end)
					:with_buffer(bufnr)
					:with_desc "git: Toogle word diff",
				["n|<Space>hd"] = k.map_callback(function() require("gitsigns.actions").toggle_deleted() end)
					:with_buffer(bufnr)
					:with_desc "git: Toggle deleted diff",
				-- Text objects
				["o|ih"] = k.map_callback(function() require("gitsigns.actions").text_object() end):with_buffer(bufnr),
				["x|ih"] = k.map_callback(function() require("gitsigns.actions").text_object() end):with_buffer(bufnr),
			}
		end,
	}
end
