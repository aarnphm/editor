local formatting = require("modules.completion.formatting")

vim.cmd([[packadd nvim-lsp-installer]])
vim.cmd([[packadd lsp_signature.nvim]])
vim.cmd([[packadd lspsaga.nvim]])
vim.cmd([[packadd cmp-nvim-lsp]])
vim.cmd([[packadd lua-dev.nvim]])
vim.cmd([[packadd efmls-configs-nvim]])
vim.cmd([[packadd vim-illuminate]])

local lsp_installer = require("nvim-lsp-installer")
lsp_installer.setup({
  ensure_installed = { "rust_analyzer", "sumneko_lua", "bashls", "tsserver", "pyright", "dockerls", "gopls" },
  automatic_installation = true,
  ui = {
    icons = {
      server_installed = "✓",
      server_pending = "➜",
      server_uninstalled = "✗",
    },
  },
})

local saga = require("lspsaga")
-- Override diagnostics symbol
saga.init_lsp_saga({
  error_sign = "",
  warn_sign = "",
  hint_sign = "",
  infor_sign = "",
  code_action_keys = {
    quit = { "q", "<ESC>" },
  },
  rename_action_keys = {
    quit = { "q", "<ESC>" },
  },
})

local nvim_lsp = require("lspconfig")
local configs = require("lspconfig.configs")

local rnix_server = "rnix_macos"

local servers = require("nvim-lsp-installer.servers")
local installer_server = require("nvim-lsp-installer.server")

-- setup rnix-lsp
local root_dir = installer_server.get_server_root_path(rnix_server)

configs[rnix_server] = {
  default_config = {
    cmd = { "rnix-lsp" },
    filetypes = { "nix" },
    root_dir = function(fname)
      local util = require("lspconfig.util")
      return util.find_git_ancestor(fname) or vim.loop.os_homedir()
    end,
    settings = {},
    init_options = {},
  },
  docs = {
    description = [[
https://github.com/nix-community/rnix-lsp
A language server for Nix providing basic completion and formatting via nixpkgs-fmt.
To install manually, run `cargo install rnix-lsp`. If you are using nix, rnix-lsp is in nixpkgs.
This server accepts configuration via the `settings` key.
    ]],
    default_config = {
      root_dir = "vim's starting directory",
    },
  },
}

local noop_installer = function(server, callback, context) end

local rnix_macos = installer_server.Server:new({
  name = rnix_server,
  root_dir = root_dir,
  installer = noop_installer,
  languages = { "nix" },
})

