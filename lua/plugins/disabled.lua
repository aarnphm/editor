-- plugins that are disabled for now for simplicity, but can be enabled anytime

--@param plugins LazyPlugins[]
local disable_plugins = function(plugins)
	for _, plugin in ipairs(plugins) do
		plugin.enabled = false
	end
	return plugins
end

return disable_plugins {
	{
		"NvChad/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup {
				filetypes = { "*" },
				user_default_options = {
					names = false, -- "Name" codes like Blue
					RRGGBBAA = true, -- #RRGGBBAA hex codes
					rgb_fn = true, -- CSS rgb() and rgba() functions
					hsl_fn = true, -- CSS hsl() and hsla() functions
					css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
					css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
					sass = { enable = true, parsers = { "css" } },
					mode = "background",
				},
			}
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		cmd = {
			"NvimTreeToggle",
			"NvimTreeOpen",
			"NvimTreeFindFile",
			"NvimTreeFindFileToggle",
			"NvimTreeRefresh",
		},
		event = "BufReadPost",
		config = function()
			require("nvim-tree").setup {
				hijack_cursor = true,
				sort_by = "extensions",
				prefer_startup_root = true,
				respect_buf_cwd = true,
				reload_on_bufenter = true,
				sync_root_with_cwd = true,
				actions = { open_file = { quit_on_open = false } },
				update_focused_file = { enable = true, update_root = true },
				git = { ignore = false },
				filters = { custom = { "^.git$", ".DS_Store", "__pycache__", "lazy-lock.json" } },
				renderer = {
					group_empty = true,
					indent_markers = { enable = true },
					root_folder_label = ":.:s?.*?/..?",
					root_folder_modifier = ":e",
					icons = {
						padding = " ",
						symlink_arrow = "  ",
					},
				},
				trash = {
					cmd = require("zox.utils").get_binary_path "rip",
					require_confirm = true,
				},
				view = { width = "12%", side = "right" },
			}
		end,
	},
	{
		"windwp/nvim-autopairs",
		lazy = true,
		event = "InsertEnter",
		opts = {
			check_ts = true,
			enable_check_bracket_line = false,
			fast_wrap = {
				map = "<C-b>",
				chars = { "{", "[", "(", "\"", "'" },
				pattern = [=[[%'%"%)%>%]%)%}%,]]=],
				end_key = "$",
				keys = "qwertyuiopzxcvbnmasdfghjkl",
				highlight = "LightspeedShortcut",
				highlight_grey = "LightspeedGreyWash",
			},
		},
	},
	{
		"phaazon/hop.nvim",
		lazy = true,
		branch = "v2",
		event = { "CursorHold", "CursorHoldI" },
		cmd = { "HopWord", "HopLine", "HopChar1", "HopChar2" },
		config = function()
			local h = require "hop"
			local hh = require "hop.hint"
			local k = require "zox.keybind"

			h.setup()

			k.nvim_register_mapping {
				["n|<LocalLeader>w"] = k.cr("HopWord"):with_defaults "jump: Goto word",
				["n|<LocalLeader>j"] = k.cr("HopLine"):with_defaults "jump: Goto line",
				["n|<LocalLeader>k"] = k.cr("HopLine"):with_defaults "jump: Goto line",
				["n|<LocalLeader>c"] = k.cr("HopChar1"):with_defaults "jump: one char",
				["n|<LocalLeader>cc"] = k.cr("HopChar2"):with_defaults "jump: two chars",
				["n|f"] = k.callback(
					function()
						h.hint_char1 {
							direction = hh.HintDirection.AFTER_CURSOR,
							current_line_only = true,
						}
					end
				):with_defaults "motion: forward inline to char",
				["n|<LocalLeader>f"] = k.cr("HopChar1AC")
					:with_defaults "jump: one char after cursor to eol",
				["n|F"] = k.callback(
					function()
						h.hint_char1 {
							direction = hh.HintDirection.BEFORE_CURSOR,
							current_line_only = true,
						}
					end
				):with_defaults "motion: backward inline to char",
				["n|<LocalLeader>F"] = k.cr("HopChar1BC")
					:with_defaults "jump: one char after cursor to eol",
				["n|t"] = k.callback(
					function()
						h.hint_char1 {
							direction = hh.HintDirection.AFTER_CURSOR,
							current_line_only = true,
							hint_offset = -1,
						}
					end
				):with_defaults "motion: forward inline one char before requested",
				["n|T"] = k.callback(
					function()
						h.hint_char1 {
							direction = hh.HintDirection.BEFORE_CURSOR,
							current_line_only = true,
							hint_offset = -1,
						}
					end
				):with_defaults "motion: backward inline one char before requested",
			}
		end,
	},
	{
		"goolord/alpha-nvim",
		lazy = true,
		event = "BufWinEnter",
		cond = function() return #vim.api.nvim_list_uis() > 0 end,
		config = function()
			local dashboard = require "alpha.themes.dashboard"
			dashboard.section.buttons.opts.hl = "String"
			dashboard.section.buttons.val = {}
			local gen_footer = function()
				return require("zox").misc_space.BentoBox
					.. "github.com/aarnphm"
					.. "   v"
					.. vim.version().major
					.. "."
					.. vim.version().minor
					.. "."
					.. vim.version().patch
					.. "   "
					.. require("lazy").stats().count
					.. " plugins"
			end

			dashboard.section.footer.opts.hl = "Function"
			dashboard.section.footer.val = gen_footer()

			local top_button_pad = 2
			local footer_button_pad = 1
			local heights = #dashboard.section.header.val
				+ 2 * #dashboard.section.buttons.val
				+ top_button_pad

			dashboard.config.layout = {
				{
					type = "padding",
					val = math.max(0, math.ceil((vim.fn.winheight(0) - heights) * 0.12)),
				},
				dashboard.section.header,
				{ type = "padding", val = top_button_pad },
				dashboard.section.buttons,
				{ type = "padding", val = footer_button_pad },
				dashboard.section.footer,
			}

			require("alpha").setup(dashboard.config)

			vim.api.nvim_create_autocmd("User", {
				pattern = "LazyVimStarted",
				callback = function()
					dashboard.section.footer.val = gen_footer()
					pcall(vim.cmd.AlphaRedraw)
				end,
			})
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "BufReadPost",
		config = function()
			local _cache = { context = "", bufnr = -1 }
			local lspsaga_symbols = function()
				if
					vim.api.nvim_win_get_config(0).zindex
					or vim.tbl_contains({
						"terminal",
						"toggleterm",
						"prompt",
						"alpha",
						"dashboard",
						"help",
						"TelescopePrompt",
					}, vim.bo.filetype)
				then
					return "" -- Excluded filetypes
				else
					local currbuf = vim.api.nvim_get_current_buf()
					local ok, lspsaga = pcall(require, "lspsaga.symbolwinbar")
					if ok and lspsaga:get_winbar() ~= nil then
						_cache.context = lspsaga:get_winbar()
						_cache.bufnr = currbuf
					elseif _cache.bufnr ~= currbuf then
						_cache.context = "" -- NOTE: Reset [invalid] cache (usually from another buffer)
					end

					return _cache.context
				end
			end

			local diff_source = function()
				---@diagnostic disable-next-line: undefined-field
				local gitsigns = vim.b.gitsigns_status_dict
				if gitsigns then
					return {
						added = gitsigns.added,
						modified = gitsigns.changed,
						removed = gitsigns.removed,
					}
				end
			end

			local get_cwd = function()
				local cwd = vim.fn.getcwd()
				local bentoml_git_root = os.getenv "BENTOML_GIT_ROOT"
				if bentoml_git_root and cwd:find(bentoml_git_root, 1, true) == 1 then
					return require("zox").misc_space.BentoBox .. cwd:sub(#bentoml_git_root + 2)
				end

				if vim.loop.os_uname().sysname ~= "Windows_NT" then
					local home = os.getenv "HOME"
					if home and cwd:find(home, 1, true) == 1 then
						cwd = "~" .. cwd:sub(#home + 1)
					end
				end
				return require("zox").ui_space.RootFolderOpened .. cwd
			end

			local mini_sections = {
				lualine_a = { "filetype" },
				lualine_b = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			}
			local outline = {
				sections = mini_sections,
				filetypes = { "lspsagaoutline" },
			}
			local diffview = {
				sections = mini_sections,
				filetypes = { "DiffviewFiles" },
			}

			require("lualine").setup {
				options = {
					theme = "auto",
					disabled_filetypes = {
						statusline = {
							"alpha",
							"dashboard",
							"NvimTree",
							"DiffviewFiles",
							"TelescopePrompt",
							"nofile",
							"",
						},
					},
					component_separators = "|",
					section_separators = { left = "", right = "" },
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						{ "diff", source = diff_source },
					},
					lualine_c = { lspsaga_symbols },
					lualine_x = {
						{
							"diagnostics",
							sources = { "nvim_diagnostic" },
							symbols = {
								error = require("zox").diagnostics_space.Error,
								warn = require("zox").diagnostics_space.Warning,
								info = require("zox").diagnostics_space.Information,
							},
						},
						{ get_cwd },
					},
					lualine_y = {},
					lualine_z = { "progress", "location" },
				},
				inactive_sections = {},
				tabline = {},
				extensions = {
					"quickfix",
					"nvim-tree",
					"toggleterm",
					"fugitive",
					outline,
					diffview,
				},
			}

			-- Properly set background color for lspsaga
			local winbar_bg = require("zox.utils").hl_to_rgb(
				"StatusLine",
				true,
				require("rose-pine.palette").base
			)
			for _, hlGroup in pairs(require("lspsaga.lspkind").get_kind_group()) do
				require("zox.utils").extend_hl(hlGroup, { bg = winbar_bg })
			end
		end,
	},
}
