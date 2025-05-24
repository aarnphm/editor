return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          settings = {
            -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            workingDirectories = { mode = "auto" },
          },
        },
      },
      setup = {
        eslint = function()
          -- register the formatter with Util
          Util.format.register(Util.lsp.formatter {
            name = "lsp: eslint",
            primary = false,
            priority = 200,
            filter = "eslint",
          })
          return true
        end,
      },
    },
  },
}
