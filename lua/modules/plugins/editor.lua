local editor = {}

-- tpope
editor["tpope/vim-repeat"] = { lazy = true }
editor["Stormherz/tablify"] = { lazy = true }
editor["nmac427/guess-indent.nvim"] = {
  lazy = true,
  event = "BufEnter",
  config = function()
    require("guess-indent").setup({})
  end,
}
editor["jinh0/eyeliner.nvim"] = { lazy = true, event = "BufReadPost" }
editor["junegunn/vim-easy-align"] = { lazy = true, cmd = "EasyAlign" }
editor["luukvbaal/stabilize.nvim"] = { lazy = true, event = "BufReadPost" }
editor["romainl/vim-cool"] = { lazy = true, event = { "CursorMoved", "InsertEnter" } }
editor["tpope/vim-fugitive"] = { lazy = false, command = { "Git", "G", "Ggrep", "GBrowse" } }
editor["dstein64/vim-startuptime"] = { lazy = true, cmd = "StartupTime" }
editor["ojroques/nvim-bufdel"] = { lazy = true, event = "BufReadPost" }
editor["sindrets/diffview.nvim"] = {
  lazy = true,
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
}

editor["RRethy/vim-illuminate"] = { lazy = true, event = "BufReadPost", config = require("editor.vim-illuminate") }
editor["LunarVim/bigfile.nvim"] = { lazy = false, config = require("editor.bigfile") }
editor["windwp/nvim-spectre"] = { lazy = true, config = require("editor.nvim-spectre") }
editor["akinsho/nvim-toggleterm.lua"] = { lazy = true, event = "UIEnter", config = require("editor.nvim-toggleterm") }
editor["rmagatti/auto-session"] =
  { lazy = true, cmd = { "SaveSession", "RestoreSession", "DeleteSession" }, config = require("editor.auto-session") }

editor["mrjones2014/legendary.nvim"] = {
  lazy = true,
  cmd = "Legendary",
  config = require("editor.legendary"),
  dependencies = {
    { "kkharji/sqlite.lua" },
    {
      "stevearc/dressing.nvim",
      event = "VeryLazy",
      config = require("editor.dressing"),
    },
    -- Please don't remove which-key.nvim otherwise you need to set timeoutlen=300 at `lua/core/options.lua`
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      config = require("editor.which-key"),
    },
  },
}
editor["folke/trouble.nvim"] = {
  lazy = true,
  cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
  config = require("editor.trouble"),
}
editor["gelguy/wilder.nvim"] = {
  event = "CmdlineEnter",
  config = require("editor.wilder"),
  dependencies = { { "romgrk/fzy-lua-native" } },
}
editor["sudormrfbin/cheatsheet.nvim"] = {
  event = "VeryLazy",
  config = require("editor.cheatsheet"),
  command = { "Cheatsheet", "CheatsheetEdit" },
  dependencies = {
    { "nvim-telescope/telescope.nvim" },
    { "nvim-lua/popup.nvim" },
    { "nvim-lua/plenary.nvim" },
  },
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
editor["pwntester/octo.nvim"] = {
  lazy = true,
  config = function()
    require("octo").setup({ default_remote = { "upstream", "origin" } })
  end,
  cmd = "Octo",
}
editor["ThePrimeagen/refactoring.nvim"] = {
  lazy = true,
  config = require("editor.refactoring"),
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-treesitter/nvim-treesitter" },
  },
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
    { "windwp/nvim-ts-autotag", config = require("editor.nvim-ts-autotag") },
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
  config = require("editor.nvim-dap"),
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      config = require("editor.nvim-dap.nvim-dap-ui"),
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
    { "debugloop/telescope-undo.nvim" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-frecency.nvim", dependencies = { { "kkharji/sqlite.lua" } } },
    { "jvgrootveld/telescope-zoxide" },
    { "xiyaowong/telescope-emoji.nvim" },
    { "ahmedkhalf/project.nvim", event = "BufReadPost", config = require("editor.project") },
    { "nvim-telescope/telescope-live-grep-args.nvim" },
  },
}

editor["folke/zen-mode.nvim"] = {
  dependencies = { { "folke/twilight.nvim", config = require("editor.twilight") } },
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
