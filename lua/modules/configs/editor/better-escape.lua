return function()
	require("better_escape").setup {
		mapping = "jj", -- a table with mappings to use
		timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
		clear_empty_lines = true, -- clear line after escaping if there is only whitespace
		keys = "<Esc>", -- the keys to use for escaping
	}
end
