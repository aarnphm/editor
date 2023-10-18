return {
  {
    "glacambre/firenvim",
    lazy = false,
    build = function() vim.fn["firenvim#install"](0) end,
    init = function()
      if vim.g.started_by_firenvim == true then
        vim.o.guifont = "JetBrainsMonoNL Nerd Font:h18"
        vim.o.laststatus = 0
      else
        vim.o.laststatus = 2
      end
    end,
  },
}
