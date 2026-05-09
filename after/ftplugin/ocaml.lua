Util.lsp.formatters("ocaml", { "ocamlformat" })
Util.lsp.enable("ocamllsp", {
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
})

vim.bo.commentstring = "(* %s *)"
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
