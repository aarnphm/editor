-- Create command for git add all and commit
vim.api.nvim_create_user_command("GCommit", function(opts)
  if opts.args == "" then
    vim.notify("Commit message is required", vim.log.levels.ERROR)
    return
  end

  -- Stage all changes
  vim.cmd "Git add -A"

  -- Create the commit with the provided message
  vim.cmd(string.format('Git commit -S --signoff -svm "%s"', opts.args))
end, {
  nargs = "*",
  desc = "Stage all changes and commit with message",
  complete = function()
    -- No completion needed for commit message
    return {}
  end,
})
