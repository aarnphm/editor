--# selene: allow(global_usage)
_G.P = function(v)
	print(vim.inspect(v))
	return v
end

local api, wo, o, g, autocmd = vim.api, vim.wo, vim.o, vim.g, vim.api.nvim_create_autocmd

local icons = require "icons"
local utils = require "utils"

o.wrap = false
o.autowrite = true
o.undofile = true -- enable undofile
o.undodir = "/tmp/.vim-undo-dir"
wo.breakindent = true -- use breakindent
o.clipboard = "unnamedplus" -- sync system clipboard
o.expandtab = true -- space to tabs
o.number = true -- number is good for nav
o.relativenumber = true -- relativenumber is useful, grow up
o.mouse = "a" -- because sometimes mouse is needed for ssh
o.copyindent = true
o.splitright = true
vim.opt.smartcase = true
o.diffopt = "filler,iwhite,internal,linematch:60,algorithm:patience" -- better diff
-- o.shortmess = "aoOTIcF"  -- eh if I'm a pain then uncomment this
vim.opt.completeopt = { "menuone", "noselect" }
o.grepprg = "rg --vimgrep"
o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
local TAB_WIDTH = 2
o.tabstop = TAB_WIDTH
o.shiftwidth = TAB_WIDTH
o.softtabstop = TAB_WIDTH
o.expandtab = true
o.copyindent = true
o.signcolumn = "yes"
o.timeoutlen = 200
o.updatetime = 200
o.statusline = utils.statusline.build()

g.mapleader = " "
g.maplocalleader = "+"

vim.keymap.set({ "n", "x" }, " ", "", { noremap = true })

-- NOTE: Keymaps that are useful, use it and never come back.
local function map(mode, lhs, rhs, opts)
	opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
	vim.keymap.set(mode, lhs, rhs, opts)
