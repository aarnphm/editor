local completion = {}
local config = require("modules.completion.config")

-- lspconfig
completion["neovim/nvim-lspconfig"] = {
  opt = true,
  event = "BufReadPre",
  config = config.nvim_lsp,
}
completion["folke/lua-dev.nvim"] = {
  opt = true,
  after = "nvim-lspconfig",
}
completion["creativenull/efmls-configs-nvim"] = {
  opt = false,
  requires = "nvim-lspconfig",
}
completion["williamboman/nvim-lsp-installer"] = {
  opt = false,
}
completion["kevinhwang91/nvim-bqf"] = {
  opt = true,
  ft = "qf",
  config = config.bqf,
}
completion["tami5/lspsaga.nvim"] = {
  opt = true,
  after = "nvim-lspconfig",
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
  config = config.luasnip,
  requires = "rafamadriz/friendly-snippets",
}
completion["hrsh7th/nvim-cmp"] = {
  config = config.cmp,
  event = "InsertEnter",
  requires = {
    { "lukas-reineke/cmp-under-comparator" },
    { "saadparwaiz1/cmp_luasnip", after = "LuaSnip" },
    { "hrsh7th/cmp-nvim-lsp", after = "cmp_luasnip" },
    { "hrsh7th/cmp-nvim-lua", after = "cmp-nvim-lsp" },
    { "hrsh7th/cmp-path", after = "cmp-nvim-lua" },
    { "hrsh7th/cmp-buffer", after = "cmp-path" },
    { "kdheepak/cmp-latex-symbols", after = "cmp-buffer", ft = "latex" },
  },
}
completion["windwp/nvim-autopairs"] = {
  after = "nvim-cmp",
  config = config.autopairs,
}

return completion
