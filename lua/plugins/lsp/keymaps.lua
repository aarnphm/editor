-- local LSP keys setup
local M = {}

---@type LazyKeysLspSpec[] | vim.NIL
M._keys = nil

---@type M.words.Config
local defaults = {
  debounce = 200, -- time in ms to wait before updating
  notify_jump = false, -- show a notification when jumping
  notify_end = true, -- show a notification when reaching the end
  foldopen = true, -- open folds after jumping
  jumplist = true, -- set jump point before jumping
  modes = { "n", "i", "c" }, -- modes to show references
  filter = function(buf) -- what buffers to enable `M.words`
    return vim.g.M.words ~= false and vim.b[buf].M.words ~= false
  end,
}

local config = Snacks.config.get("words", defaults)
local ns = vim.api.nvim_create_namespace "vim_lsp_references"
local ns2 = vim.api.nvim_create_namespace "nvim.lsp.references"
local timer = (vim.uv or vim.loop).new_timer()

---@type snacks.words
M.words = {
  meta = {
    desc = "Auto-show LSP references and quickly navigate between them",
    needs_setup = true,
  },
  enabled = false,
  enable = function()
    if M.words.enabled then return end
    M.words.enabled = true
    local group = vim.api.nvim_create_augroup("M.words", { clear = true })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged" }, {
      group = group,
      callback = function()
        if not M.words.is_enabled { modes = true } then
          M.words.clear()
          return
        end
        if not ({ M.words.get() })[2] then M.words.update() end
      end,
    })
  end,
  disable = function()
    if not M.words.enabled then return end
    M.words.enabled = false
    vim.api.nvim_del_augroup_by_name "M.words"
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
      vim.api.nvim_buf_clear_namespace(buf, ns2, 0, -1)
    end
  end,
  clear = function() vim.lsp.buf.clear_references() end,
  update = function()
    local buf = vim.api.nvim_get_current_buf()
    timer:start(config.debounce, 0, function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_call(buf, function()
            if not M.is_enabled { modes = true } then return end
            vim.lsp.buf.document_highlight()
            M.clear()
          end)
        end
      end)
    end)
  end,
  ---@param opts? number|{buf?:number, modes:boolean} if modes is true, also check if the current mode is enabled
  is_enabled = function(opts)
    if not M.words.enabled then return false end
    opts = type(opts) == "number" and { buf = opts } or opts or {}

    if opts.modes then
      local mode = vim.api.nvim_get_mode().mode:lower()
      mode = mode:gsub("\22", "v"):gsub("\19", "s")
      mode = mode:sub(1, 2) == "no" and "o" or mode
      mode = mode:sub(1, 1):match "[ncitsvo]" or "n"
      if not vim.tbl_contains(config.modes, mode) then return false end
    end

    local buf = opts.buf or vim.api.nvim_get_current_buf()
    if not config.filter(buf) then return false end
    local clients = vim.lsp.get_clients { bufnr = buf }
    clients = vim.tbl_filter(
      function(client) return client.supports_method("textDocument/documentHighlight", { bufnr = buf }) end,
      clients
    )
    return #clients > 0
  end,
  get = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local current, ret = nil, {} ---@type number?, LspWord[]
    local extmarks = {} ---@type vim.api.keyset.get_extmark_item[]
    vim.list_extend(extmarks, vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { details = true }))
    vim.list_extend(extmarks, vim.api.nvim_buf_get_extmarks(0, ns2, 0, -1, { details = true }))
    for _, extmark in ipairs(extmarks) do
      local w = {
        from = { extmark[2] + 1, extmark[3] },
        to = { extmark[4].end_row + 1, extmark[4].end_col },
      }
      ret[#ret + 1] = w
      if cursor[1] >= w.from[1] and cursor[1] <= w.to[1] and cursor[2] >= w.from[2] and cursor[2] <= w.to[2] then
        current = #ret
      end
    end
    return ret, current
  end,
  ---@param count? number
  ---@param cycle? boolean
  jump = function(count, cycle)
    count = count or 1
    local words, idx = M.get()
    if not idx then return end
    idx = idx + count
    if cycle then idx = (idx - 1) % #words + 1 end
    local target = words[idx]
    if target then
      if config.jumplist then vim.cmd.normal { "m`", bang = true } end
      vim.api.nvim_win_set_cursor(0, target.from)
      if config.notify_jump then
        Snacks.notify.info(("Reference [%d/%d]"):format(idx, #words), { id = "M.words.jump", title = "Words" })
      end
      if config.foldopen then vim.cmd.normal { "zv", bang = true } end
    elseif config.notify_end then
      Snacks.notify.warn("No more references", { id = "M.words.jump", title = "Words" })
    end
  end,
}
---@alias LazyKeysLspSpec LazyKeysSpec|{has?:string|string[], cond?:fun():boolean}
---@alias LazyKeysLsp LazyKeys|{has?:string|string[], cond?:fun():boolean}

local diagnostic_goto = function(next, severity)
  local pos = next and 1 or -1
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function() vim.diagnostic.jump { severity = severity, count = pos } end
end

---@return LazyKeysLsp[]
M.get = function()
  if not M._keys then
    M._keys = {
      { "<leader>cl", function() Snacks.picker.lsp_config() end, desc = "lsp: info" },
      { "K", function() vim.lsp.buf.hover() end, desc = "lsp: Hover" },
      { "gr", function() vim.lsp.buf.rename() end, desc = "lsp: rename", has = "rename" },
      { "gy", function() vim.lsp.buf.type_definition() end, desc = "lsp: t[y]pe definition" },
      { "gD", function() vim.lsp.buf.declaration() end, desc = "lsp: peek declaration", has = "declaration" },
      { "gR", Util.lsp.buf.references, desc = "lsp: show references", has = "definition", nowait = true },
      { "gd", Util.lsp.buf.definitions, desc = "lsp: peek definition", has = "definition" },
      { "gI", Util.lsp.buf.implementations, desc = "lsp: implementation" },
      {
        "<C-k>",
        function() vim.lsp.buf.signature_help() end,
        mode = "i",
        desc = "lsp: signature help",
        has = "signatureHelp",
      },
      { "<leader>d", function() vim.diagnostic.open_float() end, desc = "lsp: show line diagnostics" },
      { "]d", diagnostic_goto(true), desc = "lsp: Next diagnostic" },
      { "[d", diagnostic_goto(false), desc = "lsp: Next diagnostic" },
      { "]e", diagnostic_goto(true, vim.diagnostic.severity.E), desc = "lsp: next error" },
      { "[e", diagnostic_goto(false, vim.diagnostic.severity.E), desc = "lsp: prev error" },
      { "]w", diagnostic_goto(true, vim.diagnostic.severity.W), desc = "lsp: next warning" },
      { "[w", diagnostic_goto(false, vim.diagnostic.severity.W), desc = "lsp: prev warning" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "lsp: code action", mode = { "n", "v" }, has = "codeAction" },
      { "<leader>cc", vim.lsp.codelens.run, desc = "lsp: run codelens", mode = { "n", "v" }, has = "codeLens" },
      {
        "<leader><leader>f",
        function() Util.format { force = true } end,
        mode = { "n", "v" },
        desc = "style: format buffer",
      },
      {
        "<leader>cC",
        vim.lsp.codelens.refresh,
        desc = "lsp: refresh & display codelens",
        mode = { "n" },
        has = "codeLens",
      },
      {
        "<leader>cR",
        function() Snacks.rename.rename_file() end,
        desc = "lsp: rename file",
        mode = { "n" },
        has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
      },
      { "<leader>cA", Util.lsp.action.source, desc = "lsp: source action", has = "codeAction" },
      {
        "]]",
        function() M.words.jump(vim.v.count1) end,
        has = "documentHighlight",
        desc = "Next Reference",
        cond = function() return M.words.is_enabled() end,
      },
      {
        "[[",
        function() M.words.jump(-vim.v.count1) end,
        has = "documentHighlight",
        desc = "Prev Reference",
        cond = function() return M.words.is_enabled() end,
      },
      {
        "<C-n>",
        function() M.words.jump(vim.v.count1, true) end,
        has = "documentHighlight",
        desc = "Next Reference",
        cond = function() return M.words.is_enabled() end,
      },
      {
        "<C-p>",
        function() M.words.jump(-vim.v.count1, true) end,
        has = "documentHighlight",
        desc = "Prev Reference",
        cond = function() return M.words.is_enabled() end,
      },
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
    if client:supports_method(method, buffer) then return true end
  end
  return false
end

---@return LazyKeysLsp[]
function M.resolve(buffer)
  local Keys = require "lazy.core.handler.keys"
  if not Keys.resolve then return {} end
  local spec = M.get()
  ---@type PluginLspOptions
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
      ---@cast opts vim.keymap.set.LazyOpts
      opts.cond = nil
      opts.has = nil
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
    end
  end
end

return M
