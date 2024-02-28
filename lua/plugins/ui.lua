return {
  {
    "stevearc/dressing.nvim",
    lazy = true,
    opts = {
      input = { border = BORDER, win_options = { winhighlight = "TelescopeNormal:StatusLine" } },
      builtin = { border = BORDER },
    },
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.input(...)
      end
    end,
  },
  {
    "utilyre/barbecue.nvim",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      show_modified = true,
      symbols = {
        ellipsis = "...",
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "BufReadPost",
    opts = { plugins = { presets = { operators = false } } },
    config = function(_, opts) require("which-key").setup(opts) end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = Util.lazy_file_events,
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false },
    },
  },
}
