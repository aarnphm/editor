Util.lsp.formatters("nix", { "alejandra" })
Util.lsp.enable("nil_ls", {
  settings = {
    ["nil"] = {
      formatting = { command = { "alejandra" } },
      nix = { flake = { autoArchive = true } },
    },
  },
})

vim.bo.commentstring = "# %s"
vim.bo.formatprg = "alejandra -q -"
