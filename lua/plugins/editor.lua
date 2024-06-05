return {
  {
    "ggandor/flit.nvim",
    opts = { labeled_modes = "nx" },
    ---@diagnostic disable-next-line: assign-type-mismatch
    keys = function()
      ---@type table<string, LazyKeys[]>
      local ret = {}
      for _, key in ipairs { "f", "F", "t", "T" } do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
      end
      return ret
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    build = false,
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Replace in Files (Spectre)" },
    },
  },
  {
    "ggandor/leap.nvim",
    keys = { { "gs", mode = { "n", "x", "o" }, desc = "motion: Leap from windows" } },
    config = function(_, opts)
      local leap = require "leap"
      for key, val in pairs(opts) do
        leap.opts[key] = val
      end
      leap.add_default_mappings(true)
      vim.keymap.del({ "x", "o" }, "x")
      vim.keymap.del({ "x", "o" }, "X")
    end,
  },
  { "tpope/vim-repeat", event = "VeryLazy" },
  { "tpope/vim-sleuth", event = "VeryLazy" },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
  },
}
