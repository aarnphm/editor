return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "ninja", "rst" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          init_options = { settings = { logLevel = "error" } },
          keys = {
            {
              "<leader>co",
              Util.lsp.action["source.organizeImports"],
              desc = "lsp: organize imports",
            },
          },
        },
        ruff_lsp = {
          keys = {
            {
              "<leader>co",
              Util.lsp.action["source.organizeImports"],
              desc = "Organize Imports",
            },
          },
        },
        pyright = {
          settings = {
            pyright = {
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                ignore = { "*" },
                autoImportCompletions = true,
                autoSearchPaths = true,
                typeCheckingMode = "strict",
                useLibraryCodeForTypes = true,
                diagnosticSeverityOverrides = {
                  reportUnusedExpression = "none",
                },
              },
            },
          },
        },
      },
      setup = {
        ruff = function()
          Util.lsp.on_attach(function(client, _)
            if client.name == "ruff" then
              client.server_capabilities.hoverProvider = false
              client.server_capabilities.documentFormattingProvider = false -- NOTE: disable ruff formatting because I don't like deterministic formatter  in python
            end
          end, "ruff")
        end,
      },
    },
  },
  {
    "nvim-cmp",
    opts = function(_, opts)
      opts.auto_brackets = opts.auto_brackets or {}
      table.insert(opts.auto_brackets, "python")
    end,
  },
}
