local editor = {}
local config = require("modules.editor.config")

editor["RRethy/vim-illuminate"] = { config = config.illuminate }
editor["nvim-treesitter/nvim-treesitter"] = { run = ":TSUpdate", config = config.nvim_treesitter }
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
editor["andymass/vim-matchup"] = {
  opt = true,
  after = "nvim-treesitter",
}
editor["ThePrimeagen/refactoring.nvim"] = {
  module = "refactoring",
  after = "nvim-treesitter",
  config = function()
    require("refactoring").setup({
      -- prompt for return type
      prompt_func_return_type = {
        go = true,
        cpp = true,
        c = true,
        java = true,
      },
      -- prompt for function parameters
      prompt_func_param_type = {
        go = true,
        cpp = true,
        c = true,
        java = true,
      },
    })
  end,
}

editor["kylechui/nvim-surround"] = {
  config = function()
    require("nvim-surround").setup()
  end,
}

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

editor["phaazon/hop.nvim"] = {
  opt = true,
  branch = "v2",
  event = "BufRead",
  config = function()
    require("hop").setup()
  end,
}
editor["windwp/nvim-spectre"] = {
  module = "spectre",
  config = config.spectre,
}
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
editor["nvim-telescope/telescope-frecency.nvim"] = {
  opt = true,
  after = "telescope-fzf-native.nvim",
  requires = { "kkharji/sqlite.lua" },
}
editor["jvgrootveld/telescope-zoxide"] = { opt = true, after = "telescope-frecency.nvim" }
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
editor["sindrets/diffview.nvim"] = {
  opt = true,
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  requires = {
    "kyazdani42/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
  },
}
editor["sudormrfbin/cheatsheet.nvim"] = {
  opt = true,
  after = "telescope.nvim",
  config = config.cheatsheet,
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
  after = "nvim-treesitter",
  requires = { "folke/twilight.nvim" },
  config = function()
    require("zen-mode").setup({})
  end,
}
editor["romainl/vim-cool"] = {
  opt = true,
  event = { "CursorMoved", "InsertEnter" },
}
editor["hrsh7th/vim-eft"] = { opt = true, event = "BufReadPost" }
editor["luukvbaal/stabilize.nvim"] = {
  opt = true,
  event = "BufReadPost",
}

editor["akinsho/nvim-toggleterm.lua"] = {
  opt = true,
  event = "BufRead",
  config = config.toggleterm,
}
editor["rmagatti/auto-session"] = {
  opt = true,
  cmd = { "SaveSession", "RestoreSession", "DeleteSession" },
  config = config.auto_session,
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
editor["Stormherz/tablify"] = {
  opt = true,
  ft = "rst",
}
editor["dstein64/vim-startuptime"] = { opt = true, cmd = "StartupTime" }

return editor
