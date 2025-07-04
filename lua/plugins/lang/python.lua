return {
  { "mason-org/mason.nvim", opts = { ensure_installed = { "ruff", "basedpyright", "mypy", "ty" } } },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = { python = { "ruff", "mypy" } },
      linters = {
        ruff = {
          condition = function(ctx)
            return vim.fs.find({ "pyproject.toml", "ruff.toml", ".ruff.toml" }, { path = ctx.filename, upward = true })[1]
          end,
        },
        mypy = {
          condition = function(ctx)
            return vim.fs.find({ "pyproject.toml", "mypy.ini" }, { path = ctx.filename, upward = true })[1]
          end,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        ruff_organize_import = {
          inherit = false,
          command = "ruff",
          args = {
            "check",
            "--fix",
            "--force-exclude",
            "--exit-zero",
            "--no-cache",
            "--stdin-filename",
            "$FILENAME",
            "-",
          },
          stdin = true,
        },
      },
      formatters_by_ft = { python = { "ruff_fix", "ruff_organize_import" } },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {},
        ty = {},
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          init_options = { settings = { logLevel = "error" } },
        },
      },
    },
  },
}
