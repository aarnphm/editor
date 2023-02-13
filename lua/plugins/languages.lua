local k = require "keybind"
local icons = {
	diagnostics = require("icons").get("diagnostics", true),
	git = require("icons").get("git", true),
	misc = require("icons").get("misc", true),
	ui = require("icons").get("ui", true),
	kind = require("icons").get("kind", true),
	dap = require("icons").get("dap", true),
	cmp = require("icons").get "cmp",
	type = require("icons").get "type",
}

return {
	-- NOTE: Language-specific plugins
	{ "chrisbra/csv.vim", lazy = true, ft = "csv" },
	{ "folke/neodev.nvim", lazy = true, ft = "lua" },
	{ "Stormherz/tablify", lazy = true, ft = "rst" },
	{
		"bazelbuild/vim-bazel",
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
		"iamcco/markdown-preview.nvim",
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
	{
		"lervag/vimtex",
		lazy = true,
		ft = "tex",
		config = function()
			vim.g.vimtex_view_method = "zathura"
			if require("editor").global.is_mac then
				vim.g.vimtex_view_method = "skim"
				vim.g.vimtex_view_general_viewer = "/Applications/Skim.app/Contents/SharedSupport/displayline"
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

					if vim.fn.empty(vim.fn.system "pgrep Skim") == 0 then table.insert(cmd, "-g") end

					vim.fn.jobstart(vim.list_extend(cmd, { vim.fn.line ".", out, src_file_path }))
				end,
			})
		end,
	},
	{ "p00f/clangd_extensions.nvim", lazy = true, ft = { "c", "cpp", "hpp", "h" } },
	{ "simrat39/rust-tools.nvim", lazy = true, ft = "rust", dependencies = { "nvim-lua/plenary.nvim" } },
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
				null_ls = { enabled = true, name = "crates.nvim" },
			}
		end,
		init = function()
			if vim.fn.expand "%:t" == "Cargo.toml" then
				k.nvim_register_mapping {
					["n|<Leader>ct"] = k.callback(require("crates").toggle)
						:with_buffer(0)
						:with_defaults "crates: Toggle",
					["n|<Leader>cr"] = k.callback(require("crates").reload)
						:with_buffer(0)
						:with_defaults "crates: reload",
					["n|<Leader>cv"] = k.callback(require("crates").show_versions_popup)
						:with_defaults "crates: show versions popup",
					["n|<Leader>cf"] = k.callback(require("crates").show_features_popup)
						:with_defaults "crates: show features popup",
					["n|<Leader>cd"] = k.callback(require("crates").show_dependencies_popup)
						:with_defaults "crates: show dependencies popup",
					["n|<Leader>cu"] = k.callback(require("crates").update_crate):with_defaults "crates: update crate",
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
			end
		end,
	},

	{
		"mfussenegger/nvim-dap",
		lazy = true,
		cmd = {
			"DapSetLogLevel",
			"DapShowLog",
			"DapContinue",
			"DapToggleBreakpoint",
			"DapToggleRepl",
			"DapStepOver",
			"DapStepInto",
			"DapStepOut",
			"DapTerminate",
		},
		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				config = function()
					require("dapui").setup {
						icons = {
							expanded = icons.ui.ArrowOpen,
							collapsed = icons.ui.ArrowClosed,
							current_frame = icons.ui.Indicator,
						},
						layouts = {
							{
								elements = {
									-- Provide as ID strings or tables with "id" and "size" keys
									{
										id = "scopes",
										size = 0.25, -- Can be float or integer > 1
									},
									{ id = "breakpoints", size = 0.25 },
									{ id = "stacks", size = 0.25 },
									{ id = "watches", size = 0.25 },
								},
								size = 40,
								position = "left",
							},
							{ elements = { "repl" }, size = 10, position = "bottom" },
						},
						controls = {
							icons = {
								pause = icons.dap.Pause,
								play = icons.dap.Play,
								step_into = icons.dap.StepInto,
								step_over = icons.dap.StepOver,
								step_out = icons.dap.StepOut,
								step_back = icons.dap.StepBack,
								run_last = icons.dap.RunLast,
								terminate = icons.dap.Terminate,
							},
						},
						windows = { indent = 1 },
					}
				end,
			},
		},
		config = function()
			local dap = require "dap"
			local dapui = require "dapui"

			dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
			dap.listeners.after.event_terminated["dapui_config"] = function() dapui.close() end
			dap.listeners.after.event_exited["dapui_config"] = function() dapui.close() end

			-- We need to override nvim-dap's default highlight groups, AFTER requiring nvim-dap for catppuccin.
			-- vim.api.nvim_set_hl(0, "DapStopped", { fg = colors.green })

			for _, v in ipairs { "Breakpoint", "BreakpointRejected", "BreakpointCondition", "LogPoint", "Stopped" } do
				vim.fn.sign_define("Dap" .. v, { text = icons.dap[v], texthl = "Dap" .. v, line = "", numhl = "" })
			end

			-- Config lang adaptors
			for _, dbg in ipairs { "lldb", "debugpy", "dlv" } do
				local ok, _ = pcall(require, string.format("plugins.zox.adapters.%s", dbg))
				if not ok then
					vim.notify_once("Failed to load " .. dbg, vim.log.levels.ERROR, { title = "dap.nvim" })
				end
			end
		end,
		init = function()
			k.nvim_register_mapping {
				["n|<F6>"] = k.callback(function() require("dap").continue() end):with_defaults "debug: Run/Continue",
				["n|<F7>"] = k.callback(function()
					require("dap").terminate()
					require("dapui").close()
				end):with_defaults "debug: Stop",
				["n|<F8>"] = k.callback(function() require("dap").toggle_breakpoint() end)
					:with_defaults "debug: Toggle breakpoint",
				["n|<F9>"] = k.callback(function() require("dap").step_into() end):with_defaults "debug: Step into",
				["n|<F10>"] = k.callback(function() require("dap").step_out() end):with_defaults "debug: Step out",
				["n|<F11>"] = k.callback(function() require("dap").step_over() end):with_defaults "debug: Step over",
				["n|<Leader>db"] = k.callback(
					function() require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ") end
				):with_defaults "debug: Set breakpoint with condition",
				["n|<Leader>dc"] = k.callback(function() require("dap").run_to_cursor() end)
					:with_defaults "debug: Run to cursor",
				["n|<Leader>dl"] = k.callback(function() require("dap").run_last() end):with_defaults "debug: Run last",
				["n|<Leader>do"] = k.callback(function() require("dap").repl.open() end)
					:with_defaults "debug: Open REPL",
			}
		end,
	},

	-- NOTE: Native LSP configuration
	{
		"neovim/nvim-lspconfig",
		lazy = true,
		event = { "CursorHold", "CursorHoldI" },
		dependencies = {
			{
				"simrat39/inlay-hints.nvim",
				lazy = true,
				event = { "BufReadPost" },
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
			{ "williamboman/mason.nvim" },
			{ "ray-x/lsp_signature.nvim" },
			{ "williamboman/mason-lspconfig.nvim", lazy = true, event = { "CursorHold", "CursorHoldI" } },
			{ "jay-babu/mason-nvim-dap.nvim", lazy = true, event = { "CursorHold", "CursorHoldI" } },
			{
				"jose-elias-alvarez/null-ls.nvim",
				lazy = true,
				event = { "BufReadPost" },
				dependencies = { "nvim-lua/plenary.nvim", "jay-babu/mason-null-ls.nvim" },
			},
			{
				"glepnir/lspsaga.nvim",
				lazy = true,
				branch = "main",
				events = "VeryLazy",
				dependencies = { "nvim-tree/nvim-web-devicons", "nvim-treesitter/nvim-treesitter" },
				config = function()
					require("lspsaga").setup {
						finder = { keys = { jump_to = "e" } },
						lightbulb = { enable = false },
						diagnostic = { keys = { exec_action = "<CR>" } },
						definition = { split = "<C-c>s" },
						outline = {
							win_with = "lsagaoutline",
							win_width = math.floor(vim.o.columns * 0.2),
							keys = { jump = "<CR>" },
						},
						symbol_in_winbar = {
							enable = false,
							separator = " " .. icons.ui.Separator,
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
						callhierarchy = { show_detail = true },
					}
				end,
				init = function()
					k.nvim_register_mapping {
						["n|<LocalLeader>ci"] = k.cr("Lspsaga incoming_calls"):with_defaults "lsp: Show incoming calls",
						["n|<LocalLeader>co"] = k.cr("Lspsaga outgoing_calls"):with_defaults "lsp: Show outgoing calls",
						["n|go"] = k.cr("Lspsaga outline"):with_defaults "lsp: Toggle outline",
						["n|g["] = k.cr("Lspsaga diagnostic_jump_prev"):with_defaults "lsp: Prev diagnostic",
						["n|g]"] = k.cr("Lspsaga diagnostic_jump_next"):with_defaults "lsp: Next diagnostic",
						["n|gr"] = k.cr("Lspsaga rename"):with_defaults "lsp: Rename in file range",
						["n|ga"] = k.cr("Lspsaga code_action"):with_defaults "lsp: Code action for cursor",
						["v|ga"] = k.cu("Lspsaga code_action"):with_defaults "lsp: Code action for range",
						["n|gd"] = k.cr("Lspsaga peek_definition"):with_defaults "lsp: Preview definition",
						["n|gD"] = k.cr("Lspsaga goto_definition"):with_defaults "lsp: Goto definition",
						["n|gh"] = k.cr("Lspsaga lsp_finder"):with_defaults "lsp: Show reference",
						["n|gs"] = k.callback(vim.lsp.buf.signature_help):with_defaults "lsp: Signature help",
						["n|K"] = k.callback(function()
							local filetype = vim.bo.filetype
							if vim.tbl_contains({ "vim", "help" }, filetype) then
								vim.cmd("h " .. vim.fn.expand "<cword>")
							elseif vim.tbl_contains({ "man" }, filetype) then
								vim.cmd("Man " .. vim.fn.expand "<cword>")
							elseif vim.fn.expand "%:t" == "Cargo.toml" and require("crates").popup_available() then
								require("crates").show_popup()
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

			-- Configuring native diagnostics
			vim.diagnostic.config {
				virtual_text = true,
				signs = true,
				update_in_insert = true,
				underline = false,
				severity_sort = false,
				float = {
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
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
			require("mason-nvim-dap").setup {
				ensure_installed = { "python", "delve", "cppdbg", "codelldb", "bash" },
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
			local on_attach = function(client, bufnr)
				--- NOTE: Avoid LSP foratting, since it will be handled by null-ls
				client.server_capabilities.documentFormattingProvider = false
				client.server_capabilities.documentRangeFormattingProvider = false

				require("lsp_signature").on_attach({
					floating_window_off_x = 5, -- adjust float windows x position.
					floating_window_off_y = function() -- adjust float windows y position. e.g. set to -2 can make floating window move up 2 lines
						local pumheight = vim.o.pumheight
						local winline = vim.fn.winline() -- line number in the window
						local winheight = vim.fn.winheight(0)
						-- window top
						if winline - 1 < pumheight then return pumheight end
						-- window bottom
						if winheight - winline < pumheight then return -pumheight end
						return 0
					end,
					hint_enable = false,
					toggle_key = "<Leader>a",
					select_signature_key = "<LocalLeader>a",
					hi_parameter = "Search",
					handler_opts = { border = "rounded" },
				}, bufnr)
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
					local healthy, lspconfig = pcall(require, ("plugins.zox.servers.%s"):format(lsp_name))
					if healthy then
						nvim_lsp[lsp_name].setup(vim.tbl_extend("force", options, lspconfig))
					else
						if require("editor").config.debug then
							vim.notify(
								(
									"LSP config %s does not exists. Using default setup. If "
									.. "you wish to add configuration, make sure it is available "
									.. "under modules/languages/servers/%s.lua."
								):format(lsp_name, lsp_name),
								vim.log.levels.INFO,
								{ title = "nvim-lspconfig" }
							)
						end
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
				-- NOTE: Let clangd_extensions setup clangd
				clangd = function()
					capabilities.offsetEncoding = { "utf-16", "utf-8" }
					require("clangd_extensions").setup {
						server = vim.tbl_deep_extend("keep", require "plugins.zox.servers.clangd", {
							on_attach = options.on_attach,
							capabilities = capabilities,
						}),
						extensions = { other_hints_prefix = ":: ", show_parameter_hints = false },
					}
				end,
				rust_analyzer = lsp_callback "rust_analyzer",
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
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		lazy = true,
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				lazy = true,
				dependencies = { "rafamadriz/friendly-snippets" },
				build = "make install_jsregexp",
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
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-buffer" },
			{ "ray-x/cmp-treesitter" },
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
			local compare = require "cmp.config.compare"

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
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<Tab>"] = function(fallback)
						if require("copilot.suggestion").is_visible() then
							require("copilot.suggestion").accept()
						elseif cmp.visible() then
							cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
						elseif require("luasnip").expand_or_jumpable() then
							vim.fn.feedkeys(k.replace_termcodes "<Plug>luasnip-expand-or-jump", "")
						elseif require("utils").check_backspace() then
							vim.fn.feedkeys(k.replace_termcodes "<Tab>", "n")
						elseif require("utils").has_words_before() then
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
					{ name = "buffer", keyword_length = 3 },
					{ name = "luasnip", keyword_length = 2 },
					{ name = "treesitter" },
				},
			}
		end,
	},
}
