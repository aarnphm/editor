return {
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "<leader>R", "", desc = "+Rest" },
      { "<leader>Rs", function() require("kulala").run() end, desc = "curl: send request" },
      { "<leader>Rt", function() require("kulala").toggle_view() end, desc = "curl: toggle headers/body" },
      { "<leader>Rp", function() require("kulala").jump_prev() end, desc = "curl: jump to previous requests" },
      { "<leader>Rn", function() require("kulala").jump_next() end, desc = "curl: jump to next requests" },
    },
    opts = {},
  },
  {
    "andweeb/presence.nvim",
    event = "LazyFile",
    opts = { enable_line_number = true },
  },
  {
    "yetone/avante.nvim",
    dev = true,
    version = false,
    event = "VeryLazy",
    cmd = "AvanteAsk",
    build = "make",
    dependencies = {
      {
        "grapp-dev/nui-components.nvim",
        dependencies = {
          "MunifTanjim/nui.nvim",
        },
      },
    },
    ---@type avante.Config
    opts = {
      mappings = {
        ask = "<leader>ua",
        refresh = "<leader>ur",
      },
    },
  },
}
