Util.lsp.formatters("go", { "goimports", "gofumpt" })
Util.lsp.enable("gopls", {
  settings = {
    gopls = {
      gofumpt = true,
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
      semanticTokens = true,
    },
  },
})

Util.lsp.on_attach("gopls", "semantic_tokens_fallback", function(client)
  if client.server_capabilities.semanticTokensProvider then return end

  local semantic = client.config.capabilities
    and client.config.capabilities.textDocument
    and client.config.capabilities.textDocument.semanticTokens
  if semantic then
    client.server_capabilities.semanticTokensProvider = {
      full = true,
      legend = {
        tokenTypes = semantic.tokenTypes,
        tokenModifiers = semantic.tokenModifiers,
      },
      range = true,
    }
  end
end)

vim.bo.expandtab = false
vim.bo.tabstop = 4
vim.bo.shiftwidth = 0
vim.bo.softtabstop = 0
vim.bo.commentstring = "// %s"

vim.keymap.set("n", "<leader>ct", vim.lsp.codelens.run, { buffer = true, desc = "go: run codelens" })
