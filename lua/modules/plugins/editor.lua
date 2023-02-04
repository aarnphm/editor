local editor = {}

-- tpope
editor["tpope/vim-repeat"] = { lazy = true }
editor["hrsh7th/vim-eft"] = { lazy = true, event = "BufReadPost" }
editor["junegunn/vim-easy-align"] = { lazy = true, cmd = "EasyAlign" }
editor["luukvbaal/stabilize.nvim"] = { lazy = true, event = "BufReadPost" }
editor["romainl/vim-cool"] = { lazy = true, event = { "CursorMoved", "InsertEnter" } }
editor["tpope/vim-fugitive"] = { lazy = true, command = { "Git", "G", "Ggrep", "GBrowse" } }
editor["Stormherz/tablify"] = { lazy = true, ft = "rst" }
editor["dstein64/vim-startuptime"] = { lazy = true, cmd = "StartupTime" }
editor["ojroques/nvim-bufdel"] = { lazy = true, event = "BufReadPost" }
editor["untitled-ai/jupyter_ascending.vim"] =
  { lazy = true, ft = "ipynb", cmd = { "JupyterExecute", "JupyterExecuteAll" } }

editor["RRethy/vim-illuminate"] = { lazy = true, event = "BufReadPost", config = require("editor.vim-illuminate") }
editor["LunarVim/bigfile.nvim"] = { lazy = false, config = require("editor.bigfile") }
editor["sudormrfbin/cheatsheet.nvim"] = { lazy = true, config = require("editor.cheatsheet") }
editor["windwp/nvim-spectre"] = { lazy = true, config = require("editor.nvim-spectre") }
editor["akinsho/nvim-toggleterm.lua"] = { lazy = true, event = "UIEnter", config = require("editor.nvim-toggleterm") }
editor["rmagatti/auto-session"] =
  { lazy = true, cmd = { "SaveSession", "RestoreSession", "DeleteSession" }, config = require("editor.auto-session") }

editor["gelguy/wilder.nvim"] = {
  event = "CmdlineEnter",
  config = require("editor.wilder"),
  dependencies = { { "romgrk/fzy-lua-native" } },
}
editor["kylechui/nvim-surround"] = {
  lazy = false,
  config = function()
    require("nvim-surround").setup()
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
editor["sindrets/diffview.nvim"] = {
  lazy = true,
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
  },
}
editor["pwntester/octo.nvim"] = {
  lazy = true,
  config = function()
    require("octo").setup({ default_remote = { "upstream", "origin" } })
  end,
  cmd = "Octo",
}
editor["ThePrimeagen/refactoring.nvim"] = {
  lazy = true,
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

editor["nvim-treesitter/nvim-treesitter"] = {
  lazy = true,
  build = ":TSUpdate",
  event = "BufReadPost",
  config = require("editor.nvim-treesitter"),
  dependencies = {
    { "nvim-treesitter/nvim-treesitter-textobjects" },
    { "p00f/nvim-ts-rainbow" },
    { "romgrk/nvim-treesitter-context" },
    { "JoosepAlviste/nvim-ts-context-commentstring" },
    { "mfussenegger/nvim-ts-hint-textobject" },
    { "andymass/vim-matchup" },
    { "windwp/nvim-ts-autotag", config = require("editor.autotag") },
    {
      "NvChad/nvim-colorizer.lua",
      config = function()
        require("colorizer").setup()
      end,
    },
  },
}

editor["mfussenegger/nvim-dap"] = {
  lazy = true,
  cmd = {
    "DapSetLogLevel",
    "DapShowLog",
    "DapContinue",
    "DapToggleBreakpoint",
    "DapToggleRepl",
    "DapStepOver",
    "DapStepInto",
    "DapStepOut",
    "DapTerminate",
  },
  config = require("editor.dap"),
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      config = require("editor.dap.dapui"),
    },
  },
}

editor["nvim-telescope/telescope.nvim"] = {
  cmd = "Telescope",
  lazy = true,
  config = require("editor.nvim-telescope"),
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    { "nvim-lua/plenary.nvim" },
    { "nvim-lua/popup.nvim" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-frecency.nvim", dependencies = {
      { "kkharji/sqlite.lua" },
    } },
    { "jvgrootveld/telescope-zoxide" },
    { "xiyaowong/telescope-emoji.nvim" },
  },
}

editor["folke/trouble.nvim"] = {
  lazy = true,
  cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
  config = require("editor.trouble"),
}
editor["folke/which-key.nvim"] = { lazy = false, config = require("editor.which-key") }
editor["stevearc/dressing.nvim"] = { lazy = false, event = "VeryLazy", config = require("editor.dressing") }
editor["folke/zen-mode.nvim"] = {
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

return editor
