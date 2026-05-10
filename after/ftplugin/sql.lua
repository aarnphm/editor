local sql_filetypes = { "sql", "mysql", "plsql", "ddl" }

Util.lsp.formatters(sql_filetypes, { "sqlfluff" })
Util.lint.linters(sql_filetypes, { "sqlfluff" })

vim.bo.commentstring = "-- %s"
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
