return {
  "nvim-lua/plenary.nvim",
  "tpope/vim-repeat",
  { "romainl/vim-cool", event = { "CursorMoved", "InsertEnter" } },
  { "folke/lazy.nvim", version = false },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@return snacks.Config
    opts = function()
      return {
        toggle = { map = Util.safe_keymap_set },
        bigfile = { enabled = true, size = 1.5 * 1024 * 1024 },
        notifier = { enabled = false },
        input = { enabled = true },
        image = { enabled = false, math = { enabled = false }, convert = { notify = false } },
        rename = { enabled = true },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = false },
      }
    end,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...) Snacks.debug.inspect(...) end
          _G.bt = function() Snacks.debug.backtrace() end
          _G.P = function(...)
            print(vim.inspect(...))
            return ...
          end
        end,
      })
    end,
  },
  {
    "nuvic/flexoki-nvim",
    name = "flexoki",
    enabled = true,
    priority = 1000,
    ---@return Options
    opts = function()
      local palette = require "flexoki.palette"
      return {
        styles = {
          italic = true,
        },
        highlight_groups = {
          -- treesitter disabling italics for parameters
          -- because it is kinda annoying
          ["@variable"] = { fg = palette.text, italic = false },
          ["@parameter"] = { fg = palette.purple_two, italic = false },
          ["@variable.parameter"] = { fg = palette.purple_two, italic = false },
          -- normal colorscheme
          StatusLine = { fg = palette.orange_two, bg = palette.overlay },
          StatusLineNC = { bg = palette.overlay },
          QuickFixLine = { bg = palette.highlight_high },
          WinBar = { bg = palette.base },
          WinBarNC = { bg = palette.base },
          -- avante.nvim
          AvanteTitle = { bg = palette.red_two },
          AvanteReversedTitle = { fg = palette.red_two },
          AvanteSubtitle = { fg = palette.highlight_med, bg = palette.cyan_two },
          AvanteReversedSubtitle = { fg = palette.cyan_two },
          AvanteThirdTitle = { fg = palette.highlight_med, bg = palette.purple_two },
          AvanteReversedThirdTitle = { fg = palette.purple_two },
          AvanteConflictCurrent = { bg = palette.red_two },
          AvanteConflictIncoming = { bg = palette.green_two },
          -- mini.nvim
          MiniStatuslineModeNormal = { bg = palette.blue_two },
          MiniStatuslineModeVisual = { bg = palette.green_two },
          MiniStatuslineModeInsert = { bg = palette.orange_two },
          MiniStatuslineModeReplace = { bg = palette.red_two },
          MiniStatuslineModeCommand = { bg = palette.purple_two },
          MiniStatuslineModeOther = { bg = palette.purple_two },
          -- dropbar.nvim
          DropBarMenuCurrentContext = { bg = palette.base },
        },
      }
    end,
    config = function(_, opts)
      require("flexoki").setup(opts)
      vim.cmd "colorscheme flexoki"
    end,
  },
}
