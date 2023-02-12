local k = require "keybind"
local icons = {
	diagnostics = require("utils.icons").get("diagnostics", true),
	git = require("utils.icons").get("git", true),
	misc = require("utils.icons").get("misc", true),
	ui = require("utils.icons").get("ui", true),
	kind = require("utils.icons").get("kind", true),
	dap = require("utils.icons").get("dap", true),
	cmp = require("utils.icons").get "cmp",
	type = require("utils.icons").get "type",
}

return {
	-- NOTE: Language-specific plugins
	["chrisbra/csv.vim"] = { lazy = true, ft = "csv" },
	["folke/neodev.nvim"] = { lazy = true, ft = "lua" },
	["Stormherz/tablify"] = { lazy = true, ft = "rst" },
	["bazelbuild/vim-bazel"] = {
		lazy = true,
		dependencies = { "google/vim-maktaba" },
		cmd = { "Bazel" },
		ft = "bzl",
		init = function()
			k.nvim_register_mapping {
				["n|<LocalLeader>bb"] = k.args("Bazel build"):with_defaults "bazel: build",
				["n|<LocalLeader>bc"] = k.args("Bazel clean"):with_defaults "bazel: clean",
				["n|<LocalLeader>bd"] = k.args("Bazel debug"):with_defaults "bazel: debug",
				["n|<LocalLeader>br"] = k.args("Bazel run"):with_defaults "bazel: run",
				["n|<LocalLeader>bt"] = k.args("Bazel test"):with_defaults "bazel: test",
			}
		end,
	},
	["fatih/vim-go"] = {
		lazy = true,
		ft = "go",
		run = ":GoInstallBinaries",
		config = function()
			vim.g.go_doc_keywordprg_enabled = 0
			vim.g.go_def_mapping_enabled = 0
			vim.g.go_code_completion_enabled = 0
		end,
	},
	["iamcco/markdown-preview.nvim"] = {
		lazy = true,
		ft = "markdown",
		run = "cd app && yarn install",
		build = "cd app && yarn install",
		init = function()
			k.nvim_register_mapping {
				["n|mpt"] = k.cr("MarkdownPreviewToggle"):with_defaults "markdown: preview",
			}
		end,
	},
	["lervag/vimtex"] = {
		lazy = true,
		ft = "tex",
		config = function()
			if require("editor").global.is_mac then
				vim.g.vimtex_view_method = "skim"
				vim.g.vimtex_view_general_viewer = "/Applications/Skim.app/Contents/SharedSupport/displayline"
				vim.g.vimtex_view_general_options = "-r @line @pdf @tex"
			end

			vim.api.nvim_create_autocmd("User", {
				group = vim.api.nvim_create_augroup("vimtext_mac", { clear = true }),
				pattern = "VimtexEventCompileSuccess",
				callback = function(_)
					local out = vim.b.vimtex.out()
					local src_file_path = vim.fn.expand "%:p"
					local cmd = { vim.g.vimtex_view_general_viewer, "-r" }

					if vim.fn.empty(vim.fn.system "pgrep Skim") == 0 then table.insert(cmd, "-g") end

					vim.fn.jobstart(vim.list_extend(cmd, { vim.fn.line ".", out, src_file_path }))
				end,
			})
		end,
	},
	["p00f/clangd_extensions.nvim"] = { lazy = true, ft = { "c", "cpp", "hpp", "h" } },
	["simrat39/rust-tools.nvim"] = {
		lazy = true,
		ft = "rust",
		requires = { "nvim-lua/plenary.nvim" },
		config = function()
			local get_rust_adapters = function()
				if require("editor").global.is_windows then
					return {
						type = "executable",
						command = "lldb-vscode",
						name = "rt_lldb",
					}
				end

				local codelldb_extension_path = vim.env.HOME .. "/.vscode/extensions/vadimcn.vscode-lldb-1.8.1/"
				local codelldb_path = codelldb_extension_path .. "adapter/codelldb"
				local extension = ".so"
				if require("editor").global.is_mac then extension = ".dylib" end
				local liblldb_path = codelldb_extension_path .. "lldb/lib/liblldb" .. extension
				return require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
			end
			require("rust-tools").setup {
				on_initialized = function(_)
					require("lsp_signature").on_attach {
						bind = true,
						use_lspsaga = false,
						floating_window = true,
						fix_pos = true,
						hint_enable = true,
						hi_parameter = "Search",
						handler_opts = { "double" },
					}
				end,
				tools = {
					inlay_hints = {
						only_current_line = false,
						show_parameter_hints = true,
						other_hints_prefix = ":: ",
					},
				},
				dap = { adapter = get_rust_adapters() },
				server = {
					standalone = true,
					settings = {
						["rust-analyzer"] = {
							cargo = {
								loadOutDirsFromCheck = true,
								buildScripts = { enable = true },
							},
							inlayHints = { locationLinks = false },
							checkOnSave = { command = "clippy" },
							procMacro = { enable = true },
						},
					},
				},
			}
		end,
	},
	["saecki/crates.nvim"] = {
		lazy = true,
		event = { "BufReadPost Cargo.toml" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("crates").setup {
				avoid_prerelease = false,
				thousands_separator = ",",
				notification_title = "Crates",
				text = {
					loading = " " .. icons.misc.Watch .. "Loading",
					version = " " .. icons.ui.Check .. "%s",
					prerelease = " " .. icons.diagnostics.WarningHolo .. "%s",
					yanked = " " .. icons.diagnostics.Error .. "%s",
					nomatch = " " .. icons.diagnostics.Question .. "No match",
					upgrade = " " .. icons.diagnostics.HintHolo .. "%s",
					error = " " .. icons.diagnostics.Error .. "Error fetching crate",
				},
				popup = {
					hide_on_select = true,
					copy_register = "\"",
					border = "rounded",
					show_version_date = true,
					text = {
						title = icons.ui.Package .. "%s",
						description = "%s",
						created_label = icons.misc.Added .. "created" .. "        ",
						created = "%s",
						updated_label = icons.misc.ManUp .. "updated" .. "        ",
						updated = "%s",
						downloads_label = icons.ui.CloudDownload .. "downloads      ",
						downloads = "%s",
						homepage_label = icons.misc.Campass .. "homepage       ",
						homepage = "%s",
						repository_label = icons.git.Repo .. "repository     ",
						repository = "%s",
						documentation_label = icons.diagnostics.InformationHolo .. "documentation  ",
						documentation = "%s",
						crates_io_label = icons.ui.Package .. "crates.io      ",
						crates_io = "%s",
						categories_label = icons.kind.Class .. "categories     ",
						keywords_label = icons.kind.Keyword .. "keywords       ",
						version = "  %s",
						prerelease = icons.diagnostics.WarningHolo .. "%s prerelease",
						yanked = icons.diagnostics.Error .. "%s yanked",
						version_date = "  %s",
						feature = "  %s",
						enabled = icons.dap.Play .. "%s",
						transitive = icons.ui.List .. "%s",
						normal_dependencies_title = icons.kind.Interface .. "Dependencies",
						build_dependencies_title = icons.misc.Gavel .. "Build dependencies",
						dev_dependencies_title = icons.misc.Glass .. "Dev dependencies",
						dependency = "  %s",
						optional = icons.ui.BigUnfilledCircle .. "%s",
						dependency_version = "  %s",
						loading = " " .. icons.misc.Watch,
					},
				},
				src = {
					text = {
						prerelease = " " .. icons.diagnostics.WarningHolo .. "pre-release ",
						yanked = " " .. icons.diagnostics.ErrorHolo .. "yanked ",
					},
				},
			}
		end,
		init = function()
			k.nvim_register_mapping {
				["n|<Leader>ct"] = k.callback(require("crates").toggle):with_buffer(0):with_defaults "crates: Toggle",
				["n|<Leader>cr"] = k.callback(require("crates").reload):with_buffer(0):with_defaults "crates: reload",
				["n|<Leader>cv"] = k.callback(require("crates").show_versions_popup)
					:with_defaults "crates: show versions popup",
				["n|<Leader>cf"] = k.callback(require("crates").show_features_popup)
					:with_defaults "crates: show features popup",
				["n|<Leader>cd"] = k.callback(require("crates").show_dependencies_popup)
					:with_defaults "crates: show dependencies popup",
				["n|<Leader>cu"] = k.callback(require("crates").update_crate):with_defaults "crates: update crate",
				["v|<Leader>cu"] = k.callback(require("crates").update_crates):with_defaults "crates: update crates",
				["n|<Leader>ca"] = k.callback(require("crates").update_all_crates)
					:with_defaults "crates: update all crates",
				["n|<Leader>cU"] = k.callback(require("crates").upgrade_crate):with_defaults "crates: upgrade crate",
				["v|<Leader>cU"] = k.callback(require("crates").upgrade_crates):with_defaults "crates: upgrade crates",
				["n|<Leader>cA"] = k.callback(require("crates").upgrade_all_crates)
					:with_defaults "crates: upgrade all crates",
				["n|<Leader>cH"] = k.callback(require("crates").open_homepage):with_defaults "crates: show homepage",
				["n|<Leader>cR"] = k.callback(require("crates").open_repository)
					:with_defaults "crates: show repository",
				["n|<Leader>cD"] = k.callback(require("crates").open_documentation)
					:with_defaults "crates: show documentation",
				["n|<Leader>cC"] = k.callback(require("crates").open_crates_io):with_defaults "crates: open crates.io",
			}
		end,
	},

	-- NOTE: Native LSP configuration
	["neovim/nvim-lspconfig"] = {
		lazy = true,
		event = { "BufAdd", "BufReadPost", "BufNewFile" },
		dependencies = {
			{ "ray-x/lsp_signature.nvim" },
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			{
				"jose-elias-alvarez/null-ls.nvim",
				dependencies = { "nvim-lua/plenary.nvim", "jay-babu/mason-null-ls.nvim" },
				requires = { "nvim-lua/plenary.nvim" },
			},
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				config = function()
					require("mason-tool-installer").setup {

						-- a list of all tools you want to ensure are installed upon
						-- start; they should be the names Mason uses for each tool
						ensure_installed = {

							-- NOTE: Formatter
							"stylua",
							"prettierd",
							"black",
							"shfmt",
							"isort",
							"buf", -- proto
							"buildifier", -- bazel
							"markdownlint", -- style checker for markdownj
							"cbfmt", -- format codeblocks in markdown
							"beautysh", -- bash formatter
							"yamlfmt",
							"jq",
							"ruff",

							-- NOTE: Linters
							"selene",
							"eslint_d",
							"shellcheck",
							"tflint",
							"yamllint",
							"vulture",
							"vint",
						},
					}
				end,
			},
			{
				"glepnir/lspsaga.nvim",
				branch = "main",
				event = { "BufRead", "BufReadPost" },
				dependencies = { "nvim-tree/nvim-web-devicons" },
				config = function()
					require("lspsaga").setup {
						finder = { keys = { jump_to = "e" } },
						lightbulb = { enable = false },
						diagnostic = { keys = { exec_action = "<CR>" } },
						definition = {
							edit = "<C-c>o",
							vsplit = "<C-c>v",
							split = "<C-c>s",
							tabe = "<C-c>t",
							quit = "q",
							close = "<Esc>",
						},
						outline = {
							win_with = "_sagaoutline",
							auto_preview = false,
							keys = { jump = "<CR>" },
						},
						symbol_in_winbar = {
							enable = false,
							separator = " " .. icons.ui.DoubleSeparator,
							show_file = false,
						},
						ui = {
							theme = "round",
							expand = icons.ui.ArrowClosed,
							collapse = icons.ui.ArrowOpen,
							preview = icons.ui.Newspaper,
							code_action = icons.ui.CodeAction,
							diagnostic = icons.ui.Bug,
							incoming = icons.ui.Incoming,
							outgoing = icons.ui.Outgoing,
						},
					}
				end,
				init = function()
					k.nvim_register_mapping {
						["n|go"] = k.cr("Lspsaga outline"):with_defaults "lsp: Toggle outline",
						["n|g["] = k.cr("Lspsaga diagnostic_jump_prev"):with_defaults "lsp: Prev diagnostic",
						["n|g]"] = k.cr("Lspsaga diagnostic_jump_next"):with_defaults "lsp: Next diagnostic",
						["n|gs"] = k.callback(vim.lsp.buf.signature_help):with_defaults "lsp: Signature help",
						["n|gr"] = k.cr("Lspsaga rename"):with_defaults "lsp: Rename in file range",
						["n|K"] = k.cr("Lspsaga hover_doc"):with_defaults "lsp: Show doc",
						["n|ga"] = k.cr("Lspsaga code_action"):with_defaults "lsp: Code action for cursor",
						["v|ga"] = k.cu("Lspsaga code_action"):with_defaults "lsp: Code action for range",
						["n|gd"] = k.cr("Lspsaga peek_definition"):with_defaults "lsp: Preview definition",
						["n|gD"] = k.cr("Lspsaga goto_definition"):with_defaults "lsp: Goto definition",
						["n|gh"] = k.cr("Lspsaga lsp_finder"):with_defaults "lsp: Show reference",
						["n|<LocalLeader>ci"] = k.cr("Lspsaga incoming_calls"):with_defaults "lsp: Show incoming calls",
						["n|<LocalLeader>co"] = k.cr("Lspsaga outgoing_calls"):with_defaults "lsp: Show outgoing calls",
					}
				end,
			},
		},
		config = function()
			local nvim_lsp = require "lspconfig"
			local mason = require "mason"
			require("lspconfig.ui.windows").default_options.border = "single"
			-- Configuring native diagnostics
			vim.diagnostic.config {
				signs = true,
				update_in_insert = true,
				underline = true,
				virtual_text = {
					source = "true",
				},
				float = {
					source = "if_many",
					focusable = true,
				},
			}

			mason.setup {
				ui = {
					border = "rounded",
					icons = {
						package_pending = icons.ui.ModifiedHolo,
						package_installed = icons.ui.Check,
						package_uninstalled = icons.misc.Ghost,
					},
				},
			}
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

			local disabled_workspaces = require("editor").config.disabled_workspaces
			local format_on_save = require("editor").config.format_on_save

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
					d.eslint_d,
					d.ruff,
					d.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
					d.selene,
					d.markdownlint.with { extra_args = { "--disable MD033" } },
					d.zsh,
					d.buf,
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
							callback = function()
								vim.lsp.buf.format { bufnr = bufnr }
								vim.notify(
									string.format("[%s] Format successfully!", client.name),
									vim.log.levels.INFO,
									{ title = "LspFormat" }
								)
							end,
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

			local options = {
				on_attach = function(client, _)
					--- NOTE: Avoid LSP foratting, since it will be handled by null-ls
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false

					---Disable |lsp-semantic_tokens| (conflicting with TS highlights)
					client.server_capabilities.semanticTokensProvider = nil

					require("lsp_signature").on_attach {
						bind = true,
						use_lspsaga = false,
						floating_window = true,
						fix_pos = true,
						hint_enable = true,
						hi_parameter = "Search",
						handler_opts = { border = "rounded" },
					}
				end,
				capabilities = capabilities,
			}

			local lsp_callback = function(lsp_name)
				return function()
					local config
					ok, config = pcall(require, ("languages.servers.%s"):format(lsp_name))
					if ok then
						local final_options = vim.tbl_extend("keep", config, options)
						nvim_lsp[lsp_name].setup(final_options)
					else
						vim.notify(
							("LSP config %s is not supported. Make sure it is available under lua/core/modules/configs/completion/servers/%s.lua. Using default setup."):format(
								lsp_name,
								lsp_name
							),
							vim.log.levels.DEBUG,
							{ title = "nvim-lspconfig" }
						)
						nvim_lsp[lsp_name].setup {}
					end
				end
			end

			require("mason-lspconfig").setup_handlers {
				function(server)
					nvim_lsp[server].setup {
						capabilities = options.capabilities,
						on_attach = options.on_attach,
					}
				end,

				-- TODO: support starlark-rust for bazel
				-- NOTE: Let rust-tools setup rust-analyzer
				rust_analyzer = function() end,
				-- NOTE: Let clangd_extensions setup clangd
				clangd = function() end,
				html = lsp_callback "html",
				marksman = lsp_callback "marksman",
				bufls = lsp_callback "bufls",
				bashls = lsp_callback "bashls",
				gopls = lsp_callback "gopls",
				jsonls = lsp_callback "jsonls",
				jdtls = lsp_callback "jdtls",
				lua_ls = lsp_callback "lua_ls",
				yamlls = lsp_callback "yamlls",
				tsserver = lsp_callback "tsserver",
				pyright = lsp_callback "pyright",
			}

			require("clangd_extensions").setup {
				server = vim.tbl_deep_extend("keep", require "languages.servers.clangd", {
					on_attach = options.on_attach,
					capabilities = vim.tbl_deep_extend(
						"keep",
						{ offsetEncoding = { "utf-16", "utf-8" } },
						capabilities
					),
				}),
			}
		end,
	},
	["hrsh7th/nvim-cmp"] = {
		lazy = true,
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				lazy = true,
				dependencies = { "rafamadriz/friendly-snippets" },
				config = function()
					local snippet_path = vim.fn.stdpath "config" .. "/custom-snippets/"
					if not vim.tbl_contains(vim.opt.rtp:get(), snippet_path) then vim.opt.rtp:append(snippet_path) end
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
			{ "hrsh7th/cmp-emoji" },
			{
				"windwp/nvim-autopairs",
				config = function()
					local cmp = require "cmp"
					local cmp_autopairs = require "nvim-autopairs.completion.cmp"
					local handlers = require "nvim-autopairs.completion.handlers"
					cmp.event:on(
						"confirm_done",
						cmp_autopairs.on_confirm_done {
							map_char = { tex = "" },
							filetypes = {
								-- "*" is an alias to all filetypes
								["*"] = {
									["("] = {
										kind = {
											cmp.lsp.CompletionItemKind.Function,
											cmp.lsp.CompletionItemKind.Method,
										},
										handler = handlers["*"],
									},
								},
								-- Disable for tex
								tex = false,
							},
						}
					)
				end,
			},
			{
				"zbirenbaum/copilot.lua",
				lazy = true,
				cmd = "Copilot",
				event = "InsertEnter",
				config = function()
					vim.defer_fn(function()
						require("copilot").setup {
							panel = {
								enabled = true,
								auto_refresh = true,
							},
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

			local compare = require "cmp.config.compare"
			compare.lsp_scores = function(entry1, entry2)
				local diff
				if entry1.completion_item.score and entry2.completion_item.score then
					diff = (entry2.completion_item.score * entry2.score) - (entry1.completion_item.score * entry1.score)
				else
					diff = entry2.score - entry1.score
				end
				return (diff < 0)
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
				sorting = {
					priority_weight = 2,
					comparators = {
						compare.offset,
						compare.exact,
						compare.lsp_scores,
						require "clangd_extensions.cmp_scores",
						compare.kind,
						compare.sort_text,
						compare.length,
						compare.order,
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
							symbol_map = vim.tbl_deep_extend("force", icons.kind, icons.type, icons.cmp),
						}(entry, vim_item)
						local strings = vim.split(kind.kind, "%s", { trimempty = true })
						kind.kind = " " .. strings[1] .. " "
						kind.menu = "    (" .. strings[2] .. ")"
						return kind
					end,
				},
				mapping = cmp.mapping.preset.insert {
					["<CR>"] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
					["<C-k>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
					["<C-j>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
					["<Tab>"] = function(fallback)
						if require("copilot.suggestion").is_visible() then
							require("copilot.suggestion").accept()
						elseif cmp.visible() and require("utils").has_words_before() then
							cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
						elseif require("luasnip").expand_or_jumpable() then
							vim.fn.feedkeys(k.replace_termcodes "<Plug>luasnip-expand-or-jump", "")
						elseif require("utils").check_backspace() then
							vim.fn.feedkeys(k.replace_termcodes "<Tab>", "n")
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
					{ name = "buffer", keyword_length = 3 },
					{ name = "nvim_lua", keyword_length = 2 },
					{ name = "luasnip" },
					{ name = "emoji" },
				},
			}
		end,
	},
}
