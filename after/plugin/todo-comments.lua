vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "todo: Next comment" })
vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "todo: Previous comment" })
