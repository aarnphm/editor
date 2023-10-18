return {
  {
    "glacambre/firenvim",
    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    -- run this without cond: nvim --headless "+call firenvim#install(0) | q"
    lazy = false,
    build = function() vim.fn["firenvim#install"](0) end,
    init = function()
      vim.g.firenvim_config = {
        globalSettings = {
          alt = "all",
        },
        localSettings = {
          [".*"] = {
            takeover = "never",
          },
        },
      }
      if vim.g.started_by_firenvim == true then
        vim.o.guifont = "JetBrainsMonoNL Nerd Font:h18"
        vim.o.laststatus = 0
      end
    end,
  },
  {
    "NStefan002/speedtyper.nvim",
    lazy = true,
    cmd = "Speedtyper",
    opts = {},
  },
}
