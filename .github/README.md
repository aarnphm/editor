<div align="center">
<h1>editor</h1>

fast. minimalist. choose 2

</div>

Plugin spine:

- flexoki for color
- mini.nvim for minimalist everything
- blink.cmp for completion
- built-in LSP plus nvim-lspconfig
- conform.nvim for formatting
- nvim-treesitter
- dropbar breadcrumbs
- leap.nvim for motion
- gitsigns.nvim for hunks
- grug-far.nvim for search and replace

```text
Startuptime target: boring and low.
Plugin manager: vim.pack.
Lockfile: nvim-pack-lock.json.
```

> [!note]
>
> Language servers and formatters are installed outside this repo. The flake is for editor tooling, not for owning every LSP binary.

This config is deliberately monolithic at `init.lua` for the hot path, with ordinary Neovim hierarchy for startup files, filetype hooks, after-plugin hooks, queries, snippets, and scripts.

Used with [dix](https://github.com/aarnphm/dix)
