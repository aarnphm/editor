local completion = {}
local conf = require("modules.completion.config")

-- lspconfig
completion["neovim/nvim-lspconfig"] = {
  event = "BufReadPre",
  module = "lspconfig",
  config = conf.nvim_lsp,
}
completion["folke/lua-dev.nvim"] = {
  opt = true,
}
completion["creativenull/efmls-configs-nvim"] = {
  opt = true,
}
completion["williamboman/nvim-lsp-installer"] = {
  opt = true,
}
completion["RishabhRD/nvim-lsputils"] = {
  opt = true,
  config = conf.nvim_lsputils,
}
completion["tami5/lspsaga.nvim"] = {
  opt = true,
  after = "nvim-lspconfig",
}
completion["kosayoda/nvim-lightbulb"] = {
  opt = true,
  after = "nvim-lspconfig",
  config = conf.lightbulb,
}
completion["ray-x/lsp_signature.nvim"] = {
  opt = true,
  after = "nvim-lspconfig",
}

-- completion
completion["rafamadriz/friendly-snippets"] = {
  module = "cmp_nvim_lsp",
  event = "InsertEnter",
}
completion["L3MON4D3/LuaSnip"] = {
  after = "nvim-cmp",
  wants = "friendly-snippets",
  config = conf.luasnip,
  requires = { { "rafamadriz/friendly-snippets" } },
}
completion["hrsh7th/nvim-cmp"] = {
  config = conf.cmp,
  after = "friendly-snippets",
  requires = {
    { "saadparwaiz1/cmp_luasnip", after = "LuaSnip" },
    { "lukas-reineke/cmp-under-comparator", after = "LuaSnip" },
    { "hrsh7th/cmp-nvim-lsp", after = "cmp_luasnip" },
    { "hrsh7th/cmp-nvim-lua", after = "cmp-nvim-lsp" },
    { "hrsh7th/cmp-path", after = "cmp-nvim-lua" },
    { "hrsh7th/cmp-buffer", after = "cmp-path" },
    { "kdheepak/cmp-latex-symbols", after = "cmp-buffer", ft = "latex" },
  },
}
completion["windwp/nvim-autopairs"] = {
  after = "nvim-cmp",
  config = conf.autopairs,
}
return completion
