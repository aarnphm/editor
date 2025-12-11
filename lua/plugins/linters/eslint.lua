return {
  {
    "mfussenegger/nvim-lint",
    linters = {
      eslint = {
        condition = function(ctx)
          return vim.fs.find({
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.yaml",
            ".eslintrc.yml",
            ".eslintrc.json",
            "eslint.config.js",
            "eslint.config.mjs",
            "eslint.config.cjs",
            "eslint.config.ts",
            "eslint.config.mts",
            "eslint.config.cts",
          }, { path = ctx.filename, upward = true })[1]
        end,
      },
    },
  },
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
