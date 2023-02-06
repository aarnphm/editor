-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/sumneko_lua.lua
-- call neodev before setup sumneko_lua
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
return {
  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace",
      },
      diagnostics = {
        globals = { "vim" },
      },
      telemetry = { enable = false },
      -- Do not override treesitter lua highlighting with sumneko lua highlighting
      semantic = { enable = false },
    },
  },
}
