Util.lint.apply()

local function try_lint(buf)
  if vim.v.vim_did_enter == 0 then
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        vim.defer_fn(function() Util.lint.try(buf) end, 100)
      end,
    })
    return
  end

  Util.lint.try(buf)
end

vim.api.nvim_create_autocmd(Util.lint.events, {
  group = augroup "nvim_lint",
  callback = Util.lint.debounce(100, function(args)
    if Util.is_bigfile(args.buf) or vim.b[args.buf].simple_arena then return end
    try_lint(args.buf)
  end),
})

vim.api.nvim_create_user_command("Lint", function() Util.lint.try(0) end, { desc = "lint: current buffer" })
