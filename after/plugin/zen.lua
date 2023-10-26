vim.keymap.set("n", "<leader>z", function()
  local view = require "zen-mode.view"
  if view.is_open() then
    view.close()
    vim.wo.number = true
    vim.wo.rnu = true
    vim.o.laststatus = 3
    vim.cmd [[do VimResized]]
  else
    view.open { window = { width = 0.79, options = {} } }
    vim.wo.wrap = false
    vim.wo.number = false
    vim.wo.rnu = false
    vim.opt.colorcolumn = "0"
    vim.o.laststatus = 0
    vim.cmd [[do VimResized]]
  end
end, { desc = "zen: no colorcolumn" })
