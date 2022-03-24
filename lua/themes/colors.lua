local colors = {}
local mod = "themes.integrated."
local supported_themes = require("themes.plugins").supported_themes

local M = {}

function M.init(config)
  for _, theme in pairs(supported_themes) do
    if theme == config.colorscheme then
      colors = require(mod .. theme)
    end
  end

  if vim.tbl_isempty(colors) then
    return false
  end

  return colors
end

return M
