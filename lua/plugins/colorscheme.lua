local transparent_background = true
local clear = {}

return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    lazy = not (vim.g.simple_colorscheme == "rose-pine"),
    opts = function()
      local opts = {
        dark_variant = "main",
        dim_inactive_windows = false,
        styles = { transparency = not transparent_background },
        highlight_groups = {
          Comment = { fg = "muted", italic = true },
          StatusLine = { fg = "rose", bg = "overlay", blend = 10 },
          StatusLineNC = { fg = "subtle", bg = "overlay" },
          WinBar = { fg = "rose", bg = "overlay", blend = 10 },
          WinBarNC = { fg = "subtle", bg = "overlay" },
          --- nvim-window-picker.nvim
          WindowPickerStatusLine = { fg = "rose", bg = "iris", blend = 10 },
          WindowPickerStatusLineNC = { fg = "subtle", bg = "surface" },
          --- glance.nvim
          GlanceWinBarTitle = { fg = "rose", bg = "iris", blend = 10 },
          GlanceWinBarFilepath = { fg = "subtle", bg = "surface" },
          GlanceWinBarFilename = { fg = "love", bg = "surface" },
          GlancePreviewNormal = { bg = "surface" },
          GlanceListNormal = { bg = "overlay" },
          GlancePreviewMatch = { fg = "love" },
          --- headlines.nvim
          Headline1 = { bg = "surface" },
          Headline2 = { bg = "gold" },
          Headline3 = { bg = "rose" },
          Headline4 = { bg = "pine" },
          Headline5 = { bg = "foam" },
          Headline6 = { bg = "iris" },
        },
      }
      if vim.g.simple_background == "light" then
        opts.highlight_groups = vim.tbl_extend("force", opts.highlight_groups, { IblScope = { fg = "rose" } })
      end
      return opts
    end,
  },
  { "kepano/flexoki-neovim", name = "flexoki" },
}
