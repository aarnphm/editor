vim.bo.commentstring = "// %s"
vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true

vim.keymap.set("n", "<leader>cR", vim.lsp.buf.code_action, { buffer = true, desc = "rust: code action" })
vim.keymap.set("n", "<leader>dr", vim.lsp.codelens.run, { buffer = true, desc = "rust: run codelens" })
