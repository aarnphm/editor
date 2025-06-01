return {
  {
    "nuvic/flexoki-nvim",
    name = "flexoki",
    priority = 1000,
    ---@return Options
    opts = function()
      local palette = require "flexoki.palette"
      return {
        styles = {
          italic = true,
        },
        highlight_groups = {
          -- treesitter disabling italics for parameters
          -- because it is kinda annoying
          ["@variable"] = { fg = palette.text, italic = false },
          ["@parameter"] = { fg = palette.purple_two, italic = false },
          ["@variable.parameter"] = { fg = palette.purple_two, italic = false },
          -- normal colorscheme
          StatusLine = { fg = palette.orange_two, bg = palette.overlay },
          StatusLineNC = { bg = palette.overlay },
          QuickFixLine = { bg = palette.highlight_high },
          Winbar = { bg = palette.base },
          WinbarNC = { bg = palette.base },
          AvanteTitle = { bg = palette.red_two },
          AvanteReversedTitle = { fg = palette.red_two },
          AvanteSubtitle = { fg = palette.highlight_med, bg = palette.cyan_two },
          AvanteReversedSubtitle = { fg = palette.cyan_two },
          AvanteThirdTitle = { fg = palette.highlight_med, bg = palette.purple_two },
          AvanteReversedThirdTitle = { fg = palette.purple_two },
          AvanteConflictCurrent = { bg = palette.red_two },
          AvanteConflictIncoming = { bg = palette.green_two },
          -- mini.nvim
          MiniStatuslineModeNormal = { bg = palette.blue_two },
          MiniStatuslineModeVisual = { bg = palette.green_two },
          MiniStatuslineModeInsert = { bg = palette.orange_two },
          MiniStatuslineModeReplace = { bg = palette.red_two },
          MiniStatuslineModeCommand = { bg = palette.purple_two },
          MiniStatuslineModeOther = { bg = palette.purple_two },
        },
      }
    end,
    config = function(_, opts)
      require("flexoki").setup(opts)
      vim.cmd "colorscheme flexoki"
    end,
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
          -- WinBar = { fg = "subtle", bg = "none", blend = 0 },
          -- WinBarNC = { fg = "subtle", bg = "none" },
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
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd "colorscheme rose-pine"
    end,
  },
}
