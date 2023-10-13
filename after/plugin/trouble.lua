vim.keymap.set("n", "[q", function()
  if #vim.fn.getqflist() > 0 then
    if require("trouble").is_open() then
      require("trouble").previous { skip_groups = true, jump = true }
    else
      vim.cmd.cprev()
    end
  else
    vim.notify("trouble: No items in quickfix", vim.log.levels.INFO)
  end
end, { desc = "qf: Previous items" })

vim.keymap.set("n", "]q", function()
  if #vim.fn.getqflist() > 0 then
    if require("trouble").is_open() then
      require("trouble").next { skip_groups = true, jump = true }
    else
      vim.cmd.cnext()
    end
  else
    vim.notify("trouble: No items in quickfix", vim.log.levels.INFO)
  end
end, { desc = "qf: Next items" })
