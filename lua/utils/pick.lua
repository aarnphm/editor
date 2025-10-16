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

local function tbl_isempty(t) return t == nil or next(t) == nil end

local function shell_join(cmd)
  return table.concat(vim.tbl_map(function(part) return vim.fn.shellescape(part) end, cmd), " ")
end

local function detect_tool(preferred)
  local function executable(name) return vim.fn.executable(name) == 1 end

  if preferred ~= nil then
    if preferred == "fallback" then return nil end
    if executable(preferred) then return preferred end
  end

  if executable "rg" then return "rg" end
  if executable "fd" then return "fd" end
  if executable "git" then return "git" end
  return nil
end

local function build_default_files_command(opts)
  local tool = detect_tool(opts.tool)
  if tool == "rg" then return { "rg", "--files", "--color=never" } end
  if tool == "fd" then return { "fd", "--type=f", "--color=never" } end
  if tool == "git" then return { "git", "ls-files", "--cached", "--others", "--exclude-standard" } end
  return nil
end

local function build_include_command()
  if tbl_isempty(M.force_include_globs) or vim.fn.executable "rg" ~= 1 then return nil end

  local cmd = { "rg", "--files", "--color=never", "--ignore" }
  for _, pattern in ipairs(M.force_include_globs) do
    table.insert(cmd, "--glob")
    table.insert(cmd, pattern)
  end
  return cmd
end

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

local function open_files_with_force_include(opts)
  if tbl_isempty(M.force_include_globs) then return false end

  local base_command = build_default_files_command(opts)
  local include_command = build_include_command()

  if not base_command or not include_command then return false end

  local source = vim.deepcopy(opts.source or {})
  local cwd = source.cwd or opts.cwd or vim.fn.getcwd()
  if type(cwd) ~= "string" or cwd == "" then cwd = vim.fn.getcwd() end
  source.cwd = cwd

  local pick_opts = vim.tbl_deep_extend("force", {}, opts, { source = source, show = true })
  pick_opts.tool = nil
  pick_opts.cwd = nil
  pick_opts.root = nil
  pick_opts.show_untracked = nil

  local combined = string.format("(%s; %s) | LC_ALL=C sort -u", shell_join(base_command), shell_join(include_command))

  local result =
    require("mini.pick").builtin.cli({ command = { "bash", "-lc", combined }, spawn_opts = { cwd = cwd } }, pick_opts)

  return true, result
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

  -- if command == "files" then
  --   local ok, handled, res = pcall(open_files_with_force_include, opts)
  --   if not ok then
  --     Util.error(handled)
  --     return
  --   end
  --   if handled then return res end
  -- end
  --
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
