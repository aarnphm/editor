---@class simple.util
---@field lsp simple.util.lsp
---@field pack table<string, any>
---@field root simple.util.root
---@field treesitter simple.util.treesitter
---@field ui simple.util.ui
local M = {}

function M.is_win() return vim.uv.os_uname().sysname:find "Windows" ~= nil end

---@param plugin string
---@return boolean
function M.has(plugin)
  if not vim.pack then return false end
  local ok, plugins = pcall(vim.pack.get, nil, { info = false })
  if not ok then return false end
  for _, item in ipairs(plugins) do
    if item.active and item.spec and item.spec.name == plugin then return true end
  end
  return false
end

---@return table<string, any>
function M.opts(_) return {} end

---@param name string
---@param fn fun(name: string): nil
function M.on_load(name, fn)
  vim.schedule(function() fn(name) end)
end

local lint = {
  events = { "BufWritePost", "BufReadPost", "InsertLeave" },
  linters_by_ft = {},
  linter_configs = {},
}

local function list(value) return type(value) == "table" and value or { value } end

function lint.debounce(ms, fn)
  local timer = vim.uv.new_timer()
  return function(...)
    local args = { ... }
    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule_wrap(fn)(unpack(args))
    end)
  end
end

function lint.apply()
  if not package.loaded.lint then return end

  local lint_mod = require "lint"
  for name, linter in pairs(lint.linter_configs) do
    if type(linter) == "table" and type(lint_mod.linters[name]) == "table" then
      lint_mod.linters[name] = vim.tbl_deep_extend("force", lint_mod.linters[name], linter)
    else
      lint_mod.linters[name] = linter
    end
  end
  lint_mod.linters_by_ft = vim.tbl_deep_extend("force", lint_mod.linters_by_ft or {}, lint.linters_by_ft)
end

function lint.linter(name, opts)
  lint.linter_configs[name] = vim.tbl_deep_extend("force", lint.linter_configs[name] or {}, opts)
  lint.apply()
end

