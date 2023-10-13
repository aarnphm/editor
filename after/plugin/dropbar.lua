require("dropbar").setup {
  icons = {
    enable = true,
    ui = {
      bar = { separator = "  ", extends = "…" },
      menu = { separator = " ", indicator = "  " },
    },
  },
}
vim.keymap.set("n", "<LocalLeader>b", require("dropbar.api").pick)
