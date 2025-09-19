if not _G.Util then return end

local Util = require "utils"
local api = vim.api
local fn = vim.fn
local inspect = vim.inspect

---@class ScratchPadConfig
---@field width integer
---@field output_height integer
---@field side "left"|"right"
---@field focus_on_open boolean

---@class ScratchPadState
---@field code_buf? integer
---@field output_buf? integer
---@field code_win? integer
---@field output_win? integer
---@field side? "left"|"right"
---@field output_lines? string[]
---@field last_selection? { line1?: integer, line2?: integer }

---@class ScratchPadCapture
---@field kind string
---@field lines string[]
---@field side? "left"|"right"
---@field view? table

---@class ScratchPad
---@field config ScratchPadConfig
---@field state ScratchPadState
---@field augroup integer
---@field _win_closed_autocmd? boolean
---@field open fun(opts?: {side?:"left"|"right", width?:integer, output_height?:integer, focus?:boolean}): (integer?, integer?)
---@field close fun()
---@field run fun(line1?: integer, line2?: integer, buf?: integer): string[]|nil
---@field write_output fun(lines: string[])
---@field clear_output fun()
---@field capture fun(win?: integer, buf?: integer): ScratchPadCapture?
---@field rehydrate fun(win?: integer, buf?: integer, state?: ScratchPadCapture)
---@field is_scratch_buffer fun(buf: integer): boolean

---@type ScratchPad
local Scratchpad = _G.Scratchpad or {}

---@type ScratchPadConfig
local defaults = {
  width = 72,
  output_height = 12,
  side = "right",
  focus_on_open = true,
}

Scratchpad.config = vim.tbl_deep_extend("force", defaults, Scratchpad.config or {})
---@type ScratchPadState
Scratchpad.state = Scratchpad.state or {}

local augroup = Scratchpad.augroup
if not augroup then
  augroup = api.nvim_create_augroup("LuaScratchpad", { clear = true })
  Scratchpad.augroup = augroup
end

local function is_buf_valid(buf) return buf and api.nvim_buf_is_valid(buf) end

local function is_win_valid(win) return win and api.nvim_win_is_valid(win) end

local function set_winopt(win, name, value)
  pcall(api.nvim_set_option_value, name, value, { scope = "local", win = win })
end

if not Scratchpad._win_closed_autocmd then
  api.nvim_create_autocmd("WinClosed", {
    group = augroup,
    callback = function(ev)
      local win = tonumber(ev.match)
      if not win then return end
      if Scratchpad.state.code_win == win then Scratchpad.state.code_win = nil end
      if Scratchpad.state.output_win == win then Scratchpad.state.output_win = nil end
    end,
  })
  Scratchpad._win_closed_autocmd = true
end

---@param buf integer
local function configure_code_buffer(buf)
  api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  api.nvim_set_option_value("bufhidden", "hide", { buf = buf })
  api.nvim_set_option_value("swapfile", false, { buf = buf })
  api.nvim_set_option_value("undofile", false, { buf = buf })
  api.nvim_set_option_value("modeline", false, { buf = buf })
  api.nvim_set_option_value("buflisted", false, { buf = buf })
  api.nvim_set_option_value("modifiable", true, { buf = buf })
  api.nvim_set_option_value("filetype", "lua", { buf = buf })
  api.nvim_set_option_value("spell", false, { buf = buf })
  vim.b[buf].scratchpad = true
  vim.b[buf].scratchpad_kind = "code"
  vim.b[buf].scratchpad_state_version = 1

  if not vim.b[buf].scratchpad_autocmd then
    api.nvim_create_autocmd("BufWipeout", {
      group = augroup,
      buffer = buf,
      callback = function()
        if Scratchpad.state.code_buf == buf then Scratchpad.state.code_buf = nil end
      end,
    })
    vim.b[buf].scratchpad_autocmd = true
  end

  if not vim.b[buf].scratchpad_keymaps then
    vim.keymap.set("n", "<leader>lr", function() Scratchpad.run() end, {
      buffer = buf,
      desc = "Run Lua scratchpad buffer",
    })
    vim.keymap.set("v", "<leader>lr", function()
      local start_line = fn.line "'<"
      local end_line = fn.line "'>"
      Scratchpad.run(start_line, end_line)
    end, {
      buffer = buf,
      desc = "Run Lua scratchpad selection",
    })
    vim.keymap.set("n", "<leader>lc", function() Scratchpad.clear_output() end, {
      buffer = buf,
      desc = "Clear Lua scratchpad output",
    })
    vim.b[buf].scratchpad_keymaps = true
  end

  if not vim.b[buf].scratchpad_named then
    api.nvim_buf_set_name(buf, "lua-scratchpad://code")
    local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
    if #lines == 1 and lines[1] == "" then
      api.nvim_buf_set_lines(buf, 0, -1, false, {
        "-- Lua scratchpad",
        "-- Use <leader>lr to run buffer or selection",
        "",
      })
    end
    vim.b[buf].scratchpad_named = true
  end
