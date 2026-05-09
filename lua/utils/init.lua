---@class simple.util
---@field lsp simple.util.lsp
---@field root simple.util.root
---@field treesitter simple.util.treesitter
---@field ui simple.util.ui
local M = {}

setmetatable(M, {
  __index = function(t, k)
    local ok, mod = pcall(require, "utils." .. k)
    if not ok then error(mod) end
    t[k] = mod
    return mod
  end,
})

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

return M
