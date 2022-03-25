local colors = {}

local M = {}

local supported_themes = {
  "catppuccin",
  "dracula",
  "github",
  "gruvbox",
  "kanagawa",
  "nightfox",
  "nord",
  "onedark",
  "rose-pine",
  "tokyonight",
  "tender",
  "papercolor",
  "edge",
}

function M.init()
  for _, theme in pairs(supported_themes) do
    if theme == _G.__editor_config.colorscheme then
      colors = require("themes.integrated." .. theme)
    end
  end

  if vim.tbl_isempty(colors) then
    return false
  end

  return colors
end

return M
