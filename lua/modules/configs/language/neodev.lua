return function()
  require("neodev").setup({
    library = {
      enabled = true,
      runtime = true,
      types = true,
      plugins = {
        "dap",
        "nvim-dap-ui",
        "lualine",
        "nvim-treesitter",
        "telescope.nvim",
        "efmls-configs",
        "mason.nvim",
        "mason-lspconfig.nvim",
        "cmp-nvim-lsp",
        "nvim-cmp",
        "copilot.lua",
        "lazy.nvim",
        "gitsigns.nvim",
      },
    },
  })
end
