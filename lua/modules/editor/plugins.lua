local editor = {}
local config = require("modules.editor.config")

editor["tpope/vim-fugitive"] = { opt = true, cmd = { "Git", "G", "Ggrep", "GBrowse" } }

editor["junegunn/vim-easy-align"] = { opt = true, cmd = "EasyAlign" }

editor["alexghergh/nvim-tmux-navigation"] = {
  opt = true,
  config = function()
    require("nvim-tmux-navigation").setup({
      disable_when_zoomed = true, -- defaults to false
    })
  end,
  cond = function()
    return vim.api.nvim_eval('exists("$TMUX")') ~= 0
  end,
}

editor["simrat39/symbols-outline.nvim"] = {
  opt = true,
  cmd = { "SymbolsOutline", "SymbolsOutlineOpen" },
  config = config.symbols_outline,
}
editor["RRethy/vim-illuminate"] = {
  event = "BufRead",
  config = function()
    vim.g.Illuminate_highlightUnderCursor = 0
    vim.g.Illuminate_ftblacklist = {
      "help",
      "dashboard",
      "alpha",
      "packer",
      "norg",
      "DoomInfo",
      "NvimTree",
      "Outline",
      "toggleterm",
    }
  end,
}

editor["nvim-treesitter/nvim-treesitter"] = {
  opt = true,
  run = ":TSUpdate",
  event = "BufRead",
  config = config.nvim_treesitter,
}
editor["nvim-treesitter/nvim-treesitter-textobjects"] = {
  opt = true,
  after = "nvim-treesitter",
}
editor["romgrk/nvim-treesitter-context"] = {
  opt = true,
  after = "nvim-treesitter",
}
editor["JoosepAlviste/nvim-ts-context-commentstring"] = {
  opt = true,
  after = "nvim-treesitter",
}
editor["mfussenegger/nvim-ts-hint-textobject"] = {
  opt = true,
  after = "nvim-treesitter",
}
editor["windwp/nvim-ts-autotag"] = {
  opt = true,
  ft = { "html", "xml" },
  after = "nvim-treesitter",
  config = config.autotag,
}
editor["renerocksai/telekasten.nvim"] = {
  opt = true,
  module = "telekasten",
  config = config.telekasten,
  requires = { "renerocksai/calendar-vim", opt = true, after = "telekasten", module = "telekasten" },
}
editor["windwp/nvim-spectre"] = {
  module = "spectre",
  config = config.spectre,
}
editor["tpope/vim-dispatch"] = { cmd = "Dispatch" }
editor["wakatime/vim-wakatime"] = { opt = true }
editor["nvim-telescope/telescope.nvim"] = {
  cmd = "Telescope",
  requires = {
    { "nvim-lua/popup.nvim", opt = true },
  },
  config = config.telescope,
}
editor["nvim-telescope/telescope-fzf-native.nvim"] = {
  opt = true,
  run = "make",
  after = "telescope.nvim",
}
editor["nvim-telescope/telescope-file-browser.nvim"] = {
  opt = true,
  after = "telescope-fzf-native.nvim",
}
editor["nvim-telescope/telescope-frecency.nvim"] = {
  opt = true,
  after = "telescope-file-browser.nvim",
  requires = { { "tami5/sqlite.lua", opt = true } },
}
editor["nvim-telescope/telescope-ui-select.nvim"] = {
  opt = true,
  after = "telescope.nvim",
}
editor["xiyaowong/telescope-emoji.nvim"] = {
  opt = true,
  after = "telescope.nvim",
}
editor["pwntester/octo.nvim"] = {
  opt = true,
  after = "telescope.nvim",
  config = config.octo,
  cmd = "Octo",
  module = "octo",
  requires = {
    "nvim-telescope/telescope.nvim",
  },
}
editor["sudormrfbin/cheatsheet.nvim"] = {
  opt = true,
  after = "telescope.nvim",
  config = config.cheatsheet,
}
editor["gelguy/wilder.nvim"] = {
  event = "CmdlineEnter",
  config = config.wilder,
  run = ":UpdateRemotePlugins",
  requires = {
    { "romgrk/fzy-lua-native", opt = true, after = "wilder.nvim" },
  },
}
editor["dstein64/vim-startuptime"] = {
  opt = true,
  cmd = "StartupTime",
  disable = __editor_config.debug ~= true,
}
editor["folke/trouble.nvim"] = {
  opt = true,
  cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
  config = config.trouble,
}
editor["folke/twilight.nvim"] = {
  opt = true,
  config = function()
    require("twilight").setup({
      {
        dimming = {
          alpha = 0.5, -- amount of dimming
          -- we try to get the foreground from the highlight groups or fallback color
          color = { "Normal", "#ffffff" },
          inactive = true, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
        },
        context = 50, -- amount of lines we will try to show around the current line
        treesitter = true, -- use treesitter when available for the filetype
        -- treesitter is used to automatically expand the visible text,
        -- but you can further control the types of nodes that should always be fully expanded
        expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
          "function",
          "method",
          "table",
          "if_statement",
        },
        exclude = { ".git*" }, -- exclude these filetypes
      },
    })
  end,
}
editor["folke/zen-mode.nvim"] = {
  opt = true,
  after = "nvim-treesitter",
  requires = {
    "folke/twilight.nvim",
  },
  config = function()
    require("zen-mode").setup({})
  end,
}
editor["andymass/vim-matchup"] = {
  opt = true,
  after = "nvim-treesitter",
  config = config.matchup,
}
editor["akinsho/nvim-toggleterm.lua"] = {
  opt = true,
  event = "BufRead",
  config = config.toggleterm,
}
editor["norcalli/nvim-colorizer.lua"] = {
  opt = true,
  event = "BufRead",
  config = function()
    require("colorizer").setup({})
  end,
}
editor["untitled-ai/jupyter_ascending.vim"] = {
  opt = true,
  ft = "ipynb",
  cmd = { "JupyterExecute", "JupyterExecuteAll" },
}

return editor
