return function()
	local nvim_lsp = require "lspconfig"
	local mason = require "mason"

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
	require("mason-lspconfig").setup {
		ensure_installed = {
			"bashls",
			"bufls",
			"clangd",
			"dockerls",
			"gopls",
			"grammarly",
			"marksman",
			"html",
			"jdtls",
			"jsonls",
			"pyright",
			"rnix",
			"ruff_lsp",
			"rust_analyzer",
			"spectral",
			"sumneko_lua",
			"taplo",
			"tflint",
			"tsserver",
			"vimls",
			"yamlls",
		},
		automatic_installation = true,
	}

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
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

	require("mason-lspconfig").setup_handlers {
		function(server)
			require("lspconfig")[server].setup {
				capabilities = options.capabilities,
				on_attach = options.on_attach,
			}
		end,

		-- TODO: support starlark-rust
		clangd = function()
			nvim_lsp.clangd.setup(vim.tbl_deep_extend("keep", require "completion.servers.clangd", {
				on_attach = options.on_attach,
				capabilities = vim.tbl_deep_extend("keep", { offsetEncoding = { "utf-16", "utf-8" } }, capabilities),
			}))
		end,
		html = function() nvim_lsp.html.setup(vim.tbl_deep_extend("keep", require "completion.servers.html", options)) end,
		marksman = setup_lsp "marksman",
		bufls = setup_lsp "bufls",
		bashls = setup_lsp "bashls",
		gopls = setup_lsp "gopls",
		jsonls = setup_lsp "jsonls",
		jdtls = setup_lsp "jdtls",
		sumneko_lua = setup_lsp "sumneko_lua",
		yamlls = setup_lsp "yamlls",
		tsserver = setup_lsp "tsserver",
		pyright = setup_lsp "pyright",
	}
end
