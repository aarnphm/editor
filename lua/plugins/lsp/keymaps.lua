-- local LSP keys setup
local M = {}

---@type LazyKeysLspSpec[]|nil
M._keys = nil

---@alias LazyKeysLspSpec LazyKeysSpec|{has?:string|string[], cond?:fun():boolean}
---@alias LazyKeysLsp LazyKeys|{has?:string|string[], cond?:fun():boolean}

M.get = function()
  if not M._keys then
    M._keys = {
      { "K", vim.lsp.buf.hover, desc = "lsp: Hover" },
      { "H", vim.lsp.buf.signature_help, desc = "lsp: Signature help", has = "signatureHelp" },
      { "gr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
      { "gD", vim.lsp.buf.declaration, desc = "lsp: peek definition", has = "declaration" },
      { "gy", vim.lsp.buf.type_definition, desc = "lsp: t[y]pe definition" },
      { "gK", vim.lsp.buf.signature_help, desc = "lsp: signature help", has = "signatureHelp" },
      { "gR", Util.lsp.buffer.references, desc = "lsp: show references", has = "definition", nowait = true },
      { "gd", Util.lsp.buffer.definitions, desc = "lsp: peek definition", has = "definition" },
      { "gI", Util.lsp.buffer.implementations, desc = "lsp: implementation" },
      { "gh", Util.telescope "lsp_references", desc = "lsp: references", has = "references" },
      { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "lsp: signature help", has = "signatureHelp" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "lsp: code action", mode = { "n", "v" }, has = "codeAction" },
      { "<leader>cc", vim.lsp.codelens.run, desc = "lsp: run codelens", mode = { "n", "v" }, has = "codeLens" },
      { "<leader>cC", vim.lsp.codelens.refresh, desc = "lsp: refresh & display codelens", mode = { "n" }, has = "codeLens" },
      { "<leader>cR", Util.lsp.rename_file, desc = "lsp: rename file", mode = { "n" }, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
      { "<leader>cr", vim.lsp.buf.rename, desc = "lsp: rename", has = "rename" },
      { "<leader>cA", Util.lsp.action.source, desc = "lsp: source action", has = "codeAction" },
      { "]]", function() Util.lsp.words.jump(vim.v.count1) end, has = "documentHighlight", desc = "lsp: next reference", cond = function() return Util.lsp.words.enabled end },
      { "[[", function() Util.lsp.words.jump(-vim.v.count1) end, has = "documentHighlight", desc = "lsp: prev reference", cond = function() return Util.lsp.words.enabled end },
      { "<a-n>", function() Util.lsp.words.jump(vim.v.count1, true) end, has = "documentHighlight", desc = "lsp: next reference", cond = function() return Util.lsp.words.enabled end },
      { "<a-p>", function() Util.lsp.words.jump(-vim.v.count1, true) end, has = "documentHighlight", desc = "lsp: prev reference", cond = function() return Util.lsp.words.enabled end },
    }
  end
  return M._keys
end

---@param buffer number
---@param method string|string[]
function M.has(buffer, method)
  if type(method) == "table" then
    for _, m in ipairs(method) do
      if M.has(buffer, m) then return true end
    end
    return false
  end
  method = method:find "/" and method or "textDocument/" .. method
  local clients = Util.lsp.get_clients { bufnr = buffer }
  for _, client in ipairs(clients) do
    if client.supports_method(method) then return true end
  end
  return false
end

---@return LazyKeysLsp[]
function M.resolve(buffer)
  local Keys = require "lazy.core.handler.keys"
  if not Keys.resolve then return {} end
  local spec = M.get()
  local opts = Util.opts "nvim-lspconfig"
  local clients = Util.lsp.get_clients { bufnr = buffer }
  for _, client in ipairs(clients) do
    local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
    vim.list_extend(spec, maps)
  end
  return Keys.resolve(spec)
end

function M.on_attach(_, buffer)
  local Keys = require "lazy.core.handler.keys"
  local keymaps = M.resolve(buffer)

  for _, keys in pairs(keymaps) do
    local has = not keys.has or M.has(buffer, keys.has)
    local cond = not (keys.cond == false or ((type(keys.cond) == "function") and not keys.cond()))

    if has and cond then
      local opts = Keys.opts(keys)
      opts.cond = nil
      opts.has = nil
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
    end
  end
end

return M
