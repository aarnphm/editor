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
    event = Util.lazy_file_events,
    ---@type Gitsigns.Config
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc }) end
        map("n", "]h", gs.next_hunk, "git: next hunk")
        map("n", "[h", gs.prev_hunk, "git: prev hunk")
        map("n", "<leader>hu", gs.undo_stage_hunk, "git: undo stage hunk")
        map("n", "<leader>hR", gs.reset_buffer, "git: reset buffer")
        map("n", "<leader>hS", gs.stage_buffer, "git: stage buffer")
        map("n", "<leader>hp", gs.preview_hunk, "git: preview hunk")
        map("n", "<leader>hd", gs.diffthis, "git: diff this")
        map("n", "<leader>hD", function() gs.diffthis "~" end, "git: diff this ~")
        map("n", "<leader>hb", function() gs.blame_line { full = true } end, "git: blame Line")
        map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "git: stage hunk")
        map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "git: reset hunk")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
}
