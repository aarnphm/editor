# editor: fast. minimalist. choose 2

Plugins ecosystem:

- rose-pine for soho vibes, catppuccin for based vibes
- mini.nvim for minimalist everything
- Fuzzy find with telescope.nvim
- LSP integration (nvim-cmp, nvim-lspconfig, supermaven.nvim, mason, conform.nvim)
- folke's plugins (trouble.nvim, which-key.nvim, todo-comments.nvim)
- vim-motion with leap.nvim and flit.nvim

Startup time: 12ms (with vim-startuptime and lazy.nvim)

If you wish to try out something more structural,
try out [nvimdots](https://github.com/ayamir/nvimdots) or [lazyvim](https://github.com/lazyvim/lazyvim)

> [!note] Rust
> For rustaceanvim, setup `rust-analyzer` separately with nix (via dix)

This is largely build on top of some structural hierarchy of previous LazyVim versions.
I have no intention of migrating this to LazyVim, as this ia a great playground for me to experiment and test neovim.

Used with [dix](https://github.com/aarnphm/dix)
