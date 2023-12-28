local dropbar_disable = {
  "fugitive",
  "spectre_panel",
  "neorepl",
  "alpha",
  "terminal",
  "toggleterm",
  "starter",
}

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
    "kevinhwang91/nvim-bqf",
    lazy = true,
    ft = "qf",
    opts = { preview = { border = BORDER, wrap = true, winblend = 0 } },
  },
  {
    "Bekaboo/dropbar.nvim",
    enabled = vim.fn.has "nvim-0.10" == 1,
    event = Util.lazy_file_events,
    version = false,
    ---@type dropbar_configs_t
    config = {
      general = {
        enable = function(buf, win)
          return not vim.api.nvim_win_get_config(win).zindex
            and vim.bo[buf].buftype == ""
            and (not vim.tbl_contains(dropbar_disable, vim.bo[buf].buftype))
            and vim.api.nvim_buf_get_name(buf) ~= ""
            and not vim.wo[win].diff
        end,
      },
      icons = {
        enable = true,
        ui = {
          bar = { separator = "  ", extends = "…" },
          menu = { separator = " ", indicator = "  " },
        },
      },
    },
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    config = true,
    opts = {
      progress = { display = { render_limit = 5, done_ttl = 2 } },
      notification = { window = { winblend = 20, zindex = 75 } },
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
    event = Util.lazy_file_events,
    main = "ibl",
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "", -- for all buffers without a file type
          "alpha",
          "fugitive",
          "aerial",
          "git",
          "gitcommit",
          "help",
          "json",
          "log",
          "markdown",
          "neo-tree",
          "Outline",
          "startify",
          "TelescopePrompt",
          "txt",
          "undotree",
          "vimwiki",
          "vista",
          "lazyterm",
        },
        buftypes = { "terminal", "nofile", "quickfix", "prompt" },
      },
    },
    config = function(_, opts) require("ibl").setup(opts) end,
  },
}
