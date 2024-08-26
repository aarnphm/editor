return {
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    keys = {
      {
        "]h",
        function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            require("gitsigns.actions").nav_hunk "next"
          end
        end,
        desc = "git: next hunk",
      },
      {
        "[h",
        function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            require("gitsigns.actions").nav_hunk "prev"
          end
        end,
        desc = "git: prev hunk",
      },
      {
        "<leader>hb",
        function() require("gitsigns.actions").blame_line { full = true } end,
        desc = "git: blame line",
      },
      {
        "[H",
        function() require("gitsigns.actions").nav_hunk "first" end,
        desc = "git: first hunk",
      },
      {
        "[H",
        function() require("gitsigns.actions").nav_hunk "last" end,
        desc = "git: last hunk",
      },
      {
        "<leader>hp",
        function() require("gitsigns.actions").preview_hunk_inline() end,
        desc = "git: preview hunk inline",
      },
      {
        "<leader>hP",
        function() require("gitsigns.actions").preview_hunk() end,
        desc = "git: preview hunk",
      },
      { "<leader>hR", ":Gitsigns reset_buffer<CR>", desc = "git: reset buffer" },
      { "<leader>hS", ":Gitsigns stage_buffer<CR>", desc = "git: stage buffer" },
      { "<leader>hs", ":Gitsigns stage_hunk<CR>", mode = { "n", "v" }, desc = "git: stage hunk" },
      { "<leader>hr", ":Gitsigns reset_hunk<CR>", mode = { "n", "v" }, desc = "git: reset hunk" },
      { "<leader>ugl", ":Gitsigns toggle_linehl<CR>", mode = { "n", "v" }, desc = "git: toggle linehl" },
      { "<leader>ugw", ":Gitsigns toggle_word_diff<CR>", mode = { "n", "v" }, desc = "git: toggle word diff" },
      { "ih", ":<C-U>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "git: select hunk" },
    },
    opts = {
      numhl = true,
      preview_config = { border = BORDER.impl("git", "NormalFloat", 1) },
    },
  },
}