servers.register(rnix_macos)

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_editor_attach = function(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  require("lsp_signature").on_attach({
    bind = true,
    use_lspsaga = false,
    floating_window = true,
    fix_pos = true,
    hint_enable = true,
    hi_parameter = "Search",
    handler_opts = { "double" },
  })
  require("illuminate").on_attach(client)
end

-- C server
local switch_source_header_splitcmd = function(bufnr, splitcmd)
  bufnr = nvim_lsp.util.validate_bufnr(bufnr)
  local clangd_client = nvim_lsp.util.get_active_client_by_name(bufnr, "clangd")
  local params = { uri = vim.uri_from_bufnr(bufnr) }
  if clangd_client then
    clangd_client.request("textDocument/switchSourceHeader", params, function(err, result)
      if err then
        error(tostring(err))
      end
      if not result then
        print("Corresponding file can’t be determined")
        return
      end
      vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
    end)
  else
    print("method textDocument/switchSourceHeader is not supported by any servers active on the current buffer")
  end
end

for _, server in ipairs(lsp_installer.get_installed_servers()) do
  if server.name == "gopls" then
    nvim_lsp.gopls.setup({
      on_attach = on_editor_attach,
      flags = { debounce_text_changes = 500 },
      capabilities = capabilities,
      cmd = { "gopls", "-remote=auto" },
      settings = {
        gopls = {
          usePlaceholders = true,
          analyses = {
            nilness = true,
            shadow = true,
            unusedparams = true,
            unusewrites = true,
          },
        },
      },
    })
  elseif server.name == "pyright" then
    nvim_lsp.pyright.setup({
      capabilities = capabilities,
      on_attach = on_editor_attach,
      flags = { debounce_text_changes = 150 },
      filetypes = { "python" },
      init_options = {
        formatters = {
          black = {
            command = "black",
            args = { "--quiet", "-" },
            rootPatterns = { "pyproject.toml" },
          },
          formatFiletypes = {
            python = { "black" },
          },
        },
      },
    })
  elseif server.name == "clangd" then
    local c_capabilities = capabilities
    c_capabilities.offsetEncoding = { "utf-16" }

    nvim_lsp.clangd.setup({
      capabilities = c_capabilities,
      single_file_support = true,
      on_attach = on_editor_attach,
      args = {
        "--background-index",
        "-std=c++20",
        "--pch-storage=memory",
        "--clang-tidy",
        "--suggest-missing-includes",
      },
      commands = {
        ClangdSwitchSourceHeader = {
          function()
            switch_source_header_splitcmd(0, "edit")
          end,
          description = "Open source/header in current buffer",
        },
        ClangdSwitchSourceHeaderVSplit = {
          function()
            switch_source_header_splitcmd(0, "vsplit")
          end,
          description = "Open source/header in a new vsplit",
        },
        ClangdSwitchSourceHeaderSplit = {
          function()
            switch_source_header_splitcmd(0, "split")
          end,
          description = "Open source/header in a new split",
        },
      },
    })
  elseif server.name == "sumneko_lua" then
    local lua_config = require("lua-dev").setup()
    nvim_lsp.sumneko_lua.setup(lua_config)
  elseif server.name == "tsserver" then
    nvim_lsp.tsserver.setup({
      on_attach = function(client)
        client.server_capabilities.document_formatting = false
        on_editor_attach(client)
      end,
      root_dir = nvim_lsp.util.root_pattern("tsconfig.json", "package.json", ".git"),
    })
  else
    nvim_lsp[server.name].setup({
      capabilities = capabilities,
      on_attach = on_editor_attach,
    })
  end
end

-- https://github.com/vscode-langservers/vscode-html-languageserver-bin
nvim_lsp.html.setup({
  cmd = { "html-languageserver", "--stdio" },
  filetypes = { "html" },
  init_options = {
    configurationSection = { "html", "css", "javascript" },
    embeddedLanguages = { css = true, javascript = true },
  },
  settings = {},
  single_file_support = true,
  flags = { debounce_text_changes = 500 },
  capabilities = capabilities,
  on_attach = on_editor_attach,
})

-- Init `efm-langserver` here.
local efmls = require("efmls-configs")
efmls.init({
  on_attach = on_editor_attach,
  capabilities = capabilities,
  init_options = { documentFormatting = true, codeAction = true },
})

-- Require `efmls-configs-nvim`'s config here

local vint = require("efmls-configs.linters.vint")
local clangtidy = require("efmls-configs.linters.clang_tidy")
local eslint = require("efmls-configs.linters.eslint")
local shellcheck = require("efmls-configs.linters.shellcheck")

local luafmt = require("efmls-configs.formatters.stylua")
local clangfmt = {
  formatCommand = "clang-format -style='{BasedOnStyle: LLVM}'",
  formatStdin = true,
}
local prettier = require("efmls-configs.formatters.prettier")
local shfmt = require("efmls-configs.formatters.shfmt")

-- Override default config here

-- Setup formatter and linter for efmls here
efmls.setup({
  vim = { formatter = vint },
  lua = { formatter = luafmt },
  c = { formatter = clangfmt, linter = clangtidy },
  cpp = { formatter = clangfmt, linter = clangtidy },
  vue = { formatter = prettier },
  typescript = { formatter = prettier, linter = eslint },
  javascript = { formatter = prettier, linter = eslint },
  typescriptreact = { formatter = prettier, linter = eslint },
  javascriptreact = { formatter = prettier, linter = eslint },
  yaml = { formatter = prettier },
  html = { formatter = prettier },
  css = { formatter = prettier },
  scss = { formatter = prettier },
  sh = { formatter = shfmt, linter = shellcheck },
  markdown = { formatter = prettier },
})
formatting.configure_format_on_save()