end
-- NOTE: normal mode
map("n", "<S-Tab>", "<cmd>normal za<cr>", {
	desc = "edit: Toggle code fold",
})
map("n", "Y", "y$", { desc = "edit: Yank text to EOL" })
map("n", "D", "d$", { desc = "edit: Delete text to EOL" })
map("n", "J", "mzJ`z", { desc = "edit: Join next line" })
map("n", "\\", ":let @/=''<CR>:noh<CR>", {
	silent = true,
	desc = "window: Clean highlight",
})
map("n", ";", ":", { silent = false, desc = "command: Enter command mode" })
map("n", ";;", ";", { silent = false, desc = "normal: Enter Ex mode" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "edit: Move this line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "edit: Move this line up" })
map("v", "<", "<gv", { desc = "edit: Decrease indent" })
map("v", ">", ">gv", { desc = "edit: Increase indent" })
map(
	"c",
	"W!!",
	"execute 'silent! write !sudo tee % >/dev/null' <bar> edit!",
	{ desc = "edit: Save file using sudo" }
)
map("n", "<C-h>", "<C-w>h", { desc = "window: Focus left" })
map("n", "<C-l>", "<C-w>l", { desc = "window: Focus right" })
map("n", "<C-j>", "<C-w>j", { desc = "window: Focus down" })
map("n", "<C-k>", "<C-w>k", { desc = "window: Focus up" })
map("n", "<LocalLeader>|", "<C-w>|", { desc = "window: Maxout width" })
map("n", "<LocalLeader>-", "<C-w>_", { desc = "window: Maxout width" })
map("n", "<LocalLeader>=", "<C-w>=", { desc = "window: Equal size" })
map("n", "<Leader>qq", "<cmd>wqa<cr>", { desc = "editor: write quit all" })
map("n", "<Leader>.", "<cmd>bnext<cr>", {
	desc = "buffer: next",
})
map("n", "<Leader>,", "<cmd>bprevious<cr>", {
	desc = "buffer: previous",
})
map("n", "<Leader>q", "<cmd>copen<cr>", {
	desc = "quickfix: Open quickfix",
})
map("n", "<Leader>l", "<cmd>lopen<cr>", {
	desc = "quickfix: Open location list",
})
map("n", "<Leader>n", "<cmd>enew<cr>", { desc = "buffer: new" })
map("n", "<LocalLeader>sw", "<C-w>r", { desc = "window: swap position" })
map("n", "<LocalLeader>vs", "<C-w>v", { desc = "edit: split window vertically" })
map("n", "<LocalLeader>hs", "<C-w>s", { desc = "edit: split window horizontally" })
map(
	"n",
	"<LocalLeader>cd",
	":lcd %:p:h<cr>",
	{ desc = "misc: change directory to current file buffer" }
)
map(
	"n",
	"<LocalLeader>l",
	"<cmd>set list! list?<cr>",
	{ silent = false, desc = "misc: toggle invisible characters" }
)
map(
	"n",
	"<LocalLeader>]",
	string.format("<cmd>vertical resize -%s<cr>", 10),
	{ noremap = false, desc = "windows: resize right 10px" }
)
map(
	"n",
	"<LocalLeader>[",
	string.format("<cmd>vertical resize +%s<cr>", 10),
	{ noremap = false, desc = "windows: resize left 10px" }
)
map(
	"n",
	"<LocalLeader>-",
	string.format("<cmd>resize -%s<cr>", 10),
	{ noremap = false, desc = "windows: resize down 10px" }
)
map(
	"n",
	"<LocalLeader>+",
	string.format("<cmd>resize +%s<cr>", 10),
	{ noremap = false, desc = "windows: resize up 10px" }
)
map("n", "<LocalLeader>p", "<cmd>Lazy<cr>", {
	desc = "package: show manager",
})
map(
	"n",
	"<C-\\>",
	"<cmd>execute v:count . 'ToggleTerm direction=horizontal'<cr>",
	{ desc = "terminal: Toggle horizontal" }
)
map(
	"i",
	"<C-\\>",
	"<Esc><cmd>ToggleTerm direction=horizontal<cr>",
	{ desc = "terminal: Toggle horizontal" }
)
map("t", "<C-\\>", "<Esc><cmd>ToggleTerm<cr>", {
	desc = "terminal: Toggle horizontal",
})
map(
	"n",
	"<C-t>",
	"<cmd>execute v:count . 'ToggleTerm direction=vertical'<cr>",
	{ desc = "terminal: Toggle vertical" }
)
map(
	"i",
	"<C-t>",
	"<Esc><cmd>ToggleTerm direction=vertical<cr>",
	{ desc = "terminal: Toggle vertical" }
)
map("t", "<C-t>", "<Esc><cmd>ToggleTerm<cr>", {
	desc = "terminal: Toggle vertical",
})

-- NOTE: compatible block with vscode
if vim.g.vscode then return end

-- NOTE: augroup la autocmd setup
local augroup_name = function(name) return "simple_" .. name end
local augroup = function(name) return api.nvim_create_augroup(augroup_name(name), { clear = true }) end

-- auto place to last edit
autocmd("BufReadPost", {
	group = augroup "last_edit",
	pattern = "*",
	command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif]],
})

-- close some filetypes with <q>
autocmd("FileType", {
	group = augroup "filetype",
	pattern = {
		"qf",
		"help",
		"man",
		"nowrite", -- fugitive
		"prompt",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neorepl",
		"alpha",
		"toggleterm",
		"health",
		"PlenaryTestPopup",
		"nofile",
		"scratch",
		"",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<cmd>close<cr>", { silent = true })
	end,
})

-- Makes switching between buffer and termmode feels like normal mode
autocmd("TermOpen", {
	group = augroup "term",
	pattern = "term://*",
	callback = function(_)
		local opts = { noremap = true, silent = true }
		api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
	end,
})

-- Force write shada on leaving nvim
autocmd("VimLeave", {
	group = augroup "write_shada",
	pattern = "*",
	callback = function(_)
		if vim.fn.has "nvim" == 1 then
			api.nvim_command [[wshada]]
		else
			api.nvim_command [[wviminfo!]]
		end
	end,
})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup "checktime",
	pattern = "*",
	command = "checktime",
})
autocmd("VimResized", { group = augroup "resized", command = "tabdo wincmd =" })

