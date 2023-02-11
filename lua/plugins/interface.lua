return {
	{ "lewis6991/gitsigns.nvim", config = true },
	{
		"rose-pine/neovim",
		name = "rose-pine",
		branch = "canary",
		lazy = false,
		priority = 1000,
		config = function()
			require("rose-pine").setup {
				disable_italics = true,
				disable_float_background = true,
				highlight_groups = {
					Comment = { fg = "muted", italic = true },
					StatusLine = { fg = "iris", bg = "iris", blend = 10 },
					StatusLineNC = { fg = "subtle", bg = "surface" },
				},
			}
			vim.cmd.colorscheme "rose-pine"
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = "BufReadPost",
		config = function()
			require("nvim-treesitter.configs").setup {
				ensure_installed = {
					"lua",
					"python",
					"c",
					"cpp",
					"go",
					"bash",
					"markdown",
					"markdown_inline",
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
					"llvm",
					"toml",
					"proto",
				},
				ignore_install = { "phpdoc" },
				indent = { enable = false },
				highlight = { enable = true },
			}
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = "Telescope",
		keys = {
			{
				"<leader>f",
				"<cmd>Telescope find_files find_command=fd,-t,f,-H,-E,.git,--strip-cwd-prefix theme=dropdown previewer=false<cr>",
				desc = "Find files",
			},
			{
				"<leader>/",
				"<cmd>Telescope live_grep<cr>",
				desc = "Find text",
			},
			{
				"<leader>p",
				"<cmd>Telescope commands theme=dropdown<cr>",
				desc = "Commands",
			},
		},
		config = true,
	},
	{
		"kyazdani42/nvim-tree.lua",
		keys = {
			{
				"<C-n>",
				"<cmd>NvimTreeFindFileToggle<cr>",
				desc = "Toggle file tree",
			},
		},
		opts = {
			actions = {
				open_file = {
					quit_on_open = true,
				},
			},
			git = { ignore = false },
			renderer = {
				icons = {
					show = {
						file = false,
						folder = false,
						folder_arrow = false,
						git = false,
					},
				},
			},
			trash = { cmd = "trash" },
			view = {
				side = "right",
				mappings = {
					list = {
						{ key = "d", action = "trash" },
						{ key = "D", action = "remove" },
					},
				},
			},
		},
	},
}
