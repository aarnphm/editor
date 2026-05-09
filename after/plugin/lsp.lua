Util.pack.load "mason.nvim"
Util.pack.load "conform.nvim"
Util.pack.load "nvim-lspconfig"

local function silent_map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc }) end

local function lsp_map(bufnr, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
end

Util.lsp.prepend_mason_bin()
require("mason").setup()

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

local function format_info()
  local bufnr = vim.api.nvim_get_current_buf()
  local buffer_setting = vim.b[bufnr].autoformat
  local lines = {
    "# Format",
    ("- global: %s"):format(vim.g.autoformat ~= false and "enabled" or "disabled"),
    ("- buffer: %s"):format(buffer_setting == nil and "inherit" or buffer_setting and "enabled" or "disabled"),
    ("- effective: %s"):format(format_enabled(bufnr) and "enabled" or "disabled"),
  }

  local conform_ok, conform = pcall(require, "conform")
  if conform_ok then
    local formatters = conform.list_formatters(bufnr)
    lines[#lines + 1] = ""
    lines[#lines + 1] = #formatters > 0 and "# Formatters" or "# Formatters\n- none"
    for _, formatter in ipairs(formatters) do
      local marker = formatter.available and "x" or " "
      lines[#lines + 1] = ("- [%s] %s"):format(marker, formatter.name)
    end
  end

  Util[format_enabled(bufnr) and "info" or "warn"](lines)
end

require("conform").setup {
  default_format_opts = { timeout_ms = 3000, lsp_format = "fallback" },
  format_on_save = function(bufnr)
    if not format_enabled(bufnr) then return end
    return { timeout_ms = 3000, lsp_format = "fallback" }
  end,
  formatters_by_ft = Util.lsp.formatters_by_ft,
  formatters = {
    injected = { options = { ignore_errors = true } },
    prettier = { condition = Util.lsp.prettier_enabled },
    ruff_fix = { condition = Util.lsp.ruff_format_enabled },
    ruff_organize_imports = { condition = Util.lsp.ruff_format_enabled },
  },
}

vim.api.nvim_create_user_command("Format", function(opts)
  local range
  if opts.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, opts.line2 - 1, opts.line2, true)[1] or ""
    range = {
      start = { opts.line1, 0 },
      ["end"] = { opts.line2, end_line:len() },
    }
  end
  require("conform").format { async = true, lsp_format = "fallback", range = range }
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
  function() require("conform").format { async = true, lsp_format = "fallback" } end,
  "format: buffer"
)
silent_map(
  { "n", "v" },
  "<leader>cF",
  function() require("conform").format { formatters = { "injected" }, timeout_ms = 3000 } end,
  "format: injected langs"
)
silent_map("n", "<leader>uf", "<cmd>FormatToggle<cr>", "format: toggle autoformat")
silent_map("n", "<leader>uF", "<cmd>FormatToggle!<cr>", "format: toggle buffer autoformat")

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

vim.lsp.config("*", {
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          commitCharactersSupport = false,
          deprecatedSupport = true,
          documentationFormat = { "markdown", "plaintext" },
          insertReplaceSupport = true,
          insertTextModeSupport = { valueSet = { 1 } },
          labelDetailsSupport = true,
          preselectSupport = false,
          resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits", "command", "data" } },
          tagSupport = { valueSet = { 1 } },
        },
        completionList = {
          itemDefaults = { "commitCharacters", "editRange", "insertTextFormat", "insertTextMode", "data" },
        },
        contextSupport = true,
        insertTextMode = 1,
      },
    },
    workspace = {
      didChangeWatchedFiles = { dynamicRegistration = false },
      fileOperations = { didRename = true, willRename = true },
    },
  },
})

Util.lsp.enable("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT", special = { reload = "require" } },
      library = { vim.env.VIMRUNTIME },
      telemetry = { enable = false },
      semantic = { enable = true },
      completion = { workspaceWord = true, callSnippet = "Replace" },
      hover = { expandAlias = false },
      hint = {
        enable = true,
        setType = false,
        paramType = true,
        paramName = false,
        semicolon = "Disable",
        arrayIndex = "Disable",
      },
      diagnostics = {
        disable = { "incomplete-signature-doc", "trailing-space" },
        unusedLocalExclude = { "_*" },
      },
    },
  },
})

Util.lsp.ensure_mason_packages({ "lua-language-server" }, { ["lua-language-server"] = "lua_ls" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup "lsp_attach",
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    Util.lsp.run_attach_handlers(client, ev)

    lsp_map(ev.buf, "n", "K", vim.lsp.buf.hover, "lsp: hover")
    lsp_map(ev.buf, "i", "<C-k>", vim.lsp.buf.signature_help, "lsp: signature help")
    lsp_map(ev.buf, "n", "gr", vim.lsp.buf.rename, "lsp: rename")
    lsp_map(ev.buf, "n", "gy", vim.lsp.buf.type_definition, "lsp: type definition")
    lsp_map(ev.buf, "n", "gD", vim.lsp.buf.declaration, "lsp: declaration")
    lsp_map(ev.buf, "n", "gd", vim.lsp.buf.definition, "lsp: definition")
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
