

# editor

A fast, minimalist Neovim configuration. *fast. minimalist. choose 2.*

This configuration prioritizes low latency and simplicity by leveraging Neovim's native `vim.pack` plugin management and adhering strictly to standard runtime directory hierarchies. It is designed to be used as a dotfile repository alongside [dix](https://github.com/aarnphm/dix).

## 🌟 Plugin Spine

| Category | Plugin |
|----------|--------|
| 🎨 Colors | `flexoki` |
| 📦 Minimalism | `mini.nvim` |
| ⚡ Completion | `blink.cmp` |
| 🛠 Tool Management | `mason.nvim` |
| 💡 LSP | Built-in LSP + `nvim-lspconfig` |
| 📐 Formatting | `conform.nvim` |
| 🌲 Parsing | `nvim-treesitter` |
| 📍 Breadcrumbs | `dropbar.nvim` |
| 🏃 Motion | `leap.nvim` |
| 🔄 Git | `gitsigns.nvim` |
| 🔍 Search/Replace | `grug-far.nvim` |

## ⏱ Startup Performance

Optimized for rapid boot times. Profiled on M1 MAX:
```text
vim.pack profile (startup loads)
loads: 1 plugins, 0.67ms self, 0.67ms total
sources: 15 scripts, 8.11ms self, 9.72ms total
```

## 📦 Installation & Setup

1. **Clone/Symlink** the repository to your preferred location.
2. Set the Neovim app name environment variable:
   ```bash
   export NVIM_APPNAME=editor
   ```
3. Launch Neovim to bootstrap the config and install plugins:
   ```bash
   nvim
   ```
4. Plugins are automatically resolved and pinned to `nvim-pack-lock.json`. To sync or update the lockfile headlessly:
   ```bash
   NVIM_APPNAME=editor nvim --headless "+PackLock" +qa
   ```

> **Note:** LuaLS is bootstrapped by Mason by default. Other language servers and formatters are expected to be available on your `PATH` or within your development environment.

## 🛠 Usage & Development

### Neovim Commands
- `:PackStatus` - View registered plugin versions and states.
- `:PackLock` - Update managed plugins and rewrite `nvim-pack-lock.json`.
- `:checkhealth` - Inspect toolchain, LSP, and formatter diagnostics.

### Project Structure
The configuration follows Neovim's native runtime hierarchy:
- `init.lua` - Bootstrap surface and global declarations.
- `plugin/` - Startup options, keymaps, autocommands, menus, and user commands.
- `after/plugin/` - Plugin initialization and configuration.
- `after/ftplugin/` - Filetype-specific LSP and formatter settings.
- `lua/utils.lua` & `lua/types.lua` - Shared helper functions and typed shims.
- `queries/` & `after/queries/` - Treesitter query overrides.
- `snippets/` - LSP snippet definitions (Lua, LaTeX, Markdown).

### Linting & Formatting
Enforces consistent code style across the configuration:
```bash
# Format Lua sources (2-space indent, double quotes)
stylua .
# Lint Lua files
selene .
```

### Development Toolchain
A Nix shell is provided for an isolated, reproducible development environment:
```bash
# Enter dev shell (includes Neovim nightly, Stylua, Selene, fd, yq, shellcheck, etc.)
nix develop

# Run offline format/lint/script checks
nix flake check
```

## 📜 Notes
- Automated lockfile updates run via GitHub Actions on pushes and daily schedules.
- Keep plugin updates and UI changes in separate commits/PRs to maintain clean history.
- Use `:InspectTree` when adding or modifying Treesitter queries to verify highlights.
