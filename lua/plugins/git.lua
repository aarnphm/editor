return {
  "tpope/vim-fugitive",
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
      { "<leader>hh", ":Gitsigns setqflist<CR>", mode = { "n", "v" }, desc = "git: set qflist" },
      { "ih", ":<C-U>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "git: select hunk" },
    },
    ---@type Gitsigns.Config
    opts = {
      numhl = true,
      attach_to_untracked = true,
      _new_sign_calc = true,
      _refresh_staged_on_update = true,
    },
  },
}
