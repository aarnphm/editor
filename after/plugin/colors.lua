-- colorscheme
Util.pack.load "flexoki"

local ok, flexoki = pcall(require, "flexoki")
if not ok then
  vim.cmd.colorscheme "habamax"
else
  local c = require("flexoki.palette").palette()
  local diff_preview_fg = c._name == "light" and "#ffffff" or "#000000"
  local diff_preview_change_fg = "#000000"
  flexoki.setup {
    float_window_style = "border",
    highlight_groups = {
      -- Tree-sitter
      ["@variable"] = { fg = c.tx, italic = false },
      ["@parameter"] = { fg = c["pu-2"], italic = false },
      ["@variable.parameter"] = { fg = c["pu-2"], italic = false },
      ["@markup.heading.1.markdown"] = { fg = c["bl-2"], bold = true },
      ["@markup.heading.2.markdown"] = { fg = c["pu-2"], bold = true },
      ["@markup.heading.3.markdown"] = { fg = c["ma-2"], bold = true },
      ["@markup.heading.4.markdown"] = { fg = c["cy-2"], bold = true },
      ["@markup.heading.5.markdown"] = { fg = c["gr-2"], bold = true },
      ["@markup.heading.6.markdown"] = { fg = c["or-2"], bold = true },

      StatusLine = { fg = c.tx, bg = c.ui },
      StatusLineNC = { fg = c["tx-2"], bg = c.ui },
      WinSeparator = { fg = c["ui-2"], bg = c.bg },
      VertSplit = { link = "WinSeparator" },
      FloatBorder = { fg = c["ui-2"], bg = c.bg },
      FloatTitle = { fg = c["cy-2"], bg = c.bg },
      FloatFooter = { link = "FloatTitle" },
      MsgArea = { fg = c.tx, bg = c.bg },
      MsgSeparator = { fg = c["tx-3"], bg = c.bg },
      ModeMsg = { fg = c.tx, bg = c.bg },
      MoreMsg = { fg = c["pu-2"], bg = c.bg },
      Question = { fg = c["or-2"], bg = c.bg },
      ErrorMsg = { fg = c["re-2"], bg = c.bg },
      WarningMsg = { fg = c["or-2"], bg = c.bg },
      SimpleStatusline = { fg = c.tx, bg = c.ui },
      SimpleStatuslineModeNormal = { fg = c.bg, bg = c["bl-2"], bold = true },
      SimpleStatuslineModeInsert = { fg = c.bg, bg = c["gr-2"], bold = true },
      SimpleStatuslineModeVisual = { fg = c.bg, bg = c["ma-2"], bold = true },
      SimpleStatuslineModeReplace = { fg = c.bg, bg = c["re-2"], bold = true },
      SimpleStatuslineModeCommand = { fg = c.bg, bg = c["ye-2"], bold = true },
      SimpleStatuslineModeOther = { fg = c.bg, bg = c["pu-2"], bold = true },
      SimpleStatuslineAccent = { fg = c["bl-2"], bg = c.ui },
      SimpleStatuslineDebug = { fg = c["or-2"], bg = c.ui },
      SimpleStatuslineWarn = { fg = c["or-2"], bg = c.ui },
      SimpleStatuslineFile = { fg = c.tx, bg = c.ui, bold = true },
      SimpleStatuslineInfo = { fg = c["pu-2"], bg = c.ui },
      SimpleStatuslineFormatter = { fg = c["ma-2"], bg = c.ui },
      SimpleStatuslineLint = { fg = c["gr-2"], bg = c.ui },
      SimpleStatuslineLintRunning = { fg = c["ye-2"], bg = c.ui, bold = true },
      SimpleStatuslineMuted = { fg = c["tx-3"], bg = c.ui },
      SimpleStatuslineLocation = { fg = c["cy-2"], bg = c.ui },
      QuickFixLine = { bg = c["ui-3"] },
      WinBar = { bg = c.bg },
      WinBarNC = { bg = c.bg },
      LspCodeLens = { fg = c["pu-2"], italic = true },
      LspCodeLensSeparator = { fg = c["tx-3"], italic = true },
      DropBarMenuCurrentContext = { bg = c.bg },

      -- grug-far.nvim
      GrugFarHelpHeader = { fg = c["bl-2"] },
      GrugFarHelpHeaderKey = { fg = c["or-2"] },
      GrugFarHelpWinActionKey = { fg = c["or-2"] },
      GrugFarHelpWinActionPrefix = { fg = c["cy-2"] },
      GrugFarHelpWinActionText = { fg = c["bl-2"] },
      GrugFarHelpWinHeader = { link = "FloatTitle" },
      GrugFarInputLabel = { fg = c["cy-2"] },
      GrugFarInputPlaceholder = { link = "Comment" },
      GrugFarResultsActionMessage = { fg = c["cy-2"] },
      GrugFarResultsChangeIndicator = { fg = c["ye-2"] },
      GrugFarResultsHeader = { fg = c["bl-2"] },
      GrugFarResultsLineNo = { fg = c["pu-2"] },
      GrugFarResultsLineColumn = { link = "GrugFarResultsLineNo" },
      GrugFarResultsMatch = { link = "CurSearch" },
      GrugFarResultsPath = { fg = c["cy-2"] },
      GrugFarResultsStats = { fg = c["pu-2"] },

      -- gitsigns.nvim
      GitSignsAdd = { link = "SignAdd" },
      GitSignsChange = { link = "SignChange" },
      GitSignsDelete = { link = "SignDelete" },
      GitSignsAddPreview = { fg = diff_preview_fg, bg = c.gr },
      GitSignsDeletePreview = { fg = diff_preview_fg, bg = c.re },
      GitSignsAddInline = { fg = diff_preview_fg, bg = c.gr },
      GitSignsChangeInline = { fg = diff_preview_change_fg, bg = c.ye },
      GitSignsDeleteInline = { fg = diff_preview_fg, bg = c.re },
      SignAdd = { fg = c["gr-2"], bg = "NONE" },
      SignChange = { fg = c["ye-2"], bg = "NONE" },
      SignDelete = { fg = c["re-2"], bg = "NONE" },
    },
  }
  vim.cmd.colorscheme "flexoki"
end
