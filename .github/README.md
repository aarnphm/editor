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

Startup time you may ask? Check `PackProfile`. Here's running on M1 MAX:

```text
vim.pack profile (startup loads)
loads: 1 plugins, 0.67ms self, 0.67ms total
sources: 15 scripts, 8.11ms self, 9.72ms total

plugin loads
plugin                            total     self  packadd   config  phase
flexoki                            0.67     0.67     0.67     0.00  startup

startup sources
script                                                total     self  kind
after/plugin/colors.lua                                4.94     3.34  config
flexoki/colors/flexoki.lua                             1.61     1.61  pack
after/plugin/arena.lua                                 0.57     0.57  config
after/plugin/stream.lua                                0.48     0.48  config
after/plugin/scratchpad.lua                            0.29     0.29  config
after/plugin/mini.lua                                  0.27     0.27  config
after/plugin/motion.lua                                0.27     0.27  config
after/plugin/lsp.lua                                   0.25     0.25  config
plugin/statusline.lua                                  0.20     0.20  config
after/plugin/git.lua                                   0.20     0.20  config
after/plugin/dropbar.lua                               0.19     0.19  config
after/plugin/completion.lua                            0.17     0.17  config
after/plugin/search.lua                                0.11     0.11  config
after/plugin/treesitter.lua                            0.10     0.10  config
after/plugin/lint.lua                                  0.07     0.07  config
```

_pretty fast some might say_

> [!note]
>
> LuaLS is bootstrapped by Mason by default. Other language servers and formatters are expected on PATH or in the flake/dev environment.

This config keeps `init.lua` as the bootstrap surface, then lets ordinary Neovim hierarchy own startup files, filetype hooks, after-plugin hooks, queries, snippets, and scripts.

Used with [dix](https://github.com/aarnphm/dix)
