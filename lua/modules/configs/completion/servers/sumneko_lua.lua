-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/sumneko_lua.lua
local neodev = require("modules.configs.language.neodev")

-- call neodev before setup sumneko_lua
neodev()
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
