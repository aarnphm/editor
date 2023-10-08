local M = {}

---@type LazyKeysLspSpec[]|nil
M._keys = nil

---@alias LazyKeysLspSpec LazyKeysSpec|{has?:string}
---@alias LazyKeysLsp LazyKeys|{has?:string}

---@type PluginLspKeys
M._keys = nil

M.get = function()
  if not M._keys then
    --@class PluginLspKeys
    M._keys = {
      { "<leader>d", vim.diagnostic.open_float, desc = "lsp: show line diagnostics" },
      { "gR", "<cmd>Telescope lsp_references<cr>", desc = "lsp: references" },
      { "gD", vim.lsp.buf.declaration, desc = "lsp: Goto declaration" },
      { "]d", M.diagnostic_goto(true), desc = "lsp: Next diagnostic" },
      { "[d", M.diagnostic_goto(false), desc = "lsp: Prev diagnostic" },
      { "]e", M.diagnostic_goto(true, "ERROR"), desc = "lsp: Next error" },
      { "[e", M.diagnostic_goto(false, "ERROR"), desc = "lsp: Prev error" },
      { "]w", M.diagnostic_goto(true, "WARN"), desc = "lsp: Next warning" },
      { "[w", M.diagnostic_goto(false, "WARN"), desc = "lsp: Prev warning" },
      { "K", vim.lsp.buf.hover, desc = "Hover" },
      { "gd", "<cmd>Glance definitions<cr>", desc = "lsp: Peek definition", has = "definition" },
      { "gr", vim.lsp.buf.rename, desc = "lsp: rename", has = "rename" },
    }
  end
  return M._keys
end

---@param method string
function M.has(buffer, method)
  method = method:find("/") and method or "textDocument/" .. method
  local clients = require("utils").get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    if client.supports_method(method) then
      return true
    end
  end
  return false
end

---@return (LazyKeys|{has?:string})[]
function M.resolve(buffer)
  local Keys = require("lazy.core.handler.keys")
  if not Keys.resolve then
    return {}
  end
  local spec = M.get()
  local opts = require("utils").opts("nvim-lspconfig")
  local clients = require("utils").get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
    vim.list_extend(spec, maps)
  end
  return Keys.resolve(spec)
end

function M.on_attach(_, buffer)
  local Keys = require("lazy.core.handler.keys")
  local keymaps = M.resolve(buffer)

  for _, keys in pairs(keymaps) do
    if not keys.has or M.has(buffer, keys.has) then
      local opts = Keys.opts(keys)
      opts.has = nil
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
    end
  end
end

function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

return M
