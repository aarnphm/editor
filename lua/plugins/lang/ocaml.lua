return {
  { "mason-org/mason.nvim", opts = { ensure_installed = { "ocaml-lsp", "ocamlformat" } } },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ocamllsp = {
          filetypes = {
            "ocaml",
            "ocaml.menhir",
            "ocaml.interface",
            "ocaml.ocamllex",
            "reason",
            "dune",
          },
          root_markers = {
            function(name) return name:match ".*%.opam$" end,
            "esy.json",
            "package.json",
            ".git",
            "dune-project",
            "dune-workspace",
            function(name) return name:match ".*%.ml$" end,
          },
        },
      },
    },
  },
  { "stevearc/conform.nvim", opts = { formatters_by_ft = { ml = { "ocamlformat" } } } },
  { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { "ocaml" } } },
}
