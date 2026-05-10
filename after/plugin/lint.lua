Util.pack.load "nvim-lint"

Util.lint.apply()

vim.api.nvim_create_autocmd(Util.lint.events, {
  group = augroup "nvim_lint",
  callback = Util.lint.debounce(100, function(args) Util.lint.try(args.buf) end),
})

vim.api.nvim_create_user_command("Lint", function() Util.lint.try(0) end, { desc = "lint: current buffer" })
