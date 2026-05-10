Util.lsp.formatters({ "json", "jsonc" }, { "prettier" })
Util.lint.linters({ "json", "jsonc" }, { "jsonlint" })
Util.lsp.enable("jsonls", {
  settings = {
    json = {
      format = { enable = true },
      validate = { enable = true },
    },
  },
})

vim.bo.commentstring = "// %s"
vim.bo.formatprg = "jq"
