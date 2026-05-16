-- colorscheme
Util.pack.load "flexoki"

local ok, flexoki = pcall(require, "flexoki")
if not ok then
  vim.cmd.colorscheme "habamax"
else
  flexoki.setup {
    styles = { italic = true },
    highlight_groups = {
      ["@variable"] = { fg = "text", italic = false },
      ["@parameter"] = { fg = "purple_two", italic = false },
      ["@variable.parameter"] = { fg = "purple_two", italic = false },
      StatusLine = { fg = "text", bg = "overlay" },
      StatusLineNC = { fg = "muted", bg = "overlay" },
      SimpleStatusline = { fg = "text", bg = "overlay" },
      SimpleStatuslineModeNormal = { fg = "base", bg = "blue_two", bold = true },
      SimpleStatuslineModeInsert = { fg = "base", bg = "green_two", bold = true },
      SimpleStatuslineModeVisual = { fg = "base", bg = "magenta_two", bold = true },
      SimpleStatuslineModeReplace = { fg = "base", bg = "red_two", bold = true },
      SimpleStatuslineModeCommand = { fg = "base", bg = "yellow_two", bold = true },
      SimpleStatuslineModeOther = { fg = "base", bg = "purple_two", bold = true },
      SimpleStatuslineAccent = { fg = "blue_two", bg = "overlay" },
      SimpleStatuslineWarn = { fg = "orange_two", bg = "overlay" },
      SimpleStatuslineFile = { fg = "text", bg = "overlay", bold = true },
      SimpleStatuslineInfo = { fg = "purple_two", bg = "overlay" },
      SimpleStatuslineLint = { fg = "green_two", bg = "overlay" },
      SimpleStatuslineLintRunning = { fg = "yellow_two", bg = "overlay", bold = true },
      SimpleStatuslineMuted = { fg = "muted", bg = "overlay" },
      SimpleStatuslineLocation = { fg = "cyan_two", bg = "overlay" },
      QuickFixLine = { bg = "highlight_high" },
      WinBar = { bg = "base" },
      WinBarNC = { bg = "base" },
      LspCodeLens = { fg = "purple_two", italic = true },
      LspCodeLensSeparator = { fg = "muted", italic = true },
      DropBarMenuCurrentContext = { bg = "base" },
    },
  }
  vim.cmd.colorscheme "flexoki"
end
