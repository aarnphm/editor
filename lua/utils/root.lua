---@class simple.util.root
---@overload fun(): string
local M = setmetatable({}, {
  __call = function(m) return m.get() end,
})

M.additional_path_root_spec = { "content" }
M.root_lsp_ignore = { "copilot" }
M.spec = { "lsp", vim.list_extend({ ".git", "lua" }, M.additional_path_root_spec or {}), "cwd" }
M.detectors = {}
M.cache = {} ---@type table<number, string>

function M.detectors.cwd() return { vim.uv.cwd() } end

function M.detectors.lsp(buf)
  local bufpath = M.bufpath(buf)
  if not bufpath then return {} end

  local roots = {}
  local clients = vim.tbl_filter(
    function(client) return not vim.tbl_contains(M.root_lsp_ignore or {}, client.name) end,
    vim.lsp.get_clients { bufnr = buf }
  )

  for _, client in pairs(clients) do
    for _, ws in pairs(client.config.workspace_folders or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    if client.root_dir then roots[#roots + 1] = client.root_dir end
  end

  return vim.tbl_filter(function(path)
    path = Util.norm(path)
    return path and bufpath:find(path, 1, true) == 1
  end, roots)
end

---@param patterns string[]|string
function M.detectors.pattern(buf, patterns)
  patterns = type(patterns) == "string" and { patterns } or patterns
  local path = M.bufpath(buf) or vim.uv.cwd()
  local pattern = vim.fs.find(function(name)
    for _, p in ipairs(patterns) do
      if name == p then return true end
      if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then return true end
    end
    return false
  end, { path = path, upward = true })[1]
  return pattern and { vim.fs.dirname(pattern) } or {}
end

function M.bufpath(buf) return M.realpath(vim.api.nvim_buf_get_name(assert(buf))) end

function M.cwd() return M.realpath(vim.uv.cwd()) or "" end

function M.realpath(path)
  if path == "" or path == nil then return nil end
  path = vim.uv.fs_realpath(path) or path
  return Util.norm(path)
end

function M.resolve(spec)
  if M.detectors[spec] then
    return M.detectors[spec]
  elseif type(spec) == "function" then
    return spec
  end
  return function(buf) return M.detectors.pattern(buf, spec) end
end

---@param opts? { buf?: number, spec?: table, all?: boolean }
function M.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {}
  for _, spec in ipairs(opts.spec) do
    local paths = M.resolve(spec)(opts.buf)
    paths = type(paths) == "table" and paths or { paths }

    local roots = {}
    for _, p in ipairs(paths) do
      local pp = M.realpath(p)
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

function M.info()
  local roots = M.detect { all = true }
  local lines = {}
  local first = true
  for _, root in ipairs(roots) do
    for _, path in ipairs(root.paths) do
      lines[#lines + 1] = ("- [%s] `%s` **(%s)**"):format(
        first and "x" or " ",
        path,
        type(root.spec) == "table" and table.concat(root.spec, ", ") or root.spec
      )
      first = false
    end
  end
  Util.info(lines, { title = "Roots" })
  return roots[1] and roots[1].paths[1] or vim.uv.cwd()
end

---@param opts? {normalize?:boolean, buf?:number}
function M.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local ret = M.cache[buf]
  if not ret then
    local roots = M.detect { all = false, buf = buf }
    ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
    M.cache[buf] = ret
  end
  if opts.normalize then return ret end
  return Util.is_win() and ret:gsub("/", "\\") or ret
end

function M.git()
  local root = M.get()
  local git_root = vim.fs.find(".git", { path = root, upward = true })[1]
  return git_root and vim.fn.fnamemodify(git_root, ":h") or root
end

return M
