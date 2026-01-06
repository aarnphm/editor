---@class lazyvim.util.pick
---@overload fun(command:string, opts?:lazyvim.util.pick.Opts): fun()
local M = setmetatable({}, {
  __call = function(m, ...) return m.wrap(...) end,
})

---@class lazyvim.util.pick.Opts: table<string, any>
---@field root? boolean
---@field cwd? string | string[] | nil
---@field buf? number
---@field show_untracked? boolean

---@class LazyPicker
---@field name string
---@field open fun(command:string, opts?:lazyvim.util.pick.Opts)
---@field commands table<string, string>

---@type LazyPicker?
M.picker = nil
M.force_include_globs = {}

local function normalize_globs(globs)
  if type(globs) ~= "table" then return {} end

  local seen, normalized = {}, {}
  for _, value in ipairs(globs) do
    if type(value) == "string" then
      local trimmed = value:gsub("^%s+", ""):gsub("%s+$", "")
      trimmed = trimmed:gsub("^%./", "")
      trimmed = trimmed:gsub("\\", "/")
      trimmed = trimmed:gsub("/+", "/")
      trimmed = trimmed:gsub("/$", "")
      if trimmed ~= "" then
        local with_glob = trimmed
        if not with_glob:find "[%*%?%[]" then
          if not with_glob:find "/%*%*$" then with_glob = with_glob .. "/**" end
        end
        if not seen[with_glob] then
          seen[with_glob] = true
          table.insert(normalized, with_glob)
        end
      end
    end
  end
  return normalized
end

---@param picker LazyPicker
function M.register(picker)
  -- this only happens when using :LazyExtras
  -- so allow to get the full spec
  if vim.v.vim_did_enter == 1 then return true end

  if M.picker and M.picker.name ~= M.want() then M.picker = nil end

  if M.picker and M.picker.name ~= picker.name then
    Util.warn("`pick`: picker already set to `" .. M.picker.name .. "`,\nignoring new picker `" .. picker.name .. "`")
    return false
  end
  M.picker = picker
  return true
end

function M.want()
  vim.g.picker = vim.g.picker or "auto"
  if vim.g.picker == "auto" then return "mini.pick" end
  return vim.g.picker
end

---@param command? string
---@param opts? lazyvim.util.pick.Opts
function M.open(command, opts)
  if not M.picker then return Util.error "pick: picker not set" end

  command = command ~= "auto" and command or "files"
  opts = opts or {}

  opts = vim.deepcopy(opts)

  if type(opts.cwd) == "boolean" then
    Util.warn "pick: opts.cwd should be a string or nil"
    opts.cwd = nil
  end

  if not opts.cwd and opts.root ~= false then opts.cwd = Util.root { buf = opts.buf } end

  command = M.picker.commands[command] or command

  M.picker.open(command, opts)
end

---@param command? string
---@param opts? lazyvim.util.pick.Opts
function M.wrap(command, opts)
  opts = opts or {}
  return function() Util.pick.open(command, vim.deepcopy(opts)) end
end

function M.config_files() return M.wrap("files", { cwd = vim.fn.stdpath "config" }) end

function M.set_force_include_globs(globs) M.force_include_globs = normalize_globs(globs) end

return M
