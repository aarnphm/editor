---@class simple.util
---@field lsp simple.util.lsp
---@field pack simple.util.pack
---@field markdown simple.util.markdown
---@field obsidian simple.util.obsidian
---@field root simple.util.root
---@field treesitter simple.util.treesitter
---@field ui simple.util.ui
---@field bigfile simple.util.bigfile
---@field quickfile simple.util.quickfile
local M = {}

function M.is_win() return vim.uv.os_uname().sysname:find "Windows" ~= nil end

function M.add_nvim_treesitter_query_runtime()
  local runtime = vim.fs.joinpath(vim.fn.stdpath "data", "site/pack/core/opt/nvim-treesitter/runtime")
  if vim.fn.isdirectory(runtime) == 0 then return end
  if vim.tbl_contains(vim.opt.runtimepath:get(), runtime) then return end

  vim.opt.runtimepath:append(runtime)
end

local lint = {
  events = { "BufWritePost", "BufReadPost", "InsertLeave" },
  linters_by_ft = {},
  linter_configs = {},
}
local lint_redraw_timers = {}

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

local function resolve_linter_names(lint_mod, bufnr)
  local names = lint_mod._resolve_linter_by_ft(vim.bo[bufnr].filetype)
  names = vim.list_extend({}, names or {})
  if #names == 0 then vim.list_extend(names, lint_mod.linters_by_ft["_"] or {}) end
  vim.list_extend(names, lint_mod.linters_by_ft["*"] or {})

  local ctx = { filename = vim.api.nvim_buf_get_name(bufnr) }
  ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
  return vim.tbl_filter(function(name)
    local linter = lint_mod.linters[name]
    if not linter then M.warn("linter: not found " .. name, { title = "nvim-lint" }) end
    return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
  end, names)
end

local function stop_lint_redraw_timer(bufnr)
  local timer = lint_redraw_timers[bufnr]
  if not timer then return end

  lint_redraw_timers[bufnr] = nil
  timer:stop()
  timer:close()
end