end

---@param buf integer
local function configure_output_buffer(buf)
  api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  api.nvim_set_option_value("bufhidden", "hide", { buf = buf })
  api.nvim_set_option_value("swapfile", false, { buf = buf })
  api.nvim_set_option_value("undofile", false, { buf = buf })
  api.nvim_set_option_value("modeline", false, { buf = buf })
  api.nvim_set_option_value("buflisted", false, { buf = buf })
  api.nvim_set_option_value("modifiable", false, { buf = buf })
  api.nvim_set_option_value("readonly", true, { buf = buf })
  api.nvim_set_option_value("filetype", "lua", { buf = buf })
  api.nvim_set_option_value("spell", false, { buf = buf })
  vim.b[buf].scratchpad = true
  vim.b[buf].scratchpad_kind = "output"
  vim.b[buf].scratchpad_state_version = 1

  if not vim.b[buf].scratchpad_autocmd then
    api.nvim_create_autocmd("BufWipeout", {
      group = augroup,
      buffer = buf,
      callback = function()
        if Scratchpad.state.output_buf == buf then Scratchpad.state.output_buf = nil end
      end,
    })
    vim.b[buf].scratchpad_autocmd = true
  end

  if not vim.b[buf].scratchpad_named then
    api.nvim_buf_set_name(buf, "lua-scratchpad://output")
    api.nvim_buf_set_lines(buf, 0, -1, false, { "-- output" })
    vim.b[buf].scratchpad_named = true
  end
end

---@return integer
local function ensure_code_buf()
  local buf = Scratchpad.state.code_buf
  if not is_buf_valid(buf) then
    buf = api.nvim_create_buf(false, true)
    Scratchpad.state.code_buf = buf
  end
  configure_code_buffer(buf)
  return buf
end

---@return integer
local function ensure_output_buf()
  local buf = Scratchpad.state.output_buf
  if not is_buf_valid(buf) then
    buf = api.nvim_create_buf(false, true)
    Scratchpad.state.output_buf = buf
  end
  configure_output_buffer(buf)
  return buf
end

---@param win integer
local function apply_code_window_settings(win)
  set_winopt(win, "number", false)
  set_winopt(win, "relativenumber", false)
  set_winopt(win, "signcolumn", "no")
  set_winopt(win, "foldcolumn", "0")
  set_winopt(win, "cursorline", false)
  set_winopt(win, "list", false)
  set_winopt(win, "wrap", false)
  set_winopt(win, "spell", false)
  set_winopt(win, "winfixwidth", true)
  set_winopt(win, "statusline", " Lua Scratchpad ")
end

---@param win integer
local function apply_output_window_settings(win)
  set_winopt(win, "number", false)
  set_winopt(win, "relativenumber", false)
  set_winopt(win, "signcolumn", "no")
  set_winopt(win, "foldcolumn", "0")
  set_winopt(win, "cursorline", false)
  set_winopt(win, "list", false)
  set_winopt(win, "wrap", true)
  set_winopt(win, "spell", false)
  set_winopt(win, "winfixwidth", true)
  set_winopt(win, "winfixheight", true)
  set_winopt(win, "statusline", " Lua Scratch Output ")
end

