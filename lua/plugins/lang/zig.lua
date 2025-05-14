return {
  { "nvim-treesitter", opts = { ensure_installed = { "zig" } } },
  { "nvim-lspconfig", opts = { servers = { zls = {} } } },
}