local function redraw_lint_status(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  vim.cmd.redrawstatus()
end

local function watch_lint_status(lint_mod, bufnr)
  stop_lint_redraw_timer(bufnr)
  redraw_lint_status(bufnr)
  if #lint_mod.get_running(bufnr) == 0 then return end

  local timer = vim.uv.new_timer()
  lint_redraw_timers[bufnr] = timer
  timer:start(
    200,
    200,
    vim.schedule_wrap(function()
      if lint_redraw_timers[bufnr] ~= timer then return end
      if not vim.api.nvim_buf_is_valid(bufnr) then
        stop_lint_redraw_timer(bufnr)
        return
      end

      local running = lint_mod.get_running(bufnr)
      if #running == 0 then
        redraw_lint_status(bufnr)
        stop_lint_redraw_timer(bufnr)
      end
    end)
  )
end

function lint.names(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  if not vim.api.nvim_buf_is_valid(bufnr) then return {} end

  local lint_mod = lint_module()
  return lint_mod and resolve_linter_names(lint_mod, bufnr) or {}
end

function lint.running(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  if not vim.api.nvim_buf_is_valid(bufnr) or not package.loaded.lint then return {} end

  local ok, lint_mod = pcall(require, "lint")
  if not ok then return {} end

  local names = lint_mod.get_running(bufnr)
  table.sort(names)
  return names
end

function lint.try(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  if bufnr ~= vim.api.nvim_get_current_buf() then
    return vim.api.nvim_buf_call(bufnr, function() lint.try(0) end)
  end

  local lint_mod = lint_module()
  if not lint_mod then return end

  local names = resolve_linter_names(lint_mod, bufnr)
  if #names > 0 then
    lint_mod.try_lint(names)
    watch_lint_status(lint_mod, bufnr)
  end
end

M.lint = lint

---@class simple.util.pack
local pack = {
  defaults = {
    lazy = true,
    version = "main",
  },
  maintenance = false,
  specs = {},
}
local loaded = {}
local pack_load_events = {}
local pack_load_event_id = 0

local function pack_now() return vim.uv.hrtime() / 1000000 end

local function pack_record_load(event)
  pack_load_event_id = pack_load_event_id + 1
  event.id = pack_load_event_id
  event.self_ms = math.max(event.elapsed_ms - event.dependency_ms, 0)
  pack_load_events[#pack_load_events + 1] = event
end

local function pack_expand_src(src)
  if src:match "^[%w_.-]+/[%w_.-]+$" then return ("https://github.com/%s.git"):format(src) end
  return src
end

local function pack_name_from_src(src) return src:gsub("%.git$", ""):match "([^/:%s]+)$" end

local function pack_string_is_source(value) return value:find "/" ~= nil or value:find ":" ~= nil end

local function pack_arg_is_update_command(arg)
  if type(arg) ~= "string" then return false end
  arg = arg:gsub("^%+", "")
  return arg:match "^%s*PackUpdate!?%s*$" ~= nil
    or arg:match "^%s*PackUpdate!?%s+" ~= nil
    or arg:match "^%s*PackLock!?%s*$" ~= nil
    or arg:match "^%s*PackLock!?%s+" ~= nil
end

local function pack_argv_requests_maintenance()
  for _, arg in ipairs(vim.v.argv or {}) do
    if pack_arg_is_update_command(arg) then return true end
  end
  return false
end

local function pack_table_is_spec(value)
  if type(value) ~= "table" then return false end
  if value.src or value.name then return true end
  if type(value[1]) ~= "string" then return false end

  for key in pairs(value) do
    if type(key) ~= "number" then return true end
  end
  return #value == 1 and pack_string_is_source(value[1])
end

local function pack_normalize_spec(raw_spec)
  local spec = type(raw_spec) == "string" and { src = raw_spec } or vim.tbl_extend("force", {}, raw_spec)
  spec.src = spec.src or spec[1]
  if not spec.src then error "Pack spec missing src" end

  spec[1] = nil
  spec.name = spec.name or pack_name_from_src(spec.src)
  if not spec.name then error(("Pack spec missing name: %s"):format(spec.src)) end
  spec.src = pack_expand_src(spec.src)
  return vim.tbl_extend("force", pack.defaults, spec)
end

local function pack_dependency_name(dep, add_spec)
  if type(dep) == "string" and not pack_string_is_source(dep) then return dep end
  if type(dep) == "table" and dep.name and not (dep.src or dep[1]) then return dep.name end
  return add_spec(dep).name
end

local function pack_dependency_names_from_spec(dependencies, add_spec)
  if not dependencies then return {} end
  if pack_table_is_spec(dependencies) then return { pack_dependency_name(dependencies, add_spec) } end

  return vim.tbl_map(function(dep) return pack_dependency_name(dep, add_spec) end, dependencies)
end

local function pack_store_spec(ret, indexes, spec)
  local existing = pack.specs[spec.name]
  if existing then
    local existing_dependencies = existing.dependencies
    spec = vim.tbl_extend("force", existing, spec)
    if existing_dependencies and spec.dependencies then
      spec.dependencies = vim.list_extend(vim.deepcopy(existing_dependencies), spec.dependencies)
    end
    pack.specs[spec.name] = spec

    local add_spec = ret[indexes[spec.name]]
    add_spec.src = spec.src
    add_spec.version = spec.version
    return spec
  end

  pack.specs[spec.name] = spec
  indexes[spec.name] = #ret + 1
  ret[indexes[spec.name]] = {
    src = spec.src,
    name = spec.name,
    version = spec.version,
  }
  return spec
end

local function pack_specs_for_add(specs)
  local ret = {}
  local indexes = {}

  local function add_spec(raw_spec)
    local spec = pack_normalize_spec(raw_spec)
    spec.dependencies = pack_dependency_names_from_spec(spec.dependencies, add_spec)
    return pack_store_spec(ret, indexes, spec)
  end

  for _, raw_spec in ipairs(specs) do
    add_spec(raw_spec)
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

function pack.begin_maintenance() pack.maintenance = true end

function pack.in_maintenance() return pack.maintenance or pack_argv_requests_maintenance() end

function pack.load(name)
  if loaded[name] then return end

  local spec = pack.get(name)
  local event = {
    name = name,
    phase = vim.v.vim_did_enter == 0 and "startup" or "runtime",
    started_ms = pack_now(),
    dependency_ms = 0,
    packadd_ms = 0,
    config_ms = 0,
    elapsed_ms = 0,
    ok = false,
  }

  local ok, err = xpcall(function()
    if not spec then
      local packadd_start = pack_now()
      vim.cmd.packadd(name)
      event.packadd_ms = pack_now() - packadd_start
      loaded[name] = true
      return
    end

    for _, dep in ipairs(pack_dependency_names(spec)) do
      local dependency_start = pack_now()
      pack.load(dep)
      event.dependency_ms = event.dependency_ms + pack_now() - dependency_start
    end

    local packadd_start = pack_now()
    vim.cmd.packadd(name)
    event.packadd_ms = pack_now() - packadd_start

    local opts = pack.opts(spec)
    if spec.config then
      local config_start = pack_now()
      spec.config(spec, opts or {})
      event.config_ms = pack_now() - config_start
    end
    loaded[name] = true
  end, debug.traceback)

  event.ok = ok
  event.elapsed_ms = pack_now() - event.started_ms
  event.error = not ok and err or nil
  pack_record_load(event)

  if not ok then error(err, 0) end
end

function pack.profile(opts)
  opts = opts or {}
  local ret = {}
  for _, event in ipairs(pack_load_events) do
    if opts.all or event.phase == "startup" then ret[#ret + 1] = vim.deepcopy(event) end
  end
  return ret
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

  M.add_nvim_treesitter_query_runtime()

  pack.specs = {}
  loaded = {}
  pack_load_events = {}
  pack_load_event_id = 0
  local add_specs = pack_specs_for_add(specs)
  vim.pack.add(add_specs, { confirm = false, load = function() end })

  for _, add_spec in ipairs(add_specs) do
    local spec = pack.get(add_spec.name)
    if spec and spec.lazy == false then pack.load(add_spec.name) end
  end
end

M.pack = pack

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

---@class simple.util.bigfile
---@field size integer
---@field lines integer
---@field line_length integer
M.bigfile = {
  size = 2 * 1024 * 1024,
  lines = 80000,
  line_length = 10000,
}

---@param path string
---@param bufnr integer
---@return boolean
function M.bigfile.matches(path, bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return false end

  local size = vim.fn.getfsize(path)
  if size <= 0 then return false end
  if size > M.bigfile.size then return true end

  if not vim.api.nvim_buf_is_loaded(bufnr) then return false end

  local lines = vim.api.nvim_buf_line_count(bufnr)
  if lines > M.bigfile.lines then return true end

  return lines > 0 and (size - lines) / lines > M.bigfile.line_length
end

---@param bufnr? integer
---@return boolean
function M.is_bigfile(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  if not vim.api.nvim_buf_is_valid(bufnr) then return false end
  if vim.bo[bufnr].filetype == "bigfile" then return true end

  local cached = vim.b[bufnr].simple_bigfile
  if cached ~= nil then return cached == true end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= "" then
    if M.bigfile.matches(name, bufnr) then
      vim.b[bufnr].simple_bigfile = true
      return true
    end
  end

  return false
end

---@param bufnr integer
---@return string
function M.bigfile.filetype(bufnr) return vim.filetype.match { buf = bufnr } or "" end

---@param bufnr integer
function M.bigfile.apply(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  vim.b[bufnr].simple_bigfile = true
  vim.b[bufnr].minidiff_disable = true
  vim.b[bufnr].minihipatterns_disable = true
  vim.b[bufnr].completion = false

  local ft = M.bigfile.filetype(bufnr)
  vim.b[bufnr].simple_bigfile_filetype = ft

  vim.api.nvim_buf_call(bufnr, function()
    if vim.fn.exists ":NoMatchParen" ~= 0 then pcall(vim.cmd.NoMatchParen) end
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.statuscolumn = ""
    vim.opt_local.conceallevel = 0
  end)

  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) and ft ~= "" then vim.bo[bufnr].syntax = ft end
  end)
end

function M.bigfile.setup()
  if vim.g.simple_bigfile_setup then return end
  vim.g.simple_bigfile_setup = true

  vim.filetype.add {
    pattern = {
      [".*"] = {
        function(path, bufnr)
          if not path or not bufnr or vim.bo[bufnr].filetype == "bigfile" then return end

          local name = vim.api.nvim_buf_get_name(bufnr)
          if name == "" or M.norm(path) ~= M.norm(name) then return end
          if not M.bigfile.matches(path, bufnr) then return end

          vim.b[bufnr].simple_bigfile = true
          return "bigfile"
        end,
      },
    },
  }

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("simple_bigfile", { clear = true }),
    pattern = "bigfile",
    callback = function(ev) M.bigfile.apply(ev.buf) end,
  })
end

---@class simple.util.quickfile
---@field exclude string[]
M.quickfile = {
  exclude = { "latex" },
}

function M.quickfile.setup()
  if vim.v.vim_did_enter == 1 then return end
  if vim.bo.buftype ~= "" then return end

  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_name(bufnr) == "" then return end

  local ft = vim.filetype.match { buf = bufnr }
  if not ft then return end

  if ft == "bigfile" then
    vim.b[bufnr].simple_bigfile = true
    vim.bo[bufnr].filetype = "bigfile"
    vim.cmd.redraw()
    return
  end

  local lang = vim.treesitter.language.get_lang(ft)
  if vim.tbl_contains(M.quickfile.exclude, lang) then lang = nil end
  M.add_nvim_treesitter_query_runtime()

  local ok_query, query = pcall(vim.treesitter.query.get, lang, "highlights")
  if not (lang and ok_query and query and pcall(vim.treesitter.start, bufnr, lang)) then vim.bo[bufnr].syntax = ft end

  vim.cmd.redraw()
end

if not vim.g.simple_treesitter_bigfile_guard then
  vim.g.simple_treesitter_bigfile_guard = true
  local treesitter_start = vim.treesitter.start

  function vim.treesitter.start(buf, lang)
    local bufnr = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
    if M.is_bigfile(bufnr) then
      Util.info(
        "file is considered larger than 1.5MB, disable treesitter to avoid performance churn.",
        { title = "bigfile" }
      )
      return
    end
    return treesitter_start(buf, lang)
  end
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

---@class simple.util.obsidian
local obsidian = {}

local obsidian_file_extensions = { ".md", ".base", ".canvas" }

---@param path string?
---@return string?
local function obsidian_normalize_path(path)
  if not path or path == "" then return nil end
  return M.norm(vim.fn.fnamemodify(vim.fn.expand(path), ":p"))
end

---@param path string
---@return boolean
local function obsidian_is_file(path)
  local stat = vim.uv.fs_stat(path)
  return stat ~= nil and stat.type == "file"
end

---@return string[]
local function obsidian_vault_roots()
  local roots = {}
  for _, vault in ipairs(_G.VAULTS or {}) do
    if type(vault) == "table" and type(vault.root) == "string" then
      local root_path = obsidian_normalize_path(vault.root)
      if root_path then roots[#roots + 1] = root_path end
    end
  end
  return roots
end

---@param path string
---@return string?
local function obsidian_vault_root(path)
  path = obsidian_normalize_path(path)
  if not path then return nil end

  local best_root = nil
  for _, root_path in ipairs(obsidian_vault_roots()) do
    if path == root_path or path:sub(1, #root_path + 1) == root_path .. "/" then
      if not best_root or #root_path > #best_root then best_root = root_path end
    end
  end
  if best_root then return best_root end

  local dir = obsidian_is_file(path) and vim.fs.dirname(path) or path
  local marker = vim.fs.find(".obsidian", { path = dir, upward = true, type = "directory" })[1]
  return marker and M.norm(vim.fs.dirname(marker)) or nil
end

---@param path string
---@return string[]
local function obsidian_candidate_names(path)
  if path:match "%.[^/%.]+$" then return { path } end

  local names = { path }
  for _, ext in ipairs(obsidian_file_extensions) do
    names[#names + 1] = path .. ext
  end
  return names
end

---@param vault_root string
---@param relpath string
---@return string?
local function obsidian_file_in_root(vault_root, relpath)
  relpath = relpath:gsub("^/+", "")
  for _, name in ipairs(obsidian_candidate_names(relpath)) do
    local path = M.norm(vim.fs.joinpath(vault_root, name))
    if obsidian_is_file(path) then return path end
  end
end

---@param vault_root string
---@param name string
---@return string?
local function obsidian_find_by_basename(vault_root, name)
  local candidates = {}
  for _, candidate in ipairs(obsidian_candidate_names(name)) do
    candidates[vim.fs.basename(candidate)] = true
  end

  local matches = vim.fs.find(function(file, path)
    if not candidates[file] then return false end
    local normalized = M.norm(path)
    return not normalized:find("/.obsidian/", 1, true) and not normalized:find("/node_modules/", 1, true)
  end, { path = vault_root, type = "file", limit = 1 })

  return matches[1] and M.norm(matches[1]) or nil
end

---@param target string
---@param current_file string
---@return string?
local function obsidian_resolve_path(target, current_file)
  local vault_root = obsidian_vault_root(current_file)
  if not vault_root then return nil end

  if target == "" then return obsidian_normalize_path(current_file) end

  local current_dir = vim.fs.dirname(current_file)
  local current_relative = obsidian_file_in_root(current_dir, target)
  if current_relative then return current_relative end

  local root_relative = obsidian_file_in_root(vault_root, target)
  if root_relative then return root_relative end

  if not target:find("/", 1, true) then return obsidian_find_by_basename(vault_root, target) end
end

---@param fragment string
---@return string
local function obsidian_decode_fragment(fragment)
  local ok, decoded = pcall(vim.uri_decode, fragment)
  return ok and decoded or fragment
end

---@param text string
---@return string
local function obsidian_heading_slug(text) return text:lower():gsub("%s+", "-"):gsub("[^%w%-_]", "") end

---@param text string
---@param needle string
---@return integer?
local function obsidian_find_unescaped(text, needle)
  local escaped = false
  for idx = 1, #text do
    local char = text:sub(idx, idx)
    if escaped then
      escaped = false
    elseif char == "\\" then
      escaped = true
    elseif char == needle then
      return idx
    end
  end
end

---@param text string
---@param needle string
---@return integer?
local function obsidian_find_escaped(text, needle)
  local escaped = false
  for idx = 1, #text do
    local char = text:sub(idx, idx)
    if escaped then
      if char == needle then return idx - 1 end
      escaped = false
    elseif char == "\\" then
      escaped = true
    end
  end
end

---@param text string
---@return string
local function obsidian_unescape(text) return text:gsub("\\([\\|#%]])", "%1") end

---@param text string
---@return string
local function obsidian_unquote(text)
  local quoted = text:match '^"(.*)"$' or text:match "^'(.*)'$"
  return quoted or text
end

---@param raw string
---@return { target: string, alias: string? }?
local function obsidian_split_target_alias(raw)
  local idx = obsidian_find_unescaped(raw, "|")
  local escaped_delimiter = false
  if not idx then
    idx = obsidian_find_escaped(raw, "|")
    escaped_delimiter = idx ~= nil
  end

  if not idx then return { target = vim.trim(obsidian_unescape(raw)) } end

  local target = raw:sub(1, idx - 1)
  local alias = raw:sub(idx + (escaped_delimiter and 2 or 1))
  alias = vim.trim(obsidian_unescape(alias))

  return {
    target = vim.trim(obsidian_unescape(target)),
    alias = alias ~= "" and alias or nil,
  }
end

---@param target string
---@return string path_target
---@return string? fragment
local function obsidian_split_target_fragment(target)
  local idx = obsidian_find_unescaped(target, "#")
  local escaped_delimiter = false
  if not idx then
    idx = obsidian_find_escaped(target, "#")
    escaped_delimiter = idx ~= nil
  end
  if not idx then return vim.trim(obsidian_unescape(target)), nil end

  local path_target = target:sub(1, idx - 1)
  local fragment = target:sub(idx + (escaped_delimiter and 2 or 1))
  return vim.trim(obsidian_unescape(path_target)), obsidian_unescape(fragment)
end

---@param fragment string?
---@return boolean
function obsidian.jump_to_fragment(fragment)
  if not fragment or fragment == "" or fragment:sub(1, 1) == "{" then return false end

  fragment = vim.trim(obsidian_decode_fragment(fragment))
  if fragment == "" then return false end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if fragment:sub(1, 1) == "^" then
    local block = vim.pesc(fragment)
    for row, line in ipairs(lines) do
      local start_col = line:find(block)
      if start_col then
        vim.api.nvim_win_set_cursor(0, { row, start_col - 1 })
        vim.cmd "normal! zvzz"
        return true
      end
    end
    return false
  end

  local target_slug = obsidian_heading_slug(fragment)
  for row, line in ipairs(lines) do
    local heading = line:match "^%s*#+%s*(.-)%s*#*%s*$"
    if heading then
      heading = vim.trim(heading)
      if heading == fragment or obsidian_heading_slug(heading) == target_slug then
        vim.api.nvim_win_set_cursor(0, { row, 0 })
        vim.cmd "normal! zvzz"
        return true
      end
    end
  end

  for row, line in ipairs(lines) do
    local name = line:match "^%s*name:%s*(.-)%s*$"
    if name and obsidian_unquote(vim.trim(name)) == fragment then
      vim.api.nvim_win_set_cursor(0, { row, 0 })
      vim.cmd "normal! zvzz"
      return true
    end
  end

  return false
end

---@param bufnr? integer
---@return { raw: string, target: string, fragment: string?, alias: string?, path: string }?
function obsidian.resolve_wikilink_at_cursor(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then return nil end

  local filetype = vim.bo[bufnr].filetype
  if filetype ~= "markdown" and filetype ~= "markdown.mdx" then return nil end

  local current_file = vim.api.nvim_buf_get_name(bufnr)
  if current_file == "" then return nil end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
  local cursor = col + 1
  local search_start = 1

  while true do
    local link_start = line:find("[[", search_start, true)
    if not link_start then return nil end

    local link_end = line:find("]]", link_start + 2, true)
    if not link_end then return nil end

    if cursor >= link_start and cursor <= link_end + 1 then
      local raw = line:sub(link_start + 2, link_end - 1)
      local parsed = obsidian_split_target_alias(raw)
      if not parsed then return nil end
      if parsed.target:match "^%a[%w+.-]*://" then return nil end

      local path_target, fragment = obsidian_split_target_fragment(parsed.target)
      if path_target:match "^%a[%w+.-]*://" then return nil end
      path_target = path_target:gsub("^/+", "")

      local path = obsidian_resolve_path(path_target, current_file)
      if not path then return nil end

      return { raw = raw, target = path_target, fragment = fragment, alias = parsed.alias, path = path }
    end

    search_start = link_end + 2
  end
end

---@param bufnr? integer
---@return boolean
function obsidian.open_wikilink_at_cursor(bufnr)
  local target = obsidian.resolve_wikilink_at_cursor(bufnr)
  if not target then return false end

  local ok, err = pcall(vim.cmd.edit, vim.fn.fnameescape(target.path))
  if not ok then
    M.warn(("obsidian: failed to open %s\n%s"):format(target.path, err))
    return true
  end

  obsidian.jump_to_fragment(target.fragment)
  return true
end

M.obsidian = obsidian

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

function treesitter.not_math() return treesitter.in_text(true) end

local magic_prefixes = { ["\\v"] = true, ["\\m"] = true, ["\\M"] = true, ["\\V"] = true }

local function vim_regex(pattern)
  if #pattern < 2 or magic_prefixes[pattern:sub(1, 2)] then return vim.regex(pattern) end
  return vim.regex("\\v" .. pattern)
end

local compiled_regexes = setmetatable({}, {
  __index = function(regexes, pattern)
    local regex = vim_regex(pattern)
    regexes[pattern] = regex
    return regex
  end,
})

local function node_text(node, source)
  local ok, text = pcall(vim.treesitter.get_node_text, node, source)
  if ok then return text end
end

local function check_nodes(match, source, predicate, any, check)
  local nodes = match[predicate[2]]
  if not nodes or #nodes == 0 then return true end

  for _, node in ipairs(nodes) do
    local text = node_text(node, source)
    local result = text ~= nil and check(text, predicate)
    if any and result then
      return true
    elseif not any and not result then
      return false
    end
  end
  return not any
end

local function add_predicate(name, handler) vim.treesitter.query.add_predicate(name, handler, { force = true }) end

local function eq(match, _, source, predicate)
  local nodes = match[predicate[2]]
  if not nodes or #nodes == 0 then return true end

  for _, node in ipairs(nodes) do
    local text = node_text(node, source)
    if text == nil then return false end

    local expected = predicate[3]
    if type(expected) ~= "string" then
      local other = assert(match[expected])
      assert(#other == 1, "#eq? does not support comparison with captures on multiple nodes")
      expected = node_text(other[1], source)
      if expected == nil then return false end
    end

    if text ~= expected then return false end
  end
  return true
end

local function any_eq(match, _, source, predicate)
  local nodes = match[predicate[2]]
  if not nodes or #nodes == 0 then return true end

  for _, node in ipairs(nodes) do
    local text = node_text(node, source)
    if text ~= nil then
      local expected = predicate[3]
      if type(expected) ~= "string" then
        local other = assert(match[expected])
        assert(#other == 1, "#any-eq? does not support comparison with captures on multiple nodes")
        expected = node_text(other[1], source)
      end
      if expected ~= nil and text == expected then return true end
    end
  end
  return false
end

local function lua_match(match, _, source, predicate)
  return check_nodes(match, source, predicate, false, function(text, pred) return text:find(pred[3]) ~= nil end)
end

local function any_lua_match(match, _, source, predicate)
  return check_nodes(match, source, predicate, true, function(text, pred) return text:find(pred[3]) ~= nil end)
end

local function match(captures, _, source, predicate)
  return check_nodes(
    captures,
    source,
    predicate,
    false,
    function(text, pred) return compiled_regexes[pred[3]]:match_str(text) ~= nil end
  )
end

local function any_match(captures, _, source, predicate)
  return check_nodes(
    captures,
    source,
    predicate,
    true,
    function(text, pred) return compiled_regexes[pred[3]]:match_str(text) ~= nil end
  )
end

local function contains(captures, _, source, predicate)
  return check_nodes(captures, source, predicate, false, function(text, pred)
    for i = 3, #pred do
      if not text:find(pred[i], 1, true) then return false end
    end
    return true
  end)
end

local function any_contains(captures, _, source, predicate)
  return check_nodes(captures, source, predicate, true, function(text, pred)
    for i = 3, #pred do
      if text:find(pred[i], 1, true) then return true end
    end
    return false
  end)
end

local function any_of(captures, _, source, predicate)
  local nodes = captures[predicate[2]]
  if not nodes or #nodes == 0 then return true end

  predicate.string_set = predicate.string_set or {}
  if not next(predicate.string_set) then
    for i = 3, #predicate do
      predicate.string_set[predicate[i]] = true
    end
  end

  for _, node in ipairs(nodes) do
    local text = node_text(node, source)
    if text ~= nil and predicate.string_set[text] then return true end
  end
  return false
end

function treesitter.setup()
  M.add_nvim_treesitter_query_runtime()

  local ts = require "nvim-treesitter"
  ts.setup()

  add_predicate("eq?", eq)
  add_predicate("any-eq?", any_eq)
  add_predicate("lua-match?", lua_match)
  add_predicate("any-lua-match?", any_lua_match)
  add_predicate("match?", match)
  add_predicate("any-match?", any_match)
  add_predicate("vim-match?", match)
  add_predicate("any-vim-match?", any_match)
  add_predicate("contains?", contains)
  add_predicate("any-contains?", any_contains)
  add_predicate("any-of?", any_of)
end

M.treesitter = treesitter

---@class simple.util.ui
local ui = {}

function ui.foldtext()
  return table.concat({
    vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)[1],
    (" 󰁂 %d"):format(vim.v.foldend - vim.v.foldstart),
  }, " ")
end

M.ui = ui

---@class simple.util.cmp
local cmp = {}

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
local mason_setup = false
local lsp_defaults_configured = false
local pending_lsp_enable = {}
local pending_lsp_enable_scheduled = false

local mason_bin = vim.fs.joinpath(vim.fn.stdpath "data", "mason", "bin")

local server_executables = {
  bashls = "bash-language-server",
  clangd = "clangd",
  cssls = "vscode-css-language-server",
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

function lsp.prepend_mason_bin()
  if vim.env.PATH and not vim.env.PATH:find(mason_bin, 1, true) then
    vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
  end
end

function lsp.configure_defaults()
  if lsp_defaults_configured then return end

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

  lsp_defaults_configured = true
end

function lsp.setup_mason()
  if M.pack and M.pack.in_maintenance and M.pack.in_maintenance() then return false end
  lsp.prepend_mason_bin()
  if mason_setup then return true end

  if M.pack and M.pack.get "mason.nvim" then pcall(M.pack.load, "mason.nvim") end

  local ok, mason = pcall(require, "mason")
  if not ok then return false end

  mason.setup()
  mason_setup = true
  return true
end

function lsp.ensure_mason_packages(packages, package_servers)
  if M.pack and M.pack.in_maintenance and M.pack.in_maintenance() then return end

  if vim.v.vim_did_enter == 0 then
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        vim.schedule(function() lsp.ensure_mason_packages(packages, package_servers) end)
      end,
    })
    return
  end

  if not lsp.setup_mason() then return end

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

local function add_formatter_names(names, seen, formatters)
  if type(formatters) ~= "table" then return end

  for _, name in ipairs(formatters) do
    if type(name) == "string" and not seen[name] then
      names[#names + 1] = name
      seen[name] = true
    end
  end
end

local function matching_formatter_config(bufnr)
  local filetype = vim.bo[bufnr].filetype
  if filetype == "" then return nil end

  local candidates = { filetype }
  local parts = vim.split(filetype, ".", { plain = true })
  for i = #parts, 1, -1 do
    candidates[#candidates + 1] = parts[i]
  end
  candidates[#candidates + 1] = "_"

  for _, candidate in ipairs(candidates) do
    local formatters = lsp.formatters_by_ft[candidate]
    if formatters and not (type(formatters) == "table" and vim.tbl_isempty(formatters)) then return formatters end
  end
end

function lsp.formatter_names(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  if not vim.api.nvim_buf_is_valid(bufnr) then return {} end

  local names = {}
  local seen = {}
  local formatters = matching_formatter_config(bufnr)
  if type(formatters) == "function" then
    local ok, resolved = pcall(formatters, bufnr)
    formatters = ok and resolved or nil
  end

  add_formatter_names(names, seen, formatters)
  add_formatter_names(names, seen, lsp.formatters_by_ft["*"])
  return names
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
  if M.pack and M.pack.in_maintenance and M.pack.in_maintenance() then return end

  if vim.v.vim_did_enter == 0 then
    pending_lsp_enable[name] = { name = name, config = config }
    if not pending_lsp_enable_scheduled then
      pending_lsp_enable_scheduled = true
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          vim.schedule(function()
            local pending = pending_lsp_enable
            pending_lsp_enable = {}
            pending_lsp_enable_scheduled = false
            for _, item in pairs(pending) do
              lsp.enable(item.name, item.config)
            end
          end)
        end,
      })
    end
    return
  end

  lsp.prepend_mason_bin()
  if M.pack and M.pack.get "nvim-lspconfig" then pcall(M.pack.load, "nvim-lspconfig") end
  lsp.configure_defaults()

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

  return { "ruff_fix", "ruff_organize_imports", "ruff_format" }
end

function lsp.ruff_format_enabled(_, ctx) return not lsp.skip_ruff_format(ctx and ctx.filename) end

local cbfmt_languages = M.memoize(function(config)
  local ok, lines = pcall(vim.fn.readfile, config)
  if not ok then return {} end

  local languages = {}
  local in_languages = false
  for _, line in ipairs(lines) do
    local section = line:match "^%s*%[([^%]]+)%]"
    if section then
      in_languages = section == "languages"
    elseif in_languages then
      local key = line:match "^%s*[\"']([^\"']+)[\"']%s*=" or line:match "^%s*([%w_.+-]+)%s*="
      if key then languages[key] = true end
    end
  end

  return languages
end)

local function markdown_code_fence_language(line)
  local marker, info = line:match "^%s*(```+)%s*(.-)%s*$"
  if not marker then
    marker, info = line:match "^%s*(~~~+)%s*(.-)%s*$"
  end
  if not marker then return nil end

  local language = info:match "^%{?%.?([%w_.+-]+)"
  return language, marker:sub(1, 1), #marker
end

local function markdown_has_cbfmt_language(bufnr, languages)
  local in_fence = false
  local fence_char = nil
  local fence_len = 0

  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    local language, char, len = markdown_code_fence_language(line)
    if char then
      if in_fence then
        if char == fence_char and len >= fence_len then
          in_fence = false
          fence_char = nil
          fence_len = 0
        end
      else
        if language and languages[language] then return true end
        in_fence = true
        fence_char = char
        fence_len = len
      end
    end
  end

  return false
end

function lsp.cbfmt_enabled(_, ctx)
  if not (ctx and ctx.buf and vim.api.nvim_buf_is_valid(ctx.buf)) then return false end
  if not (ctx.filename and ctx.filename ~= "") then return false end

  local start = ctx.dirname or vim.fs.dirname(ctx.filename)
  local config = start and vim.fs.find(".cbfmt.toml", { path = start, upward = true, type = "file" })[1]
  if not config then return false end

  return markdown_has_cbfmt_language(ctx.buf, cbfmt_languages(config))
end

function lsp.use_markdown_formatters(bufnr)
  local formatters = { "oxfmt", lsp_format = "never" }
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local ctx = {
    buf = bufnr,
    dirname = filename ~= "" and vim.fs.dirname(filename) or nil,
    filename = filename,
  }

  if lsp.cbfmt_enabled(nil, ctx) then formatters[#formatters + 1] = "cbfmt" end
  return formatters
end

M.lsp = lsp

---@class simple.util.markdown
local markdown = {}
local markdown_frontmatter_ignored_suffixes = {
  "%.flashcards%.md$",
  "%.fc%.md$",
}

---@param cmd string[]
---@param input string?
---@return string
local function markdown_system(cmd, input)
  local result = vim.system(cmd, { stdin = input, text = true }):wait()
  if result.code ~= 0 then error((result.stderr or "") ~= "" and result.stderr or table.concat(cmd, " ")) end
  return result.stdout or ""
end

---@param yaml string
---@return table<string, any>
local function markdown_yaml_to_table(yaml)
  if vim.trim(yaml) == "" then return {} end
  local json = markdown_system({ "yq", "eval", "-o=json", "-" }, yaml)
  local ok, parsed = pcall(vim.fn.json_decode, json)
  if ok and type(parsed) == "table" then return parsed end
  return {}
end

---@param tbl table<string, any>
---@return string[]
local function markdown_table_to_yaml(tbl)
  local yaml = markdown_system({ "yq", "eval", "sort_keys(..)", "-P", "-p=json", "-" }, vim.fn.json_encode(tbl))
  local lines = {}
  for line in yaml:gmatch "[^\r\n]+" do
    table.insert(lines, line)
  end
  return lines
end

---@param path string
---@return table<string, any>? vault
---@return string? root
local function markdown_vault_for_path(path)
  if path == "" or not path:match "%.md$" then return nil, nil end

  local normalized_path = vim.uv.fs_realpath(path) or vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(path), ":p"))
  for _, vault in ipairs(_G.VAULTS or {}) do
    if type(vault) == "table" and type(vault.root) == "string" then
      local vault_root = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(vault.root), ":p"))
      vault_root = vim.uv.fs_realpath(vault_root) or vault_root
      if lsp.path_is_under(normalized_path, vault_root) then return vault, vault_root end
    end
  end
end

---@param path string?
---@return boolean
function markdown.frontmatter_ignored_path(path)
  if type(path) ~= "string" or path == "" then return false end
  for _, suffix in ipairs(markdown_frontmatter_ignored_suffixes) do
    if path:match(suffix) then return true end
  end
  return false
end

---@param bufnr integer?
---@return boolean
function markdown.frontmatter_enabled(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  if vim.g.markdown_frontmatter == false then return false end
  if vim.b[bufnr].markdown_frontmatter ~= nil then return vim.b[bufnr].markdown_frontmatter end
  return true
end

---@param bufnr integer?
---@return boolean
function markdown.update_frontmatter(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  if not vim.api.nvim_buf_is_valid(bufnr) then return false end
  if not markdown.frontmatter_enabled(bufnr) then return false end
  if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable then return false end

  local path = vim.api.nvim_buf_get_name(bufnr)
  if markdown.frontmatter_ignored_path(path) then return false end

  if vim.fn.executable "yq" == 0 then
    M.warn("frontmatter: yq is required", { title = "markdown" })
    return false
  end

  local vault, vault_root = markdown_vault_for_path(path)
  if not vault or not vault_root then return false end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local fm_start, fm_end

  if lines[1] and lines[1]:match "^---%s*$" then
    fm_start = 1
    for i = 2, #lines do
      if lines[i]:match "^---%s*$" then
        fm_end = i
        break
      end
    end
  end

  local existing = {}
  if fm_start and fm_end and fm_end > fm_start + 1 then
    local ok, parsed =
      pcall(markdown_yaml_to_table, table.concat(vim.list_slice(lines, fm_start + 1, fm_end - 1), "\n"))
    if not ok then
      M.warn(("frontmatter: %s"):format(tostring(parsed):gsub("\n.*", "")), { title = "markdown" })
      return false
    end
    existing = parsed
  end

  local filename = vim.fs.basename(path)
  local id = filename:gsub("%.md$", "")
  local is_tag_note = lsp.path_is_under(path, vim.fs.joinpath(vault_root, "tags"))
  local default_frontmatter = is_tag_note and { title = id }
    or { date = os.date "%Y-%m-%d", id = id, tags = { "seed" }, title = id }
  local frontmatter = vim.tbl_deep_extend("force", default_frontmatter, existing)

  if frontmatter.title == nil then frontmatter.title = id end
  if frontmatter.aliases and #frontmatter.aliases == 0 then frontmatter.aliases = nil end

  local existing_no_modified = vim.deepcopy(existing)
  existing_no_modified.modified = nil
  local frontmatter_no_modified = vim.deepcopy(frontmatter)
  frontmatter_no_modified.modified = nil
  local meta_changed = not vim.deep_equal(frontmatter_no_modified, existing_no_modified)

  if not vim.bo[bufnr].modified and not meta_changed then return false end

  if not is_tag_note then
    local offset = os.date "%z"
    frontmatter.modified = os.date "%Y-%m-%d %H:%M:%S"
      .. string.format(" GMT%s%s:%s", offset:sub(1, 1), offset:sub(2, 3), offset:sub(4, 5))
  end

  local ok, yaml = pcall(markdown_table_to_yaml, frontmatter)
  if not ok then
    M.warn(("frontmatter: %s"):format(tostring(yaml):gsub("\n.*", "")), { title = "markdown" })
    return false
  end

  local new_fm = { "---" }
  vim.list_extend(new_fm, yaml)
  table.insert(new_fm, "---")

  if fm_start and fm_end then
    vim.api.nvim_buf_set_lines(bufnr, fm_start - 1, fm_end, false, new_fm)
  else
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, vim.list_extend(new_fm, { "" }))
  end

  return true
end

M.markdown = markdown

return M
