-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/sumneko_lua.lua

-- call neodev before setup sumneko_lua
require("neodev").setup({
  library = {
    enabled = true,
    runtime = true,
    types = true,
    plugins = { "dap", "nvim-dap-ui", "lualine", "nvim-treesitter", "telescope.nvim" },
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
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
      telemetry = { enable = false },
      -- Do not override treesitter lua highlighting with sumneko lua highlighting
      semantic = { enable = false },
    },
  },
}
