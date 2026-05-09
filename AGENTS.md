## project structure & module organization

This Neovim configuration is anchored by `init.lua`, which intentionally owns globals plus the small native plugin list. Native plugin management uses `vim.pack`; plugin state is tracked in `nvim-pack-lock.json`. Startup options, keymaps, autocommands, menus, and user commands belong in `plugin/` so they follow Neovim's normal startup hierarchy. Plugin setup belongs in `after/plugin/`. Filetype-local behavior, including language-specific LSP and formatter setup, belongs in `after/ftplugin/`. Shared helpers stay flattened in `lua/utils.lua`, with typed shims in `lua/types.lua`. Tree-sitter query overrides belong in `queries/` or `after/queries/`. Snippets reside in `snippets/`.

This should follow neovim file structure best practice. Most of initial keyboards/options plugins is now saved under `plugin/`.

## build, test, and development commands
- `NVIM_APPNAME=nvim nvim --headless "+lua print('boot-ok')" +qa` verifies that native `vim.pack` bootstrap and core modules load.
- `NVIM_APPNAME=nvim nvim --headless "+PackUpdate!" +qa` updates managed plugins and rewrites `nvim-pack-lock.json`.
- `nix develop` enters the repo tool shell with Neovim nightly, Stylua, Selene, fd, yq, shellcheck, and Lua language tooling.
- `nix flake check` runs the offline format/lint/script checks. It does not boot Neovim because first-time `vim.pack` installs need network.
- `NVIM_APPNAME=nvim nvim --headless "+PackStatus" +qa` checks the registered native pack set.
- `stylua .` formats all Lua sources according to `stylua.toml` (2-space indent, double quotes).
- `selene .` lints Lua files with the relaxed rules defined in `selene.toml`.
- Launching with `NVIM_APPNAME=nvim nvim` verifies the config interactively; use `:PackStatus` for plugin status and `:checkhealth` to inspect toolchain issues.

## coding style & naming conventions
Use two-space indentation and spaces for tabs; align with Stylua defaults. Prefer double quotes unless interpolation or escaping argues otherwise. Keep the top-level config runtime-native rather than abstraction-heavy; shared helper behavior should stay namespaced under `Util` in `lua/utils.lua` to satisfy Selene. Global additions should be declared in `lua/types.lua` so the language server and Selene stay quiet.

## testing guidelines
Before committing, format and lint (`stylua . && selene .`). To ensure plugins resolve, run `NVIM_APPNAME=nvim nvim --headless "+lua print('boot-ok')" +qa` and review diff in `nvim-pack-lock.json`. For runtime sanity, launch Neovim with the same `NVIM_APPNAME` and trigger `:checkhealth` for any new toolchains (e.g., language servers). When adding snippets or Treesitter queries, open representative files and run `:InspectTree` to confirm highlights and ensure no errors log to `:messages`.

## commit & pull request guidelines
Recent history follows Conventional Commits (`chore: update lockfile`, `feat: add rust tools`). Use clear types (`feat`, `fix`, `chore`, `docs`, etc.) and keep scope small. Include regenerated `nvim-pack-lock.json` when plugin revisions occur. In pull requests, provide a short summary, list manual checks (formatting, linting, Neovim launch), and link any related issues. Screenshots or short recordings help when adjusting UI-focused modules (statusline, colorscheme). Avoid mixing unrelated plugin updates in the same PR; open follow-ups instead.
