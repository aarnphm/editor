require("modules.completion.formatting")

vim.cmd([[packadd nvim-lsp-installer]])
vim.cmd([[packadd lsp_signature.nvim]])
vim.cmd([[packadd lspsaga.nvim]])
vim.cmd([[packadd cmp-nvim-lsp]])
vim.cmd([[packadd lua-dev.nvim]])
vim.cmd([[packad efmls-configs-nvim]])

local lsp_installer = require("nvim-lsp-installer")
lsp_installer.setup({
  ensure_installed = { "rust_analyzer", "sumneko_lua", "bashls", "tsserver", "pyright" },
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

local on_editor_attach = function(client)
  require("lsp_signature").on_attach({
    bind = true,
    use_lspsaga = false,
    floating_window = true,
    fix_pos = true,
    hint_enable = true,
    hi_parameter = "Search",
    handler_opts = { "double" },
  })

  if client.server_capabilities.document_formatting then
    vim.cmd([[augroup Format]])
    vim.cmd([[autocmd! * <buffer>]])
    vim.cmd([[autocmd BufWritePost <buffer> lua require'modules.completion.formatting'.format()]])
    vim.cmd([[augroup END]])
  end
end

nvim_lsp.gopls.setup({
  on_attach = on_editor_attach,
  flags = { debounce_text_changes = 500 },
  capabilities = capabilities,
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

local lua_config = require("lua-dev").setup({ })

nvim_lsp.sumneko_lua.setup(lua_config)

nvim_lsp.tsserver.setup({
  on_attach = function(client)
    client.server_capabilities.document_formatting = false
    on_editor_attach(client)
  end,
  root_dir = nvim_lsp.util.root_pattern("tsconfig.json", "package.json", ".git"),
})

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

local eslint = require("efmls-configs.linters.eslint")
local pylint = require("efmls-configs.linters.pylint")
local shellcheck = require("efmls-configs.linters.shellcheck")

local black = require("efmls-configs.formatters.black")
local prettier = require("efmls-configs.formatters.prettier")
local shfmt = require("efmls-configs.formatters.shfmt")

-- Override default config here

-- Setup formatter and linter for efmls here
efmls.setup({
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
