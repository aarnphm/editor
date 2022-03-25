local colors = {}
local mod = "themes.integrated."
local supported_themes = require("themes.plugins").supported_themes

local M = {}

M.config = _G.__editor_config

function M.init()
  for _, theme in pairs(supported_themes) do
    if theme == M.config.colorscheme then
      colors = require(mod .. theme)
    end
  end

  if vim.tbl_isempty(colors) then
    return false
  end

  return colors
end

return M
