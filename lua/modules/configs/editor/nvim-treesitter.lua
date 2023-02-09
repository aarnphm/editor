return function()
	vim.api.nvim_set_option_value("foldmethod", "expr", {})
	vim.api.nvim_set_option_value("foldexpr", "nvim_treesitter#foldexpr()", {})

	require("nvim-treesitter.configs").setup {
		ensure_installed = {
			"lua",
			"python",
			"c",
			"cpp",
			"go",
			"bash",
			"markdown",
			"javascript",
			"typescript",
			"terraform",
			"make",
			"nix",
			"rust",
			"query",
			"regex",
			"tsx",
			"vim",
			"yaml",
		},
		ignore_install = { "phpdoc" },
		indent = { enable = false },
		highlight = {
			enable = true,
			disable = function(ft, bufnr)
				if vim.tbl_contains({ "vim", "help" }, ft) then
					return true
				end

				local ok, is_large_file = pcall(vim.api.nvim_buf_get_var, bufnr, "bigfile_disable_treesitter")
				return ok and is_large_file
			end,
			additional_vim_regex_highlighting = false,
		},
		matchup = { enable = true },
		lsp_interop = {
			enable = true,
			border = "none",
			peek_definition_code = {
				["<leader>sd"] = "@function.outer",
				["<leader>sD"] = "@class.outer",
			},
		},
		textobjects = {
			select = {
				enable = true,
				keymaps = {
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					["ic"] = "@class.inner",
				},
			},
			move = {
				enable = true,
				set_jumps = true, -- whether to set jumps in the jumplist
				goto_next_start = {
					["]["] = "@function.outer",
					["]m"] = "@class.outer",
				},
				goto_next_end = {
					["]]"] = "@function.outer",
					["]M"] = "@class.outer",
				},
				goto_previous_start = {
					["[["] = "@function.outer",
					["[m"] = "@class.outer",
				},
				goto_previous_end = {
					["[]"] = "@function.outer",
					["[M"] = "@class.outer",
				},
			},
		},
	}

	require("nvim-treesitter.install").prefer_git = true
	local parsers = require "nvim-treesitter.parsers"
	local parsers_config = parsers.get_parser_configs()
	for _, p in pairs(parsers_config) do
		p.install_info.url = p.install_info.url:gsub("https://github.com/", "git@github.com:")
	end

	-- use with octo.nvim
	parsers.filetype_to_parsername.octo = "markdown"
end
