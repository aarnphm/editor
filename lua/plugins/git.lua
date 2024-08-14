return {
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      numhl = true,
      preview_config = { border = BORDER.impl "git" },
      on_attach = function(bufnr)
        local map = function(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc }) end

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            require("gitsigns.actions").nav_hunk "next"
          end
        end, "git: next hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            require("gitsigns.actions").nav_hunk "prev"
          end
        end, "git: prev hunk")
        map(
          "n",
          "<leader>hb",
          function() require("gitsigns.actions").blame_line { full = true } end,
          "git: blame line"
        )
        map("n", "]H", function() require("gitsigns.actions").nav_hunk "last" end, "git: last hunk")
        map("n", "[H", function() require("gitsigns.actions").nav_hunk "first" end, "git: first hunk")
        map("n", "<leader>hu", require("gitsigns.actions").undo_stage_hunk, "git: undo stage hunk")
        map("n", "<leader>hR", require("gitsigns.actions").reset_buffer, "git: reset buffer")
        map("n", "<leader>hS", require("gitsigns.actions").stage_buffer, "git: stage buffer")
        map("n", "<leader>hp", require("gitsigns.actions").preview_hunk_inline, "git: preview hunk inline")
        map("n", "<leader>hP", require("gitsigns.actions").preview_hunk, "git: preview hunk")
        map("n", "<leader>hd", require("gitsigns.actions").diffthis, "git: diff this")
        map("n", "<leader>hD", function() require("gitsigns.actions").diffthis "~" end, "git: diff this ~")
        map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "git: stage hunk")
        map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "git: reset hunk")
        map({ "n", "v" }, "<leader>ugl", ":Gitsigns toggle_linehl<CR>", "git: toggle linehl")
        map({ "n", "v" }, "<leader>ugw", ":Gitsigns toggle_word_diff<CR>", "git: toggle word diff")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "git: select hunk")
      end,
    },
  },
}