---@param opts? {side?:"left"|"right", width?:integer, output_height?:integer, focus?:boolean}
---@return integer?, integer?
function Scratchpad.open(opts)
  opts = opts or {}
  local code_buf = ensure_code_buf()
  local output_buf = ensure_output_buf()
  local config = Scratchpad.config
  local side = opts.side or config.side or "right"
  local width = opts.width or config.width
  local output_height = opts.output_height or config.output_height
  local focus = opts.focus
  if focus == nil then focus = opts.focus ~= false and config.focus_on_open end

  local prev_win = api.nvim_get_current_win()
  local code_win = Scratchpad.state.code_win
  if not is_win_valid(code_win) then
    if side == "left" then
      vim.cmd "topleft vsplit"
    else
      vim.cmd "botright vsplit"
    end
    code_win = api.nvim_get_current_win()
    Scratchpad.state.code_win = code_win
  end

  apply_code_window_settings(code_win)
  if width then pcall(api.nvim_win_set_width, code_win, width) end
  api.nvim_win_set_buf(code_win, code_buf)

  local output_win = Scratchpad.state.output_win
  if not is_win_valid(output_win) or output_win == code_win then
    api.nvim_set_current_win(code_win)
    vim.cmd "belowright split"
    output_win = api.nvim_get_current_win()
    Scratchpad.state.output_win = output_win
  end

  apply_output_window_settings(output_win)
  if output_height then pcall(api.nvim_win_set_height, output_win, output_height) end
  api.nvim_win_set_buf(output_win, output_buf)

  Scratchpad.state.side = side

  if focus then
    api.nvim_set_current_win(code_win)
  else
    api.nvim_set_current_win(prev_win)
  end

  return code_win, output_win
end

function Scratchpad.close()
  if is_win_valid(Scratchpad.state.output_win) then pcall(api.nvim_win_close, Scratchpad.state.output_win, true) end
  if is_win_valid(Scratchpad.state.code_win) then pcall(api.nvim_win_close, Scratchpad.state.code_win, true) end
end

---@param lines string[]
function Scratchpad.write_output(lines)
  local output_buf = ensure_output_buf()
  local readonly = api.nvim_get_option_value("readonly", { buf = output_buf })
  local modifiable = api.nvim_get_option_value("modifiable", { buf = output_buf })
  if readonly then api.nvim_set_option_value("readonly", false, { buf = output_buf }) end
  if not modifiable then api.nvim_set_option_value("modifiable", true, { buf = output_buf }) end
  api.nvim_buf_set_lines(output_buf, 0, -1, false, lines)
  api.nvim_set_option_value("modifiable", false, { buf = output_buf })
  api.nvim_set_option_value("readonly", true, { buf = output_buf })
  Scratchpad.state.output_lines = vim.deepcopy(lines)
  vim.b[output_buf].scratchpad_snapshot = vim.deepcopy(lines)

  local output_win = Scratchpad.state.output_win
  if is_win_valid(output_win) then api.nvim_win_call(output_win, function() vim.cmd "normal! G" end) end
end

function Scratchpad.clear_output() Scratchpad.write_output { "-- output cleared --" } end

