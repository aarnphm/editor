return {
  { "mason-org/mason.nvim", opts = { ensure_installed = { "alejandra" } } },
  {
    "neovim/nvim-lspconfig",
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
  { "stevearc/conform.nvim", opts = { formatters_by_ft = { nix = { "alejandra" } } } },
}
