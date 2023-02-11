return function()
	local disabled_worksapces = {}
	local format_on_save = __editor_config.format_on_save

	-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins
	local b = require("null-ls").builtins

	local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

	local with_diagnostics_code = function(builtin)
		return builtin.with {
			diagnostics_format = "#{m} [#{c}]",
		}
	end

	require("null-ls").setup {
		debug = false,
		update_in_insert = false,
		diagnostics_format = "[#{c}] #{m} (#{s})",
		sources = {
			-- NOTE: formatting
			b.formatting.prettierd.with {
				extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
			},
			b.formatting.black,
			b.formatting.ruff,
			b.formatting.isort,
			b.formatting.stylua,
			b.formatting.shfmt,
			b.formatting.markdownlint,
			b.formatting.cbfmt,
			b.formatting.beautysh,
			b.formatting.yamlfmt,
			b.formatting.rustfmt,
			b.formatting.jq,
			b.formatting.buf,
			b.formatting.buildifier,

			-- NOTE: diagnostics
			b.diagnostics.eslint_d,
			b.diagnostics.ruff,
			with_diagnostics_code(b.diagnostics.shellcheck),
			b.diagnostics.selene,
			b.diagnostics.markdownlint.with {
				extra_args = { "--disable MD033" },
			},
			b.diagnostics.zsh,
			b.diagnostics.buf,
			b.diagnostics.buildifier,
			b.diagnostics.yamllint,
			b.diagnostics.vulture,
			b.diagnostics.vale,
			b.diagnostics.vint,

			-- NOTE: code actions
			b.code_actions.gitrebase,
			b.code_actions.gitsigns, -- retrieve code actions from lewis6991/gitsigns.nvim
			b.code_actions.shellcheck,
		},
		on_attach = function(client, bufnr)
			local cwd = vim.fn.getcwd()
			for i = 1, #disabled_worksapces do
				if cwd.find(cwd, disabled_worksapces[i]) ~= nil then
					return
				end
			end
			if client.supports_method "textDocument/formatting" and format_on_save then
				vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = augroup,
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format {
							bufnr = bufnr,
							name = "null-ls",
						}
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
end
