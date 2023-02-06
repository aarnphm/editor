return function()
	local nvim_lsp = require "lspconfig"
	local mason = require "mason"
	local mason_lspconfig = require "mason-lspconfig"
	local efmls = require "efmls-configs"

	require("lspconfig.ui.windows").default_options.border = "single"

	local icons = {
		ui = require("utils.icons").get("ui", true),
		misc = require("utils.icons").get("misc", true),
	}

	mason.setup {
		ui = {
			border = "rounded",
			icons = {
				package_pending = icons.ui.Modified_alt,
				package_installed = icons.ui.Check,
				package_uninstalled = icons.misc.Ghost,
			},
			keymaps = {
				toggle_server_expand = "<CR>",
				install_server = "i",
				update_server = "u",
				check_server_version = "c",
				update_all_servers = "U",
				check_outdated_servers = "C",
				uninstall_server = "X",
				cancel_installation = "<C-c>",
			},
		},
	}
	mason_lspconfig.setup {
		ensure_installed = {
			"bashls",
			"clangd",
			"efm",
			"gopls",
			"ruff_lsp",
			"pyright",
			"sumneko_lua",
			"taplo",
			"rust_analyzer",
			"tsserver",
			"eslint",
			"efm",
			"bashls",
			"zk",
			"spectral",
		},
		automatic_installation = true,
	}

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

	local options = {
		on_attach = function()
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

	local setup_lsp = function(lsp_name)
		return function()
			local ok, config = pcall(require, ("completion.servers.%s"):format(lsp_name))
			if ok then
				local final_options = vim.tbl_extend("keep", config, options)
				nvim_lsp[lsp_name].setup(final_options)
			else
				vim.notify(
					("LSP config %s is not supported. Make sure it is available under lua/core/modules/configs/completion/servers/%s.lua"):format(
						lsp_name,
						lsp_name
					),
					vim.log.levels.ERROR,
					{ title = "LSP config not found" }
				)
			end
		end
	end

	mason_lspconfig.setup_handlers {
		function(server)
			require("lspconfig")[server].setup {
				capabilities = options.capabilities,
				on_attach = options.on_attach,
			}
		end,

		efm = function()
			-- Do not setup efm
		end,
		clangd = function()
			local config = require "completion.servers.clangd"
			nvim_lsp.clangd.setup(vim.tbl_deep_extend("keep", config, {
				on_attach = options.on_attach,
				capabilities = vim.tbl_deep_extend("keep", { offsetEncoding = { "utf-16", "utf-8" } }, capabilities),
			}))
		end,
		bashls = setup_lsp "bashls",
		gopls = setup_lsp "gopls",
		jsonls = setup_lsp "jsonls",
		jdtls = setup_lsp "jdtls",
		sumneko_lua = setup_lsp "sumneko_lua",
		yamlls = setup_lsp "yamlls",
		tsserver = setup_lsp "tsserver",
		pyright = setup_lsp "pyright",
	}

	if vim.fn.executable "html-languageserver" then
		local config = require "completion.servers.html"
		nvim_lsp.html.setup(vim.tbl_deep_extend("keep", config, options))
	end

	-- Init `efm-langserver` here.
	efmls.init {
		on_attach = options.on_attach,
		capabilities = capabilities,
		init_options = { documentFormatting = true, codeAction = true },
	}

	-- Require `efmls-configs-nvim`'s config here
	local eslint = require "efmls-configs.linters.eslint"
	local prettier = require "efmls-configs.formatters.prettier"

	-- Setup formatter and linter for efmls here

	efmls.setup {
		vue = { formatter = prettier },
		yaml = { formatter = prettier },
		html = { formatter = prettier },
		css = { formatter = prettier },
		scss = { formatter = prettier },
		markdown = { formatter = prettier },
		typescript = { formatter = prettier, linter = eslint },
		javascript = { formatter = prettier, linter = eslint },
		typescriptreact = { formatter = prettier, linter = eslint },
		javascriptreact = { formatter = prettier, linter = eslint },
		vim = { formatter = require "efmls-configs.linters.vint" },
		lua = { formatter = require "efmls-configs.formatters.stylua" },
		c = { formatter = require "completion.efm.formatters.clangfmt" },
		cpp = { formatter = require "completion.efm.formatters.clangfmt" },
		rust = { formatter = require "completion.efm.formatters.rustfmt" },
		python = {
			formatter = require "efmls-configs.formatters.black",
			linter = require "efmls-configs.linters.pylint",
		},
		rst = { linter = require "efmls-configs.linters.vale" },
		sh = {
			formatter = require "efmls-configs.formatters.shfmt",
			linter = require "efmls-configs.linters.shellcheck",
		},
		bash = {
			formatter = require "efmls-configs.formatters.shfmt",
			linter = require "efmls-configs.linters.shellcheck",
		},
		zsh = {
			formatter = require "efmls-configs.formatters.shfmt",
			linter = require "efmls-configs.linters.shellcheck",
		},
	}

	require("completion._utils.formatting").configure_format_on_save()
end
