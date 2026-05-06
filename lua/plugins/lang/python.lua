local ruff_format_excluded_roots = {
  "$WORKSPACE/monpy",
}

local function get_ruff_format_excluded_roots()
  local roots = vim.list_extend({}, ruff_format_excluded_roots)
  local extra = vim.g.python_ruff_format_excluded_roots

  if type(extra) == "string" then
    table.insert(roots, extra)
  elseif type(extra) == "table" then
    vim.list_extend(roots, extra)
  end

  return roots
end

local function expand_path(path)
  local unresolved = false
  local expanded = path:gsub("%${([%w_]+)}", function(name)
    local value = vim.env[name]
    if value == nil or value == "" then
      unresolved = true
      return ""
    end
    return value
  end)

  expanded = expanded:gsub("%$([%w_]+)", function(name)
    local value = vim.env[name]
    if value == nil or value == "" then
      unresolved = true
      return ""
    end
    return value
  end)

  if unresolved then return nil end
  expanded = vim.fn.expand(expanded)
  if expanded == "" then return nil end
  return vim.fs.normalize(expanded)
end

local function path_is_under(path, root)
  path = vim.uv.fs_realpath(path) or vim.fs.normalize(path)
  root = vim.uv.fs_realpath(root) or vim.fs.normalize(root)

  return path == root or vim.startswith(path, root .. "/")
end

local function skip_ruff_format(path)
  if path == nil or path == "" then return false end

  for _, root in ipairs(get_ruff_format_excluded_roots()) do
    local expanded = expand_path(root)
    if expanded and path_is_under(path, expanded) then return true end
  end

  return false
end

local function use_ruff_formatters(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if skip_ruff_format(path) then return {} end
  return { "ruff_fix", "ruff_organize_import" }
end

local function ruff_format_enabled(_, ctx) return not skip_ruff_format(ctx.filename) end

local function disable_ruff_lsp_formatting(client, bufnr)
  if client.name ~= "ruff" or not skip_ruff_format(vim.api.nvim_buf_get_name(bufnr)) then return end

  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
  client.server_capabilities.documentOnTypeFormattingProvider = nil
end

return {
  { "mason-org/mason.nvim", opts = { ensure_installed = { "ruff", "mypy", "ty" } } },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = { python = { "ruff", "mypy" } },
      linters = {
        ruff = {
          condition = function(ctx)
            return vim.fs.find({ "pyproject.toml", "ruff.toml", ".ruff.toml" }, { path = ctx.filename, upward = true })[1]
          end,
        },
        mypy = {
          condition = function(ctx)
            return vim.fs.find({ "pyproject.toml", "mypy.ini" }, { path = ctx.filename, upward = true })[1]
          end,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        ruff_fix = {
          condition = ruff_format_enabled,
        },
        ruff_organize_import = {
          inherit = false,
          command = "ruff",
          args = {
            "check",
            "--fix",
            "--force-exclude",
            "--exit-zero",
            "--no-cache",
            "--stdin-filename",
            "$FILENAME",
            "-",
          },
          stdin = true,
          condition = ruff_format_enabled,
        },
      },
      formatters_by_ft = { python = use_ruff_formatters },
    },
  },
  {
    "neovim/nvim-lspconfig",
    init = function()
      local group = vim.api.nvim_create_augroup("python_ruff_format_exclusions", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then disable_ruff_lsp_formatting(client, args.buf) end
        end,
      })
      for _, client in ipairs(vim.lsp.get_clients { name = "ruff" }) do
        for bufnr in pairs(client.attached_buffers or {}) do
          disable_ruff_lsp_formatting(client, bufnr)
        end
      end
    end,
    opts = {
      servers = {
        ty = {},
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          init_options = { settings = { logLevel = "error" } },
          on_attach = disable_ruff_lsp_formatting,
        },
      },
    },
  },
}
