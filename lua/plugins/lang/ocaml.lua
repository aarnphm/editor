return {
  { "mason-org/mason.nvim", opts = { ensure_installed = { "ocaml-lsp", "ocamlformat" } } },
  { "neovim/nvim-lspconfig", opts = { servers = { ocamllsp = {} } } },
  { "stevearc/conform.nvim", opts = { formatters_by_ft = { ml = { "ocamlformat" } } } },
}
