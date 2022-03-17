require("modules.completion.formatting")

vim.cmd([[packadd nvim-lsp-installer]])
vim.cmd([[packadd lsp_signature.nvim]])
vim.cmd([[packadd lspsaga.nvim]])
vim.cmd([[packadd cmp-nvim-lsp]])
vim.cmd([[packadd lua-dev.nvim]])
vim.cmd([[packadd aerial.nvim]])

local saga = require("lspsaga")
local lspconfig = require("lspconfig")
local lsp_installer = require("nvim-lsp-installer")
local lsp_configs = require("lspconfig.configs")

-- Include the servers you want to have installed by default below
local to_be_installed = {
  "bashls",
  "pyright",
  "sumneko_lua",
  "gopls",
  "dockerls",
  "bashls",
  "terraformls",
  "elmls",
  "jedi_language_server",
}

for _, name in pairs(to_be_installed) do
  local server_is_found, server = lsp_installer.get_server(name)
  if server_is_found and not server:is_installed() then
    print("Installing " .. name)
    server:install()
  end
end

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

lsp_installer.settings({
  ui = {
    icons = {
      server_installed = "✓",
      server_pending = "➜",
      server_uninstalled = "✗",
    },
  },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

-- Override default format setting
vim.lsp.handlers["textDocument/formatting"] = function(err, result, ctx)
  if err ~= nil or result == nil then
    return
  end
  if vim.api.nvim_buf_get_var(ctx.bufnr, "init_changedtick") == vim.api.nvim_buf_get_var(ctx.bufnr, "changedtick") then
    local view = vim.fn.winsaveview()
    vim.lsp.util.apply_text_edits(result, ctx.bufnr, "utf-16")
    vim.fn.winrestview(view)
    if ctx.bufnr == vim.api.nvim_get_current_buf() then
      vim.b.saving_format = true
      vim.cmd([[update]])
      vim.b.saving_format = false
    end
  end
end

local function on_editor_attach(client)
  require("lsp_signature").on_attach({
    bind = true,
    use_lspsaga = false,
    floating_window = true,
    fix_pos = true,
    hint_enable = true,
    hi_parameter = "Search",
    handler_opts = { "double" },
  })
  require("aerial").on_attach(client)

  if client.resolved_capabilities.document_formatting then
    vim.cmd([[augroup Format]])
    vim.cmd([[autocmd! * <buffer>]])
    vim.cmd([[autocmd BufWritePost <buffer> lua require'modules.completion.formatting'.format()]])
    vim.cmd([[augroup END]])
  end
end

-- Override server settings here
local default_options = {
  capabilities = capabilities,
  on_attach = on_editor_attach,
  flags = { debounce_text_changes = 150 },
}

local format_config = require("modules.completion.formatting").language_format()
local servers = {
  tsserver = {
    root_dir = lspconfig.util.root_pattern("tsconfig.json", "package.json", ".git"),
  },
  pyright = {
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
  },
  efm = {
    filetypes = vim.tbl_keys(format_config),
    init_options = { documentFormatting = true },
    root_dir = lspconfig.util.root_pattern({ ".git/", "." }),
    settings = { languages = format_config },
  },
  sumneko_lua = require("lua-dev").setup({}),
}

if not lsp_configs.ls_emmet then
  lsp_configs.ls_emmet = {
    default_config = {
      cmd = { "ls_emmet", "--stdio" },
      filetypes = {
        "html",
        "css",
        "scss",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "haml",
        "xml",
        "xsl",
        "pug",
        "slim",
        "sass",
        "stylus",
        "less",
        "sss",
        "hbs",
        "handlebars",
      },
      root_dir = function(fname)
        return vim.loop.cwd()
      end,
      settings = {},
    },
  }
end

local enhance_server_opts = {
  ["sumneko_lua"] = function(opts)
    opts.settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
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
    }
  end,
  ["tsserver"] = function(opts)
    -- Disable `tsserver`'s format
    opts.on_attach = function(client)
      client.resolved_capabilities.document_formatting = false
      on_editor_attach(client)
    end
  end,
  ["dockerls"] = function(opts)
    -- Disable `dockerls`'s format
    opts.on_attach = function(client)
      client.resolved_capabilities.document_formatting = false
      on_editor_attach(client)
    end
  end,
  ["gopls"] = function(opts)
    opts.settings = {
      gopls = {
        usePlaceholders = true,
        analyses = {
          nilness = true,
          shadow = true,
          unusedparams = true,
          unusewrites = true,
        },
      },
    }
    -- Disable `gopls`'s format
    opts.on_attach = function(client)
      client.resolved_capabilities.document_formatting = false
      on_editor_attach(client)
    end
  end,
}

lspconfig.ls_emmet.setup({ capabilities = capabilities })

lsp_installer.on_server_ready(function(server)
  local opt = servers[server.name] or {}
  opt = vim.tbl_deep_extend("force", {}, default_options, opt)
  if enhance_server_opts[server.name] then
    enhance_server_opts[server.name](opt)
  end

  server:setup(opt)
end)

-- https://github.com/vscode-langservers/vscode-html-languageserver-bin
lspconfig.html.setup({
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
local pylint = require("efmls-configs.linters.pylint")
local shellcheck = require("efmls-configs.linters.shellcheck")
local staticcheck = require("efmls-configs.linters.staticcheck")

local black = require("efmls-configs.formatters.black")
local luafmt = require("efmls-configs.formatters.lua_format")
local clangfmt = require("efmls-configs.formatters.clang_format")
local goimports = require("efmls-configs.formatters.goimports")
local prettier = require("efmls-configs.formatters.prettier")
local shfmt = require("efmls-configs.formatters.shfmt")

-- Override default config here

-- Setup formatter and linter for efmls here
efmls.setup({
  vim = { formatter = vint },
  lua = { formatter = luafmt },
  c = { formatter = clangfmt, linter = clangtidy },
  cpp = { formatter = clangfmt, linter = clangtidy },
  go = { formatter = goimports, linter = staticcheck },
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
