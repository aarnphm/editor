Util.lsp.formatters("yaml", { "oxfmt", lsp_format = "never" })
Util.lsp.on_attach("yamlls", "disable_formatting", function(client)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
  client.server_capabilities.documentOnTypeFormattingProvider = nil
end)
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
      format = { enable = false },
      validate = true,
      schemaStore = { enable = true },
    },
  },
})

vim.bo.commentstring = "# %s"
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
