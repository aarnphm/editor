return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = function()
      local opts = {
        dark_variant = "main",
        dim_inactive_windows = false,
        enable = { migrations = true },
        styles = { transparency = false, italic = false },
        highlight_groups = {
          Comment = { fg = "muted", italic = true },
          StatusLine = { fg = "rose", bg = "overlay", blend = 0 },
          StatusLineNC = { fg = "subtle", bg = "overlay" },
          WinBar = { fg = "subtle", bg = "none", blend = 0 },
          WinBarNC = { fg = "subtle", bg = "none" },
          --- nvim-window-picker.nvim
          WindowPickerStatusLine = { fg = "rose", bg = "iris", blend = 10 },
          WindowPickerStatusLineNC = { fg = "subtle", bg = "surface" },
          --- telescope.nvim
          TelescopeNormal = { bg = "none" },
          TelescopeBorder = { bg = "none" },
          --- mini.files
          MiniFilesBorder = { bg = "none" },
          MiniFilesNormal = { bg = "none" },
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

      -- get background, if it is light, change the IblScope to rose
      if vim.api.nvim_get_option_value("background", {}) == "light" then
        opts.highlight_groups = vim.tbl_extend("force", opts.highlight_groups, { IblScope = { fg = "rose" } })
      end
      return opts
    end,
  },
}
