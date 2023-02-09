return function()
	local crates = require "crates"
	local icons = {
		diagnostics = require("utils.icons").get("diagnostics", true),
		git = require("utils.icons").get("git", true),
		misc = require("utils.icons").get("misc", true),
		ui = require("utils.icons").get("ui", true),
		kind = require("utils.icons").get("kind", true),
	}

	crates.setup {
		avoid_prerelease = false,
		smart_insert = true,
		insert_closing_quote = true,
		autoload = true,
		autoupdate = true,
		autoupdate_throttle = 250,
		loading_indicator = true,
		date_format = "%Y-%m-%d",
		thousands_separator = ",",
		notification_title = "Crates",
		curl_args = { "-sL", "--retry", "1" },
		disable_invalid_feature_diagnostic = false,
		text = {
			loading = " " .. icons.misc.Watch .. "Loading",
			version = " " .. icons.ui.Check .. "%s",
			prerelease = " " .. icons.diagnostics.Warning_alt .. "%s",
			yanked = " " .. icons.diagnostics.Error .. "%s",
			nomatch = " " .. icons.diagnostics.Question .. "No match",
			upgrade = " " .. icons.diagnostics.Hint_alt .. "%s",
			error = " " .. icons.diagnostics.Error .. "Error fetching crate",
		},
		popup = {
			autofocus = false,
			hide_on_select = true,
			copy_register = "\"",
			style = "minimal",
			border = "rounded",
			show_version_date = true,
			show_dependency_version = true,
			max_height = 30,
			min_width = 20,
			padding = 1,
			text = {
				title = icons.ui.Package .. "%s",
				description = "%s",
				created_label = icons.misc.Added .. "created" .. "        ",
				created = "%s",
				updated_label = icons.misc.ManUp .. "updated" .. "        ",
				updated = "%s",
				downloads_label = icons.ui.CloudDownload .. "downloads      ",
				downloads = "%s",
				homepage_label = icons.misc.Campass .. "homepage       ",
				homepage = "%s",
				repository_label = icons.git.Repo .. "repository     ",
				repository = "%s",
				documentation_label = icons.diagnostics.Information_alt .. "documentation  ",
				documentation = "%s",
				crates_io_label = icons.ui.Package .. "crates.io      ",
				crates_io = "%s",
				categories_label = icons.kind.Class .. "categories     ",
				keywords_label = icons.kind.Keyword .. "keywords       ",
				version = "  %s",
				prerelease = icons.diagnostics.Warning_alt .. "%s prerelease",
				yanked = icons.diagnostics.Error .. "%s yanked",
				version_date = "  %s",
				feature = "  %s",
				enabled = icons.ui.Play .. "%s",
				transitive = icons.ui.List .. "%s",
				normal_dependencies_title = icons.kind.Interface .. "Dependencies",
				build_dependencies_title = icons.misc.Gavel .. "Build dependencies",
				dev_dependencies_title = icons.misc.Glass .. "Dev dependencies",
				dependency = "  %s",
				optional = icons.ui.BigUnfilledCircle .. "%s",
				dependency_version = "  %s",
				loading = " " .. icons.misc.Watch,
			},
		},
		src = {
			insert_closing_quote = true,
			text = {
				prerelease = " " .. icons.diagnostics.Warning_alt .. "pre-release ",
				yanked = " " .. icons.diagnostics.Error_alt .. "yanked ",
			},
		},
	}

	local k = require "keybind"
	k.nvim_load_mapping {
		["n|<Leader>ct"] = k.map_callback(crates.toggle):with_defaults():with_buffer(0):with_desc "crates: Toggle",
		["n|<Leader>cr"] = k.map_callback(crates.reload):with_defaults():with_buffer(0):with_desc "crates: reload",
		["n|<Leader>cv"] = k.map_callback(crates.show_versions_popup)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: show versions popup",
		["n|<Leader>cf"] = k.map_callback(crates.show_features_popup)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: show features popup",
		["n|<Leader>cd"] = k.map_callback(crates.show_dependencies_popup)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: show dependencies popup",
		["n|<Leader>cu"] = k.map_callback(crates.update_crate)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: update crate",
		["v|<Leader>cu"] = k.map_callback(crates.update_crates)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: update crates",
		["n|<Leader>ca"] = k.map_callback(crates.update_all_crates)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: update all crates",
		["n|<Leader>cU"] = k.map_callback(crates.upgrade_crate)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: upgrade crate",
		["v|<Leader>cU"] = k.map_callback(crates.upgrade_crates)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: upgrade crates",
		["n|<Leader>cA"] = k.map_callback(crates.upgrade_all_crates)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: upgrade all crates",
		["n|<Leader>cH"] = k.map_callback(crates.open_homepage)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: show homepage",
		["n|<Leader>cR"] = k.map_callback(crates.open_repository)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: show repository",
		["n|<Leader>cD"] = k.map_callback(crates.open_documentation)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: show documentation",
		["n|<Leader>cC"] = k.map_callback(crates.open_crates_io)
			:with_defaults()
			:with_buffer(0)
			:with_desc "crates: open crates.io",
	}
end
