return {
	{
		"epwalsh/obsidian.nvim",
		ft = "markdown",
		lazy = true,
		cmd = {
			"ObsidianBacklinks",
			"ObsidianFollowLink",
			"ObsidianSearch",
			"ObsidianOpen",
			"ObsidianLink",
		},
		config = function()
			require("obsidian").setup {
				dir = vim.NIL ~= vim.env.WORKSPACE and vim.env.WORKSPACE .. "/garden/content/"
					or vim.fn.getcwd(),
				use_advanced_uri = true,
				completion = { nvim_cmp = true },
				note_frontmatter_func = function(note)
					local out = { id = note.id, tags = note.tags }
					-- `note.metadata` contains any manually added fields in the frontmatter.
					-- So here we just make sure those fields are kept in the frontmatter.
					if
						note.metadata ~= nil
						and require("obsidian").util.table_length(note.metadata) > 0
					then
						for k, v in pairs(note.metadata) do
							out[k] = v
						end
					end
					return out
				end,
			}

			local k = require "zox.keybind"
			k.nvim_register_mapping {
				["n|<Leader>gf"] = k.callback(function()
					if require("obsidian").utils.cursor_on_markdown_link() then
						pcall(vim.cmd.ObsidianFollowLink)
					end
				end):with_defaults "obsidian: Follow link",
				["n|<LocalLeader>obl"] = k.cr("ObsidianBacklinks")
					:with_defaults "obsidian: Backlinks",
				["n|<LocalLeader>on"] = k.cr("ObsidianNew"):with_defaults "obsidian: New notes",
				["n|<LocalLeader>oo"] = k.cr("ObsidianOpen"):with_defaults "obsidian: Open",
			}
		end,
	},
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		events = { "VeryLazy" },
		config = true,
		opts = { window = { width = 0.46 } },
	},
	{
		"pwntester/octo.nvim",
		lazy = true,
		cmd = "Octo",
		event = "BufReadPost",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("octo").setup()
			-- Use treesitter markdown parser for Octo buffer
			vim.treesitter.language.register("markdown", "octo")
		end,
		keys = function()
			local k = require "zox.keybind"
			return k.to_lazy_mapping {
				["n|<leader>o"] = k.args("Octo"):with_defaults "octo: open",
				["n|<leader>oc"] = k.args("Octo comment"):with_defaults "octo: comment",
				["n|<leader>oi"] = k.args("Octo issue"):with_defaults "octo: issue",
				["n|<leader>op"] = k.args("Octo pr"):with_defaults "octo: pr",
				["n|<leader>or"] = k.args("Octo review"):with_defaults "octo: review",
				["n|<leader>os"] = k.args("Octo status"):with_defaults "octo: status",
			}
		end,
	},
	{
		"TimUntersberger/neogit",
		lazy = true,
		dependencies = "nvim-lua/plenary.nvim",
		cmd = "Neogit",
	},
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
		config = true,
	},
}
