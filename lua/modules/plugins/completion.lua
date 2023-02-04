local completion = {}

-- lspconfig
completion["neovim/nvim-lspconfig"] = {
  lazy = true,
  event = { "BufReadPost", "BufAdd", "BufNewFile" },
  config = require("completion.lsp"),
  dependencies = {
    { "creativenull/efmls-configs-nvim" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "WhoIsSethDaniel/mason-tool-installer.nvim", config = require("completion.mason-tool-installer") },
    {
      "glepnir/lspsaga.nvim",
      config = require("completion.lspsaga"),
      event = "BufRead",
      dependencies = { { "nvim-tree/nvim-web-devicons" } },
    },
    { "ray-x/lsp_signature.nvim" },
  },
}

completion["hrsh7th/nvim-cmp"] = {
  config = require("completion.cmp"),
  event = "InsertEnter",
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      config = require("completion.luasnip"),
      dependencies = { "rafamadriz/friendly-snippets" },
    },
    { "onsails/lspkind.nvim" },
    { "lukas-reineke/cmp-under-comparator" },
    { "saadparwaiz1/cmp_luasnip" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-nvim-lua" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-emoji" },
    { "kdheepak/cmp-latex-symbols" },
    { "f3fora/cmp-spell" },
    { "windwp/nvim-autopairs", config = require("completion.autopairs") },
  },
}

completion["zbirenbaum/copilot.lua"] = {
  cmd = "Copilot",
  event = "InsertEnter",
  config = require("completion.copilot"),
}

return completion
