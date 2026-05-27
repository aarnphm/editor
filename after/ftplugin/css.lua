Util.lsp.formatters({ "css", "scss", "less" }, { "oxfmt", lsp_format = "never" })
Util.lsp.on_attach("cssls", "disable_formatting", function(client)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
  client.server_capabilities.documentOnTypeFormattingProvider = nil
end)
Util.lsp.enable("cssls", {
  init_options = { provideFormatter = false },
  settings = {
    css = { format = { enable = false }, validate = true },
    scss = { format = { enable = false }, validate = true },
    less = { format = { enable = false }, validate = true },
  },
})
Util.lsp.ensure_mason_packages({ "css-lsp" }, { ["css-lsp"] = "cssls" })

vim.cmd.runtime "after/ftplugin/tailwindcss.lua"
