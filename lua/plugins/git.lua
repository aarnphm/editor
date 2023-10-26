return {
  "tpope/vim-fugitive",
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    ---@type DiffviewConfig
    opts = { diff_binaries = true },
    keys = { { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "DiffView" } },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    ---@type Gitsigns.Config
    opts = {
      numhl = true,
      watch_gitdir = { interval = 1000, follow_files = true },
      current_line_blame = true,
      current_line_blame_opts = { delay = 1000, virtual_text_pos = "eol" },
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      word_diff = false,
      preview_config = { border = "none" },
      diff_opts = { internal = true },
      on_attach = function(bufnr)
        local actions = require "gitsigns.actions"
        local map = function(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc }) end
        map("n", "]h", actions.next_hunk, "git: next hunk")
        map("n", "[h", actions.prev_hunk, "git: prev hunk")
        map("n", "<leader>hu", actions.undo_stage_hunk, "git: undo stage hunk")
        map("n", "<leader>hR", actions.reset_buffer, "git: reset buffer")
        map("n", "<leader>hS", actions.stage_buffer, "git: stage buffer")
        map("n", "<leader>hp", actions.preview_hunk, "git: preview hunk")
        map("n", "<leader>hd", actions.diffthis, "git: diff this")
        map("n", "<leader>hD", function() actions.diffthis "~" end, "git: diff this ~")
        map("n", "<leader>hb", function() actions.blame_line { full = true } end, "git: blame Line")
        map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "git: stage hunk")
        map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "git: reset hunk")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
}
