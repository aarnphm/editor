---@class lazyvim.util: LazyUtilCore
---@field inject lazyvim.util.inject
---@field ui lazyvim.util.ui
---@field format lazyvim.util.format
---@field lsp lazyvim.util.lsp
---@field root lazyvim.util.root
---@field cmp lazyvim.util.cmp
---@field mini lazyvim.util.mini
---@field pick lazyvim.util.pick
---@field motion lazyvim.util.motion
---@field terminal lazyvim.util.terminal
---@field treesitter lazyvim.util.treesitter
---@field statusline lazyvim.util.statusline
local M = {}

local LazyUtil = require "lazy.core.util"
local LazyEvent = require "lazy.core.handler.event"

setmetatable(M, {
  __index = function(t, k)
    if LazyUtil[k] then return LazyUtil[k] end

    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("utils." .. k)
    return t[k]
  end,
})

M.STL = M.statusline.generate()

M.did_setup = false

---@param opts LazyConfig
function M.setup(opts)
  _G.Util = M

  LazyEvent.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
  LazyEvent.mappings["User LazyFile"] = LazyEvent.mappings.LazyFile

  require("lazy").setup(opts)

  M.on_very_lazy(function()
    M.format.setup()

    Util.format.snacks_toggle():map "<leader>uf"
    Util.format.snacks_toggle(true):map "<leader>uF"
    Snacks.toggle.option("spell", { name = "spelling" }):map "<leader>us"
    Snacks.toggle.option("wrap", { name = "wrap" }):map "<leader>uw"
    Snacks.toggle.option("relativenumber", { name = "relative number" }):map "<leader>uL"
    Snacks.toggle.line_number():map "<leader>ul"
    Snacks.toggle.diagnostics():map "<leader>ud"
    Snacks.toggle
      .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
      :map "<leader>uc"
    Snacks.toggle.treesitter():map "<leader>uT"
    Snacks.toggle.option("background", { off = "light", on = "dark", name = "dark background" }):map "<leader>ub"
    if vim.lsp.inlay_hint then Snacks.toggle.inlay_hints():map "<leader>uh" end
    Util.ui.maximize():map "<leader>wm"
  end)

  return M
end

M.is_win = function() return vim.uv.os_uname().sysname:find "Windows" ~= nil end

---@param plugin string
---@return boolean
M.has = function(plugin) return require("lazy.core.config").plugins[plugin] ~= nil end

-- Fast implementation to check if a table is a list
---@param t table
M.is_list = function(t)
  local i = 0
  ---@diagnostic disable-next-line: no-unknown
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then return false end
  end
  return true
end

M.is_loaded = function(name)
  local Config = require "lazy.core.config"
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

local function can_merge(v) return type(v) == "table" and (vim.tbl_isempty(v) or not M.is_list(v)) end

--- Merges the values similar to vim.tbl_deep_extend with the **force** behavior,
--- but the values can be any type, in which case they override the values on the left.
--- Values will me merged in-place in the first left-most table. If you want the result to be in
--- a new table, then simply pass an empty table as the first argument `vim.merge({}, ...)`
--- Supports clearing values by setting a key to `vim.NIL`
---@generic T
---@param ... T
---@return T
M.merge = function(...)
  local ret = select(1, ...)
  if ret == vim.NIL then ret = nil end
  for i = 2, select("#", ...) do
    local value = select(i, ...)
    if can_merge(ret) and can_merge(value) then
      for k, v in pairs(value) do
        ret[k] = M.merge(ret[k], v)
      end
    elseif value == vim.NIL then
      ret = nil
    elseif value ~= nil then
      ret = value
    end
  end
  return ret
end

---@param name string
---@return table<string, any>
M.opts = function(name)
  local plugin = require("lazy.core.config").plugins[name]
  if not plugin then return {} end
  return require("lazy.core.plugin").values(plugin, "opts", false)
end

---@param name string
---@param fn fun(name: string): nil
M.on_load = function(name, fn)
  local Config = require "lazy.core.config"
  if Config.plugins[name] and Config.plugins[name]._.loaded then
    vim.schedule(function() fn(name) end)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

-- Wrapper around vim.keymap.set that will
-- not create a keymap if a lazy key handler exists.
-- It will also set `silent` to true by default.
--
---@param mode string|string[] Mode short-name, see |nvim_set_keymap()|.
---                            Can also be list of modes to create mapping on multiple modes.
---@param lhs string           Left-hand side |{lhs}| of the mapping.
---@param rhs string|function  Right-hand side |{rhs}| of the mapping, can be a Lua function.
---
---@param opts? vim.keymap.set.Opts
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  local modes = type(mode) == "string" and { mode } or mode

  ---@param m string
  modes = vim.tbl_filter(function(m) return not (keys.have and keys:have(lhs, m)) end, modes)

  -- do not create the keymap if a lazy keys handler exists
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      ---@diagnostic disable-next-line: no-unknown
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

M.on_very_lazy = function(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function(ev) fn(ev) end,
  })
end

-- delay notifications till vim.notify was replaced or after 500ms
function M.lazy_notify()
  local notifs = {}
  local function temp(...) table.insert(notifs, vim.F.pack_len(...)) end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.uv.new_timer()
  local check = assert(vim.uv.new_check())

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig -- put back the original notify if needed
    end
    vim.schedule(function()
      ---@diagnostic disable-next-line: no-unknown
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- wait till vim.notify has been replaced
  check:start(function()
    if vim.notify ~= temp then replay() end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end

---@generic T
---@param list T[]
---@return T[]
function M.dedup(list)
  local ret = {}
  local seen = {}
  for _, v in ipairs(list) do
    if not seen[v] then
      table.insert(ret, v)
      seen[v] = true
    end
  end
  return ret
end

M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
function M.create_undo()
  if vim.api.nvim_get_mode().mode == "i" then vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false) end
end

--- regex used for matching a valid URL/URI string
M.url_matcher =
  "\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

--- Delete the syntax matching rules for URLs/URIs if set
---@param win integer? the window id to remove url highlighting in (default: current window)
M.delete_url_match = function(win)
  if not win then win = vim.api.nvim_get_current_win() end
  for _, match in ipairs(vim.fn.getmatches(win)) do
    if match.group == "HighlightURL" then vim.fn.matchdelete(match.id, win) end
  end
  vim.w[win].highlighturl_enabled = false
end

--- Add syntax matching rules for highlighting URLs/URIs
---@param win integer? the window id to remove url highlighting in (default: current window)
M.set_url_match = function(win)
  if not win then win = vim.api.nvim_get_current_win() end
  M.delete_url_match(win)
  vim.fn.matchadd("HighlightURL", M.url_matcher, 15, -1, { window = win })
  vim.w[win].highlighturl_enabled = true
end

--- XXX: Vendorred from lazy.nvim for now

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

--- Override the default title for notifications.
for _, level in ipairs { "info", "warn", "error" } do
  M[level] = function(msg, opts)
    opts = opts or {}
    opts.title = opts.title or "editor"
    return LazyUtil[level](msg, opts)
  end
end

local cache = {} ---@type table<(fun()), table<string, any>>
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

return M
