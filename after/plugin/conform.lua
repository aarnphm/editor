require("conform").setup {
  formatters_by_ft = {
    lua = { "stylua" },
    toml = { "taplo" },
    proto = { { "buf", "protolint" } },
  },
  format_on_save = function(bufnr)
    -- Disable autoformat on certain filetypes
    local ignore_filetypes = { "gitcommit", "java" }
    if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then return end
    -- Disable with a global or buffer-local variable
    if vim.g.autoformat or vim.b[bufnr].autoformat then return end
    -- Disable autoformat for files in a certain path
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname:match "/node_modules/" then return end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
}

vim.api.nvim_create_user_command("FormatDisable", function(args)
  -- FormatDisable! will disable formatting just for this buffer
  if args.bang then
    vim.b.autoformat = true
  else
    vim.g.autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})
vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.autoformat = false
  vim.g.autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format { async = true, lsp_fallback = true, range = range }
end, { range = true })

vim.keymap.set(
  "n",
  "<Leader><Leader>",
  function() require("conform").format { async = true, lsp_fallback = true } end,
  { desc = "style: format buffer" }
)
