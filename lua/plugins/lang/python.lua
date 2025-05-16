return {
  { "mason.nvim", opts = { ensure_installed = { "ruff", "pyright", "mypy" } } },
  {
    "nvim-lint",
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
  { "conform.nvim", opts = { formatters_by_ft = { python = { "ruff_fix", "ruff_organize_import" } } } },
  {
    "nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        ty = { mason = false },
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          init_options = { settings = { logLevel = "error" } },
        },
      },
    },
  },
}
