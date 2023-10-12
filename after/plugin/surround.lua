local opts = {
  mappings = {
    add = "sa", -- Add surrounding in Normal and Visual modes
    delete = "sd", -- Delete surrounding
    find = "sf", -- Find surrounding (to the right)
    find_left = "sF", -- Find surrounding (to the left)
    highlight = "sh", -- Highlight surrounding
    replace = "sr", -- Replace surrounding
    update_n_lines = "sn", -- Update `n_lines`
  },
}

vim.keymap.set({ "n", "v" }, opts.mappings.add, "", { desc = "Add surrounding" })
vim.keymap.set("n", opts.mappings.delete, "", { desc = "Delete surrounding" })
vim.keymap.set("n", opts.mappings.find, "", { desc = "Find right surrounding" })
vim.keymap.set("n", opts.mappings.find_left, "", { desc = "Find left surrounding" })
vim.keymap.set("n", opts.mappings.highlight, "", { desc = "Highlight surrounding" })
vim.keymap.set("n", opts.mappings.replace, "", { desc = "Replace surrounding" })
vim.keymap.set("n", opts.mappings.update_n_lines, "", { desc = "Update  `MiniSurround.config.n_lines`" })
