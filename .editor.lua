return {
	debug = true,
	reset_cache = false,
	background = "dark",
	colorscheme = "catppuccin",
	repos = "bentoml/bentoml",
	format_on_save = true,
	load_big_files_faster = false,
	use_ssh = false,
	plugins = {
		catppuccin = {
			dark_variant = "mocha",
			light_variant = "latte",
		},
		["rose-pine"] = {
			dark_variant = "moon",
		},
		nvim_tree = {
			git = {
				ignore = false,
			},
		},
		lualine = {
			globalstatus = true,
		},
	},
}
