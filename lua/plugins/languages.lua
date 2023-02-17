local k = require "zox.keybind"
return {
	-- Setup language servers.
	-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		dependencies = {
			{ "folke/neodev.nvim", lazy = true, ft = "lua" },
			{
				"ii14/neorepl.nvim",
				lazy = true,
				ft = "lua",
				keys = {
					{
						"<Leader>or",
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
			{ "p00f/clangd_extensions.nvim", lazy = true, ft = { "c", "cpp", "hpp", "h" } },
			{
				"bazelbuild/vim-bazel",
				lazy = true,
				dependencies = { "google/vim-maktaba" },
				cmd = "Bazel",
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

							vim.fn.jobstart(
								vim.list_extend(cmd, { vim.fn.line ".", out, src_file_path })
							)
						end,
					})
				end,
			},
			{
				"simrat39/rust-tools.nvim",
				lazy = true,
				ft = "rust",
				dependencies = {
					{
						"saecki/crates.nvim",
						lazy = true,
						event = "BufReadPost Cargo.toml",
						cond = function() return vim.fn.expand "%:t" == "Cargo.toml" end,
						dependencies = { "nvim-lua/plenary.nvim" },
						config = function()
							require("crates").setup {
								avoid_prerelease = false,
								thousands_separator = ",",
								notification_title = "Crates",
								text = {
									loading = " " .. require("zox").misc_space.Watch .. "Loading",
									version = " " .. require("zox").ui_space.Check .. "%s",
									prerelease = " "
										.. require("zox").diagnostics_space.WarningHolo
										.. "%s",
									yanked = " " .. require("zox").diagnostics_space.Error .. "%s",
									nomatch = " "
										.. require("zox").diagnostics_space.Question
										.. "No match",
									upgrade = " "
										.. require("zox").diagnostics_space.HintHolo
										.. "%s",
									error = " "
										.. require("zox").diagnostics_space.Error
										.. "Error fetching crate",
								},
								popup = {
									hide_on_select = true,
									copy_register = "\"",
									border = "rounded",
									show_version_date = true,
									text = {
										title = require("zox").ui_space.Package .. "%s",
										description = "%s",
										created_label = require("zox").misc_space.Added
											.. "created"
											.. "        ",
										created = "%s",
										updated_label = require("zox").misc_space.ManUp
											.. "updated"
											.. "        ",
										updated = "%s",
										downloads_label = require("zox").ui_space.CloudDownload
											.. "downloads      ",
										downloads = "%s",
										homepage_label = require("zox").misc_space.Campass
											.. "homepage       ",
										homepage = "%s",
										repository_label = require("zox").git_space.Repo
											.. "repository     ",
										repository = "%s",
										documentation_label = require("zox").diagnostics_space.InformationHolo
											.. "documentation  ",
										documentation = "%s",
										crates_io_label = require("zox").ui_space.Package
											.. "crates.io      ",
										crates_io = "%s",
										categories_label = require("zox").kind_space.Class
											.. "categories     ",
										keywords_label = require("zox").kind_space.Keyword
											.. "keywords       ",
										version = "  %s",
										prerelease = require("zox").diagnostics_space.WarningHolo
											.. "%s prerelease",
										yanked = require("zox").diagnostics_space.Error
											.. "%s yanked",
										version_date = "  %s",
										feature = "  %s",
										enabled = require("zox").dap_space.Play .. "%s",
										transitive = require("zox").ui_space.List .. "%s",
										normal_dependencies_title = require("zox").kind_space.Interface
											.. "Dependencies",
										build_dependencies_title = require("zox").misc_space.Gavel
											.. "Build dependencies",
										dev_dependencies_title = require("zox").misc_space.Glass
											.. "Dev dependencies",
										dependency = "  %s",
										optional = require("zox").ui_space.BigUnfilledCircle
											.. "%s",
										dependency_version = "  %s",
										loading = " " .. require("zox").misc_space.Watch,
									},
								},
								src = {
									text = {
										prerelease = " "
											.. require("zox").diagnostics_space.WarningHolo
											.. "pre-release ",
										yanked = " "
											.. require("zox").diagnostics_space.ErrorHolo
											.. "yanked ",
									},
								},
								null_ls = { enabled = true, name = "crates.nvim" },
							}
							k.nvim_register_mapping {
								["n|<Leader>ct"] = k.callback(require("crates").toggle)
									:with_buffer(0)
									:with_defaults "crates: Toggle",
								["n|<Leader>cr"] = k.callback(require("crates").reload)
									:with_buffer(0)
									:with_defaults "crates: reload",
								["n|<Leader>cv"] = k.callback(
									require("crates").show_versions_popup
								)
									:with_defaults "crates: show versions popup",
								["n|<Leader>cf"] = k.callback(
									require("crates").show_features_popup
								)
									:with_defaults "crates: show features popup",
								["n|<Leader>cd"] = k.callback(
									require("crates").show_dependencies_popup
								)
									:with_defaults "crates: show dependencies popup",
								["n|<Leader>cu"] = k.callback(require("crates").update_crate)
									:with_defaults "crates: update crate",
								["v|<Leader>cu"] = k.callback(require("crates").update_crates)
									:with_defaults "crates: update crates",
								["n|<Leader>ca"] = k.callback(require("crates").update_all_crates)
									:with_defaults "crates: update all crates",
								["n|<Leader>cU"] = k.callback(require("crates").upgrade_crate)
									:with_defaults "crates: upgrade crate",
								["v|<Leader>cU"] = k.callback(require("crates").upgrade_crates)
									:with_defaults "crates: upgrade crates",
								["n|<Leader>cA"] = k.callback(require("crates").upgrade_all_crates)
									:with_defaults "crates: upgrade all crates",
								["n|<Leader>cH"] = k.callback(require("crates").open_homepage)
									:with_defaults "crates: show homepage",
								["n|<Leader>cR"] = k.callback(require("crates").open_repository)
									:with_defaults "crates: show repository",
								["n|<Leader>cD"] = k.callback(require("crates").open_documentation)
									:with_defaults "crates: show documentation",
								["n|<Leader>cC"] = k.callback(require("crates").open_crates_io)
									:with_defaults "crates: open crates.io",
							}
						end,
					},
				},
			},
			{ "williamboman/mason.nvim", cmd = "Mason" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "jay-babu/mason-nvim-dap.nvim" },
			{
				"simrat39/inlay-hints.nvim",
				cond = function()
					return not vim.tbl_contains({
						"DoomInfo",
						"DressingSelect",
						"NvimTree",
						"Outline",
						"TelescopePrompt",
						"Trouble",
						"alpha",
						"dashboard",
						"dirvish",
						"fugitive",
						"help",
						"lsgsagaoutline",
						"neogitstatus",
						"norg",
						"toggleterm",
					}, vim.bo.filetype)
				end,
				lazy = true,
				opts = {
					parameter = { show = true },
					renderer = "inlay-hints.render.eol",
					only_current_line = true,
					eol = {
						parameter = { separator = "," },
					},
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
				config = function()
					require("lspsaga").setup {
						finder = { keys = { jump_to = "e" } },
						lightbulb = { enable = false },
						diagnostic = { keys = { exec_action = "<CR>" } },
						definition = { split = "<C-c>s" },
						beacon = { enable = false },
						outline = {
							win_width = math.floor(vim.o.columns * 0.3),
							keys = { jump = "<CR>" },
						},
						code_actions = { extend_gitsigns = false },
						symbol_in_winbar = {
							enable = false,
							separator = " " .. require("zox").ui_space.Separator,
							show_file = false,
						},
						callhierarchy = { show_detail = true },
						ui = {
							theme = "round",
							border = "single",
							winblend = 0,
							expand = require("zox").ui_space.ArrowClosed,
							collapse = require("zox").ui_space.ArrowOpen,
							preview = require("zox").ui_space.Newspaper,
							code_action = require("zox").ui_space.CodeAction,
							diagnostic = require("zox").ui_space.Bug,
							incoming = require("zox").ui_space.Incoming,
							outgoing = require("zox").ui_space.Outgoing,
						},
					}
					k.nvim_register_mapping {
						["n|go"] = k.callback(function() require("lspsaga.outline"):outline() end)
							:with_defaults "lsp: Toggle outline",
						["n|g["] = k.callback(
							function() require("lspsaga.diagnostic"):goto_prev() end
						)
							:with_defaults "lsp: Prev diagnostic",
						["n|g]"] = k.callback(
							function() require("lspsaga.diagnostic"):goto_next() end
						)
							:with_defaults "lsp: Next diagnostic",
						["n|gl"] = k.callback(
							function() require("lspsaga.diagnostic"):show_diagnostics({}, "line") end
						):with_defaults "lsp: Show line diagnotics",
						["n|gC"] = k.callback(
							function() require("lspsaga.diagnostic"):show_diagnostics({}, "cursor") end
						):with_defaults "lsp: Show cursor diagnotics",
						["n|gB"] = k.cr("Lspsaga show_buf_diagnostics")
							:with_defaults "lsp: Show cursor diagnotics",
						["n|gr"] = k.cr("Lspsaga rename"):with_defaults "lsp: Rename in file range",
						["n|ca"] = k.cr("Lspsaga code_action")
							:with_defaults "lsp: Code action for cursor",
						["v|ca"] = k.cr("Lspsaga code_action")
							:with_defaults "lsp: Code action for range",
						["n|gd"] = k.cr("Lspsaga peek_definition")
							:with_defaults "lsp: Preview definition",
						["n|gD"] = k.cr("Lspsaga goto_definition")
							:with_defaults "lsp: Goto definition",
						["n|gh"] = k.cr("Lspsaga lsp_finder"):with_defaults "lsp: Show reference",
						["n|gs"] = k.callback(vim.lsp.buf.signature_help)
							:with_defaults "lsp: Signature help",
						["n|K"] = k.callback(function()
							if vim.tbl_contains({ "vim", "help" }, vim.bo.filetype) then
								vim.cmd("h " .. vim.fn.expand "<cword>")
							elseif vim.tbl_contains({ "man" }, vim.bo.filetype) then
								vim.cmd("Man " .. vim.fn.expand "<cword>")
							elseif
								vim.fn.expand "%:t" == "Cargo.toml"
								and require("crates").popup_available()
							then
								require("crates").show_popup()
							else
								vim.cmd "Lspsaga hover_doc"
							end
						end):with_defaults "lsp: Show doc",
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
			require("mason-nvim-dap").setup {
				ensure_installed = { "python", "delve", "codelldb", "bash" },
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
					f.deno_fmt,

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
			{ "lukas-reineke/cmp-under-comparator" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-buffer" },
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

			local cmp_window = require "cmp.utils.window"

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
					{ name = "nvim-lua" },
					{ name = "luasnip" },
					{ name = "treesitter" },
					{ name = "buffer" },
				},
			}
		end,
	},
}
