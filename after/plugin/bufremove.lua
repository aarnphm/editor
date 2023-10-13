vim.keymap.set("n", "<C-x>", function()
  local bd = require("mini.bufremove").delete
  if vim.bo.modified then
    local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
    if choice == 1 then -- yes
      vim.cmd.write()
      bd(0)
    elseif choice == 2 then -- no
      bd(0, true)
    end
  else
    bd(0)
  end
end, { desc = "buf: delete" })
vim.keymap.set("n", "<C-q>", function() require("mini.bufremove").delete(0, true) end, { desc = "buf: force delete" })
