Util.lsp.formatters("python", Util.lsp.use_ruff_formatters)
Util.lint.linters("python", { "ruff", "mypy" })
Util.lint.linter("ruff", {
  condition = function(ctx)
    return vim.fs.find({ "pyproject.toml", "ruff.toml", ".ruff.toml" }, { path = ctx.filename, upward = true })[1]
  end,
})
Util.lint.linter("mypy", {
  condition = function(ctx)
    return vim.fs.find({ "pyproject.toml", "mypy.ini" }, { path = ctx.filename, upward = true })[1]
  end,
})

local ruff_configuration = {
  ["indent-width"] = 2,
  ["line-length"] = 119,
  preview = true,
}

Util.lsp.enable("ruff", {
  cmd = { "uvx", "ruff", "server" },
  cmd_env = { RUFF_TRACE = "messages" },
  init_options = {
    settings = {
      configuration = ruff_configuration,
      format = {
        backend = "uv",
        preview = true,
      },
      lineLength = ruff_configuration["line-length"],
      logLevel = "error",
    },
  },
})
Util.lsp.enable("ty", {
  cmd = { "uvx", "ty", "server" },
})

Util.lsp.on_attach("ruff", "disable_format_for_excluded_roots", function(client, ev)
  if not Util.lsp.skip_ruff_format(vim.api.nvim_buf_get_name(ev.buf)) then return end

  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
  client.server_capabilities.documentOnTypeFormattingProvider = nil
end)

vim.bo.commentstring = "# %s"
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true
