-- colorscheme
Util.pack.load "flexoki"

local ok, palette = pcall(require, "flexoki.palette")
if not ok then
  vim.cmd.colorscheme "habamax"
else
  require("flexoki").setup {
    styles = { italic = true },
    highlight_groups = {
      ["@variable"] = { fg = palette.text, italic = false },
      ["@parameter"] = { fg = palette.purple_two, italic = false },
      ["@variable.parameter"] = { fg = palette.purple_two, italic = false },
      StatusLine = { fg = palette.text, bg = palette.overlay },
      StatusLineNC = { fg = palette.muted, bg = palette.overlay },
      SimpleStatusline = { fg = palette.text, bg = palette.overlay },
      SimpleStatuslineModeNormal = { fg = palette.base, bg = palette.blue_two, bold = true },
      SimpleStatuslineModeInsert = { fg = palette.base, bg = palette.green_two, bold = true },
      SimpleStatuslineModeVisual = { fg = palette.base, bg = palette.magenta_two, bold = true },
      SimpleStatuslineModeReplace = { fg = palette.base, bg = palette.red_two, bold = true },
      SimpleStatuslineModeCommand = { fg = palette.base, bg = palette.yellow_two, bold = true },
      SimpleStatuslineModeOther = { fg = palette.base, bg = palette.purple_two, bold = true },
      SimpleStatuslineAccent = { fg = palette.blue_two, bg = palette.overlay },
      SimpleStatuslineWarn = { fg = palette.orange_two, bg = palette.overlay },
      SimpleStatuslineFile = { fg = palette.text, bg = palette.overlay, bold = true },
      SimpleStatuslineInfo = { fg = palette.purple_two, bg = palette.overlay },
      SimpleStatuslineMuted = { fg = palette.muted, bg = palette.overlay },
      SimpleStatuslineLocation = { fg = palette.cyan_two, bg = palette.overlay },
      QuickFixLine = { bg = palette.highlight_high },
      WinBar = { bg = palette.base },
      WinBarNC = { bg = palette.base },
      LspCodeLens = { fg = palette.purple_two, italic = true },
      LspCodeLensSeparator = { fg = palette.muted, italic = true },
      DropBarMenuCurrentContext = { bg = palette.base },
    },
  }
  vim.cmd.colorscheme "flexoki"
end
