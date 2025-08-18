<div align="center">
<h1>editor</h1>

fast. minimalist. choose 2

</div>

Plugins ecosystem:

- flexoki for contrast vibes, rose-pine for soho vibes
- mini.nvim for minimalist everything
- LSP integration (blink.cmp, nvim-lspconfig, copilot.lua, mason-org, conform.nvim, nvim-lint)
- folke's plugins (which-key.nvim, todo-comments.nvim)
- vim-motion with leap.nvim and flit.nvim

```text
Startuptime: 37.49ms

Based on the actual CPU time of the Neovim process till UIEnter.
This is more accurate than `nvim --startuptime`.
  LazyStart 17.83ms
  LazyDone  33.49ms (+15.66ms)
  UIEnter   37.49ms (+4ms)
```

If you wish to try out something more structural, try out [nvimdots](https://github.com/ayamir/nvimdots) or [lazyvim](https://github.com/lazyvim/lazyvim)

> [!note]
>
> For rustaceanvim, setup `rust-analyzer` separately with nix (via dix)

This is largely build on top of some structural hierarchy of previous LazyVim versions.
I have no intention of migrating this to LazyVim, as this ia a great playground for me to experiment and test neovim.

Used with [dix](https://github.com/aarnphm/dix)
