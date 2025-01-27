if not vim.g.vscode then return {} end

local enabled = {
  "flit.nvim",
  "lazy.nvim",
  "leap.nvim",
  "mini.ai",
  "mini.surround",
  "nvim-treesitter",
  "nvim-treesitter-textobjects",
  "snacks.nvim",
  "ts-comments.nvim",
  "vim-repeat",
}

local Config = require "lazy.core.config"
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
Config.options.defaults.cond = function(plugin) return vim.tbl_contains(enabled, plugin.name) or plugin.vscode end

return {
  {
    "snacks.nvim",
    opts = {
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      picker = { enabled = false },
      quickfile = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { highlight = { enable = false } },
  },
}
