Util.lsp.prepend_mason_bin()

local function silent_map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc }) end

local function lsp_map(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
end

local function jump_to_first_location(what)
  if vim.tbl_isempty(what.items) then return end
  vim.fn.setqflist({}, " ", what)
  vim.cmd "cfirst"
end

local function clear_lsp_json_nulls(value)
  if value == vim.NIL or type(value) == "userdata" then return nil end
  if type(value) ~= "table" then return value end

  for key, child in pairs(value) do
    value[key] = clear_lsp_json_nulls(child)
  end
  return value
end

local function normalize_lsp_file_operations(client)
  local workspace = client.server_capabilities and client.server_capabilities.workspace
  if not (workspace and workspace.fileOperations) then return end

  workspace.fileOperations = clear_lsp_json_nulls(workspace.fileOperations)
end

local function format_enabled(bufnr)
  if bufnr == nil or bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return false end
  if vim.b[bufnr].autoformat ~= nil then return vim.b[bufnr].autoformat end
  return vim.g.autoformat ~= false
end

local function set_autoformat(enabled, buf_only)
  if buf_only then
    vim.b.autoformat = enabled
  else
    vim.g.autoformat = enabled
    vim.g.markdown_frontmatter = enabled
    vim.b.autoformat = nil
  end
end

local conform_setup = false

local function conform()
  if not conform_setup then
    Util.pack.load "conform.nvim"
    require("conform").setup {
      default_format_opts = { timeout_ms = 3000, lsp_format = "fallback" },
      formatters_by_ft = Util.lsp.formatters_by_ft,
      formatters = {
        injected = { options = { ignore_errors = true } },
        prettier = { condition = Util.lsp.prettier_enabled },
        ruff_fix = { condition = Util.lsp.ruff_format_enabled },
        ruff_organize_imports = { condition = Util.lsp.ruff_format_enabled },
      },
    }
    conform_setup = true
  end
  return require "conform"
end

local function format_info()
  local bufnr = vim.api.nvim_get_current_buf()
  local buffer_setting = vim.b[bufnr].autoformat
  local lines = {
    "# Format",
    ("- global: %s"):format(vim.g.autoformat ~= false and "enabled" or "disabled"),
    ("- buffer: %s"):format(buffer_setting == nil and "inherit" or buffer_setting and "enabled" or "disabled"),
    ("- effective: %s"):format(format_enabled(bufnr) and "enabled" or "disabled"),
  }

  local formatters = conform().list_formatters(bufnr)
  lines[#lines + 1] = ""
  lines[#lines + 1] = #formatters > 0 and "# Formatters" or "# Formatters\n- none"
  for _, formatter in ipairs(formatters) do
    local marker = formatter.available and "x" or " "
    lines[#lines + 1] = ("- [%s] %s"):format(marker, formatter.name)
  end

  Util[format_enabled(bufnr) and "info" or "warn"](lines)
end

vim.api.nvim_create_user_command("Format", function(opts)
  local range
  if opts.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, opts.line2 - 1, opts.line2, true)[1] or ""
    range = {
      start = { opts.line1, 0 },
      ["end"] = { opts.line2, end_line:len() },
    }
  end
  conform().format { async = true, lsp_format = "fallback", range = range }
end, { desc = "format: selection or buffer", range = true })
vim.api.nvim_create_user_command("FormatInfo", format_info, { desc = "format: info" })
vim.api.nvim_create_user_command("FormatDisable", function(opts)
  set_autoformat(false, opts.bang)
  format_info()
end, { bang = true, desc = "format: disable autoformat" })
vim.api.nvim_create_user_command("FormatEnable", function(opts)
  set_autoformat(true, opts.bang)
  format_info()
end, { bang = true, desc = "format: enable autoformat" })
vim.api.nvim_create_user_command("FormatToggle", function(opts)
  set_autoformat(not format_enabled(0), opts.bang)
  format_info()
end, { bang = true, desc = "format: toggle autoformat" })

silent_map(
  { "n", "v" },
  "<leader><leader>f",
  function() conform().format { async = true, lsp_format = "fallback" } end,
  "format: buffer"
)
silent_map(
  { "n", "v" },
  "<leader>cF",
  function() conform().format { formatters = { "injected" }, timeout_ms = 3000 } end,
  "format: injected langs"
)
silent_map("n", "<leader>uf", "<cmd>FormatToggle<cr>", "format: toggle autoformat")
silent_map("n", "<leader>uF", "<cmd>FormatToggle!<cr>", "format: toggle buffer autoformat")

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup "format_on_save",
  callback = function(event)
    if not format_enabled(event.buf) then return end
    conform().format { bufnr = event.buf, timeout_ms = 3000, lsp_format = "fallback" }
  end,
})

local function setup_diagnostics()
  vim.diagnostic.config {
    severity_sort = true,
    underline = false,
    update_in_insert = false,
    virtual_text = false,
    float = {
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      focusable = false,
      focus = false,
      source = "if_many",
      format = function(diagnostic) return string.format("%s (%s)", diagnostic.message, diagnostic.source) end,
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "✖",
        [vim.diagnostic.severity.WARN] = "▲",
        [vim.diagnostic.severity.HINT] = "⚑",
        [vim.diagnostic.severity.INFO] = "●",
      },
    },
  }
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup "diagnostics",
  once = true,
  callback = function()
    vim.schedule(function()
      setup_diagnostics()
      for _, client in ipairs(vim.lsp.get_clients()) do
        normalize_lsp_file_operations(client)
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup "lsp_attach",
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    normalize_lsp_file_operations(client)
    Util.lsp.run_attach_handlers(client, ev)

    lsp_map(ev.buf, "n", "K", vim.lsp.buf.hover, "lsp: hover")
    lsp_map(ev.buf, "i", "<C-k>", vim.lsp.buf.signature_help, "lsp: signature help")
    lsp_map(ev.buf, "n", "gr", vim.lsp.buf.rename, "lsp: rename")
    lsp_map(ev.buf, "n", "gy", vim.lsp.buf.type_definition, "lsp: type definition")
    lsp_map(ev.buf, "n", "gD", vim.lsp.buf.declaration, "lsp: declaration")
    lsp_map(
      ev.buf,
      "n",
      "gd",
      function() vim.lsp.buf.definition { on_list = jump_to_first_location } end,
      "lsp: definition"
    )
    lsp_map(ev.buf, "n", "gI", vim.lsp.buf.implementation, "lsp: implementation")
    lsp_map(ev.buf, "n", "gR", vim.lsp.buf.references, "lsp: references")
    lsp_map(ev.buf, { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "lsp: code action")
    lsp_map(
      ev.buf,
      { "n", "v" },
      "<leader><leader>f",
      function() vim.lsp.buf.format { async = true } end,
      "lsp: format"
    )
  end,
})
