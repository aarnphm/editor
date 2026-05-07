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
      local formatting_clients = vim.tbl_filter(
        ---@param client vim.lsp.Client
        function(client)
          return client:supports_method "textDocument/formatting"
            or client:supports_method "textDocument/rangeFormatting"
        end,
        clients
      )
      ---@param client vim.lsp.Client
      return vim.tbl_map(function(client) return client.name end, formatting_clients)
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

M.codelens = {}

local codelens_namespace = vim.api.nvim_create_namespace "lsp_codelens_inline"
local codelens_refresh = {} ---@type table<integer, integer>

---@alias InlineCodeLensRow table<integer, {title: string, character: integer}[]>

local function clear_codelens(buffer)
  if vim.api.nvim_buf_is_valid(buffer) then vim.api.nvim_buf_clear_namespace(buffer, codelens_namespace, 0, -1) end
end

---@param rows InlineCodeLensRow
---@param lens lsp.CodeLens
local function add_codelens_row(rows, lens)
  local command = lens.command
  local range = lens.range
  if not (command and command.title and range and range.start) then return end

  local row = range.start.line
  local lenses = rows[row] or {}
  table.insert(lenses, {
    title = command.title,
    character = range.start.character or 0,
  })
  rows[row] = lenses
end

---@param buffer integer
---@param rows InlineCodeLensRow
---@param inline boolean
local function render_codelens(buffer, rows, inline)
  clear_codelens(buffer)

  local line_count = vim.api.nvim_buf_line_count(buffer)
  for row, lenses in pairs(rows) do
    if row >= 0 and row < line_count then
      table.sort(lenses, function(left, right)
        if left.character == right.character then return left.title < right.title end
        return left.character < right.character
      end)

      local virt_text = { { "  ", "LspCodeLensSeparator" } }
      for index, lens in ipairs(lenses) do
        if index > 1 then table.insert(virt_text, { " | ", "LspCodeLensSeparator" }) end
        table.insert(virt_text, { lens.title, "LspCodeLens" })
      end

      vim.api.nvim_buf_set_extmark(buffer, codelens_namespace, row, 0, {
        virt_text = virt_text,
        virt_text_pos = inline and "eol" or "right_align",
        hl_mode = "combine",
      })
    end
  end
end

---@param buffer integer
---@param responses table<integer, {err: lsp.ResponseError?, result: lsp.CodeLens[]?}>
---@param on_done fun(rows: InlineCodeLensRow)
local function collect_codelens(buffer, responses, on_done)
  local rows = {}
  local pending = 1

  local function done()
    pending = pending - 1
    if pending == 0 then on_done(rows) end
  end

  for client_id, response in pairs(responses) do
    if not response.err then
      for _, lens in ipairs(response.result or {}) do
        if lens.command then
          add_codelens_row(rows, lens)
        else
          local client = vim.lsp.get_client_by_id(client_id)
          if client and client:supports_method("codeLens/resolve", buffer) then
            pending = pending + 1
            local ok = client:request("codeLens/resolve", lens, function(err, resolved_lens)
              if not err and resolved_lens then add_codelens_row(rows, resolved_lens) end
              done()
            end, buffer)
            if not ok then done() end
          end
        end
      end
    end
  end

  done()
end

---@class InlineCodeLensOptions
---@field inline? boolean

---@param buffer integer
---@param opts InlineCodeLensOptions
local function refresh_codelens(buffer, opts)
  if not (vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == "") then return end
  if #vim.lsp.get_clients { bufnr = buffer, method = "textDocument/codeLens" } == 0 then
    clear_codelens(buffer)
    return
  end

  codelens_refresh[buffer] = (codelens_refresh[buffer] or 0) + 1
  local refresh = codelens_refresh[buffer]
  local params = { textDocument = vim.lsp.util.make_text_document_params(buffer) }
  vim.lsp.buf_request_all(buffer, "textDocument/codeLens", params, function(responses)
    collect_codelens(buffer, responses, function(rows)
      if codelens_refresh[buffer] == refresh and vim.api.nvim_buf_is_valid(buffer) then
        render_codelens(buffer, rows, opts.inline ~= false)
      end
    end)
  end)
end

---@param opts InlineCodeLensOptions
function M.codelens.setup(opts)
  opts = opts or {}
  local codelens_group = vim.api.nvim_create_augroup("lsp_codelens_refresh", { clear = true })

  Snacks.util.lsp.on({ method = "textDocument/codeLens" }, function(buffer)
    refresh_codelens(buffer, opts)
    vim.api.nvim_clear_autocmds { group = codelens_group, buffer = buffer }
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
      group = codelens_group,
      buffer = buffer,
      callback = function() refresh_codelens(buffer, opts) end,
    })
  end)
end

return M
