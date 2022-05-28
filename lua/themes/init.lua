local config = require("themes.config")
local M = {}

M.setup = function(use)
  use({
    "rose-pine/neovim",
    as = "rose-pine",
    config = config.rose_pine,
  })
end

-- returns a table of colors for given or current theme
M.get = function(theme)
  if not theme then
    theme = __editor_config.colorscheme
  end
  return require(theme)
end

return M
