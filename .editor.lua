return {
	---Change the colors of the global palette here.
	---Settings will complete their replacement at initialization.
	---Example: { sky = "#04A5E5" }
	---@type palette
	palette_overwrite = {},
	---@type string[]
	disabled_workspaces = {},
	---@type boolean whether to enable debug
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
		gitsigns = {
			word_diff = false,
		},
		telescope = {
			defaults = {
				file_ignore_patterns = {
					"static_content",
					"node_modules",
					".git/",
					".cache",
					"%.class",
					"%.pdf",
					"%.mkv",
					"%.mp4",
					"%.zip",
					"lazy-lock.json",
				},
			},
		},
	},
}
