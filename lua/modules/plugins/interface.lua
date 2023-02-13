local k = require "keybind"
local icons = { ui = require("utils.icons").get "ui", diagnostics = require("utils.icons").get "diagnostics" }
return {
	["nathom/filetype.nvim"] = { lazy = false },

	-- NOTE: Colorscheme
	["catppuccin/nvim"] = {
		as = "catppuccin",
		lazy = false,
		name = "catppuccin",
		config = require "interface.catppuccin",
	},
	["rose-pine/neovim"] = {
		as = "rose-pine",
		lazy = false,
		priority = 1000,
		branch = "canary",
		name = "rose-pine",
		config = function()
			require("rose-pine").setup {
				--- @usage 'main' | 'moon'
				dark_variant = require("editor").config.plugins["rose-pine"].dark_variant,
				disable_background = true,
				disable_float_background = true,
				highlight_groups = {
					Comment = { fg = "muted", italic = true },
					StatusLine = { fg = "iris", bg = "iris", blend = 10 },
					StatusLineNC = { fg = "subtle", bg = "surface" },
				},
			}
		end,
	},

	["lukas-reineke/indent-blankline.nvim"] = {
		lazy = true,
		event = "BufRead",
		config = require "interface.indent-blankline",
	},
	["lewis6991/gitsigns.nvim"] = {
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		config = require "interface.gitsigns",
	},
	["goolord/alpha-nvim"] = {
		lazy = true,
		event = "BufWinEnter",
		config = require "interface.alpha-nvim",
		cond = function() return #vim.api.nvim_list_uis() > 0 end,
	},
	["nvim-lualine/lualine.nvim"] = {
		lazy = true,
		event = "VeryLazy",
		config = require "interface.lualine",
	},
	["nvim-tree/nvim-tree.lua"] = {
		cmd = {
			"NvimTreeToggle",
			"NvimTreeOpen",
			"NvimTreeFindFile",
			"NvimTreeFindFileToggle",
			"NvimTreeRefresh",
		},
		config = require "interface.nvim-tree",
		init = function()
			k.nvim_register_mapping {
				["n|<C-n>"] = k.cr("NvimTreeToggle"):with_defaults "file-explorer: Toggle",
				["n|<LocalLeader>nr"] = k.cr("NvimTreeRefresh"):with_defaults "file-explorer: Refresh",
			}
		end,
	},
	["zbirenbaum/neodim"] = {
		lazy = true,
		event = "LspAttach",
		config = function()
			require("neodim").setup {
				blend_color = require("utils").hl_to_rgb("Normal", true),
				update_in_insert = { delay = 100 },
				hide = {
					virtual_text = false,
					signs = false,
					underline = false,
				},
			}
		end,
	},
	["folke/todo-comments.nvim"] = {
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "BufRead",
		config = function() require("todo-comments").setup {} end,
		init = function()
			k.nvim_register_mapping {
				["n|<Leader>tqf"] = k.cr("TodoQuickFix"):with_defaults "todo-comments: Open quickfix",
				["n|]t"] = k.callback(function() require("todo-comments").jump_next() end)
					:with_defaults "todo-comments: Next",
				["n|[t"] = k.callback(function() require("todo-comments").jump_prev() end)
					:with_defaults "todo-comments: Previous",
				["n|<Leader>tt"] = k.cr("TodoTelescope"):with_defaults "todo-comments: Telescope",
			}
		end,
	},
	["j-hui/fidget.nvim"] = {
		lazy = true,
		event = "BufRead",
		config = function()
			require("fidget").setup {
				text = { spinner = "dots" },
				window = { blend = 0 },
			}
		end,
	},

	["akinsho/nvim-bufferline.lua"] = {
		lazy = true,
		branch = "main",
		event = { "BufReadPost", "BufAdd", "BufRead", "BufNewFile" },
		config = function()
			require("bufferline").setup {
				options = {
					modified_icon = icons.ui.Modified,
					buffer_close_icon = icons.ui.Close,
					left_trunc_marker = icons.ui.Left,
					right_trunc_marker = icons.ui.Right,
					diagnostics = "nvim_lsp",
					separator_style = { "|", "|" },
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							text_align = "center",
							padding = 1,
						},
						{
							filetype = "undotree",
							text = "Undo Tree",
							text_align = "center",
							highlight = "Directory",
							separator = true,
						},
					},
				},
			}
		end,
		init = function()
			k.nvim_register_mapping {
				["n|<LocalLeader>p"] = k.cr("BufferLinePick"):with_defaults "buffer: Pick",
				["n|<LocalLeader>c"] = k.cr("BufferLinePickClose"):with_defaults "buffer: Close",
				["n|<Leader>."] = k.cr("BufferLineCycleNext"):with_defaults "buffer: Cycle to next buffer",
				["n|<Leader>,"] = k.cr("BufferLineCyclePrev"):with_defaults "buffer: Cycle to previous buffer",
				["n|<Leader>1"] = k.cr("BufferLineGoToBuffer 1"):with_defaults "buffer: Goto buffer 1",
				["n|<Leader>2"] = k.cr("BufferLineGoToBuffer 2"):with_defaults "buffer: Goto buffer 2",
				["n|<Leader>3"] = k.cr("BufferLineGoToBuffer 3"):with_defaults "buffer: Goto buffer 3",
				["n|<Leader>4"] = k.cr("BufferLineGoToBuffer 4"):with_defaults "buffer: Goto buffer 4",
				["n|<Leader>5"] = k.cr("BufferLineGoToBuffer 5"):with_defaults "buffer: Goto buffer 5",
				["n|<Leader>6"] = k.cr("BufferLineGoToBuffer 6"):with_defaults "buffer: Goto buffer 6",
				["n|<Leader>7"] = k.cr("BufferLineGoToBuffer 7"):with_defaults "buffer: Goto buffer 7",
				["n|<Leader>8"] = k.cr("BufferLineGoToBuffer 8"):with_defaults "buffer: Goto buffer 8",
				["n|<Leader>9"] = k.cr("BufferLineGoToBuffer 9"):with_defaults "buffer: Goto buffer 9",
			}
		end,
	},
	["rcarriga/nvim-notify"] = {
		lazy = true,
		event = "VeryLazy",
		config = function()
			local notify = require "notify"

			notify.setup {
				stages = "static",
				---@usage timeout for notifications in ms, default 5000
				timeout = 3000,
				-- @usage User render fps value
				fps = 60,
				max_height = function() return math.floor(vim.o.lines * 0.75) end,
				max_width = function() return math.floor(vim.o.columns * 0.75) end,
				render = "minimal",
				background_colour = "Normal",
				---@usage notifications with level lower than this would be ignored. [ERROR > WARN > INFO > DEBUG > TRACE]
				level = require("editor").config.debug and "DEBUG" or "INFO",
				---@usage Icons for the different levels
				icons = {
					ERROR = icons.diagnostics.Error,
					WARN = icons.diagnostics.Warning,
					INFO = icons.diagnostics.Information,
					DEBUG = icons.ui.Bug,
					TRACE = icons.ui.Pencil,
				},
			}

			vim.notify = notify
		end,
		cond = function() return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype) end,
	},
}
