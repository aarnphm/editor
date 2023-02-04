local formatting = require("modules.completion.formatting")

local nvim_lsp = require("lspconfig")
local mason = require("mason")
local mason_lsp = require("mason-lspconfig")

require("lspconfig.ui.windows").default_options.border = "single"

local efmls = require("efmls-configs")

local icons = {
  ui = require("utils.icons").get("ui", true),
  misc = require("utils.icons").get("misc", true),
}

mason.setup({
  ui = {
    border = "rounded",
    icons = {
      package_pending = icons.ui.Modified_alt,
      package_installed = icons.ui.Check,
      package_uninstalled = icons.misc.Ghost,
    },
    keymaps = {
      toggle_server_expand = "<CR>",
      install_server = "i",
      update_server = "u",
      check_server_version = "c",
      update_all_servers = "U",
      check_outdated_servers = "C",
      uninstall_server = "X",
      cancel_installation = "<C-c>",
    },
  },
})
mason_lsp.setup({
  ensure_installed = {
    "bashls",
    "efm",
    "sumneko_lua",
    "clangd",
    "gopls",
    "pyright",
    "taplo",
  },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

local on_editor_attach = function(client, _)
  require("lsp_signature").on_attach({
    bind = true,
    use_lspsaga = false,
    floating_window = true,
    fix_pos = true,
    hint_enable = true,
    hi_parameter = "Search",
    handler_opts = {
      border = "rounded",
    },
  })
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
        vim.notify("Corresponding file can’t be determined", vim.log.levels.ERROR, { title = "LSP Error!" })
        return
      end
      vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
    end)
  else
    vim.notify(
      "Method textDocument/switchSourceHeader is not supported by any active server on this buffer",
      vim.log.levels.ERROR,
      { title = "LSP Error!" }
    )
  end
end

for _, server in ipairs(mason_lsp.get_installed_servers()) do
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
  elseif server.name == "yamlls" then
    nvim_lsp.yamlls.setup({
      on_attach = on_editor_attach,
      capabilities = capabilities,
      settings = {
        yaml = {
          schemas = {
            ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
          },
        },
      },
    })
  elseif server.name == "jdtls" then
    nvim_lsp.jdtls.setup({
      on_attach = on_editor_attach,
      flags = { debounce_text_changes = 500 },
      capabilities = capabilities,
      settings = {
        root_dir = {
          -- Single-module projects
          {
            "build.xml", -- Ant
            "pom.xml", -- Maven
            "settings.gradle", -- Gradle
            "settings.gradle.kts", -- Gradle
          },
          -- Multi-module projects
          { "build.gradle", "build.gradle.kts" },
          { "$BENTOML_GIT_ROOT/grpc-client/java" },
        } or vim.fn.getcwd(),
      },
    })
  elseif server == "clangd" then
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
        "--query-driver=/usr/bin/clang++,/usr/bin/**/clang-*,/bin/clang,/bin/clang++,/usr/bin/gcc,/usr/bin/g++",
        "--all-scopes-completion",
        "--cross-file-rename",
        "--completion-style=detailed",
        "--header-insertion-decorators",
        "--header-insertion=iwyu",
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
  elseif server == "sumneko_lua" then
    nvim_lsp.sumneko_lua.setup({
      capabilities = capabilities,
      on_attach = on_editor_attach,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim", "packer_plugins" } },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
            },
            maxPreload = 100000,
            preloadFileSize = 10000,
          },
          telemetry = { enable = false },
        },
      },
    })
  elseif server.name == "tsserver" then
    nvim_lsp.tsserver.setup({
      on_attach = function(client)
        client.server_capabilities.document_formatting = false
        on_editor_attach(client)
      end,
      root_dir = nvim_lsp.util.root_pattern("tsconfig.json", "package.json", ".git"),
    })
  elseif server == "pyright" then
    nvim_lsp.pyright.setup({
      on_attach = on_editor_attach,
      flags = { debounce_text_changes = 500 },
      capabilities = capabilities,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      },
    })
  elseif server == "jsonls" then
    nvim_lsp.jsonls.setup({
      flags = { debounce_text_changes = 500 },
      capabilities = capabilities,
      on_attach = on_editor_attach,
      settings = {
        json = {
          -- Schemas https://www.schemastore.org
          schemas = {
            {
              fileMatch = { "package.json" },
              url = "https://json.schemastore.org/package.json",
            },
            {
              fileMatch = { "tsconfig*.json" },
              url = "https://json.schemastore.org/tsconfig.json",
            },
            {
              fileMatch = {
                ".prettierrc",
                ".prettierrc.json",
                "prettier.config.json",
              },
              url = "https://json.schemastore.org/prettierrc.json",
            },
            {
              fileMatch = { ".eslintrc", ".eslintrc.json" },
              url = "https://json.schemastore.org/eslintrc.json",
            },
            {
              fileMatch = {
                ".babelrc",
                ".babelrc.json",
                "babel.config.json",
              },
              url = "https://json.schemastore.org/babelrc.json",
            },
            {
              fileMatch = { "lerna.json" },
              url = "https://json.schemastore.org/lerna.json",
            },
            {
              fileMatch = {
                ".stylelintrc",
                ".stylelintrc.json",
                "stylelint.config.json",
              },
              url = "http://json.schemastore.org/stylelintrc.json",
            },
            {
              fileMatch = { "/.github/workflows/*" },
              url = "https://json.schemastore.org/github-workflow.json",
            },
          },
        },
      },
    })
  elseif server ~= "efm" then
    nvim_lsp[server].setup({
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
efmls.init({
  on_attach = on_editor_attach,
  capabilities = capabilities,
  init_options = { documentFormatting = true, codeAction = true },
})

-- Require `efmls-configs-nvim`'s config here

local vint = require("efmls-configs.linters.vint")
local eslint = require("efmls-configs.linters.eslint")
local shellcheck = require("efmls-configs.linters.shellcheck")
local pylint = require("efmls-configs.linters.pylint")

local black = require("efmls-configs.formatters.black")
local stylua = require("efmls-configs.formatters.stylua")
local prettier = require("efmls-configs.formatters.prettier")
local shfmt = require("efmls-configs.formatters.shfmt")
local clangfmt = { formatCommand = "clang-format -style='{BasedOnStyle: LLVM, IndentWidth: 4}'", formatStdin = true }

-- Setup formatter and linter for efmls here
efmls.setup({
  vim = { formatter = vint },
  lua = { formatter = stylua },
  c = { formatter = clangfmt },
  cpp = { formatter = clangfmt },
  vue = { formatter = prettier },
  python = { formatter = black, linter = pylint },
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
