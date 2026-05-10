Util.pack.load "lazydev.nvim"

require("lazydev").setup {
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    { path = "conform.nvim", words = { "conform" } },
  },
}

Util.lsp.formatters("lua", { "stylua" })
Util.lint.linters("lua", { "selene" })
Util.lint.linter("selene", {
  condition = function(ctx) return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1] end,
})
