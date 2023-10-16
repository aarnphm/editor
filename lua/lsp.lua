local Util = require "utils"

local K = {}

---@type LazyKeysLspSpec[]|nil
K._keys = nil

---@alias LazyKeysLspSpec LazyKeysSpec|{has?:string}
---@alias LazyKeysLsp LazyKeys|{has?:string}

K.get = function()
  if not K._keys then
    --@class PluginLspKeys
    K._keys = {
      { "<leader>d", vim.diagnostic.open_float, desc = "lsp: show line diagnostics" },
      { "gR", "<cmd>Telescope lsp_references<cr>", desc = "lsp: references" },
      { "gD", vim.lsp.buf.declaration, desc = "lsp: Goto declaration" },
      { "]d", K.diagnostic_goto(true), desc = "lsp: Next diagnostic" },
      { "[d", K.diagnostic_goto(false), desc = "lsp: Prev diagnostic" },
      { "]e", K.diagnostic_goto(true, "ERROR"), desc = "lsp: Next error" },
      { "[e", K.diagnostic_goto(false, "ERROR"), desc = "lsp: Prev error" },
      { "]w", K.diagnostic_goto(true, "WARN"), desc = "lsp: Next warning" },
      { "[w", K.diagnostic_goto(false, "WARN"), desc = "lsp: Prev warning" },
      { "K", vim.lsp.buf.hover, desc = "Hover" },
      { "gd", "<cmd>Glance definitions<cr>", desc = "lsp: Peek definition", has = "definition" },
      { "gh", "<cmd>Glance references<cr>", desc = "lsp: Show references", has = "definition" },
      { "gr", vim.lsp.buf.rename, desc = "lsp: rename", has = "rename" },
    }
  end
  return K._keys
end

---@param method string
function K.has(buffer, method)
  method = method:find "/" and method or "textDocument/" .. method
  local clients = Util.get_clients { bufnr = buffer }
  for _, client in ipairs(clients) do
    if client.supports_method(method) then return true end
  end
  return false
end

---@return (LazyKeys|{has?:string})[]
function K.resolve(buffer)
  local Keys = require "lazy.core.handler.keys"
  if not Keys.resolve then return {} end
  local spec = K.get()
  local opts = Util.opts "nvim-lspconfig"
  local clients = Util.get_clients { bufnr = buffer }
  for _, client in ipairs(clients) do
    local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
    vim.list_extend(spec, maps)
  end
  return Keys.resolve(spec)
end

function K.on_attach(_, buffer)
  local Keys = require "lazy.core.handler.keys"
  local keymaps = K.resolve(buffer)

  for _, keys in pairs(keymaps) do
    if not keys.has or K.has(buffer, keys.has) then
      local opts = Keys.opts(keys)
      opts.has = nil
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
    end
  end
end

function K.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function() go { severity = severity } end
end

---@param opts PluginLspOptions
return function(_, opts)
  local lspconfig = require "lspconfig"

  Util.on_attach(function(cl, bufnr) K.on_attach(cl, bufnr) end)
  local register_capability = vim.lsp.handlers["client/registerCapability"]

  vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
    local ret = register_capability(err, res, ctx)
    local client_id = ctx.client_id
    ---@type lsp.Client|nil
    local cl = vim.lsp.get_client_by_id(client_id)
    local buffer = vim.api.nvim_get_current_buf()
    K.on_attach(cl, buffer)
    return ret
  end

  local inlay_hint = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint

  if opts.inlay_hints.enabled and inlay_hint then
    Util.on_attach(function(client, bufnr)
      if client.supports_method "textDocument/inlayHint" then inlay_hint(bufnr, true) end
    end)
  end

  Util.on_attach(function(cl, _)
    if cl.supports_method "textDocument/publishDiagnostics" then
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        signs = true,
        underline = false,
        virtual_text = false,
        update_in_insert = true,
      })
    end
  end)

  local servers = opts.servers
  local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  local capabilities = vim.tbl_deep_extend(
    "force",
    {},
    vim.lsp.protocol.make_client_capabilities(),
    has_cmp and cmp_nvim_lsp.default_capabilities() or {}
  )

  local function setup(server)
    local server_opts = vim.tbl_deep_extend("force", {
      capabilities = vim.deepcopy(capabilities),
      flags = { debounce_text_changes = 500 },
    }, servers[server] or {})

    if opts.setup[server] then
      if opts.setup[server](server, server_opts) then return end
    elseif opts.setup["*"] then
      if opts.setup["*"](server, server_opts) then return end
    end
    lspconfig[server].setup(server_opts)
  end

  -- get all the servers that are available through mason-lspconfig
  local have_mason, mlsp = pcall(require, "mason-lspconfig")
  local all_mslp_servers = {}
  if have_mason then
    all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
  end

  local ensure_installed = {} ---@type string[]
  for server, server_opts in pairs(servers) do
    if server_opts then
      server_opts = server_opts == true and {} or server_opts
      -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
      if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
        setup(server)
      else
        ensure_installed[#ensure_installed + 1] = server
      end
    end
  end

  if have_mason then mlsp.setup { ensure_installed = ensure_installed, handlers = { setup } } end
end