-- Set noundofile for temporary files
autocmd("BufWritePre", {
	group = augroup "tempfile",
	pattern = { "/tmp/*", "*.tmp", "*.bak" },
	command = "setlocal noundofile",
})
-- set filetype for header files
autocmd({ "BufNewFile", "BufRead" }, {
	group = augroup "cpp_headers",
	pattern = { "*.h", "*.hpp", "*.hxx", "*.hh" },
	command = "setlocal filetype=c",
})

-- set filetype for dockerfile
autocmd({ "BufNewFile", "BufRead", "FileType" }, {
	group = augroup "dockerfile",
	pattern = { "*.dockerfile", "Dockerfile-*", "Dockerfile.*", "Dockerfile.template" },
	command = "setlocal filetype=dockerfile",
})

-- Set mapping for switching header and source file
autocmd("FileType", {
	group = augroup "cpp",
	pattern = "c,cpp",
	callback = function(event)
		api.nvim_buf_set_keymap(
			event.buf,
			"n",
			"<Leader><Leader>h",
			":ClangdSwitchSourceHeaderVSplit<CR>",
			{ noremap = true }
		)
		api.nvim_buf_set_keymap(
			event.buf,
			"n",
			"<Leader><Leader>v",
			":ClangdSwitchSourceHeaderSplit<CR>",
			{ noremap = true }
		)
		api.nvim_buf_set_keymap(
			event.buf,
			"n",
			"<Leader><Leader>oh",
			":ClangdSwitchSourceHeader<CR>",
			{ noremap = true }
		)
	end,
})

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup "highlight_yank",
	pattern = "*",
	callback = function(_) vim.highlight.on_yank { higroup = "IncSearch", timeout = 100 } end,
})

-- NOTE: vim options
if vim.loop.os_uname().sysname == "Darwin" then
	vim.g.clipboard = {
		name = "macOS-clipboard",
		copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
		paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
		cache_enabled = 0,
	}
end

-- bootstrap logics
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	}
end
vim.opt.runtimepath:prepend(lazypath)

local load_textobjects = true

