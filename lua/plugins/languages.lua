return {
	-- Setup language servers.
	-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
	{ "fatih/vim-go", lazy = true, ft = "go", run = ":GoInstallBinaries" },
	{ "simrat39/rust-tools.nvim", lazy = true, ft = { "rs", "rust" } },
	{ "folke/neodev.nvim", lazy = true, ft = "lua" },
	{ "p00f/clangd_extensions.nvim", lazy = true, ft = { "c", "cpp", "hpp", "h" } },
	{
		"bazelbuild/vim-bazel",
		lazy = true,
		cmd = "Bazel",
		dependencies = { "google/vim-maktaba" },
		ft = { "bzl", "bazel", "bzlmod" },
	},
	{
		"lervag/vimtex",
		lazy = true,
		ft = "tex",
		config = function()
			vim.g.vimtex_view_method = "zathura"
			if vim.loop.os_uname().sysname == "Darwin" then
				vim.g.vimtex_view_method = "skim"
				vim.g.vimtex_view_general_viewer =
					"/Applications/Skim.app/Contents/SharedSupport/displayline"
				vim.g.vimtex_view_general_options = "-r @line @pdf @tex"
			end

			vim.api.nvim_create_autocmd("User", {
				group = vim.api.nvim_create_augroup("vimtext_mac", { clear = true }),
				pattern = "VimtexEventCompileSuccess",
				callback = function(_)
					---@diagnostic disable-next-line: undefined-field
					local out = vim.b.vimtex.out()
					local src_file_path = vim.fn.expand "%:p"
					local cmd = { vim.g.vimtex_view_general_viewer, "-r" }

					if vim.fn.empty(vim.fn.system "pgrep Skim") == 0 then
						table.insert(cmd, "-g")
					end

					vim.fn.jobstart(vim.list_extend(cmd, { vim.fn.line ".", out, src_file_path }))
				end,
			})
		end,
	},
	{
		"ii14/neorepl.nvim",
		lazy = true,
		ft = "lua",
		keys = {
			{
				"<LocalLeader>or",
				function()
					-- get current buffer and window
					local buf = vim.api.nvim_get_current_buf()
					local win = vim.api.nvim_get_current_win()
					-- create a new split for the repl
					vim.cmd "split"
					-- spawn repl and set the context to our buffer
					require("neorepl").new { lang = "lua", buffer = buf, window = win }
					-- resize repl window and make it fixed height
					vim.cmd "resize 10 | setl winfixheight"
				end,
				desc = "repl: Open lua repl",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		dependencies = {
			{ "williamboman/mason-lspconfig.nvim" },
			{ "williamboman/mason.nvim", cmd = "Mason" },
			{
				"simrat39/inlay-hints.nvim",
				lazy = true,
				opts = {
					parameter = { show = true },
					renderer = "inlay-hints.render.eol",
					only_current_line = true,
					eol = { parameter = { separator = "," } },
				},
			},
			{
				"jose-elias-alvarez/null-ls.nvim",
				dependencies = { "nvim-lua/plenary.nvim", "jay-babu/mason-null-ls.nvim" },
			},
			{
				"glepnir/lspsaga.nvim",
				branch = "main",
				events = "BufReadPost",
				dependencies = { "nvim-tree/nvim-web-devicons", "nvim-treesitter/nvim-treesitter" },
				opts = {
					finder = { keys = { jump_to = "e" } },
					lightbulb = { enable = false },
					diagnostic = { keys = { exec_action = "<CR>" } },
					definition = { split = "<C-c>s" },
					beacon = { enable = false },
					outline = {
						win_width = math.floor(vim.o.columns * 0.2),
						with_position = "left",
						keys = { jump = "<CR>" },
					},
					code_actions = { extend_gitsigns = false },
					symbol_in_winbar = {
						enable = false,
						respect_root = true,
						separator = " " .. require("zox").ui_space.Separator,
						show_file = false,
					},
					callhierarchy = { show_detail = true },
				},
			},
		},
		config = function()
			local nvim_lsp = require "lspconfig"
			local mason = require "mason"

			require("lspconfig.ui.windows").default_options.border = "single"

			mason.setup {}
			require("mason-lspconfig").setup {
				ensure_installed = {
					"bashls",
					"bufls",
					"clangd",
					"dockerls",
					"gopls",
					"lua_ls",
					"marksman",
					"denols",
					"html",
					"jdtls",
					"jsonls",
					"pyright",
					"rnix",
					"ruff_lsp",
					"rust_analyzer",
					"spectral",
					"taplo",
					"tflint",
					"tsserver",
					"vimls",
					"yamlls",
				},
				automatic_installation = true,
			}

			local disabled_workspaces = {}
			local format_on_save = true

			-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins
			local f = require("null-ls").builtins.formatting
			local d = require("null-ls").builtins.diagnostics
			local ca = require("null-ls").builtins.code_actions

			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

			require("null-ls").setup {
				update_in_insert = false,
				diagnostics_format = "[#{c}] #{m} (#{s})",
				sources = {
					-- NOTE: formatting
					f.prettierd.with {
						extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
						extra_filetypes = { "jsonc", "astro", "svelte" },
					},
					f.shfmt.with { extra_args = { "-i", 4, "-ci", "-sr" } },
					f.clang_format,
					f.black,
					f.ruff,
					f.isort,
					f.stylua,
					f.markdownlint,
					f.cbfmt,
					f.beautysh,
					f.rustfmt,
					f.jq,
					f.buf,
					f.buildifier,
					-- NOTE: format with 4 spaces
					f.taplo.with {
						extra_args = { "fmt", "-o", "indent_string='" .. string.rep(" ", 4) .. "'" },
					},
					f.deno_fmt,

					-- NOTE: diagnostics
					d.clang_check,
					d.eslint_d,
					d.ruff,
					d.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
					d.selene,
					d.golangci_lint,
					d.markdownlint.with { extra_args = { "--disable MD033" } },
					d.zsh,
					d.buf,
					d.pydocstyle,
					d.buildifier,
					d.yamllint,
					d.vulture,
					d.vint,

					-- NOTE: code actions
					ca.gitrebase,
					ca.shellcheck,
				},
				on_attach = function(client, bufnr)
					local cwd = vim.fn.getcwd()
					for i = 1, #disabled_workspaces do
						if cwd.find(cwd, disabled_workspaces[i]) ~= nil then return end
					end
					if client.supports_method "textDocument/formatting" and format_on_save then
						vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function() vim.lsp.buf.format { bufnr = bufnr } end,
						})
					end
				end,
			}
			require("mason-null-ls").setup {
				ensure_installed = nil,
				automatic_installation = true,
				automatic_setup = false,
			}

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if ok then capabilities = cmp_nvim_lsp.default_capabilities(capabilities) end
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			local ih = require "inlay-hints"
			local on_attach_factory = function(use_server_formatting_provider)
				return function(client, bufnr)
					--- NOTE: Avoid LSP formatting, since it will be handled by null-ls
					if not use_server_formatting_provider then
						client.server_capabilities.documentFormattingProvider = false
						client.server_capabilities.documentRangeFormattingProvider = false
					end

					local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

					-- Enable completion triggered by <c-x><c-o>
					buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
				end
			end

			local options = {
				on_attach = on_attach_factory(false),
				capabilities = capabilities,
				flags = { debounce_text_changes = 150 },
			}

			--- A small wrapper to setup lsp with nvim-lspconfig
			--- Supports inlay-hints with `ih.on_attach`
			---@overload fun(lsp_name: string, enable_inlay_hints?: boolean): fun():nil
			---@overload fun(lsp_name: string): fun():nil
			local mason_handler = function(
				lsp_name,
				enable_inlay_hints,
				use_server_formatting_provider
			)
				use_server_formatting_provider = use_server_formatting_provider or false
				if use_server_formatting_provider then
					options.on_attach = on_attach_factory(true)
				end

				enable_inlay_hints = enable_inlay_hints or false
				if enable_inlay_hints then
					options.on_attach = function(client, bufnr)
						ih.on_attach(client, bufnr)
						on_attach_factory(false)(client, bufnr)
					end
				end

				return function()
					---@param path string path to given directory containing lua files.
					---@return string[] list of files in given directory
					local available = function(path)
						return require("zox.utils").map(
							vim.split(vim.fn.glob(path .. "/*.lua"), "\n"),
							function(_) return _:sub(#path + 2, -5) end
						)
					end

					if
						not vim.tbl_contains(
							available(
								require("zox.utils").path.join(
									vim.fn.stdpath "config",
									"lua",
									"zox",
									"servers"
								)
							),
							lsp_name
						)
					then
						--- NOTE: default to nvim-lspconfig for servers
						--- that doesn't include a configuration setup.
						nvim_lsp[lsp_name].setup(options)
						return
					end

					local lspconfig = require("zox").servers[lsp_name]
					if type(lspconfig) == "function" then
						--- This is the case where the language server has its own setup
						--- e.g. clangd_extensions, lua_ls, rust_analyzer
						lspconfig(options)
					elseif type(lspconfig) == "table" then
						nvim_lsp[lsp_name].setup(vim.tbl_extend("force", options, lspconfig))
					else
						error(
							string.format(
								"Failed to setup '%s'. Server defined "
									.. "under zox/servers must return either a "
									.. "function(opts) or a table. Got type '%s' instead.",
								lsp_name,
								type(lspconfig)
							),
							vim.log.levels.ERROR
						)
					end
				end
			end

			require("mason-lspconfig").setup_handlers {
				function(client_name)
					ok, _ = pcall(mason_handler(client_name))
					if not ok then
						error(
							string.format("Failed to setup lspconfig for %s", client_name),
							vim.log.levels.ERROR
						)
					end
				end,
				gopls = mason_handler("gopls", true),
				lua_ls = mason_handler("lua_ls", true),
				tsserver = mason_handler("tsserver", true),
				marksman = mason_handler("marksman", false, false),
			}

			mason_handler "starlark_rust"
		end,
	},

	-- Setup completions.
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				lazy = true,
				dependencies = { "rafamadriz/friendly-snippets" },
				config = function()
					require("luasnip").config.set_config {
						history = true,
						updateevents = "TextChanged,TextChangedI",
						delete_check_events = "TextChanged,InsertLeave",
					}
					require("luasnip.loaders.from_lua").lazy_load()
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},
			{ "onsails/lspkind.nvim" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "lukas-reineke/cmp-under-comparator" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-buffer" },
			{
				"petertriho/cmp-git",
				dependencies = { "nvim-lua/plenary.nvim" },
				config = true,
				opts = { filetypes = { "gitcommit", "octo", "neogitCommitMessage" } },
			},
			{
				"saecki/crates.nvim",
				event = { "BufRead Cargo.toml" },
				opts = { popup = { border = "rounded" } },
			},
			{
				"zbirenbaum/copilot.lua",
				cmd = "Copilot",
				event = "InsertEnter",
				config = function()
					vim.defer_fn(
						function()
							require("copilot").setup {
								panel = { enabled = false },
								suggestion = {
									enabled = true,
									auto_trigger = true,
								},
								filetypes = {
									help = false,
									markdown = true,
									terraform = false,
									gitcommit = false,
									gitrebase = false,
									hgcommit = false,
									svn = false,
									cvs = false,
									["octo"] = false,
									["TelescopePrompt"] = false,
									["dap-repl"] = false,
									["big_file_disabled_ft"] = false,
									["neogitCommitMessage"] = false,
									["gitcommit"] = false,
								},
							}
						end,
						100
					)
				end,
			},
		},
		config = function()
			local lspkind = require "lspkind"
			local cmp = require "cmp"

			local cmp_window = require "cmp.utils.window"
			local k = require "zox.keybind"

			local prev_info = cmp_window.info
			---@diagnostic disable-next-line: duplicate-set-field
			cmp_window.info = function(self)
				local info = prev_info(self)
				info.scrollable = false
				return info
			end

			local compare = require "cmp.config.compare"
			compare.lsp_scores = function(entry1, entry2)
				local diff
				if entry1.completion_item.score and entry2.completion_item.score then
					diff = (entry2.completion_item.score * entry2.score)
						- (entry1.completion_item.score * entry1.score)
				else
					diff = entry2.score - entry1.score
				end
				return (diff < 0)
			end

			local has_words_before = function()
				if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api
							.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]
							:match "^%s*$"
						== nil
			end

			local check_backspace = function()
				local col = vim.fn.col "." - 1
				return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
			end

			cmp.setup {
				preselect = cmp.PreselectMode.None,
				snippet = {
					expand = function(args) require("luasnip").lsp_expand(args.body) end,
				},
				sorting = {
					priority_weight = 2,
					comparators = {
						compare.offset,
						compare.exact,
						compare.lsp_scores,
						require("cmp-under-comparator").under,
						compare.kind,
						compare.sort_text,
						compare.length,
						compare.order,
					},
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						local kind = lspkind.cmp_format {
							mode = "symbol_text",
							maxwidth = 50,
						}(entry, vim_item)
						local strings = vim.split(kind.kind, "%s", { trimempty = true })
						kind.kind = " " .. strings[1] .. " "
						kind.menu = "    (" .. strings[2] .. ")"
						return kind
					end,
				},
				mapping = cmp.mapping.preset.insert {
					["<CR>"] = cmp.mapping.confirm {
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					},
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<Tab>"] = function(fallback)
						if require("copilot.suggestion").is_visible() then
							require("copilot.suggestion").accept()
						elseif cmp.visible() then
							cmp.select_next_item()
						elseif require("luasnip").expand_or_jumpable() then
							vim.fn.feedkeys(k.replace_termcodes "<Plug>luasnip-expand-or-jump", "")
						elseif check_backspace() then
							vim.fn.feedkeys(k.replace_termcodes "<Tab>", "n")
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end,
					["<S-Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif require("luasnip").jumpable(-1) then
							vim.fn.feedkeys(k.replace_termcodes "<Plug>luasnip-jump-prev", "")
						elseif require("utils").has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end,
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "path" },
					{ name = "luasnip" },
					{ name = "nvim-lua" },
					{ name = "crates" },
					{ name = "buffer" },
					{ name = "git" },
				},
				window = {
					completion = cmp.config.window.bordered { border = "single" },
					documentation = cmp.config.window.bordered { border = "single" },
				},
				experimental = { ghost_text = { hl_group = "LspCodeLens" } },
			}
		end,
	},
}
