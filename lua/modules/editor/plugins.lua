local editor = {}
local config = require("modules.editor.config")

-- tpope
editor["tpope/vim-repeat"] = { lazy = true }
editor["tpope/vim-fugitive"] = { lazy = true, command = { "Git", "G", "Ggrep", "GBrowse" } }

editor["RRethy/vim-illuminate"] = { lazy = true, event = "BufReadPost", config = config.illuminate }
editor["LunarVim/bigfile.nvim"] = { lazy = false, config = config.bigfile }
editor["nvim-treesitter/nvim-treesitter"] = {
  lazy = true,
  build = ":TSUpdate",
  event = "BufReadPost",
  config = config.nvim_treesitter,
  dependencies = {
    { "nvim-treesitter/nvim-treesitter-textobjects" },
    { "p00f/nvim-ts-rainbow" },
    { "romgrk/nvim-treesitter-context" },
    { "JoosepAlviste/nvim-ts-context-commentstring" },
    { "mfussenegger/nvim-ts-hint-textobject" },
    { "andymass/vim-matchup" },
    { "windwp/nvim-ts-autotag", config = config.autotag },
    { "NvChad/nvim-colorizer.lua", config = config.nvim_colorizer },
  },
}
editor["ThePrimeagen/refactoring.nvim"] = {
  lazy = true,
  module = "refactoring",
  requires = {
    "nvim-treesitter/nvim-treesiter",
  },
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
  lazy = false,
  config = function()
    require("nvim-surround").setup()
  end,
}

editor["junegunn/vim-easy-align"] = { lazy = true, cmd = "EasyAlign" }

editor["alexghergh/nvim-tmux-navigation"] = {
  lazy = true,
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
  lazy = true,
  branch = "v2",
  event = "BufRead",
  config = function()
    require("hop").setup()
  end,
}
editor["windwp/nvim-spectre"] = {
  lazy = true,
  module = "spectre",
  config = config.spectre,
}
editor["nvim-telescope/telescope.nvim"] = {
  cmd = "Telescope",
  lazy = true,
  module = "telescope",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    { "nvim-lua/plenary.nvim" },
    { "nvim-lua/popup.nvim" },
    { "debugloop/telescope-undo.nvim" },
    { "ahmedkhalf/project.nvim", event = "BufReadPost", config = config.project },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-frecency.nvim", dependencies = {
      { "kkharji/sqlite.lua" },
    } },
    { "jvgrootveld/telescope-zoxide" },
    { "nvim-telescope/telescope-live-grep-args.nvim" },
    { "xiyaowong/telescope-emoji.nvim" },
  },
  config = config.telescope,
}

editor["pwntester/octo.nvim"] = {
  lazy = true,
  config = config.octo,
  cmd = "Octo",
  module = "octo",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
}
editor["sindrets/diffview.nvim"] = {
  lazy = true,
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
  },
}
editor["sudormrfbin/cheatsheet.nvim"] = {
  lazy = true,
  config = config.cheatsheet,
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
}
editor["folke/trouble.nvim"] = {
  lazy = true,
  cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
  config = config.trouble,
}

editor["folke/which-key.nvim"] = { lazy = false, config = config.which_key }
editor["stevearc/dressing.nvim"] = { lazy = false, event = "VeryLazy", config = config.dressing }

editor["folke/zen-mode.nvim"] = {
  requires = {
    "nvim-treesitter/nvim-treesiter",
  },
  dependencies = {
    {
      "folke/twilight.nvim",
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
    },
  },
  config = function()
    require("zen-mode").setup({})
  end,
}

editor["stevearc/dressing.nvim"] = {
  lazy = false,
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
  },
}

editor["romainl/vim-cool"] = {
  lazy = true,
  event = { "CursorMoved", "InsertEnter" },
}
editor["hrsh7th/vim-eft"] = { lazy = true, event = "BufReadPost" }
editor["luukvbaal/stabilize.nvim"] = {
  lazy = true,
  event = "BufReadPost",
}

editor["terrortylor/nvim-comment"] = {
  lazy = false,
  config = function()
    require("nvim_comment").setup({
      hook = function()
        require("ts_context_commentstring.internal").update_commentstring()
      end,
    })
  end,
}
editor["akinsho/nvim-toggleterm.lua"] = {
  lazy = true,
  event = "UIEnter",
  config = config.toggleterm,
}
editor["rmagatti/auto-session"] = {
  lazy = true,
  cmd = { "SaveSession", "RestoreSession", "DeleteSession" },
  config = config.auto_session,
}
editor["gelguy/wilder.nvim"] = {
  event = "CmdlineEnter",
  config = config.wilder,
  dependencies = { { "romgrk/fzy-lua-native" } },
}
editor["untitled-ai/jupyter_ascending.vim"] = {
  lazy = true,
  ft = "ipynb",
  cmd = { "JupyterExecute", "JupyterExecuteAll" },
}
editor["Stormherz/tablify"] = {
  lazy = true,
  ft = "rst",
}
editor["dstein64/vim-startuptime"] = { lazy = true, cmd = "StartupTime" }

return editor
