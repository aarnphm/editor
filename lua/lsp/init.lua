local M = {}
local utils = require "utils"

M.setup = function(_, opts)
  ---@module "lspconfig"
  local lspconfig = require "lspconfig"
  local lsp_format = require "lsp.format"
  local lsp_keymaps = require "lsp.keymaps"

  -- setup autoformat
  lsp_format.setup(opts)

  utils.on_attach(function(client, bufnr) lsp_keymaps.on_attach(client, bufnr) end)

  local register_capability = vim.lsp.handlers["client/registerCapability"]

  vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
    local ret = register_capability(err, res, ctx)
    local client_id = ctx.client_id
    ---@type lsp.Client
    local client = vim.lsp.get_client_by_id(client_id)
    local buffer = vim.api.nvim_get_current_buf()
    lsp_keymaps.on_attach(client, buffer)
    return ret
  end

  local inlay_hint = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint

  if opts.inlay_hints.enabled and inlay_hint then
    utils.on_attach(function(client, bufnr)
      if client.supports_method "textDocument/inlayHint" then inlay_hint(bufnr, true) end
    end)
  end

  utils.on_attach(function(client, bufnr)
    if client.supports_method "textDocument/publishDiagnostics" then
      vim.lsp.handlers["textDocument/publishDiagnostics"] =
          vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            signs = true,
            underline = true,
            virtual_text = false,
            update_in_insert = true,
          })
    end
  end)

  utils.on_attach(function(client, bufnr)
    if client.name == "ruff_lsp" then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end)

  -- diagnostic
  for _, type in pairs {
    { "Error", "✖" },
    { "Warn", "▲" },
    { "Hint", "⚑" },
    { "Info", "●" },
  } do
    local hl = string.format("DiagnosticSign%s", type[1])
    vim.fn.sign_define(hl, { text = type[2], texthl = hl, numhl = hl })
  end

  vim.diagnostic.config {
    severity_sort = true,
    underline = false,
    update_in_insert = false,
    virtual_text = false,
    float = {
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      focusable = false,
      focus = false,
      format = function(diagnostic)
        return string.format("%s (%s)", diagnostic.message, diagnostic.source)
      end,
      source = "if_many",
      border = "none",
    },
  }

  local servers = opts.servers
  local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  local capabilities = vim.tbl_deep_extend(
    "force",
    {},
    vim.lsp.protocol.make_client_capabilities(),
    has_cmp and cmp_nvim_lsp.default_capabilities() or {},
    opts.capabilities or {}
  )

  local mason_handler = function(server)
    local server_opts = vim.tbl_deep_extend("force", {
      capabilities = vim.deepcopy(capabilities),
      flags = { debounce_text_changes = 150 },
    }, servers[server] or {})

    if opts.setup[server] then
      if opts.setup[server](lspconfig, server_opts) then return end
    elseif opts.setup["*"] then
      if opts.setup["*"](lspconfig, server_opts) then return end
    end
    lspconfig[server].setup(server_opts)
  end

  local have_mason, mason_lspconfig = pcall(require, "mason-lspconfig")
  local available = {}
  if have_mason then
    available = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
  end

  local ensure_installed = {} ---@type string[]
  for server, server_opts in pairs(servers) do
    if server_opts then
      server_opts = server_opts == true and {} or server_opts
      -- NOTE: servers that are isolated should be setup manually.
      if server_opts.isolated then
        ensure_installed[#ensure_installed + 1] = server
      else
        -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
        if server_opts.mason == false or not vim.tbl_contains(available, server) then
          mason_handler(server)
        else
          ensure_installed[#ensure_installed + 1] = server
        end
      end
    end
  end

  if have_mason then
    mason_lspconfig.setup { ensure_installed = ensure_installed, handlers = { mason_handler } }
  end
end

return M
