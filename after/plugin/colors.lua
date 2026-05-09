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
      StatusLine = { fg = palette.orange_two, bg = palette.overlay },
      StatusLineNC = { bg = palette.overlay },
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
