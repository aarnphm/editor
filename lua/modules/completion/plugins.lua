local completion = {}
local config = require("modules.completion.config")

completion["kevinhwang91/nvim-bqf"] = { ft = "qf" }
-- lspconfig
completion["neovim/nvim-lspconfig"] = {
  opt = true,
  event = "BufReadPre",
  config = config.lspconfig,
}
completion["creativenull/efmls-configs-nvim"] = { opt = false, requires = "neovim/nvim-lspconfig" }
completion["williamboman/mason.nvim"] = {
  requires = {
    { "williamboman/mason-lspconfig.nvim" },
    { "WhoIsSethDaniel/mason-tool-installer.nvim", config = config.mason_install },
  },
}
completion["github/copilot.vim"] = {
  opt = true,
  setup = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.g.copilot_tab_fallback = ""
  end,
  after = "nvim-cmp",
  cmd = { "Copilot" },
}
completion["glepnir/lspsaga.nvim"] = {
  opt = true,
  event = "LspAttach",
  config = config.lspsaga,
}
completion["ray-x/lsp_signature.nvim"] = {
  opt = true,
  after = "nvim-lspconfig",
}

-- completion
completion["L3MON4D3/LuaSnip"] = {
  after = "nvim-cmp",
  config = config.luasnip,
  requires = "rafamadriz/friendly-snippets",
}
completion["hrsh7th/nvim-cmp"] = {
  config = config.cmp,
  event = "InsertEnter",
  requires = {
    { "onsails/lspkind.nvim" },
    { "lukas-reineke/cmp-under-comparator" },
    { "saadparwaiz1/cmp_luasnip", after = "LuaSnip" },
    { "hrsh7th/cmp-nvim-lsp", after = "cmp_luasnip" },
    { "hrsh7th/cmp-nvim-lua", after = "cmp-nvim-lsp" },
    { "hrsh7th/cmp-path", after = "cmp-nvim-lua" },
    { "hrsh7th/cmp-buffer", after = "cmp-path" },
    { "hrsh7th/cmp-emoji", after = "cmp-buffer" },
    { "kdheepak/cmp-latex-symbols", after = "cmp-buffer", ft = "latex" },
    { "f3fora/cmp-spell", after = "cmp-latex-symbols" },
  },
}
completion["windwp/nvim-autopairs"] = {
  after = "nvim-cmp",
  config = config.autopairs,
}
completion["fatih/vim-go"] = {
  opt = true,
  ft = "go",
  run = ":GoInstallBinaries",
  config = config.golang,
}
completion["simrat39/rust-tools.nvim"] = {
  opt = true,
  ft = "rust",
  config = config.rust_tools,
}
completion["lervag/vimtex"] = { opt = true, ft = "tex", config = config.vimtex }
completion["bazelbuild/vim-bazel"] = { requires = "google/vim-maktaba", ft = "bzl" }

return completion