function lint.linters(filetypes, names)
  filetypes = list(filetypes)
  names = list(names)

  for _, filetype in ipairs(filetypes) do
    lint.linters_by_ft[filetype] = lint.linters_by_ft[filetype] or {}
    for _, name in ipairs(names) do
      if not vim.tbl_contains(lint.linters_by_ft[filetype], name) then
        lint.linters_by_ft[filetype][#lint.linters_by_ft[filetype] + 1] = name
      end
    end
  end

  lint.apply()
end

local function lint_module()
  if not package.loaded.lint and M.pack and M.pack.get "nvim-lint" then pcall(M.pack.load, "nvim-lint") end

  local ok, lint_mod = pcall(require, "lint")
  if not ok then return nil end
  lint.apply()
  return lint_mod
end

function lint.try(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  if bufnr ~= vim.api.nvim_get_current_buf() then
    return vim.api.nvim_buf_call(bufnr, function() lint.try(0) end)
  end

  local lint_mod = lint_module()
  if not lint_mod then return end

  local names = lint_mod._resolve_linter_by_ft(vim.bo.filetype)
  names = vim.list_extend({}, names or {})
  if #names == 0 then vim.list_extend(names, lint_mod.linters_by_ft["_"] or {}) end
  vim.list_extend(names, lint_mod.linters_by_ft["*"] or {})

  local ctx = { filename = vim.api.nvim_buf_get_name(bufnr) }
  ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
  names = vim.tbl_filter(function(name)
    local linter = lint_mod.linters[name]
    if not linter then M.warn("linter: not found " .. name, { title = "nvim-lint" }) end
    return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
  end, names)

  if #names > 0 then lint_mod.try_lint(names) end
end

M.lint = lint

local pack = { specs = {} }
local loaded = {}

local function pack_specs_for_add(specs)
  local ret = {}
  for _, spec in ipairs(specs) do
    pack.specs[spec.name] = spec
    ret[#ret + 1] = {
      src = spec.src,
      name = spec.name,
      version = spec.version,
    }
  end
  return ret
end

local function pack_dependency_names(spec)
  local ret = {}
  for _, dep in ipairs(spec.dependencies or {}) do
    ret[#ret + 1] = type(dep) == "string" and dep or dep.name
  end
  return ret
end

local function pack_plugin_info(name)
  local ok_info, plugins = pcall(vim.pack.get, { name }, { info = false })
  if not ok_info then return nil end
  return plugins[1]
end

function pack.opts(spec)
  if type(spec) == "string" then spec = pack.get(spec) end
  if not spec then return nil end
  if type(spec.opts) == "function" then return spec.opts(spec) end
  return spec.opts
end

function pack.get(name) return pack.specs[name] end

function pack.load(name)
  if loaded[name] then return end

  local spec = pack.get(name)
  if not spec then
    vim.cmd.packadd(name)
    loaded[name] = true
    return
  end

  for _, dep in ipairs(pack_dependency_names(spec)) do
    pack.load(dep)
  end

  vim.cmd.packadd(name)
  loaded[name] = true

  local opts = pack.opts(spec)
  if spec.config then spec.config(spec, opts or {}) end
end

function pack.run_build(name)
  local spec = pack.get(name)
  if not (spec and spec.build) then return false end

  local info = pack_plugin_info(name)
  if not (info and info.path) then return false end

  if type(spec.build) == "function" then
    spec.build(spec, info.path)
    return true
  end

  local cmd = type(spec.build) == "table" and spec.build or { vim.o.shell, vim.o.shellcmdflag, spec.build }
  local result = vim.system(cmd, { cwd = info.path, text = true }):wait()
  if result.code ~= 0 then
    error(("PackBuild failed for %s\n%s"):format(name, result.stderr ~= "" and result.stderr or result.stdout))
  end
  return true
end

function pack.build(names)
  names = names or vim.tbl_keys(pack.specs)
  if type(names) == "string" then names = { names } end

  local built = {}
  for _, name in ipairs(names) do
    if pack.run_build(name) then built[#built + 1] = name end
  end
  return built
end

function pack.setup(specs)
  if not vim.pack then error "This config expects Nvim with vim.pack support" end

  pack.specs = {}
  loaded = {}
  vim.pack.add(pack_specs_for_add(specs), { confirm = false, load = function() end })
end

M.pack = pack

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
function M.safe_keymap_set(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

---@param msg any
---@param opts? table
local function notify(level, msg, opts)
  opts = opts or {}
  opts.title = opts.title or "editor"
  if type(msg) == "table" then msg = table.concat(msg, "\n") end
  vim.notify(tostring(msg), level, opts)
end

function M.info(msg, opts) notify(vim.log.levels.INFO, msg, opts) end

function M.warn(msg, opts) notify(vim.log.levels.WARN, msg, opts) end

function M.error(msg, opts) notify(vim.log.levels.ERROR, msg, opts) end

---@generic T
---@param fn fun(): T
---@param opts? { msg?: string }
---@return T?
function M.try(fn, opts)
  local ok, ret = pcall(fn)
  if ok then return ret end
  M.error((opts and opts.msg or "operation failed") .. "\n" .. ret)
end

---@param path string
---@return string
function M.norm(path)
  if path:sub(1, 1) == "~" then
    local home = vim.uv.os_homedir()
    if home:sub(-1) == "\\" or home:sub(-1) == "/" then home = home:sub(1, -2) end
    path = home .. path:sub(2)
  end
  path = path:gsub("\\", "/"):gsub("/+", "/")
  return path:sub(-1) == "/" and path:sub(1, -2) or path
end

local cache = {} ---@type table<function, table<string, any>>

---@generic T: fun()
---@param fn T
---@return T
function M.memoize(fn)
  return function(...)
    local key = vim.inspect { ... }
    cache[fn] = cache[fn] or {}
    if cache[fn][key] == nil then cache[fn][key] = fn(...) end
    return cache[fn][key]
  end
end

local defaults = {} ---@type table<string, boolean>

---@param option string
---@param value string|number|boolean
---@return boolean
function M.set_default(option, value)
  local local_value = vim.api.nvim_get_option_value(option, { scope = "local" })
  local global_value = vim.api.nvim_get_option_value(option, { scope = "global" })
  defaults[("%s=%s"):format(option, value)] = true

  if local_value ~= global_value and not defaults[("%s=%s"):format(option, local_value)] then return false end

  vim.api.nvim_set_option_value(option, value, { scope = "local" })
  return true
end

M.url_matcher =
  "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

---@param win integer?
function M.delete_url_match(win)
  win = win or vim.api.nvim_get_current_win()
  for _, match in ipairs(vim.fn.getmatches(win)) do
    if match.group == "HighlightURL" then vim.fn.matchdelete(match.id, win) end
  end
  vim.w[win].highlighturl_enabled = false
end

---@param win integer?
function M.set_url_match(win)
  win = win or vim.api.nvim_get_current_win()
  M.delete_url_match(win)
  vim.fn.matchadd("HighlightURL", M.url_matcher, 15, -1, { window = win })
  vim.w[win].highlighturl_enabled = true
end

---@return string?
function M.url_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local start = 0

  while true do
    local match = vim.fn.matchstrpos(line, M.url_matcher, start)
    local url, s, e = match[1], match[2], match[3]
    if s == -1 then return nil end
    if col >= s and col < e then return url end
    start = e <= start and (start + 1) or e
  end
end

---@param url string
function M.open_url(url)
  if not url or url == "" then
    M.warn "open-url: no link under cursor"
    return
  end

  if vim.ui and vim.ui.open then
    local ok = pcall(vim.ui.open, url)
    if ok then return end
  end

  local opener
  if vim.fn.has "wsl" == 1 and vim.fn.executable "wslview" == 1 then
    opener = { "wslview", url }
  elseif vim.fn.executable "xdg-open" == 1 then
    opener = { "xdg-open", url }
  elseif vim.fn.executable "open" == 1 then
    opener = { "open", url }
  elseif M.is_win() then
    opener = { "cmd.exe", "/c", "start", "", url }
  end

  if not opener then
    M.error "open-url: no system opener found"
    return
  end

  vim.system(opener, { detach = true })
end

---@class simple.util.root
---@overload fun(): string
local root = setmetatable({}, {
  __call = function(r) return r.get() end,
})

root.additional_path_root_spec = { "content" }
root.root_lsp_ignore = { "copilot" }
root.spec = { "lsp", vim.list_extend({ ".git", "lua" }, root.additional_path_root_spec or {}), "cwd" }
root.detectors = {}
root.cache = {} ---@type table<number, string>

function root.detectors.cwd() return { vim.uv.cwd() } end

function root.detectors.lsp(buf)
  local bufpath = root.bufpath(buf)
  if not bufpath then return {} end

  local roots = {}
  local clients = vim.tbl_filter(
    function(client) return not vim.tbl_contains(root.root_lsp_ignore or {}, client.name) end,
    vim.lsp.get_clients { bufnr = buf }
  )

  for _, client in pairs(clients) do
    for _, ws in pairs(client.config.workspace_folders or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.root_dir then roots[#roots + 1] = client.root_dir end
  end

  return vim.tbl_filter(function(path)
    path = M.norm(path)
    return path and bufpath:find(path, 1, true) == 1
  end, roots)
end

---@param patterns string[]|string
function root.detectors.pattern(buf, patterns)
  patterns = type(patterns) == "string" and { patterns } or patterns
  local path = root.bufpath(buf) or vim.uv.cwd()
  local pattern = vim.fs.find(function(name)
    for _, p in ipairs(patterns) do
      if name == p then return true end
      if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then return true end
    end
    return false
  end, { path = path, upward = true })[1]
  return pattern and { vim.fs.dirname(pattern) } or {}
end

function root.bufpath(buf) return root.realpath(vim.api.nvim_buf_get_name(assert(buf))) end

function root.cwd() return root.realpath(vim.uv.cwd()) or "" end

function root.realpath(path)
  if path == "" or path == nil then return nil end
  path = vim.uv.fs_realpath(path) or path
  return M.norm(path)
end

function root.resolve(spec)
  if root.detectors[spec] then
    return root.detectors[spec]
  elseif type(spec) == "function" then
    return spec
  end
  return function(buf) return root.detectors.pattern(buf, spec) end
end

---@param opts? { buf?: number, spec?: table, all?: boolean }
function root.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec or root.spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {}
  for _, spec in ipairs(opts.spec) do
    local paths = root.resolve(spec)(opts.buf)
    paths = type(paths) == "table" and paths or { paths }

    local roots = {}
    for _, p in ipairs(paths) do
      local pp = root.realpath(p)
      if pp and not vim.tbl_contains(roots, pp) then roots[#roots + 1] = pp end
    end
    table.sort(roots, function(a, b) return #a > #b end)

    if #roots > 0 then
      ret[#ret + 1] = { spec = spec, paths = roots }
      if opts.all == false then break end
    end
  end
  return ret
end

function root.info()
  local roots = root.detect { all = true }
  local lines = {}
  local first = true
  for _, item in ipairs(roots) do
    for _, path in ipairs(item.paths) do
      lines[#lines + 1] = ("- [%s] `%s` **(%s)**"):format(
        first and "x" or " ",
        path,
        type(item.spec) == "table" and table.concat(item.spec, ", ") or item.spec
      )
      first = false
    end
  end
  M.info(lines, { title = "Roots" })
  return roots[1] and roots[1].paths[1] or vim.uv.cwd()
end

---@param opts? {normalize?:boolean, buf?:number}
function root.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local ret = root.cache[buf]
  if not ret then
    local roots = root.detect { all = false, buf = buf }
    ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
    root.cache[buf] = ret
  end
  if opts.normalize then return ret end
  return M.is_win() and ret:gsub("/", "\\") or ret
end

function root.git()
  local cwd = root.get()
  local git_root = vim.fs.find(".git", { path = cwd, upward = true })[1]
  return git_root and vim.fn.fnamemodify(git_root, ":h") or cwd
end

M.root = root

---@class simple.util.treesitter
local treesitter = {}

treesitter._installed = nil ---@type table<string,boolean>?
treesitter._queries = {} ---@type table<string,boolean>

---@param update boolean?
function treesitter.get_installed(update)
  if update then
    treesitter._installed, treesitter._queries = {}, {}
    for _, lang in ipairs(require("nvim-treesitter").get_installed "parsers") do
      treesitter._installed[lang] = true
    end
  end
  return treesitter._installed or {}
end

---@param lang string
---@param query string
function treesitter.have_query(lang, query)
  local key = lang .. ":" .. query
  if treesitter._queries[key] == nil then treesitter._queries[key] = vim.treesitter.query.get(lang, query) ~= nil end
  return treesitter._queries[key]
end

---@param what string|number|nil
---@param query? string
---@return boolean
function treesitter.have(what, query)
  what = what or vim.api.nvim_get_current_buf()
  what = type(what) == "number" and vim.bo[what].filetype or what
  local lang = vim.treesitter.language.get_lang(what)
  if lang == nil or treesitter.get_installed()[lang] == nil then return false end
  if query and not treesitter.have_query(lang, query) then return false end
  return true
end

function treesitter.foldexpr() return treesitter.have(nil, "folds") and vim.treesitter.foldexpr() or "0" end

function treesitter.indentexpr()
  return treesitter.have(nil, "indents") and require("nvim-treesitter").indentexpr() or -1
end

local MATH_NODES = {
  displayed_equation = true,
  inline_formula = true,
  math_environment = true,
}

local TEXT_NODES = {
  label_definition = true,
  label_reference = true,
  text_mode = true,
}

local CODE_BLOCK_NODES = {
  fenced_code_block = true,
  indented_code_block = true,
}

function treesitter.in_text(check_parent)
  local node = vim.treesitter.get_node { ignore_injections = false }

  local block_node = node
  while block_node do
    if CODE_BLOCK_NODES[block_node:type()] then return true end
    block_node = block_node:parent()
  end

  while node do
    if node:type() == "text_mode" then
      if check_parent then
        local parent = node:parent()
        if parent and MATH_NODES[parent:type()] then return false end
      end
      return true
    elseif MATH_NODES[node:type()] then
      return false
    end
    node = node:parent()
  end
  return true
end

function treesitter.in_math()
  local node = vim.treesitter.get_node { ignore_injections = false }

  if vim.bo.filetype == "markdown" or vim.bo.filetype == "quarto" then
    local block_node = node
    while block_node do
      if CODE_BLOCK_NODES[block_node:type()] then return false end
      block_node = block_node:parent()
    end
  end

  while node do
    if TEXT_NODES[node:type()] then
      return false
    elseif MATH_NODES[node:type()] then
      return true
    end
    node = node:parent()
  end
  return false
end

function treesitter.not_math() return treesitter.in_text(true) end

M.treesitter = treesitter

---@class simple.util.ui
local ui = {}

function ui.foldtext()
  return table.concat({
    vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)[1],
    (" 󰁂 %d"):format(vim.v.foldend - vim.v.foldstart),
  }, " ")
end

function ui.foldexpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    if vim.bo[buf].filetype == "" then return "0" end
    vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
  end
  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

---@return {fg?:string}?
function ui.fg(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  local fg = hl and hl.fg or hl.foreground
  return fg and { fg = string.format("#%06x", fg) } or nil
end

M.ui = ui

---@class simple.util.cmp
local cmp = {}

---@alias simple.util.cmp.Action fun():boolean?
---@type table<string, simple.util.cmp.Action>
cmp.actions = {
  snippet_forward = function()
    if vim.snippet.active { direction = 1 } then
      vim.schedule(function() vim.snippet.jump(1) end)
      return true
    end
  end,
  snippet_stop = function()
    if vim.snippet then vim.snippet.stop() end
  end,
}

---@param actions string[]
---@param fallback? string|fun()
function cmp.map(actions, fallback)
  return function()
    for _, name in ipairs(actions) do
      if cmp.actions[name] then
        local ret = cmp.actions[name]()
        if ret then return true end
      end
    end
    return type(fallback) == "function" and fallback() or fallback
  end
end

---@alias Placeholder {n:number, text:string}

---@param snippet string
---@param fn fun(placeholder:Placeholder):string
---@return string
function cmp.snippet_replace(snippet, fn)
  return snippet:gsub("%$%b{}", function(m)
    local n, name = m:match "^%${(%d+):(.+)}$"
    return n and fn { n = n, text = name } or m
  end) or snippet
end

-- This function resolves nested placeholders in a snippet.
---@param snippet string
---@return string
function cmp.snippet_preview(snippet)
  local ok, parsed = pcall(function() return vim.lsp._snippet_grammar.parse(snippet) end)
  return ok and tostring(parsed)
    or cmp
      .snippet_replace(snippet, function(placeholder) return cmp.snippet_preview(placeholder.text) end)
      :gsub("%$0", "")
end

-- This function replaces nested placeholders in a snippet with LSP placeholders.
function cmp.snippet_fix(snippet)
  local texts = {} ---@type table<number, string>
  return cmp.snippet_replace(snippet, function(placeholder)
    texts[placeholder.n] = texts[placeholder.n] or cmp.snippet_preview(placeholder.text)
    return "${" .. placeholder.n .. ":" .. texts[placeholder.n] .. "}"
  end)
end

function cmp.visible()
  ---@module 'blink.cmp'
  local blink = package.loaded["blink.cmp"]
  if blink then return blink.windows and blink.windows.autocomplete.win:is_open() end
  return false
end

function cmp.expand(snippet)
  -- Native sessions don't support nested snippet sessions.
  -- Always use the top-level session.
  -- Otherwise, when on the first placeholder and selecting a new completion,
  -- the nested session will be used instead of the top-level session.
  -- See: https://github.com/LazyVim/LazyVim/issues/3199
  local session = vim.snippet.active() and vim.snippet._session or nil

  local ok, err = pcall(vim.snippet.expand, snippet)
  if not ok then
    local fixed = cmp.snippet_fix(snippet)
    ok = pcall(vim.snippet.expand, fixed)

    local msg = ok and "Failed to parse snippet,\nbut was able to fix it automatically."
      or ("Failed to parse snippet.\n" .. err)

    Util[ok and "warn" or "error"](
      ([[%s
```%s
%s
```]]):format(msg, vim.bo.filetype, snippet),
      { title = "vim.snippet" }
    )
  end

  -- Restore top-level session when needed
  if session then vim.snippet._session = session end
end

M.cmp = cmp

---@class simple.util.lsp
local lsp = {}

lsp.formatters_by_ft = {}

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
  tailwindcss = "tailwindcss-language-server",
  taplo = "taplo",
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

function lsp.prepend_mason_bin()
  if vim.env.PATH and not vim.env.PATH:find(mason_bin, 1, true) then
    vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
  end
end

function lsp.ensure_mason_packages(packages, package_servers)
  local ok, registry = pcall(require, "mason-registry")
  if not ok then return end

  package_servers = package_servers or {}

  registry:on("package:install:success", function(package)
    local server = package_servers[package.name]
    if server then vim.schedule(function() lsp.enable(server) end) end
  end)

  registry.refresh(function()
    for _, package_name in ipairs(packages) do
      local ok_package, package = pcall(registry.get_package, package_name)
      if ok_package and not package:is_installed() and not package:is_installing() then
        local ok_install, err = pcall(function()
          package:install({}, function(success, result)
            if success then return end
            vim.schedule(
              function() M.warn(("mason: failed to install %s\n%s"):format(package_name, vim.inspect(result))) end
            )
          end)
        end)
        if not ok_install then
          vim.schedule(function() M.warn(("mason: failed to install %s\n%s"):format(package_name, err)) end)
        end
      end
    end
  end)
end

function lsp.formatters(filetypes, formatters)
  if type(filetypes) == "string" then filetypes = { filetypes } end

  for _, filetype in ipairs(filetypes) do
    lsp.formatters_by_ft[filetype] = formatters
  end
end

function lsp.executable_for(name, config)
  if config and config.cmd then return config.cmd[1] end

  return server_executables[name] or name
end

function lsp.server_is_available(name, config)
  local executable = lsp.executable_for(name, config)
  if vim.fn.executable(executable) == 1 then return true end

  return vim.fn.executable(vim.fs.joinpath(mason_bin, executable)) == 1
end

function lsp.enable(name, config)
  if enabled_servers[name] then return end

  if config ~= nil then vim.lsp.config(name, config) end

  if lsp.server_is_available(name, config) then
    vim.lsp.enable(name)
    enabled_servers[name] = true
  end
end

function lsp.on_attach(name, key, callback)
  attach_handlers[name] = attach_handlers[name] or {}
  attach_handlers[name][key] = callback
end

function lsp.run_attach_handlers(client, ev)
  for _, callback in pairs(attach_handlers[client.name] or {}) do
    callback(client, ev)
  end
end

function lsp.expand_env_path(path)
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

function lsp.path_is_under(path, parent)
  if not path or not parent or parent == "" then return false end

  local normalized_path = vim.uv.fs_realpath(path) or vim.fs.normalize(path)
  local normalized_parent = vim.uv.fs_realpath(parent) or vim.fs.normalize(parent)
  return normalized_path == normalized_parent or vim.startswith(normalized_path, normalized_parent .. "/")
end

function lsp.skip_ruff_format(path)
  if path == nil or path == "" then return false end

  local roots = vim.list_extend({}, ruff_format_excluded_roots)
  if type(vim.g.python_ruff_format_excluded_roots) == "string" then
    roots[#roots + 1] = vim.g.python_ruff_format_excluded_roots
  elseif type(vim.g.python_ruff_format_excluded_roots) == "table" then
    vim.list_extend(roots, vim.g.python_ruff_format_excluded_roots)
  end

  for _, item in ipairs(roots) do
    local expanded = lsp.expand_env_path(item)
    if expanded and lsp.path_is_under(path, expanded) then return true end
  end

  return false
end

function lsp.use_ruff_formatters(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)
  if lsp.skip_ruff_format(path) then return {} end

  return { "ruff_fix", "ruff_organize_imports" }
end

function lsp.ruff_format_enabled(_, ctx) return not lsp.skip_ruff_format(ctx and ctx.filename) end

local prettier_has_config = M.memoize(function(filename)
  if vim.fn.executable "prettier" == 0 then return false end
  vim.fn.system { "prettier", "--find-config-path", filename }
  return vim.v.shell_error == 0
end)

local prettier_has_parser = M.memoize(function(filetype, filename)
  if vim.fn.executable "prettier" == 0 then return false end
  if vim.tbl_contains(prettier_filetypes, filetype) then return true end

  local ret = vim.fn.system { "prettier", "--file-info", filename }
  local parsed_ok, info = pcall(vim.json.decode, ret)
  return parsed_ok and info and info.inferredParser ~= nil and info.inferredParser ~= vim.NIL
end)

function lsp.prettier_enabled(_, ctx)
  return prettier_has_parser(vim.bo[ctx.buf].filetype, ctx.filename) and prettier_has_config(ctx.filename)
end

M.lsp = lsp

return M
