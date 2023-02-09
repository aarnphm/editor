local k = require "keybind"
return {
	["chrisbra/csv.vim"] = { lazy = true, ft = "csv" },
	["folke/neodev.nvim"] = { lazy = true, ft = "lua" },
	["Stormherz/tablify"] = { lazy = true, ft = "rst" },
	["lervag/vimtex"] = { lazy = true, ft = "tex", config = require "language.vimtex" },
	["bazelbuild/vim-bazel"] = { lazy = true, dependencies = { "google/vim-maktaba" }, ft = "bzl" },
	["simrat39/rust-tools.nvim"] = { lazy = true, ft = "rust", config = require "language.rust-tools" },
	["fatih/vim-go"] = { lazy = true, ft = "go", run = ":GoInstallBinaries", config = require "language.vim-go" },
	["iamcco/markdown-preview.nvim"] = {
		lazy = true,
		ft = "markdown",
		run = "cd app && yarn install",
		build = "cd app && yarn install",
		init = function()
			k.nvim_load_mapping {
				["n|mpt"] = k.map_cr("MarkdownPreviewToggle"):with_defaults():with_desc "markdown: preview",
			}
		end,
	},
	["saecki/crates.nvim"] = {
		lazy = true,
		event = { "BufReadPost Cargo.toml" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = require "language.crates",
	},
}
