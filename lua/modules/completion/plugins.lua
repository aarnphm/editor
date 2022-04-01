local completion = {}
local conf = require("modules.completion.config")

completion["tom-doerr/vim_codex"] = {
  opt = true,
  after = "nvim-lspconfig",
  config = function()
    vim.cmd([[
nnoremap  <C-z> :CreateCompletion<CR>
inoremap  <C-z> <Esc>li<C-g>u<Esc>l:CreateCompletion<CR>
 ]])
  end,
}
completion["neovim/nvim-lspconfig"] = {
  event = "BufReadPre",
  config = conf.nvim_lsp,
}
completion["folke/lua-dev.nvim"] = { opt = true, requires = "neovim/nvim-lspconfig" }
completion["creativenull/efmls-configs-nvim"] = {
  opt = true,
  requires = "neovim/nvim-lspconfig",
}
completion["williamboman/nvim-lsp-installer"] = {
  opt = true,
  requires = {
    "neovim/nvim-lspconfig",
  },
  after = "nvim-lspconfig",
}
completion["RishabhRD/nvim-lsputils"] = {
  opt = true,
  after = "nvim-lspconfig",
  config = conf.nvim_lsputils,
}
completion["tami5/lspsaga.nvim"] = { opt = true, after = "nvim-lspconfig" }
completion["kosayoda/nvim-lightbulb"] = {
  opt = true,
  after = "nvim-lspconfig",
  config = conf.lightbulb,
}
completion["ray-x/lsp_signature.nvim"] = { opt = true, after = "nvim-lspconfig" }

completion["hrsh7th/nvim-cmp"] = {
  config = conf.cmp,
  event = "InsertEnter",
  requires = {
    { "lukas-reineke/cmp-under-comparator", after = "nvim-cmp" },
    { "saadparwaiz1/cmp_luasnip", after = "LuaSnip" },
    { "hrsh7th/cmp-nvim-lsp", after = "cmp_luasnip" },
    { "hrsh7th/cmp-nvim-lua", after = "cmp-nvim-lsp" },
    { "andersevenrud/cmp-tmux", after = "cmp-nvim-lua" },
    { "hrsh7th/cmp-path", after = "cmp-tmux" },
    { "f3fora/cmp-spell", after = "cmp-path" },
    { "hrsh7th/cmp-buffer", after = "cmp-spell" },
    { "kdheepak/cmp-latex-symbols", after = "cmp-buffer" },
  },
}
completion["L3MON4D3/LuaSnip"] = {
  after = "nvim-cmp",
  config = conf.luasnip,
  requires = "rafamadriz/friendly-snippets",
}
completion["windwp/nvim-autopairs"] = {
  after = "nvim-cmp",
  config = conf.autopairs,
}
return completion
