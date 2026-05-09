vim.bo.expandtab = false
vim.bo.tabstop = 4
vim.bo.shiftwidth = 0
vim.bo.softtabstop = 0
vim.bo.commentstring = "// %s"

vim.keymap.set("n", "<leader>ct", vim.lsp.codelens.run, { buffer = true, desc = "go: run codelens" })
