return {
  { "AstroNvim/astrotheme", priority = 1000, opts = {}, enabled = false },
  { "folke/tokyonight.nvim", priority = 1000, opts = {}, enabled = true },
  { "navarasu/onedark.nvim", priority = 1000, opts = {}, enabled = true },
  { "rmehri01/onenord.nvim", priority = 1000, opts = {}, enabled = false },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = function()
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
