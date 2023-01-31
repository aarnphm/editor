local completion = {}
local config = require("modules.completion.config")

-- lspconfig
completion["neovim/nvim-lspconfig"] = {
  lazy = true,
  event = "BufReadPre",
  config = config.lspconfig,
  dependencies = {
    { "creativenull/efmls-configs-nvim" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "WhoIsSethDaniel/mason-tool-installer.nvim", config = config.mason_install },
    { "glepnir/lspsaga.nvim", config = config.lspsaga },
    { "ray-x/lsp_signature.nvim" },
  },
}
completion["zbirenbaum/copilot.lua"] = {
  cmd = "Copilot",
  event = "InsertEnter",
  config = config.copilot,
}

-- completion
completion["hrsh7th/nvim-cmp"] = {
  lazy = false,
  config = config.cmp,
  event = "InsertEnter",
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      config = config.luasnip,
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
    { "windwp/nvim-autopairs", config = config.autopairs },
  },
}
completion["fatih/vim-go"] = {
  lazy = true,
  ft = "go",
  run = ":GoInstallBinaries",
  config = config.golang,
}
completion["simrat39/rust-tools.nvim"] = {
  lazy = true,
  ft = "rust",
  config = config.rust_tools,
}
completion["iamcco/markdown-preview.nvim"] = {
  lazy = true,
  lazy = true,
  ft = "markdown",
  run = "cd app && yarn install",
  build = "cd app && yarn install",
}
completion["chrisbra/csv.vim"] = {
  lazy = true,
  ft = "csv",
}
completion["lervag/vimtex"] = { lazy = true, ft = "tex", config = config.vimtex }
completion["bazelbuild/vim-bazel"] = { dependencies = { "google/vim-maktaba" }, ft = "bzl" }

return completion
