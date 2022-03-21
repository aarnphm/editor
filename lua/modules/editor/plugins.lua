local editor = {}
local conf = require("modules.editor.config")

editor["tpope/vim-fugitive"] = { opt = false, cmd = { "Git", "G" } }
editor["tpope/vim-surround"] = { opt = false }

editor["junegunn/vim-easy-align"] = { opt = true, cmd = "EasyAlign" }
editor["itchyny/vim-cursorword"] = {
  opt = true,
  event = { "BufReadPre", "BufNewFile" },
  config = conf.vim_cursorword,
}

editor["alexghergh/nvim-tmux-navigation"] = {
  opt = false,
  config = function()
    require("nvim-tmux-navigation").setup({
      disable_when_zoomed = true, -- defaults to false
    })

    vim.api.nvim_set_keymap(
      "n",
      "<C-h>",
      ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateLeft()<cr>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<C-j>",
      ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateDown()<cr>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<C-k>",
      ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateUp()<cr>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<C-l>",
      ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateRight()<cr>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<C-\\>",
      ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateLastActive()<cr>",
      { noremap = true, silent = true }
    )
    vim.api.nvim_set_keymap(
      "n",
      "<C-Space>",
      ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateNext()<cr>",
      { noremap = true, silent = true }
    )
  end,
}

editor["terrortylor/nvim-comment"] = {
  opt = false,
  config = function()
    require("nvim_comment").setup({
      hook = function()
        require("ts_context_commentstring.internal").update_commentstring()
      end,
    })
  end,
}

editor["simrat39/symbols-outline.nvim"] = {
  opt = true,
  cmd = { "SymbolsOutline", "SymbolsOutlineOpen" },
  config = conf.symbols_outline,
}

editor["nvim-treesitter/nvim-treesitter"] = {
  opt = true,
  run = ":TSUpdate",
  event = "BufRead",
  config = conf.nvim_treesitter,
}
editor["nvim-treesitter/nvim-treesitter-textobjects"] = {
  opt = true,
  after = "nvim-treesitter",
}
editor["nvim-treesitter/playground"] = {
  opt = true,
  after = "nvim-treesitter",
}
editor["romgrk/nvim-treesitter-context"] = {
  opt = true,
  after = "nvim-treesitter",
}
editor["p00f/nvim-ts-rainbow"] = {
  opt = true,
  after = "nvim-treesitter",
  event = "BufRead",
}
editor["JoosepAlviste/nvim-ts-context-commentstring"] = {
  opt = true,
  after = "nvim-treesitter",
}
editor["mfussenegger/nvim-ts-hint-textobject"] = {
  opt = true,
  after = "nvim-treesitter",
}
editor["lewis6991/spellsitter.nvim"] = {
  opt = true,
  after = "nvim-treesitter",
  config = function()
    require("spellsitter").setup()
  end,
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
    require("zen-mode").setup({
      window = {
        backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
        -- height and width can be:
        -- * an absolute number of cells when > 1
        -- * a percentage of the width / height of the editor when <= 1
        -- * a function that returns the width or the height
        width = 120, -- width of the Zen window
        height = 1, -- height of the Zen window
        -- by default, no options are changed for the Zen window
        -- uncomment any of the options below, or add other vim.wo options you want to apply
        options = {
          -- signcolumn = "no", -- disable signcolumn
          -- number = false, -- disable number column
          -- relativenumber = false, -- disable relative numbers
          -- cursorline = false, -- disable cursorline
          -- cursorcolumn = false, -- disable cursor column
          -- foldcolumn = "0", -- disable fold column
          -- list = false, -- disable whitespace characters
        },
      },
      plugins = {
        -- disable some global vim options (vim.o...)
        -- comment the lines to not apply the options
        options = {
          enabled = true,
          ruler = false, -- disables the ruler text in the cmd line area
          showcmd = false, -- disables the command in the last line of the screen
        },
        twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
        gitsigns = { enabled = false }, -- disables git signs
        tmux = { enabled = false }, -- disables the tmux statusline
        -- this will change the font size on kitty when in zen mode
        -- to make this work, you need to set the following kitty options:
        -- - allow_remote_control socket-only
        -- - listen_on unix:/tmp/kitty
        kitty = {
          enabled = false,
          font = "+4", -- font size increment
        },
      },
    })
  end,
}
editor["windwp/nvim-ts-autotag"] = {
  opt = true,
  ft = { "html", "xml" },
  after = "nvim-treesitter",
  config = conf.autotag,
}
editor["andymass/vim-matchup"] = {
  opt = true,
  after = "nvim-treesitter",
  config = conf.matchup,
}
editor["romainl/vim-cool"] = {
  opt = true,
  event = { "CursorMoved", "InsertEnter" },
}
editor["vimlab/split-term.vim"] = { opt = true, cmd = { "Term", "VTerm" } }
editor["akinsho/nvim-toggleterm.lua"] = {
  opt = true,
  event = "BufRead",
  config = conf.toggleterm,
}
editor["numtostr/FTerm.nvim"] = { opt = true, event = "BufRead" }
editor["norcalli/nvim-colorizer.lua"] = {
  opt = true,
  event = "BufRead",
  config = conf.nvim_colorizer,
}
editor["rmagatti/auto-session"] = {
  opt = true,
  cmd = { "SaveSession", "RestoreSession", "DeleteSession" },
  config = conf.auto_session,
}
editor["jdhao/better-escape.vim"] = { opt = true, event = "InsertEnter" }
editor["untitled-ai/jupyter_ascending.vim"] = {
  opt = true,
  event = { "InsertEnter", "BufWrite" },
  cmd = { "JupyterExecute", "JupyterExecuteAll" },
}
editor["famiu/bufdelete.nvim"] = {
  opt = true,
  cmd = { "Bdelete", "Bwipeout", "Bdelete!", "Bwipeout!" },
}
editor["abecodes/tabout.nvim"] = {
  opt = true,
  event = "InsertEnter",
  wants = "nvim-treesitter",
  after = "nvim-cmp",
  config = conf.tabout,
}

return editor
