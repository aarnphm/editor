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
completion["creativenull/efmls-configs-nvim"] = { opt = true, requires = "nvim-lspconfig" }
completion["williamboman/nvim-lsp-installer"] = { opt = true }
completion["github/copilot.vim"] = {
  setup = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_tab_fallback = ""
    vim.g.copilot_filetypes = {
      TelescopePrompt = false,
    }
  end,
  after = "nvim-cmp",
}
completion["kevinhwang91/nvim-bqf"] = {
  ft = "qf",
  cmd = { "BqfEnable", "BqfAutoToggle" },
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
    { "hrsh7th/cmp-cmdline", after = "cmp-buffer" },
    { "hrsh7th/cmp-emoji", after = "cmp-buffer" },
    { "andersevenrud/cmp-tmux", after = "cmp-buffer" },
    { "kdheepak/cmp-latex-symbols", after = "cmp-buffer", ft = "latex" },
    { "f3fora/cmp-spell", after = "cmp-latex-symbols" },
  },
}
completion["windwp/nvim-autopairs"] = {
  after = "nvim-cmp",
  config = config.autopairs,
}

completion["simrat39/rust-tools.nvim"] = {
  opt = true,
  ft = "rust",
  config = config.rust_tools,
  requires = "nvim-lua/plenary.nvim",
}
completion["mzlogin/vim-markdown-toc"] = {
  opt = true,
  ft = "md",
  cmd = "GenTocGFM",
}
completion["iamcco/markdown-preview.nvim"] = {
  opt = true,
  ft = "markdown",
  run = "cd app && yarn install",
}
completion["lervag/vimtex"] = { opt = true, ft = "tex", config = config.vimtex }

return completion
