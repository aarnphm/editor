return {
  {
    "nuvic/flexoki-nvim",
    name = "flexoki",
    enabled = true,
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
          -- avante.nvim
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
          -- dropbar.nvim
          DropBarMenuCurrentContext = { bg = palette.base },
        },
      }
    end,
    config = function(_, opts)
      require("flexoki").setup(opts)
      vim.cmd "colorscheme flexoki"
    end,
  },
}
