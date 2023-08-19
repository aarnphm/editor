local builtin = require('telescope.builtin')

vim.keymap.set('n', 'gI', function(...)
  builtin.lsp_implementation { reuse_win = true }
end, { desc = 'lsp: Goto implementation' })
vim.keymap.set('n', 'gY', function(...)
  builtin.lsp_type_definitions { reuse_win = true }
end, { desc = 'lsp: Goto type definitions' })
vim.keymap.set('n', '<C-p>', function(...)
  builtin.keymaps {
    lhs_filter = function(lhs) return not string.find(lhs, "Þ") end,
    layout_config = {
      width = 0.6,
      height = 0.6,
      prompt_position = "top",
    },
  }
end, { desc = "telescope: Keymaps", noremap = true, silent = true })
vim.keymap.set('n', '<leader>b', function(...)
  builtin.buffers {
    layout_config = { width = 0.6, height = 0.6, prompt_position = "top" },
    show_all_buffers = true,
    previewer = false,
  }
end, { desc = "telescope: Manage buffers" })
vim.keymap.set('n', "<leader>f", builtin.find_files, { desc = "telescope: Find files" })
vim.keymap.set('n', "<LocalLeader>f", builtin.git_files, { desc = "telescope: Find files (git)" })
vim.keymap.set("n", "<leader>/", function()
  builtin.grep_string { word_match = '-w' }
end, { desc = "telescope: Grep string" })
vim.keymap.set("v", "<leader>/", builtin.grep_string, { desc = "telescope: Grep string" })
vim.keymap.set("n", "<leader>w",
  function() require("telescope").extensions.live_grep_args.live_grep_args() end,
  { desc = "telescope: Help tags" })
