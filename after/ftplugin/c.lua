vim.bo.commentstring = "// %s"

vim.keymap.set("n", "<leader>ch", function()
  if vim.fn.exists ":ClangdSwitchSourceHeader" == 2 then
    vim.cmd.ClangdSwitchSourceHeader()
  else
    Util.warn "clangd: switch source/header command is unavailable"
  end
end, { buffer = true, desc = "clangd: switch source/header" })
