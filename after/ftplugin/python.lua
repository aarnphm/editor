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
Util.lsp.enable("ruff", {
  cmd_env = { RUFF_TRACE = "messages" },
  init_options = { settings = { logLevel = "error" } },
})
Util.lsp.enable "ty"

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
