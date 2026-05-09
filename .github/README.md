<div align="center">
<h1>editor</h1>

fast. minimalist. choose 2

</div>

Plugin spine:

- flexoki for color
- mini.nvim for minimalist everything
- blink.cmp for completion
- mason.nvim for default executable installs
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
> LuaLS is bootstrapped by Mason by default. Other language servers and formatters are expected on PATH or in the flake/dev environment.

This config keeps `init.lua` as the bootstrap surface, then lets ordinary Neovim hierarchy own startup files, filetype hooks, after-plugin hooks, queries, snippets, and scripts.

Used with [dix](https://github.com/aarnphm/dix)
