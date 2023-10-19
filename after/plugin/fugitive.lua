vim.keymap.set("n", "<leader>gs", "<cmd>vertical Git<CR>", { desc = "fugitive" })

local autocmd = vim.api.nvim_create_autocmd

autocmd("BufWinEnter", {
  group = augroup "Fugitive",
  pattern = "*",
  callback = function()
    if vim.bo.ft ~= "fugitive" then return end
    local bufnr = vim.api.nvim_get_current_buf()
    vim.keymap.set(
      "n",
      "<leader>p",
      "<CMD>Git pull --rebase<CR>",
      { desc = "git: pull rebase", buffer = bufnr, remap = false }
    )
    vim.keymap.set(
      "n",
      "<leader>P",
      function() vim.cmd.Git "push" end,
      { desc = "git: push", buffer = bufnr, remap = false }
    )
    vim.keymap.set(
      "n",
      "<leader>cc",
      "<CMD>Git commit -S --signoff -sv<CR>",
      { desc = "git: commit", buffer = bufnr, remap = false }
    )
    vim.keymap.set(
      "n",
      "<leader>t",
      ":Git push -u origin ",
      { desc = "git: push to specific branch", buffer = bufnr, remap = false }
    )
  end,
})
