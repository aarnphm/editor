return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = function()
      local opts = {
        variant = "auto",
        dark_variant = "main",
        dim_inactive_windows = false,
        enable = { migrations = true },
        styles = { transparency = false, italic = false },
        highlight_groups = {
          Comment = { fg = "muted", italic = true },
          StatusLine = { fg = "rose", bg = "overlay", blend = 0 },
          QuickFixLine = { bg = "highlight_high" },
          StatusLineNC = { fg = "subtle", bg = "overlay" },
          WinBar = { fg = "subtle", bg = "none", blend = 0 },
          WinBarNC = { fg = "subtle", bg = "none" },
          --- nvim-window-picker.nvim
          WindowPickerStatusLine = { fg = "rose", bg = "iris", blend = 10 },
          WindowPickerStatusLineNC = { fg = "subtle", bg = "surface" },
          --- mini.files
          MiniFilesBorder = { bg = "none" },
          MiniFilesNormal = { bg = "none" },
          --- glance.nvim
          GlanceWinBarTitle = { fg = "rose", bg = "overlay" },
          GlanceWinBarFilepath = { fg = "subtle" },
          GlanceWinBarFilename = { fg = "love" },
          GlancePreviewNormal = { bg = "surface" },
          GlanceListNormal = { bg = "overlay" },
          -- GlancePreviewMatch = { fg = "love" },
          GlanceBorderTop = { bg = "none", blend = 0 },
          GlanceListBorderBottom = { bg = "none", blend = 0 },
          GlancePreviewBorderBottom = { bg = "none", blend = 0 },
        },
      }

      -- get background, if it is light, change the IblScope to rose
      if vim.api.nvim_get_option_value("background", {}) == "light" then opts.highlight_groups = vim.tbl_extend("force", opts.highlight_groups, { IblScope = { fg = "rose" } }) end
      return opts
    end,
  },
}
