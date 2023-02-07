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
		nvim_tree = {
			git = {
				ignore = false,
			},
		},
	},
}
