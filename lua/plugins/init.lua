return {
  "nvim-lua/plenary.nvim",
  "tpope/vim-repeat",
  "tpope/vim-fugitive",
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
}
