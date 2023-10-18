return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      numhl = true,
      watch_gitdir = { interval = 1000, follow_files = true },
      current_line_blame = true,
      current_line_blame_opts = { delay = 1000, virtual_text_pos = "eol" },
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      word_diff = false,
      diff_opts = { internal = true },
      on_attach = function(bufnr)
        local actions = require "gitsigns.actions"
        local kmap = function(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc }) end
        kmap("n", "]h", actions.next_hunk, "git: next hunk")
        kmap("n", "[h", actions.prev_hunk, "git: prev hunk")
        kmap("n", "<leader>hu", actions.undo_stage_hunk, "git: undo stage hunk")
        kmap("n", "<leader>hR", actions.reset_buffer, "git: reset buffer")
        kmap("n", "<leader>hS", actions.stage_buffer, "git: stage buffer")
        kmap("n", "<leader>hp", actions.preview_hunk, "git: preview hunk")
        kmap("n", "<leader>hd", actions.diffthis, "git: diff this")
        kmap("n", "<leader>hD", function() actions.diffthis "~" end, "git: diff this ~")
        kmap("n", "<leader>hb", function() actions.blame_line { full = true } end, "git: blame Line")
        kmap({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "git: stage hunk")
        kmap({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "git: reset hunk")
        kmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
}
