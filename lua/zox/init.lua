local os_name = vim.loop.os_uname().sysname

local is_mac = os_name == "Darwin"
local is_linux = os_name == "Linux"
local is_windows = os_name == "Windows_NT"
local separator = is_windows and "\\" or "/"
local home = is_windows and os.getenv "USERPROFILE" or os.getenv "HOME"

local __cached_config = nil

local M = { adapters = {}, servers = {} }

for package, table in pairs(M) do
	setmetatable(table, {
		__index = function(t, k)
			local ok, builtin = pcall(require, string.format("zox.%s.%s", package, k))
			if not ok then
				vim.notify(
					string.format("Failed to load '%s' for '%s'; make sure '%s' is available.", k, package, k),
					vim.log.levels.DEBUG,
					{ title = "zox: configuration" }
				)
				return
			end
			rawset(t, k, builtin)
			return builtin
		end,
	})
end

local configure = function()
	if __cached_config then return __cached_config end

	local local_config_path = home .. separator .. ".editor.lua"
	local ok, config = pcall(dofile, local_config_path)
	if not ok then
		vim.notify_once(
			string.format("User config '%s' is not available. Using default config.", local_config_path),
			vim.log.levels.DEBUG,
			{ title = "zox: configuration" }
		)
	end
	__cached_config = vim.tbl_deep_extend("keep", config or {}, {
		home = home,
		is_mac = is_mac,
		is_linux = is_linux,
		is_windows = is_windows,
		separator = separator,
		exclude_ft = { "terminal", "toggleterm", "prompt", "alpha", "dashboard", "NvimTree", "help", "TelescopePrompt" },
		disabled_workspaces = {},
		debug = false,
		background = "dark",
		colorscheme = "rose-pine",
		repos = "bentoml/bentoml",
		format_on_save = true,
		load_big_files_faster = true,
		use_ssh = true,
		plugins = {
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
						"**/*/lazy-lock.json",
					},
				},
			},
		},
	})

	for package, table in pairs(__cached_config) do
		rawset(M, package, table)
	end
end

M.setup = function()
	configure()

	require "zox.options"
	require "zox.mappings"
	require "zox.events"
end

return setmetatable(M, {
	__index = function(t, k)
		if not rawget(t, k) then
			if __cached_config[k] then
				return __cached_config[k]
			else
				vim.notify(
					string.format(
						"Failed to load builtin table for package '%s'; make sure '%s' is available in zox.",
						k,
						k
					),
					vim.log.levels.WARN,
					{ title = "zox: configuration" }
				)
			end
		end
		return rawget(t, k)
	end,
})
