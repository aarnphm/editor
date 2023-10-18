vim.keymap.set("n", "<Leader>so", function() require("spectre").open() end, { desc = "replace: Open panel" })
vim.keymap.set("v", "<Leader>so", function() require("spectre").open_visual() end, { desc = "replace: Open panel" })
vim.keymap.set(
  "n",
  "<Leader>sw",
  function() require("spectre").open_visual { select_word = true } end,
  { desc = "replace: Replace word under cursor" }
)
vim.keymap.set(
  "n",
  "<Leader>sp",
  function() require("spectre").open_file_search() end,
  { desc = "replace: Replace word under file search" }
)
