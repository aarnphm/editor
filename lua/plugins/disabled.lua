-- plugins that are disabled for now for simplicity, but can be enabled anytime
return {
	{
		"windwp/nvim-autopairs",
		lazy = true,
		enabled = false,
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
		enabled = false,
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
		enabled = false,
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
		enabled = false,
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
	{
		"akinsho/nvim-bufferline.lua",
		lazy = true,
		enabled = false,
		branch = "main",
		event = "BufReadPost",
		config = function()
			require("bufferline").setup {
				options = {
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							text_align = "center",
							padding = 1,
						},
					},
				},
			}
			local k = require "zox.keybind"

			k.nvim_register_mapping {
				["n|<LocalLeader><LocalLeader>p"] = k.cr("BufferLinePick")
					:with_defaults "buffer: Pick",
				["n|<LocalLeader><LocalLeader>c"] = k.cr("BufferLinePickClose")
					:with_defaults "buffer: Close",
				["n|<Leader>."] = k.cr("BufferLineCycleNext")
					:with_defaults "buffer: Cycle to next buffer",
				["n|<Leader>,"] = k.cr("BufferLineCyclePrev")
					:with_defaults "buffer: Cycle to previous buffer",
				["n|<Leader>1"] = k.cr("BufferLineGoToBuffer 1")
					:with_defaults "buffer: Goto buffer 1",
				["n|<Leader>2"] = k.cr("BufferLineGoToBuffer 2")
					:with_defaults "buffer: Goto buffer 2",
				["n|<Leader>3"] = k.cr("BufferLineGoToBuffer 3")
					:with_defaults "buffer: Goto buffer 3",
				["n|<Leader>4"] = k.cr("BufferLineGoToBuffer 4")
					:with_defaults "buffer: Goto buffer 4",
				["n|<Leader>5"] = k.cr("BufferLineGoToBuffer 5")
					:with_defaults "buffer: Goto buffer 5",
				["n|<Leader>6"] = k.cr("BufferLineGoToBuffer 6")
					:with_defaults "buffer: Goto buffer 6",
				["n|<Leader>7"] = k.cr("BufferLineGoToBuffer 7")
					:with_defaults "buffer: Goto buffer 7",
				["n|<Leader>8"] = k.cr("BufferLineGoToBuffer 8")
					:with_defaults "buffer: Goto buffer 8",
				["n|<Leader>9"] = k.cr("BufferLineGoToBuffer 9")
					:with_defaults "buffer: Goto buffer 9",
			}
		end,
	},
}
