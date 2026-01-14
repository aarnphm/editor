---@class lazyvim.util.lsp
local M = {}

---@alias lsp.Client.filter {id?: number, bufnr?: number, name?: string, method?: string, filter?:fun(client: vim.lsp.Client):boolean}

---@param opts? lsp.Client.filter
---@return vim.lsp.Client[]
function M.get_clients(opts)
  local ret = {} ---@type vim.lsp.Client[]
  ret = vim.lsp.get_clients(opts)
  return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

---@param opts? LazyFormatter| {filter?: (string|lsp.Client.filter)}
function M.formatter(opts)
  opts = opts or {}
  local filter = opts.filter or {}
  filter = type(filter) == "string" and { name = filter } or filter
  ---@cast filter lsp.Client.filter
  ---@type LazyFormatter
  local ret = {
    name = "lsp",
    primary = true,
    priority = 1,
    format = function(buf) M.format(Util.merge({}, filter, { bufnr = buf })) end,
    sources = function(buf)
      local clients = M.get_clients(Util.merge({}, filter, { bufnr = buf }))
      local ret = vim.tbl_filter(
        ---@param client vim.lsp.Client
        function(client)
          return client:supports_method "textDocument/formatting"
            or client:supports_method "textDocument/rangeFormatting"
        end,
        clients
      )
      ---@param client vim.lsp.Client
      return vim.tbl_map(function(client) return client.name end, ret)
    end,
  }
  return Util.merge(ret, opts) --[[@as LazyFormatter]]
end

---@alias lsp.Client.format {timeout_ms?: number, format_options?: table} | lsp.Client.filter

---@param opts? lsp.Client.format
function M.format(opts)
  opts = vim.tbl_deep_extend(
    "force",
    {},
    opts or {},
    Util.opts("nvim-lspconfig").format or {},
    Util.opts("conform.nvim").format or {}
  )
  local ok, conform = pcall(require, "conform")
  -- use conform for formatting with LSP when available,
  -- since it has better format diffing
  if ok then
    opts.formatters = {}
    conform.format(opts)
  else
    vim.lsp.buf.format(opts)
  end
end

M.buf = setmetatable({}, {
  __index = function(_, action)
    return function()
      -- add some fallbacks between lsp and vim.lsp.buf
      local _methods = {
        type_definitions = "type_definition",
        implementations = "implementation",
        references = "references",
      }
      vim.lsp.buf[_methods[action] or action]()
    end
  end,
})

M.buf.definitions = function()
  local params = vim.lsp.util.make_position_params(vim.api.nvim_get_current_win(), "utf-8")

  vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, ctx, config)
    if not result or vim.tbl_isempty(result) then
      Util.warn "lsp: could not find definition"
      return
    end

    if vim.islist(result) then
      vim.lsp.util.show_document(result[1], "utf-8", { focus = true })
    else
      vim.lsp.handlers["textDocument/definition"](err, result, ctx, config)
    end
  end)
end

M.action = setmetatable({}, {
  __index = function(_, action)
    return function()
      vim.lsp.buf.code_action {
        apply = true,
        context = {
          only = { action },
          diagnostics = {},
        },
      }
    end
  end,
})

---@class LspCommand: lsp.ExecuteCommandParams
---@field open? boolean
---@field handler? lsp.Handler

---@param opts LspCommand
function M.execute(opts)
  local params = {
    command = opts.command,
    arguments = opts.arguments,
  }
  if opts.open then
    require("trouble").open {
      mode = "lsp_command",
      params = params,
    }
  else
    return vim.lsp.buf_request(0, "workspace/executeCommand", params, opts.handler)
  end
end

return M
