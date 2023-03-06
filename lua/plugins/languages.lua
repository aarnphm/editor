return {
	-- Setup language servers.
	-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
	{ "fatih/vim-go", lazy = true, ft = "go", run = ":GoInstallBinaries" },
	{ "simrat39/rust-tools.nvim", lazy = true, ft = { "rs", "rust" } },
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		opts = { popup = { border = "rounded" } },
	},
	{ "p00f/clangd_extensions.nvim", lazy = true, ft = { "c", "cpp", "hpp", "h" } },
	{
		"bazelbuild/vim-bazel",
		lazy = true,
		cmd = "Bazel",
		dependencies = { "google/vim-maktaba" },
		ft = { "bzl", "bazel", "bzlmod" },
	},
	{ "folke/neodev.nvim", lazy = true, ft = "lua" },
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
			{ "williamboman/mason.nvim", cmd = "Mason", lazy = true },
			{
				"jose-elias-alvarez/null-ls.nvim",
				dependencies = { "nvim-lua/plenary.nvim", "jay-babu/mason-null-ls.nvim" },
			},
			{
				"glepnir/lspsaga.nvim",
				branch = "main",
				events = "BufReadPost",
				dependencies = { "nvim-tree/nvim-web-devicons", "nvim-treesitter/nvim-treesitter" },
				config = function()
					require("lspsaga").setup {
						finder = { keys = { jump_to = "e" } },
						lightbulb = { enable = false },
						diagnostic = { keys = { exec_action = "<CR>" } },
						definition = { split = "<C-c>s" },
						beacon = { enable = false },
						outline = {
							auto_preview = false,
							win_width = math.floor(vim.o.columns * 0.21),
							with_position = "left",
							keys = { jump = "<CR>" },
						},
						code_actions = { extend_gitsigns = false },
						symbol_in_winbar = {
							enable = true,
							ignore_patterns = { "%w_spec" },
							respect_root = true,
							separator = " " .. require("zox").ui_space.Separator,
							show_file = false,
						},
						callhierarchy = { show_detail = true },
					}
				end,
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
					"lua_ls",
					"marksman",
					"html",
					"jdtls",
					"jsonls",
					"pyright",
					"rnix",
					"ruff_lsp",
					"svelte",
					"cssls",
					"rust_analyzer",
					"spectral",
					"taplo",
					"tflint",
					"tsserver",
					"vimls",
					"yamlls",
					"denols",
					"gopls",
				},
				automatic_installation = true,
			}

			-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins
			local f = require("null-ls").builtins.formatting
			local d = require("null-ls").builtins.diagnostics
			local ca = require("null-ls").builtins.code_actions

			require("null-ls").setup {
				update_in_insert = false,
				diagnostics_format = "[#{c}] #{m} (#{s})",
				sources = {
					-- NOTE: formatting
					f.prettierd.with {
						extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
						extra_filetypes = { "jsonc", "astro", "svelte" },
						disabled_filetypes = { "markdown" },
					},
					f.shfmt.with { extra_args = { "-i", 4, "-ci", "-sr" } },
					f.clang_format.with {
						extra_args = { "--style", "{BasedOnStyle: LLVM, IndentWidth: 4}" },
						filetypes = { "c", "cpp", "objc", "objcpp" },
					},
					f.black,
					f.ruff,
					f.isort,
					f.stylua,
					f.cbfmt,
					f.beautysh,
					f.rustfmt,
					f.jq,
					f.buf,
					f.stylelint,
					f.eslint.with {
						extra_filetypes = { "astro", "svelte" },
					},
					f.buildifier,
					-- NOTE: format with 4 spaces
					f.taplo.with {
						extra_args = { "fmt", "-o", "indent_string='" .. string.rep(" ", 4) .. "'" },
					},
					-- NOTE: Using deno fmt for markdown
					f.deno_fmt.with {
						extra_args = { "--line-width", "80" },
					},

					-- NOTE: diagnostics
					d.clang_check,
					d.eslint.with {
						extra_filetypes = { "astro", "svelte" },
					},
					d.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
					d.selene,
					d.golangci_lint,
					d.markdownlint.with { extra_args = { "--disable MD033" } },
					d.zsh,
					d.buf,
					d.buildifier,
					d.stylelint,
					d.vulture.with { extra_args = { "--min-confidence 70" } },
					d.vint,

					-- NOTE: code actions
					ca.gitrebase,
					ca.shellcheck,
					ca.eslint.with {
						extra_filetypes = { "astro", "svelte" },
					},
				},
			}
			require("mason-null-ls").setup {
				ensure_installed = nil,
				automatic_installation = true,
				automatic_setup = false,
			}
			-- require("mason-null-ls").setup_handlers()

			require("zox.formatting").configure_format_on_save()

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if ok then capabilities = cmp_nvim_lsp.default_capabilities(capabilities) end
			capabilities.textDocument.completion.completionItem.snippetSupport = true

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

					local k = require "zox.keybind"
					k.nvim_register_mapping {
						-- lsp
						["n|K"] = k.cr("Lspsaga hover_doc")
							:with_buffer(bufnr)
							:with_defaults "lsp: Signature help",
						["n|gh"] = k.callback(vim.show_pos)
							:with_buffer(bufnr)
							:with_defaults "lsp: Show hightlight",
						["n|g["] = k.cr("Lspsaga diagnostic_jump_prev")
							:with_buffer(bufnr)
							:with_defaults "lsp: Prev diagnostic",
						["n|g]"] = k.cr("Lspsaga diagnostic_jump_next")
							:with_buffer(bufnr)
							:with_defaults "lsp: Next diagnostic",
						["n|gr"] = k.callback(vim.lsp.buf.rename)
							:with_buffer(bufnr)
							:with_defaults "lsp: Rename in file range",
						["n|gd"] = k.cr("Glance definitions")
							:with_buffer(bufnr)
							:with_defaults "lsp: Peek definition",
						["n|gD"] = k.cr("Lspsaga goto_definition")
							:with_buffer(bufnr)
							:with_defaults "lsp: Goto definition",
						["n|ca"] = k.callback(vim.lsp.buf.code_action)
							:with_buffer(bufnr)
							:with_defaults "lsp: Code action for cursor",
						["v|ca"] = k.callback(vim.lsp.buf.code_action)
							:with_buffer(bufnr)
							:with_defaults "lsp: Code action for range",
						["n|go"] = k.cr("Lspsaga outline")
							:with_buffer(bufnr)
							:with_defaults "lsp: Show outline",
						["n|gR"] = k.cr("TroubleToggle lsp_references")
							:with_buffer(bufnr)
							:with_defaults "lsp: Show references",
					}
				end
			end

			local options = {
				on_attach = on_attach_factory(false),
				capabilities = capabilities,
				flags = { debounce_text_changes = 150 },
			}

			--- A small wrapper to setup lsp with nvim-lspconfig
			--- @param lsp_name string name of given lsp server
			local mason_handler = function(lsp_name, use_server_formatting_provider)
				use_server_formatting_provider = use_server_formatting_provider or false
				options.on_attach = on_attach_factory(use_server_formatting_provider)
				local check_config = function()
					local path = require("zox.utils").path.join(
						vim.fn.stdpath "config",
						"lua",
						"zox",
						"servers"
					)
					local servers = {}
					local available_configs = vim.split(vim.fn.glob(path .. "/*.lua"), "\n")
					if type(available_configs) == "table" then
						for _, s in ipairs(available_configs) do
							servers[#servers + 1] = s:sub(#path + 2, -5)
						end
					end
					return vim.tbl_contains(servers, lsp_name)
				end

				return function()
					if not check_config() then
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
				function(lsp_name)
					ok, _ = pcall(mason_handler(lsp_name))
					if not ok then
						error(string.format("Failed to setup '%s'", lsp_name), vim.log.levels.ERROR)
					end
				end,
				taplo = mason_handler("taplo", true),
				spectral = mason_handler("spectral", true),
				yamlls = mason_handler("yamlls", true),
			}

			mason_handler "starlark_rust"
		end,
	},

	-- Setup completions.
	{
		"hrsh7th/nvim-cmp",
		lazy = true,
		event = "BufReadPost",
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
				"zbirenbaum/copilot.lua",
				cmd = "Copilot",
				event = "InsertEnter",
				config = function()
					vim.defer_fn(
						function()
							require("copilot").setup {
								panel = { enabled = false },
								suggestion = { enabled = true, auto_trigger = true },
								filetypes = {
									markdown = true,
									help = false,
									terraform = false,
									hgcommit = false,
									svn = false,
									cvs = false,
									["dap-repl"] = false,
									octo = false,
									TelescopePrompt = false,
									big_file_disabled_ft = false,
									neogitCommitMessage = false,
								},
							}
						end,
						100
					)
				end,
			},
		},
		config = function()
			local cmp = require "cmp"
			local k = require "zox.keybind"
			local lspkind = require "lspkind"

			local cmp_window = require "cmp.utils.window"
			local prev_info = cmp_window.info
			---@diagnostic disable-next-line: duplicate-set-field
			cmp_window.info = function(self)
				local info = prev_info(self)
				info.scrollable = false
				return info
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
				---@diagnostic disable-next-line: param-type-mismatch
				local current_line = vim.fn.getline "."
				---@diagnostic disable-next-line: undefined-field
				return col == 0 or current_line:sub(col, col):match "%s"
			end

			cmp.setup {
				preselect = cmp.PreselectMode.None,
				snippet = {
					expand = function(args) require("luasnip").lsp_expand(args.body) end,
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
			}
		end,
	},
}
