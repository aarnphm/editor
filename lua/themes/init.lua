local config = require("themes.config")
local M = {}

M.setup = function(use)
  use({
    "jacoborus/tender.vim",
    as = "tender",
    cond = function()
      return __editor_config.colorscheme == "tender"
    end,
    setup = function()
      if __editor_config.colorscheme == "tender" then
        vim.cmd([[packadd tender]])
      end
    end,
  })
  use({
    "sainnhe/edge",
    as = "edge",
    config = config.edge,
    cond = function()
      return __editor_config.colorscheme == "edge"
    end,
    setup = function()
      if __editor_config.colorscheme == "edge" then
        vim.cmd([[packadd edge]])
      end
    end,
  })
  use({
    "folke/tokyonight.nvim",
    as = "tokyonight",
    config = config.tokyonight,
    cond = function()
      return __editor_config.colorscheme == "tokyonight"
    end,
    setup = function()
      if __editor_config.colorscheme == "tokyonight" then
        vim.cmd([[packadd tokyonight]])
      end
    end,
  })
  use({
    "catppuccin/nvim",
    as = "catppuccin",
    config = config.catppuccin,
    cond = function()
      return __editor_config.colorscheme == "catppuccin"
    end,
    setup = function()
      if __editor_config.colorscheme == "catppuccin" then
        vim.cmd([[packadd catppuccin]])
      end
    end,
  })

  use({
    "rose-pine/neovim",
    as = "rose-pine",
    config = config.rose_pine,
    cond = function()
      return __editor_config.colorscheme == "rose-pine"
    end,
    setup = function()
      if __editor_config.colorscheme == "rose-pine" then
        vim.cmd([[packadd rose-pine]])
      end
    end,
  })

  use({
    "navarasu/onedark.nvim",
    as = "onedark",
    config = function()
      vim.cmd("color onedark")
    end,
    cond = function()
      return __editor_config.colorscheme == "onedark"
    end,
    setup = function()
      if __editor_config.colorscheme == "onedark" then
        vim.cmd([[packadd onedark]])
      end
    end,
  })

  use({
    "rebelot/kanagawa.nvim",
    as = "kanagawa",
    config = config.kanagawa,
    cond = function()
      return __editor_config.colorscheme == "kanagawa"
    end,
    setup = function()
      if __editor_config.colorscheme == "kanagawa" then
        vim.cmd([[packadd kanagawa]])
      end
    end,
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
