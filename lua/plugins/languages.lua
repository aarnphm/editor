local k = require "zox.keybind"
---@param path string path to given directory containing lua files.
---@return string[] list of files in given directory
local available = function(path)
	return require("zox.utils").map(
		vim.split(vim.fn.glob(path .. "/*.lua"), "\n"),
		function(_) return _:sub(#path + 2, -5) end
	)
end
return {
	{
		"kylechui/nvim-surround",
		lazy = false,
		config = function() require("nvim-surround").setup() end,
	},
	{
		"rafcamlet/nvim-luapad",
		lazy = true,
		ft = "lua",
		cmd = { "Luapad", "LuaRun" },
		config = function()
			require("luapad").setup {
				count_limit = 150000,
				eval_on_move = true,
				error_highlight = "WarningMsg",
			}
		end,
	},
	{
		"bazelbuild/vim-bazel",
		lazy = true,
		dependencies = { "google/vim-maktaba" },
		cmd = { "Bazel" },
		ft = "bzl",
		config = function()
			k.nvim_register_mapping {
				["n|<LocalLeader>bb"] = k.args("Bazel build"):with_defaults "bazel: build",
				["n|<LocalLeader>bc"] = k.args("Bazel clean"):with_defaults "bazel: clean",
				["n|<LocalLeader>bd"] = k.args("Bazel debug"):with_defaults "bazel: debug",
				["n|<LocalLeader>br"] = k.args("Bazel run"):with_defaults "bazel: run",
				["n|<LocalLeader>bt"] = k.args("Bazel test"):with_defaults "bazel: test",
			}
		end,
	},
	{
		"fatih/vim-go",
		lazy = true,
		ft = "go",
		run = ":GoInstallBinaries",
		config = function()
			vim.g.go_doc_keywordprg_enabled = 0
			vim.g.go_def_mapping_enabled = 0
			vim.g.go_code_completion_enabled = 0
		end,
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
	{ "p00f/clangd_extensions.nvim", lazy = true, ft = { "c", "cpp", "hpp", "h" } },
	-- Setup language servers.
	-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		dependencies = {
			{ "folke/neodev.nvim", config = true, ft = "lua" },
			{ "williamboman/mason.nvim", cmd = "Mason" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "jay-babu/mason-nvim-dap.nvim" },
			{
				"simrat39/inlay-hints.nvim",
				config = function()
					require("inlay-hints").setup {
						-- {dynamic | eol | virtline }
						parameter = { show = true },
						renderer = "inlay-hints.render.eol",
						only_current_line = true,
						eol = {
							parameter = {
								separator = ",",
								format = function(hints) return string.format(":: (%s)", hints) end,
							},
						},
					}
				end,
			},
			{
				"jose-elias-alvarez/null-ls.nvim",
				lazy = true,
				event = "BufReadPost",
				dependencies = { "nvim-lua/plenary.nvim", "jay-babu/mason-null-ls.nvim" },
			},
			{
				"glepnir/lspsaga.nvim",
				lazy = true,
				branch = "main",
				events = "BufReadPost",
				dependencies = { "nvim-tree/nvim-web-devicons", "nvim-treesitter/nvim-treesitter" },
				config = function()
					require("lspsaga").setup {
						finder = { keys = { jump_to = "e" } },
						lightbulb = { virtual_text = false },
						diagnostic = { keys = { exec_action = "<CR>" } },
						definition = { split = "<C-c>s" },
						beacon = { enable = false },
						outline = {
							win_with = "lsagaoutline",
							win_width = math.floor(vim.o.columns * 0.2),
							keys = { jump = "<CR>" },
						},
						symbol_in_winbar = {
							enable = false,
							separator = " " .. ZoxIcon.UiSpace.Separator,
							show_file = false,
						},
						callhierarchy = { show_detail = true },
					}

					local p = require "rose-pine.palette"
					local h = require("rose-pine.util").highlight

					h("TitleString", { fg = p.rose, bold = true })
					h("TitleIcon", { fg = p.rose })
					h("SagaBorder", { fg = p.border })
					h("SagaNormal", { bg = p.surface })
					h("SagaExpand", { fg = p.love })
					h("SagaCollapse", { fg = p.love })
					h("SagaBeacon", { fg = p.base })
					h("ActionPreviewTitle", { fg = p.rose, bold = true })
					h("CodeActionText", { fg = p.foam })
					h("CodeActionNumber", { fg = p.foam })
					h("SagaShadow", { bg = p.overlay })
					h("OutlineIndent", { fg = p.rose })
					h("FinderSelection", { fg = p.gold })
					h("FinderFileName", { fg = p.text })
					h("FinderIcon", { fg = p.rose })
					h("FinderType", { fg = p.iris })
					h("FinderSpinnerTitle", { fg = p.iris, bold = true })
					h("FinderSpinner", { fg = p.iris, bold = true })
					h("FinderVirtText", { fg = p.rose })
					h("RenameNormal", { fg = p.love, bg = p.base })
					h("DiagnosticPos", { fg = p.subtle })
					h("DiagnosticWord", { fg = p.highlight_high })
					h("CallHierarchyIcon", { fg = p.iris })
					h("CallHierarchyTitle", { fg = p.love })

					k.nvim_register_mapping {
						["n|go"] = k.cr("Lspsaga outline"):with_defaults "lsp: Toggle outline",
						["n|g["] = k.callback(
							function() require("lspsaga.diagnostic"):goto_prev {} end
						)
							:with_defaults "lsp: Prev diagnostic",
						["n|g]"] = k.callback(
							function() require("lspsaga.diagnostic"):goto_next {} end
						)
							:with_defaults "lsp: Next diagnostic",
						["n|gr"] = k.cr("Lspsaga rename"):with_defaults "lsp: Rename in file range",
						["n|ca"] = k.cr("Lspsaga code_action")
							:with_defaults "lsp: Code action for cursor",
						["v|ca"] = k.cu("Lspsaga code_action")
							:with_defaults "lsp: Code action for range",
						["n|gd"] = k.cr("Lspsaga peek_definition")
							:with_defaults "lsp: Preview definition",
						["n|gD"] = k.cr("Lspsaga goto_definition")
							:with_defaults "lsp: Goto definition",
						["n|gh"] = k.cr("Lspsaga lsp_finder"):with_defaults "lsp: Show reference",
						["n|gs"] = k.callback(vim.lsp.buf.signature_help)
							:with_defaults "lsp: Signature help",
						["n|K"] = k.callback(function()
							local filetype = vim.bo.filetype
							if vim.tbl_contains({ "vim", "help" }, filetype) then
								vim.cmd("h " .. vim.fn.expand "<cword>")
							elseif vim.tbl_contains({ "man" }, filetype) then
								vim.cmd("Man " .. vim.fn.expand "<cword>")
							else
								require("lspsaga.hover"):render_hover_doc()
							end
						end):with_defaults "lsp: Show doc",
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
					"gopls",
					"lua_ls",
					"marksman",
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
			require("mason-nvim-dap").setup {
				ensure_installed = { "python", "delve", "cppdbg", "codelldb", "bash" },
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
					f.yamlfmt,
					f.rustfmt,
					f.jq,
					f.buf,
					f.buildifier,
					-- NOTE: format with 4 spaces
					f.taplo.with {
						extra_args = { "fmt", "-o", "indent_string='" .. string.rep(" ", 4) .. "'" },
					},

					-- NOTE: diagnostics
					d.clang_check,
					d.cppcheck,
					d.eslint_d,
					d.ruff,
					d.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
					d.selene,
					d.golangci_lint,
					d.markdownlint.with { extra_args = { "--disable MD033" } },
					d.zsh,
					d.buf,
					d.buildifier,
					d.yamllint,
					d.vulture,
					d.vint,

					-- NOTE: code actions
					ca.gitrebase,
					ca.gitsigns,
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
			local on_attach = function(client, _)
				--- NOTE: Avoid LSP formatting, since it will be handled by null-ls
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false
			end
			local options = { on_attach = on_attach, capabilities = capabilities }

			--- A small wrapper to setup lsp with nvim-lspconfig
			--- Supports inlay-hints with `ih.on_attach`
			---@overload fun(lsp_name: string, enable_inlay_hints?: boolean): fun():nil
			---@overload fun(lsp_name: string): fun():nil
			local lsp_callback = function(lsp_name, enable_inlay_hints)
				enable_inlay_hints = enable_inlay_hints or false
				if enable_inlay_hints then
					options.on_attach = function(client, bufnr)
						ih.on_attach(client, bufnr)
						on_attach(client, bufnr)
					end
				end
				return function()
					if
						not vim.tbl_contains(
							available(
								require("zox.utils").joinPath(
									vim.fn.stdpath "config",
									"lua",
									"zox",
									"servers"
								)
							),
							lsp_name
						)
					then
						vim.notify_once(
							string.format(
								"Failed to find config for '%s' under zox/servers.",
								lsp_name
							),
							vim.log.levels.ERROR,
							{ title = "zox" }
						)
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
						vim.notify(
							(
								"Failed to setup '%s'. Server defined under "
								.. "zox/servers must returns either a function(opts) or a table."
								.. " Got type '%s' instead."
							):format(lsp_name, type(lspconfig)),
							vim.log.levels.ERROR,
							{ title = "nvim-lspconfig" }
						)
						return
					end
				end
			end

			require("mason-lspconfig").setup_handlers {
				clangd = lsp_callback "clangd",
				html = lsp_callback "html",
				marksman = lsp_callback "marksman",
				bufls = lsp_callback "bufls",
				bashls = lsp_callback "bashls",
				jsonls = lsp_callback "jsonls",
				jdtls = lsp_callback "jdtls",
				yamlls = lsp_callback "yamlls",
				pyright = lsp_callback "pyright",
				gopls = lsp_callback("gopls", true),
				lua_ls = lsp_callback("lua_ls", true),
				tsserver = lsp_callback("tsserver", true),
			}

			lsp_callback "starlark_rust"
			lsp_callback "rust_analyzer"
		end,
	},

	-- Setup completions.
	{
		"hrsh7th/nvim-cmp",
		lazy = true,
		event = "BufReadPre",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				dependencies = { "rafamadriz/friendly-snippets" },
				build = "make install_jsregexp",
				config = function()
					local snippet_path = vim.fn.stdpath "config" .. "/custom-snippets/"
					if not vim.tbl_contains(vim.opt.rtp:get(), snippet_path) then
						vim.opt.rtp:append(snippet_path)
					end
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
			{ "hrsh7th/cmp-path" },
			{ "ray-x/cmp-treesitter" },
			{
				"zbirenbaum/copilot.lua",
				cmd = "Copilot",
				event = "InsertEnter",
				config = function()
					vim.defer_fn(function()
						require("copilot").setup {
							panel = { enabled = false },
							suggestion = {
								enabled = true,
								auto_trigger = true,
							},
							filetypes = {
								help = false,
								terraform = false,
								gitcommit = false,
								gitrebase = false,
								hgcommit = false,
								svn = false,
								cvs = false,
								["TelescopePrompt"] = false,
								["dap-repl"] = false,
								["big_file_disabled_ft"] = false,
								markdown = true, -- overrides default
							},
						}
					end, 100)
				end,
			},
		},
		config = function()
			local lspkind = require "lspkind"
			local cmp = require "cmp"

			local border = function(hl)
				return {
					{ "┌", hl },
					{ "─", hl },
					{ "┐", hl },
					{ "│", hl },
					{ "┘", hl },
					{ "─", hl },
					{ "└", hl },
					{ "│", hl },
				}
			end

			vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#57fa85" })

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
				window = {
					completion = {
						border = border "Normal",
						max_width = 80,
						max_height = 20,
					},
					documentation = {
						border = border "CmpDocBorder",
					},
				},
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
							cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
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
				-- You should specify your *installed* sources.
				sources = {
					{ name = "path" },
					{ name = "nvim_lsp", keyword_length = 3 },
					{ name = "treesitter" },
					{ name = "luasnip", keyword_length = 2 },
				},
			}
		end,
	},
}
