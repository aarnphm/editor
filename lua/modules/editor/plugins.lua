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
  after = "nvim-treesitter",
  config = function()
    require("twilight").setup({
      dimming = {
        alpha = 0.25, -- amount of dimming
        -- we try to get the foreground from the highlight groups or fallback color
        color = { "Normal", "#ffffff" },
        inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
      },
      context = 10, -- amount of lines we will try to show around the current line
      treesitter = true, -- use treesitter when available for the filetype
      -- treesitter is used to automatically expand the visible text,
      -- but you can further control the types of nodes that should always be fully expanded
      expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
        "function",
        "method",
        "table",
        "if_statement",
      },
      exclude = {}, -- exclude these filetypes
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
