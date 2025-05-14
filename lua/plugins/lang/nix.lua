return {
  { "nvim-treesitter", opts = { ensure_installed = { "nix" } } },
  { "mason.nvim", opts = { ensure_installed = { "nil" } } },
  {
    "nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = {
          settings = {
            ["nil"] = {
              formatting = { command = { "alejandra" } },
              nix = { flake = { autoArchive = true } },
            },
          },
        },
      },
    },
  },
  { "conform.nvim", opts = { formatters_by_ft = { nix = { "alejandra" } } } },
}
