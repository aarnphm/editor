-- local LSP keys setup
local K = {}

---@type LazyKeysLspSpec[]|nil
K._keys = nil

---@alias LazyKeysLspSpec LazyKeysSpec|{has?:string}
---@alias LazyKeysLsp LazyKeys|{has?:string}

K.get = function()
  if not K._keys then
    --@class PluginLspKeys
    K._keys = {
      { "gh", "<cmd>Telescope lsp_references<CR>", desc = "lsp: references" },
      { "K", vim.lsp.buf.hover, desc = "lsp: Hover" },
      { "H", vim.lsp.buf.signature_help, desc = "lsp: Signature help", has = "signatureHelp" },
      { "gd", vim.lsp.buf.definition, desc = "lsp: Peek definition", has = "definition" },
      { "gD", vim.lsp.buf.declaration, desc = "lsp: Peek definition", has = "declaration" },
      { "gR", "<cmd>Glance references<cr>", desc = "lsp: Show references", has = "definition" },
      { "gr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
      { "gI", vim.lsp.buf.implementation, desc = "lsp: implementation" },
      { "cr", vim.lsp.buf.references, desc = "References", nowait = true },
      { "gy", vim.lsp.buf.type_definition, desc = "lsp: t[y]pe definition" },
      { "gK", vim.lsp.buf.signature_help, desc = "lsp: signature help", has = "signatureHelp" },
      { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "lsp: signature help", has = "signatureHelp" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "lsp: code action", mode = { "n", "v" }, has = "codeAction" },
      { "<leader>cc", vim.lsp.codelens.run, desc = "lsp: run codelens", mode = { "n", "v" }, has = "codeLens" },
      {
        "<leader>cC",
        vim.lsp.codelens.refresh,
        desc = "lsp: refresh & display codelens",
        mode = { "n" },
        has = "codeLens",
      },
      {
        "<leader>cR",
        Util.lsp.rename_file,
        desc = "lsp: rename file",
        mode = { "n" },
        has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
      },
      { "<leader>cr", vim.lsp.buf.rename, desc = "lsp: rename", has = "rename" },
      { "<leader>cA", Util.lsp.action.source, desc = "lsp: source action", has = "codeAction" },
      {
        "]]",
        function() Util.lsp.words.jump(vim.v.count1) end,
        has = "documentHighlight",
        desc = "lsp: next reference",
        cond = function() return Util.lsp.words.enabled end,
      },
      {
        "[[",
        function() Util.lsp.words.jump(-vim.v.count1) end,
        has = "documentHighlight",
        desc = "lsp: prev reference",
        cond = function() return Util.lsp.words.enabled end,
      },
      {
        "<a-n>",
        function() Util.lsp.words.jump(vim.v.count1, true) end,
        has = "documentHighlight",
        desc = "lsp: next reference",
        cond = function() return Util.lsp.words.enabled end,
      },
      {
        "<a-p>",
        function() Util.lsp.words.jump(-vim.v.count1, true) end,
        has = "documentHighlight",
        desc = "lsp: prev reference",
        cond = function() return Util.lsp.words.enabled end,
      },
    }
  end
  return K._keys
end

---@param method string|string[]
function K.has(buffer, method)
  if type(method) == "table" then
    for _, m in ipairs(method) do
      if K.has(buffer, m) then return true end
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
function K.resolve(buffer)
  local Keys = require "lazy.core.handler.keys"
  if not Keys.resolve then return {} end
  local spec = K.get()
  local opts = Util.opts "nvim-lspconfig"
  local clients = Util.lsp.get_clients { bufnr = buffer }
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
    local has = not keys.has or K.has(buffer, keys.has)
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

return K
