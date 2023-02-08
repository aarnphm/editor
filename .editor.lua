return {
	debug = true,
	reset_cache = false,
	background = "light",
	colorscheme = "catppuccin",
	repos = "bentoml/bentoml",
	format_on_save = true,
	load_big_files_faster = true,
	use_ssh = true,
	plugins = {
		catppuccin = {
			flavor = "latte",
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
