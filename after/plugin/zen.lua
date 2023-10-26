vim.keymap.set("n", "<leader>zz", function()
  require("zen-mode").setup {
    window = { width = 0.85, options = {} },
  }
  require("zen-mode").toggle()
  vim.wo.wrap = false
  vim.wo.number = true
  vim.wo.rnu = true
  vim.o.laststatus = 0
  vim.cmd [[do VimResized]]
end, { desc = "zen: neutral" })

vim.keymap.set("n", "<leader>zZ", function()
  require("zen-mode").setup {
    window = { width = 0.79, options = {} },
  }
  require("zen-mode").toggle()
  vim.wo.wrap = false
  vim.wo.number = false
  vim.wo.rnu = false
  vim.opt.colorcolumn = "0"
  vim.o.laststatus = 0
  vim.cmd [[do VimResized]]
end, { desc = "zen: no colorcolumn" })
