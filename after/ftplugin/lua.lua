Util.pack.load "lazydev.nvim"

require("lazydev").setup {
  library = {
    { path = "~/workspace/neovim-plugins/avante.nvim/lua", words = { "avante" } },
    { path = "~/workspace/neovim-plugins/surf.nvim/lua", words = { "surf" } },
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    { path = "conform.nvim", words = { "conform" } },
  },
}

Util.lsp.formatters("lua", { "stylua" })
