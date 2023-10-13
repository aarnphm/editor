require("glance").setup {
  border = { enable = true, top_char = "―", bottom_char = "―" },
  height = 20,
  zindex = 50,
  theme = { enable = false },
  hooks = {
    before_open = function(results, open, _, method)
      if #results == 0 then
        vim.notify(
          "This method is not supported by any of the servers registered for the current buffer",
          vim.log.levels.WARN,
          { title = "Glance" }
        )
      elseif #results == 1 and method == "references" then
        vim.notify("The identifier under cursor is the only one found", vim.log.levels.INFO, { title = "Glance" })
      else
        open(results)
      end
    end,
  },
}
