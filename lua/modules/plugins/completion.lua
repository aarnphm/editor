local completion = {}

-- lspconfig
completion["neovim/nvim-lspconfig"] = {
  lazy = true,
  event = { "BufReadPost", "BufAdd", "BufNewFile" },
  config = require("completion.nvim-lspconfig"),
  cond = function()
    return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype)
  end,
  dependencies = {
    {
      "creativenull/efmls-configs-nvim",
      cond = function()
        return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype)
      end,
    },
    {
      "williamboman/mason.nvim",
      cond = function()
        return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype)
      end,
    },
    {
      "williamboman/mason-lspconfig.nvim",
      cond = function()
        return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype)
      end,
    },
    {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      config = require("completion.mason-tool-installer"),
      cond = function()
        return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype)
      end,
    },
    {
      "glepnir/lspsaga.nvim",
      config = require("completion.lspsaga"),
      event = "BufRead",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      cond = function()
        return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype)
      end,
    },
    { "ray-x/lsp_signature.nvim" },
  },
}

completion["hrsh7th/nvim-cmp"] = {
  config = require("completion.nvim-cmp"),
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
    { "windwp/nvim-autopairs", config = require("completion.nvim-autopairs") },
  },
  cond = function()
    return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype)
  end,
}

completion["zbirenbaum/copilot.lua"] = {
  cmd = "Copilot",
  event = "InsertEnter",
  config = require("completion.copilot"),
  cond = function()
    return not vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype)
  end,
}

return completion
