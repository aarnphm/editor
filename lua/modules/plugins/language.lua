local k = require "keybind"
return {
	["chrisbra/csv.vim"] = { lazy = true, ft = "csv" },
	["folke/neodev.nvim"] = { lazy = true, ft = "lua" },
	["Stormherz/tablify"] = { lazy = true, ft = "rst" },
	["lervag/vimtex"] = { lazy = true, ft = "tex", config = require "language.vimtex" },
	["bazelbuild/vim-bazel"] = {
		lazy = true,
		dependencies = { "google/vim-maktaba" },
		cmd = { "Bazel" },
		ft = "bzl",
		init = function()
			k.nvim_register_mapping {
				["n|<LocalLeader>bb"] = k.args("Bazel build"):with_defaults "bazel: build",
				["n|<LocalLeader>bc"] = k.args("Bazel clean"):with_defaults "bazel: clean",
				["n|<LocalLeader>bd"] = k.args("Bazel debug"):with_defaults "bazel: debug",
				["n|<LocalLeader>br"] = k.args("Bazel run"):with_defaults "bazel: run",
				["n|<LocalLeader>bt"] = k.args("Bazel test"):with_defaults "bazel: test",
			}
		end,
	},
	["simrat39/rust-tools.nvim"] = {
		lazy = true,
		ft = "rust",
		config = require "language.rust-tools",
	},
	["fatih/vim-go"] = {
		lazy = true,
		ft = "go",
		run = ":GoInstallBinaries",
		config = function()
			vim.g.go_doc_keywordprg_enabled = 0
			vim.g.go_def_mapping_enabled = 0
			vim.g.go_code_completion_enabled = 0
		end,
	},
	["iamcco/markdown-preview.nvim"] = {
		lazy = true,
		ft = "markdown",
		run = "cd app && yarn install",
		build = "cd app && yarn install",
		init = function()
			k.nvim_register_mapping {
				["n|mpt"] = k.cr("MarkdownPreviewToggle"):with_defaults "markdown: preview",
			}
		end,
	},
	["saecki/crates.nvim"] = {
		lazy = true,
		event = { "BufReadPost Cargo.toml" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = require "language.crates",
		init = function()
			k.nvim_register_mapping {
				["n|<Leader>ct"] = k.callback(require("crates").toggle):with_buffer(0):with_defaults "crates: Toggle",
				["n|<Leader>cr"] = k.callback(require("crates").reload):with_buffer(0):with_defaults "crates: reload",
				["n|<Leader>cv"] = k.callback(require("crates").show_versions_popup)
					:with_buffer(0)
					:with_defaults "crates: show versions popup",
				["n|<Leader>cf"] = k.callback(require("crates").show_features_popup)
					:with_buffer(0)
					:with_defaults "crates: show features popup",
				["n|<Leader>cd"] = k.callback(require("crates").show_dependencies_popup)
					:with_buffer(0)
					:with_defaults "crates: show dependencies popup",
				["n|<Leader>cu"] = k.callback(require("crates").update_crate)
					:with_buffer(0)
					:with_defaults "crates: update crate",
				["v|<Leader>cu"] = k.callback(require("crates").update_crates)
					:with_buffer(0)
					:with_defaults "crates: update crates",
				["n|<Leader>ca"] = k.callback(require("crates").update_all_crates)
					:with_buffer(0)
					:with_defaults "crates: update all crates",
				["n|<Leader>cU"] = k.callback(require("crates").upgrade_crate)
					:with_buffer(0)
					:with_defaults "crates: upgrade crate",
				["v|<Leader>cU"] = k.callback(require("crates").upgrade_crates)
					:with_buffer(0)
					:with_defaults "crates: upgrade crates",
				["n|<Leader>cA"] = k.callback(require("crates").upgrade_all_crates)
					:with_buffer(0)
					:with_defaults "crates: upgrade all crates",
				["n|<Leader>cH"] = k.callback(require("crates").open_homepage)
					:with_buffer(0)
					:with_defaults "crates: show homepage",
				["n|<Leader>cR"] = k.callback(require("crates").open_repository)
					:with_buffer(0)
					:with_defaults "crates: show repository",
				["n|<Leader>cD"] = k.callback(require("crates").open_documentation)
					:with_buffer(0)
					:with_defaults "crates: show documentation",
				["n|<Leader>cC"] = k.callback(require("crates").open_crates_io)
					:with_buffer(0)
					:with_defaults "crates: open crates.io",
			}
		end,
	},
}
