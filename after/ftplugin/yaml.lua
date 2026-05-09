Util.lsp.formatters("yaml", { "prettier" })
Util.lsp.enable("yamlls", {
  capabilities = {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      },
    },
  },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      keyOrdering = false,
      format = { enable = true, singleQuote = true, bracketSpacing = false, printWidth = 120 },
      validate = true,
      schemaStore = { enable = true },
    },
  },
})

vim.bo.commentstring = "# %s"
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
