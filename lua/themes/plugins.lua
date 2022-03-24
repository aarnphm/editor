local M = {}
local config = require("themes.config")

M.supported_themes = {
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

function M.init(use, global_config)
  use({
    "jacoborus/tender.vim",

    as = "tender",
    disable = global_config.colorscheme ~= "tender",
  })
  use({
    "NLKNguyen/papercolor-theme",

    as = "papercolor",
    config = function()
      vim.g.background = "light"
      vim.cmd([[silent! colorscheme PaperColor]])
    end,
    disable = global_config.colorscheme ~= "papercolor",
  })
  use({
    "sainnhe/edge",

    as = "edge",
    config = config.edge,
    disable = global_config.colorscheme ~= "edge",
  })
  use({ -- color scheme
    "folke/tokyonight.nvim",

    as = "tokyonight",
    config = config.tokyonight,
    disable = global_config.colorscheme ~= "tokyonight",
  })
  use({
    "catppuccin/nvim",

    as = "catppuccin",
    config = config.catppuccin,
    disable = global_config.colorscheme ~= "catppuccin",
  })

  use({
    "shaunsingh/nord.nvim",

    as = "nord",
    config = function()
      vim.g.nord_contrast = true
      vim.g.nord_borders = true
      require("nord").set()
    end,
    disable = global_config.colorscheme ~= "nord",
  })

  use({
    "ellisonleao/gruvbox.nvim",

    as = "gruvbox",
    requires = { "rktjmp/lush.nvim" },
    config = function()
      vim.o.background = "dark"
      vim.cmd([[silent! colorscheme gruvbox]])
    end,
    disable = global_config.colorscheme ~= "gruvbox",
  })

  use({
    "rose-pine/neovim",

    as = "rose-pine",
    tag = "v1.*",
    config = config.rose_pine,
    disable = global_config.colorscheme ~= "rose-pine",
  })

  use({
    "EdenEast/nightfox.nvim",

    as = "nightfox",
    config = function()
      vim.cmd("color nightfox")
    end,
    disable = global_config.colorscheme ~= "nightfox",
  })

  use({
    "navarasu/onedark.nvim",

    as = "onedark",
    config = function()
      vim.cmd("color onedark")
    end,
    disable = global_config.colorscheme ~= "onedark",
  })

  use({
    "Mofiqul/dracula.nvim",

    as = "dracula",
    config = function()
      vim.cmd([[color dracula]])
    end,
    disable = global_config.colorscheme ~= "dracula",
  })

  use({
    "rebelot/kanagawa.nvim",

    as = "kanagawa",
    config = config.kanagawa,
    disable = global_config.colorscheme ~= "kanagawa",
  })

  use({
    "projekt0n/github-nvim-theme",

    as = "github",
    config = function()
      require("github-theme").setup()
    end,
    disable = global_config.colorscheme ~= "github",
  })
end

return M
