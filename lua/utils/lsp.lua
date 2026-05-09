local M = {}

M.formatters_by_ft = {}

local enabled_servers = {}
local attach_handlers = {}

local mason_bin = vim.fs.joinpath(vim.fn.stdpath "data", "mason", "bin")

local server_executables = {
  bashls = "bash-language-server",
  clangd = "clangd",
  gopls = "gopls",
  jsonls = "vscode-json-language-server",
  lua_ls = "lua-language-server",
  markdown_oxide = "markdown-oxide",
  mojo = "mojo-lsp-server",
  nil_ls = "nil",
  ocamllsp = "ocamllsp",
  ruff = "ruff",
  rust_analyzer = "rust-analyzer",
  taplo = "taplo",
  tailwindcss = "tailwindcss-language-server",
  ty = "ty",
  vtsls = "vtsls",
  yamlls = "yaml-language-server",
  zls = "zls",
}

local ruff_format_excluded_roots = {
  "$WORKSPACE/monpy",
}

local prettier_filetypes = {
  "css",
  "graphql",
  "handlebars",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "less",
  "markdown",
  "markdown.mdx",
  "sass",
  "scss",
  "typescript",
  "typescriptreact",
  "vue",
  "yaml",
}

function M.prepend_mason_bin()
  if vim.env.PATH and not vim.env.PATH:find(mason_bin, 1, true) then
    vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
  end
end

function M.ensure_mason_packages(packages, package_servers)
  local ok, registry = pcall(require, "mason-registry")
  if not ok then return end

  package_servers = package_servers or {}

  registry:on("package:install:success", function(package)
    local server = package_servers[package.name]
    if server then vim.schedule(function() M.enable(server) end) end
  end)

  registry.refresh(function()
    for _, package_name in ipairs(packages) do
      local ok_package, package = pcall(registry.get_package, package_name)
      if ok_package and not package:is_installed() and not package:is_installing() then
        local ok_install, err = pcall(function()
          package:install({}, function(success, result)
            if success then return end
            vim.schedule(
              function()
                require("utils").warn(("mason: failed to install %s\n%s"):format(package_name, vim.inspect(result)))
              end
            )
          end)
        end)
        if not ok_install then
          vim.schedule(
            function() require("utils").warn(("mason: failed to install %s\n%s"):format(package_name, err)) end
          )
        end
      end
    end
  end)
end

function M.formatters(filetypes, formatters)
  if type(filetypes) == "string" then filetypes = { filetypes } end

  for _, filetype in ipairs(filetypes) do
    M.formatters_by_ft[filetype] = formatters
  end
end

function M.executable_for(name, config)
  if config and config.cmd then return config.cmd[1] end

  return server_executables[name] or name
end

function M.server_is_available(name, config)
  local executable = M.executable_for(name, config)
  if vim.fn.executable(executable) == 1 then return true end

  return vim.fn.executable(vim.fs.joinpath(mason_bin, executable)) == 1
end

function M.enable(name, config)
  if enabled_servers[name] then return end

  if config ~= nil then vim.lsp.config(name, config) end

  if M.server_is_available(name, config) then
    vim.lsp.enable(name)
    enabled_servers[name] = true
  end
end

function M.on_attach(name, key, callback)
  attach_handlers[name] = attach_handlers[name] or {}
  attach_handlers[name][key] = callback
end

function M.run_attach_handlers(client, ev)
  for _, callback in pairs(attach_handlers[client.name] or {}) do
    callback(client, ev)
  end
end

function M.expand_env_path(path)
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
  return vim.fs.normalize(vim.fn.expand(expanded))
end

function M.path_is_under(path, root)
  if not path or not root or root == "" then return false end

  local normalized_path = vim.uv.fs_realpath(path) or vim.fs.normalize(path)
  local normalized_root = vim.uv.fs_realpath(root) or vim.fs.normalize(root)
  return normalized_path == normalized_root or vim.startswith(normalized_path, normalized_root .. "/")
end

function M.skip_ruff_format(path)
  if path == nil or path == "" then return false end

  local roots = vim.list_extend({}, ruff_format_excluded_roots)
  if type(vim.g.python_ruff_format_excluded_roots) == "string" then
    roots[#roots + 1] = vim.g.python_ruff_format_excluded_roots
  elseif type(vim.g.python_ruff_format_excluded_roots) == "table" then
    vim.list_extend(roots, vim.g.python_ruff_format_excluded_roots)
  end

  for _, root in ipairs(roots) do
    local expanded = M.expand_env_path(root)
    if expanded and M.path_is_under(path, expanded) then return true end
  end

  return false
end

function M.use_ruff_formatters(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if M.skip_ruff_format(path) then return {} end

  return { "ruff_fix", "ruff_organize_imports" }
end

function M.ruff_format_enabled(_, ctx) return not M.skip_ruff_format(ctx and ctx.filename) end

local prettier_has_config = Util.memoize(function(filename)
  if vim.fn.executable "prettier" == 0 then return false end
  vim.fn.system { "prettier", "--find-config-path", filename }
  return vim.v.shell_error == 0
end)

local prettier_has_parser = Util.memoize(function(filetype, filename)
  if vim.fn.executable "prettier" == 0 then return false end
  if vim.tbl_contains(prettier_filetypes, filetype) then return true end

  local ret = vim.fn.system { "prettier", "--file-info", filename }
  local parsed_ok, info = pcall(vim.json.decode, ret)
  return parsed_ok and info and info.inferredParser ~= nil and info.inferredParser ~= vim.NIL
end)

function M.prettier_enabled(_, ctx)
  return prettier_has_parser(vim.bo[ctx.buf].filetype, ctx.filename) and prettier_has_config(ctx.filename)
end

return M