---@param line1? integer
---@param line2? integer
---@param buf? integer
---@return string[]|nil
function Scratchpad.run(line1, line2, buf)
  buf = buf or Scratchpad.state.code_buf
  if not is_buf_valid(buf) then
    Scratchpad.open { focus = true }
    buf = Scratchpad.state.code_buf
    if not is_buf_valid(buf) then
      Util.warn "scratchpad: unable to allocate code buffer"
      return
    end
  else
    Scratchpad.open { focus = true }
  end

  local start_idx = 0
  local end_idx = -1
  if line1 and line2 then
    start_idx = math.max(line1 - 1, 0)
    end_idx = line2
  end
  local lines = api.nvim_buf_get_lines(buf, start_idx, end_idx, false)
  Scratchpad.state.last_selection = { line1 = line1, line2 = line2 }

  local code = table.concat(lines, "\n")
  if code == "" then
    Scratchpad.write_output { "-- no code to execute" }
    return
  end

  local output_lines = {}
  local function push(line) output_lines[#output_lines + 1] = line end

  local function capture(...)
    if select("#", ...) == 0 then
      push ""
      return
    end
    local parts = {}
    for i = 1, select("#", ...) do
      local value = select(i, ...)
      if type(value) == "string" then
        parts[#parts + 1] = value
      else
        parts[#parts + 1] = inspect(value)
      end
    end
    push(table.concat(parts, "\t"))
    return ...
  end

  local env_vim = setmetatable({ print = capture }, {
    __index = vim,
    __newindex = vim,
  })
  local env = setmetatable({ print = capture, vim = env_vim, Util = Util }, { __index = _G })

  local chunk, err = load(code, "LuaScratchpad", "t", env)
  if not chunk then
    push "! compile error"
    push(err)
    Scratchpad.write_output(output_lines)
    return output_lines
  end

  local ok, trace = xpcall(function()
    local results = { chunk() }
    if #results > 0 then capture(unpack(results)) end
  end, function(e) return debug.traceback(e, 2) end)

  if not ok then
    push "! runtime error"
    for line in trace:gmatch "[^\n]+" do
      push(line)
    end
  elseif #output_lines == 0 then
    push "-- ok (no output)"
  end

  Scratchpad.write_output(output_lines)
  return output_lines
end

---@param win? integer
---@param buf? integer
---@return ScratchPadCapture|nil
function Scratchpad.capture(win, buf)
  if not is_buf_valid(buf) then return end
  if not vim.b[buf].scratchpad then return end
  ---@type ScratchPadCapture
  local state = {
    kind = vim.b[buf].scratchpad_kind,
    lines = api.nvim_buf_get_lines(buf, 0, -1, false),
  }
  state.side = Scratchpad.state.side
  if win and is_win_valid(win) then
    state.view = api.nvim_win_call(win, function()
      local ok, view = pcall(vim.fn.winsaveview)
      if ok then return view end
    end)
  end
  return state
end

---@param win? integer
---@param buf? integer
---@param state? ScratchPadCapture
function Scratchpad.rehydrate(win, buf, state)
  if not state or not is_buf_valid(buf) then return end
  if state.kind == "code" then
    configure_code_buffer(buf)
    Scratchpad.state.code_buf = buf
    if win and is_win_valid(win) then
      Scratchpad.state.code_win = win
      apply_code_window_settings(win)
    end
  else
    configure_output_buffer(buf)
    Scratchpad.state.output_buf = buf
    if win and is_win_valid(win) then
      Scratchpad.state.output_win = win
      apply_output_window_settings(win)
    end
  end

  if state.side then Scratchpad.state.side = state.side end

  local readonly = api.nvim_get_option_value("readonly", { buf = buf })
  local modifiable = api.nvim_get_option_value("modifiable", { buf = buf })
  api.nvim_set_option_value("readonly", false, { buf = buf })
  api.nvim_set_option_value("modifiable", true, { buf = buf })
  api.nvim_buf_set_lines(buf, 0, -1, false, state.lines or {})
  if state.kind == "output" then
    api.nvim_set_option_value("modifiable", false, { buf = buf })
    api.nvim_set_option_value("readonly", true, { buf = buf })
    Scratchpad.state.output_lines = vim.deepcopy(state.lines or {})
    vim.b[buf].scratchpad_snapshot = vim.deepcopy(state.lines or {})
  else
    api.nvim_set_option_value("modifiable", modifiable, { buf = buf })
    api.nvim_set_option_value("readonly", readonly, { buf = buf })
    vim.b[buf].scratchpad_snapshot = vim.deepcopy(state.lines or {})
  end

  if state.view and win and is_win_valid(win) then
    api.nvim_win_call(win, function() pcall(vim.fn.winrestview, state.view) end)
  end
end

---@param buf integer
---@return boolean
function Scratchpad.is_scratch_buffer(buf) return is_buf_valid(buf) and vim.b[buf].scratchpad == true end

_G.Scratchpad = Scratchpad

api.nvim_create_user_command("LuaScratch", function(opts)
  if opts.bang then
    Scratchpad.close()
  else
    Scratchpad.open()
  end
end, {
  desc = "Open Lua scratchpad side panel",
  bang = true,
})

api.nvim_create_user_command("LuaScratchRun", function(opts)
  if opts.range == 2 then
    Scratchpad.run(opts.line1, opts.line2)
  else
    Scratchpad.run()
  end
end, {
  desc = "Run Lua scratchpad buffer or range",
  range = true,
})

api.nvim_create_user_command("LuaScratchClear", function() Scratchpad.clear_output() end, {
  desc = "Clear Lua scratchpad output",
})