require("lazy").setup({
	-- NOTE: utilities
	"lewis6991/impatient.nvim",
	"nvim-lua/plenary.nvim",
	"jghauser/mkdir.nvim",
	"nvim-tree/nvim-web-devicons",
	{ "dstein64/vim-startuptime", cmd = "StartupTime" },
	{
		"stevearc/dressing.nvim",
		opts = {
			input = {
				enabled = true,
				override = function(config)
					return vim.tbl_deep_extend("force", config, { col = -1, row = 0 })
				end,
			},
			select = { enabled = true, backend = "telescope", trim_prompt = true },
		},
		init = function()
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load { plugins = { "dressing.nvim" } }
				return vim.ui.select(...)
			end
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.input = function(...)
				require("lazy").load { plugins = { "dressing.nvim" } }
				return vim.ui.input(...)
			end
		end,
		config = true,
	},
	-- NOTE: cozy colorscheme
	{
		"rose-pine/neovim",
		name = "rose-pine",
		lazy = false,
		opts = {
			disable_italics = true,
			dark_variant = "main",
			highlight_groups = {
				Comment = { fg = "muted", italic = true },
				StatusLine = { fg = "rose", bg = "iris", blend = 10 },
				StatusLineNC = { fg = "subtle", bg = "surface" },
				TelescopeBorder = { fg = "highlight_high" },
				TelescopeNormal = { fg = "subtle" },
				TelescopePromptNormal = { fg = "text" },
				TelescopeSelection = { fg = "text" },
				TelescopeSelectionCaret = { fg = "iris" },
			},
		},
	},
	-- NOTE: exit fast af
	{
		"max397574/better-escape.nvim",
		event = "InsertEnter",
		opts = { timeout = 200, clear_empty_lines = true, keys = "<Esc>" },
	},
	-- NOTE: treesitter-based dependencies
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-textobjects",
				init = function()
					-- disable rtp plugin, as we only need its queries for mini.ai
					-- In case other textobject modules are enabled, we will load them
					-- once nvim-treesitter is loaded
					require("lazy.core.loader").disable_rtp_plugin "nvim-treesitter-textobjects"
					load_textobjects = true
				end,
			},
			"windwp/nvim-ts-autotag",
		},
		cmd = { "TSUpdateSync" },
		keys = {
			{ "<c-space>", desc = "Increment selection" },
			{ "<bs>", desc = "Decrement selection", mode = "x" },
		},
		opts = {
			ensure_installed = {
				"python",
				"rust",
				"lua",
				"c",
				"cpp",
				"toml",
				"bash",
				"css",
				"vim",
				"regex",
				"markdown",
				"markdown_inline",
				"yaml",
				"go",
				"typescript",
				"tsx",
				"zig",
				"query",
				"luap",
				"luadoc",
				"javascript",
			},
			ignore_install = { "phpdoc" },
			indent = { enable = true },
			highlight = { enable = true },
			autotag = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-a>",
					node_incremental = "<C-a>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
		},
		config = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				---@type table<string, boolean>
				local added = {}
				opts.ensure_installed = vim.tbl_filter(function(lang)
					if added[lang] then return false end
					added[lang] = true
					return true
				end, opts.ensure_installed)
			end
			require("nvim-treesitter.configs").setup(opts)

			if load_textobjects then
				-- PERF: no need to load the plugin, if we only need its queries for mini.ai
				if opts.textobjects then
					for _, mod in ipairs { "move", "select", "swap", "lsp_interop" } do
						if opts.textobjects[mod] and opts.textobjects[mod].enable then
							local Loader = require "lazy.core.loader"
							Loader.disabled_rtp_plugins["nvim-treesitter-textobjects"] = nil
							local plugin =
								require("lazy.core.config").plugins["nvim-treesitter-textobjects"]
							require("lazy.core.loader").source_runtime(plugin.dir, "plugin")
							break
						end
					end
				end
			end
		end,
	},
	-- NOTE: comments, you say what?
	{
		"numToStr/Comment.nvim",
		lazy = true,
		event = "BufReadPost",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = true,
	},
	-- NOTE: mini libraries of deps because it is light and easy to use.
	{
		"echasnovski/mini.bufremove",
		keys = {
			{
				"<C-x>",
				function() require("mini.bufremove").delete(0, false) end,
				desc = "buf: delete",
			},
			{
				"<C-q>",
				function() require("mini.bufremove").delete(0, true) end,
				desc = "buf: force delete",
			},
		},
	},
	{
		-- better text-objects
		"echasnovski/mini.ai",
		event = "InsertEnter",
		dependencies = { "nvim-treesitter-textobjects" },
		opts = function()
			local ai = require "mini.ai"
			return {
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}, {}),
					f = ai.gen_spec.treesitter(
						{ a = "@function.outer", i = "@function.inner" },
						{}
					),
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
				},
			}
		end,
		config = function(_, opts)
			require("mini.ai").setup(opts)
			utils.on_load("which-key.nvim", function()
				---@type table<string, string|table>
				local i = {
					[" "] = "Whitespace",
					['"'] = 'Balanced "',
					["'"] = "Balanced '",
					["`"] = "Balanced `",
					["("] = "Balanced (",
					[")"] = "Balanced ) including white-space",
					[">"] = "Balanced > including white-space",
					["<lt>"] = "Balanced <",
					["]"] = "Balanced ] including white-space",
					["["] = "Balanced [",
					["}"] = "Balanced } including white-space",
					["{"] = "Balanced {",
					["?"] = "User Prompt",
					_ = "Underscore",
					a = "Argument",
					b = "Balanced ), ], }",
					c = "Class",
					f = "Function",
					o = "Block, conditional, loop",
					q = "Quote `, \", '",
					t = "Tag",
				}
				local a = vim.deepcopy(i)
				for k, v in pairs(a) do
					a[k] = v:gsub(" including.*", "")
				end
				local ic = vim.deepcopy(i)
				local ac = vim.deepcopy(a)
				for key, name in pairs { n = "Next", l = "Last" } do
					i[key] =
						vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
					a[key] =
						vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
				end
				require("which-key").register {
					mode = { "o", "x" },
					i = i,
					a = a,
				}
			end)
		end,
	},
	{ "echasnovski/mini.align", event = "VeryLazy" },
	{ "echasnovski/mini.surround" },
	{ "echasnovski/mini.pairs", event = "VeryLazy", opts = {} },
	-- NOTE: better UI components
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			{ "junegunn/fzf", lazy = true, build = ":call fzf#install()" },
		},
		config = true,
	},
	{
		"folke/which-key.nvim",
		event = "BufReadPost",
		opts = { plugins = { presets = { operators = false } } },
		config = function(_, opts) require("which-key").setup(opts) end,
	},
	{
		"folke/todo-comments.nvim",
		cmd = { "TodoTrouble", "TodoTelescope" },
		event = { "BufReadPost", "BufNewFile" },
		config = true,
		keys = {
			{
				"]t",
				function() require("todo-comments").jump_next() end,
				desc = "todo: Next comment",
			},
			{
				"[t",
				function() require("todo-comments").jump_prev() end,
				desc = "todo: Previous comment",
			},
		},
	},
	-- NOTE: fuzzy finder ftw
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-telescope/telescope-live-grep-args.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		keys = {
			{
				"<Leader>b",
				"<cmd>Telescope buffers show_all_buffers=true previewer=false<cr>",
				desc = "telescope: Manage buffers",
			},
			{ "<leader>B", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>;", "<cmd>Telescope command_history<cr>", desc = "Command History" },
			{
				"<leader>f",
				utils.telescope("files", { theme = "dropdown" }),
				desc = "Find Files (root dir)",
			},
			{ "<leader>r", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
			{
				"<leader>fR",
				utils.telescope("oldfiles", { cwd = vim.loop.cwd() }),
				desc = "Recent (cwd)",
			},
			-- search
			{ '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
			{
				"<leader>sa",
				"<cmd>Telescope autocommands<cr>",
				desc = "Auto Commands",
			},
			{ "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
			{
				"<leader>sc",
				"<cmd>Telescope command_history<cr>",
				desc = "Command History",
			},
			{ "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
			{
				"<leader>sd",
				"<cmd>Telescope diagnostics bufnr=0<cr>",
				desc = "Document diagnostics",
			},
			{
				"<leader>sD",
				"<cmd>Telescope diagnostics<cr>",
				desc = "Workspace diagnostics",
			},
			{
				"<leader>sg",
				utils.telescope "live_grep",
				desc = "Grep (root dir)",
			},
			{ "<leader>sG", utils.telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
			{ "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
			{
				"<leader>H",
				"<cmd>Telescope highlights<cr>",
				desc = "Search Highlight Groups",
			},
			{ "<leader>m", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
			{ "<leader>o", "<cmd>Telescope vim_options<cr>", desc = "Options" },
			{ "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
			{
				"<leader>/",
				utils.telescope("grep_string", { word_match = "-w" }),
				desc = "Word (root dir)",
			},
			{
				"<leader>/",
				utils.telescope "grep_string",
				mode = "v",
				desc = "Selection (root dir)",
			},
			{
				"<leader>?",
				utils.telescope("grep_string", { cwd = false, word_match = "-w" }),
				desc = "Word (cwd)",
			},
			{
				"<leader>sW",
				utils.telescope("grep_string", { cwd = false }),
				mode = "v",
				desc = "Selection (cwd)",
			},
			{
				"<Leader>w",
				function() require("telescope").extensions.live_grep_args.live_grep_args() end,
				desc = "telescope: Live grep args",
				noremap = true,
				silent = true,
			},
			{
				"<C-p>",
				function()
					require("telescope.builtin").keymaps {
						lhs_filter = function(lhs) return not string.find(lhs, "Þ") end,
						layout_config = {
							width = 0.6,
							height = 0.6,
							prompt_position = "top",
						},
					}
				end,
				desc = "telescope: Keymaps",
				noremap = true,
				silent = true,
			},
			{
				"gI",
				function() util.telescope("lsp_implementations", { reuse_win = true }) end,
				desc = "lsp: Goto Implementation",
			},
			{
				"gy",
				function() util.telescope("lsp_type_definitions", { reuse_win = true }) end,
				desc = "lsp: Goto T[y]pe Definition",
			},
		},
		opts = {
			defaults = {
				vimgrep_arguments = {
					"rg",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
				},
				prompt_prefix = "  ",
				selection_caret = "󰄾 ",
				file_ignore_patterns = {
					".git/",
					"node_modules/",
					"static_content/",
					"lazy-lock.json",
					"pdm.lock",
					"__pycache__",
				},
				mappings = {
					i = {
						["<C-a>"] = { "<esc>0i", type = "command" },
						["<Esc>"] = function(...) return require("telescope.actions").close(...) end,
						["<a-i>"] = function()
							local action_state = require "telescope.actions.state"
							local line = action_state.get_current_line()
							utils.telescope("find_files", { no_ignore = true, default_text = line })()
						end,
						["<a-h>"] = function()
							local action_state = require "telescope.actions.state"
							local line = action_state.get_current_line()
							utils.telescope("find_files", { hidden = true, default_text = line })()
						end,
						["<C-Down>"] = function(...)
							return require("telescope.actions").cycle_history_next(...)
						end,
						["<C-Up>"] = function(...)
							return require("telescope.actions").cycle_history_prev(...)
						end,
						["<C-f>"] = function(...)
							return require("telescope.actions").preview_scrolling_down(...)
						end,
						["<C-b>"] = function(...)
							return require("telescope.actions").preview_scrolling_up(...)
						end,
					},
					n = { ["q"] = function(...) return require("telescope.actions").close(...) end },
				},
				layout_config = { width = 0.8, height = 0.8, prompt_position = "top" },
				selection_strategy = "reset",
				sorting_strategy = "ascending",
				color_devicons = true,
			},
			extensions = {
				live_grep_args = {
					auto_quoting = false,
					mappings = {
						i = {
							["<C-k>"] = function(...)
								return require("telescope-live-grep-args.actions").quote_prompt()
							end,
							["<C-i>"] = function(...)
								return require("telescope-live-grep-args.actions").quote_prompt {
									postfix = " --iglob ",
								}
							end,
							["<C-j>"] = function(...)
								return require("telescope-live-grep-args.actions").quote_prompt {
									postfix = " -t ",
								}
							end,
						},
					},
				},
			},
			fzf = {
				fuzzy = false, -- false will only do exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			},
			pickers = {
				find_files = { hidden = true },
				live_grep = {
					on_input_filter_cb = function(prompt)
						-- AND operator for live_grep like how fzf handles spaces with wildcards in rg
						return { prompt = prompt:gsub("%s", ".*") }
					end,
					attach_mappings = function(_)
						require("telescope.actions.set").select:enhance {
							post = function() vim.cmd ":normal! zx" end,
						}
						return true
					end,
				},
			},
		},
		config = function(_, opts)
			require("telescope").setup(opts)
			require("telescope").load_extension "live_grep_args"
		end,
	},
	-- NOTE: better nvim-tree.lua
	{
		"nvim-neo-tree/neo-tree.nvim",
		cmd = "Neotree",
		dependencies = {
			{ "MunifTanjim/nui.nvim", lazy = true },
			"nvim-lua/plenary.nvim",
			{
				"s1n7ax/nvim-window-picker",
				lazy = true,
				opts = {
					autoselect_one = true,
					include_current = false,
					filter_rules = {
						-- filter using buffer options
						bo = {
							-- if the file type is one of following, the window will be ignored
							filetype = { "neo-tree", "neo-tree-popup", "notify" },
							-- if the buffer type is one of following, the window will be ignored
							buftype = { "terminal", "quickfix", "Scratch" },
						},
					},
				},
				config = function(_, opts) require("window-picker").setup(opts) end,
			},
		},
		keys = {
			{
				"<C-n>",
				function()
					require("neo-tree.command").execute { toggle = true, dir = vim.loop.cwd() }
				end,
				desc = "explorer: root dir",
			},
		},
		opts = {
			close_if_last_window = true,
			enable_diagnostics = false, -- default is set to true here.
			filesystem = {
				bind_to_cwd = true,
				use_libuv_file_watcher = true, -- use system level watcher for file change
				follow_current_file = { enabled = true },
				filtered_items = {
					visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
					hide_dotfiles = false,
					hide_gitignored = true,
					hide_by_name = {
						"node_modules",
						"pdm.lock",
					},
					hide_by_pattern = { -- uses glob style patterns
						"*.meta",
						"*/src/*/tsconfig.json",
						"*/.ruff_cache/*",
						"*/__pycache__/*",
					},
				},
			},
			event_handlers = {
				{
					event = "neo_tree_window_after_open",
					handler = function(args)
						if args.position == "left" or args.position == "right" then
							vim.cmd "wincmd ="
						end
					end,
				},
				{
					event = "neo_tree_window_after_close",
					handler = function(args)
						if args.position == "left" or args.position == "right" then
							vim.cmd "wincmd ="
						end
					end,
				},
				-- disable last status on neo-tree
				-- If I use laststatus, then uncomment this
				{
					event = "neo_tree_buffer_enter",
					handler = function() vim.opt_local.laststatus = 0 end,
				},
				{
					event = "neo_tree_buffer_leave",
					handler = function() vim.opt_local.laststatus = 2 end,
				},
			},
			always_show = { ".github" },
			window = {
				mappings = {
					["<space>"] = "none", -- disable space since it is leader
					["s"] = "split_with_window_picker",
					["v"] = "vsplit_with_window_picker",
				},
			},
			default_component_configs = {
				indent = {
					with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
			},
		},
	},
	-- NOTE: spectre for magic search and replace
	{
		"nvim-pack/nvim-spectre",
		event = "BufReadPost",
		keys = {
			{
				"<Leader>so",
				function() require("spectre").open() end,
				desc = "replace: Open panel",
			},
			{
				"<Leader>so",
				function() require("spectre").open_visual() end,
				desc = "replace: Open panel",
				mode = "v",
			},
			{
				"<Leader>sw",
				function() require("spectre").open_visual { select_word = true } end,
				desc = "replace: Replace word under cursor",
			},
			{
				"<Leader>sp",
				function() require("spectre").open_file_search() end,
				desc = "replace: Replace word under file search",
			},
		},
		opts = {
			live_update = true,
			mapping = {
				["change_replace_sed"] = {
					map = "<LocalLeader>trs",
					cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
					desc = "replace: Using sed",
				},
				["change_replace_oxi"] = {
					map = "<LocalLeader>tro",
					cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
					desc = "replace: Using oxi",
				},
				["toggle_live_update"] = {
					map = "<LocalLeader>tu",
					cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
					desc = "replace: update live changes",
				},
				-- only work if the find_engine following have that option
				["toggle_ignore_case"] = {
					map = "<LocalLeader>ti",
					cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
					desc = "replace: toggle ignore case",
				},
				["toggle_ignore_hidden"] = {
					map = "<LocalLeader>th",
					cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
					desc = "replace: toggle search hidden",
				},
			},
		},
	},
	-- NOTE: nice winbar
	{
		"Bekaboo/dropbar.nvim",
		config = true,
		enabled = vim.fn.has "nvim-0.9.0" == 0,
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			icons = {
				enable = true,
				ui = {
					bar = { separator = "  ", extends = "…" },
					menu = { separator = " ", indicator = "  " },
				},
			},
		},
	},
}, {
	install = { colorscheme = { colorscheme } },
	defaults = { lazy = true },
	change_detection = { notify = false },
	concurrency = vim.loop.os_uname() == "Darwin" and 30 or nil,
	checker = { enable = true },
	ui = { border = "none" },
	performance = {
		rtp = {
			disabled_plugins = {
				"2html_plugin",
				"getscript",
				"getscriptPlugin",
				"gzip",
				"netrw",
				"netrwPlugin",
				"netrwSettings",
				"netrwFileHandlers",
				"matchit",
				"matchparen",
				"tar",
				"tarPlugin",
				"tohtml",
				"spellfile_plugin",
				"vimball",
				"vimballPlugin",
				"zip",
				"zipPlugin",
			},
		},
	},
})

vim.o.background = "light"
vim.cmd.colorscheme("rose-pine")
