return {
  {
    "nuvic/flexoki-nvim",
    name = "flexoki",
    priority = 1000,
    config = function() vim.cmd "colorscheme flexoki" end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    enabled = false,
    opts = function()
      local palette = require "rose-pine.palette"
      local opts = {
        variant = "auto",
        dark_variant = "main",
        styles = { italic = false },
        highlight_groups = {
          StatusLine = { fg = "rose", bg = "overlay", blend = 0 },
          QuickFixLine = { bg = "highlight_high" },
          WinBar = { fg = "subtle", bg = "none", blend = 0 },
          WinBarNC = { fg = "subtle", bg = "none" },
          --- nvim-window-picker.nvim
          WindowPickerStatusLine = { fg = "rose", bg = "iris", blend = 10 },
          WindowPickerStatusLineNC = { fg = "subtle", bg = "surface" },
          --- indentmini.nvim
          IndentLine = { fg = "highlight_low" },
          IndentLineCurrent = { fg = "subtle" },
          MiniIndentscopeSymbol = { fg = "rose", bg = "NONE" },
        },
      }

      -- get background, if it is light, change the IblScope to rose
      if vim.api.nvim_get_option_value("background", {}) == "light" then
        opts.highlight_groups = vim.tbl_extend("force", opts.highlight_groups, { IblScope = { fg = palette.rose } })
      end
      return opts
    end,
  },
}
