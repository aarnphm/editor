-- Terminal Mappings
---@param dir string
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function() vim.cmd.wincmd(dir) end)
  end
end

return {
  "nvim-lua/plenary.nvim",
  { "tpope/vim-repeat", lazy = false },
  { "romainl/vim-cool", event = { "CursorMoved", "InsertEnter" } },
  { "folke/lazy.nvim", version = false },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = function()
      ---@type snacks.Config
      return {
        toggle = { map = Util.safe_keymap_set },
        bigfile = { enabled = true },
        notifier = { enabled = false },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        terminal = {
          win = {
            keys = {
              nav_h = { "<C-h>", term_nav "h", desc = "window: left", expr = true, mode = "t" },
              nav_j = { "<C-j>", term_nav "j", desc = "window: down", expr = true, mode = "t" },
              nav_k = { "<C-k>", term_nav "k", desc = "window: up", expr = true, mode = "t" },
              nav_l = { "<C-l>", term_nav "l", desc = "window: right", expr = true, mode = "t" },
            },
          },
        },
      }
    end,
  },
}
