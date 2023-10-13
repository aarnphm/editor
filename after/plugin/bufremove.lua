vim.keymap.set("n", "<C-x>", function() require("mini.bufremove").delete(0, false) end, { desc = "buf: delete" })
vim.keymap.set("n", "<C-q>", function() require("mini.bufremove").delete(0, true) end, { desc = "buf: force delete" })
