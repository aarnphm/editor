-- Command:
-- - `:Layout save <optional_name>`: Save the current windows layout, with the command running in all windows, with everything of the file edit panel
-- - `:Layout load <optional_name>`: will load the layout from this current cwd.
--
-- Note that we should also save the state, layout, under state here (vim.fn.stdpath("state"))

if not _G.Util then return end

local Util = require "utils"
local api = vim.api
local fn = vim.fn
local json = vim.json
local deepcopy = vim.deepcopy

local Layout = { version = 1 }

---@class LayoutActiveState
---@field data table
---@field mapping table<integer, integer>
---@field tab number

local active_layout ---@type LayoutActiveState?
local pending_redraw
local in_redraw = false

local layout_root = fn.stdpath "state" .. "/layouts"

local function ensure_dir(path)
  if fn.isdirectory(path) == 1 then return path end

  local ok, err = pcall(fn.mkdir, path, "p")
  if not ok then
    Util.error("layout: failed to create directory " .. path .. ": " .. err)
    return nil
  end
  return path
end

ensure_dir(layout_root)

local function set_active_layout(data, mapping)
  if not data or type(data) ~= "table" or type(data.windows) ~= "table" then
    active_layout = nil
    return
  end

  local tracked = {
    data = data,
    mapping = {},
    tab = api.nvim_get_current_tabpage(),
  }

  for index, win in pairs(mapping or {}) do
    if api.nvim_win_is_valid(win) then
      tracked.mapping[index] = win
      local info = data.windows[index]
      if info then info.bufnr = api.nvim_win_get_buf(win) end
    end
  end

  active_layout = tracked
end

local function current_viewport()
  local columns = vim.o.columns or 0
  local lines = vim.o.lines or 0
  local cmdheight = vim.o.cmdheight or 0
  local editor_lines = lines - cmdheight
  if editor_lines < 1 then editor_lines = 1 end
  return {
    columns = columns,
    lines = lines,
    cmdheight = cmdheight,
    editor_lines = editor_lines,
  }
end

local function update_ratios(data)
  if not data or type(data.windows) ~= "table" then return end
  local viewport = current_viewport()
  data.viewport = viewport
  local columns = math.max(viewport.columns, 1)
  local editor_lines = math.max(viewport.editor_lines, 1)
  for _, info in ipairs(data.windows) do
    if info then
      if type(info.width) == "number" and info.width > 0 then
        info.width_ratio = math.min(1, math.max(info.width / columns, 0))
      elseif info.width_ratio then
        info.width_ratio = math.min(1, math.max(info.width_ratio, 0))
      else
        info.width_ratio = nil
      end
      if type(info.height) == "number" and info.height > 0 then
        info.height_ratio = math.min(1, math.max(info.height / editor_lines, 0))
      elseif info.height_ratio then
        info.height_ratio = math.min(1, math.max(info.height_ratio, 0))
      else
        info.height_ratio = nil
      end
    end
  end
end

local function apply_ratios(data, mapping)
  if not data or type(data.windows) ~= "table" then return end
  local viewport = data.viewport or current_viewport()
  local columns = math.max(viewport.columns or vim.o.columns or 0, 1)
  local editor_lines = math.max(viewport.editor_lines or (vim.o.lines - (vim.o.cmdheight or 0)), 1)
  for index, win in pairs(mapping or {}) do
    if api.nvim_win_is_valid(win) then
      local info = data.windows[index]
      if info then
        local width_ratio = info.width_ratio
        if (not width_ratio or width_ratio <= 0) and info.width and columns > 0 then
          width_ratio = info.width / columns
        end
        if width_ratio and width_ratio > 0 then
          local target_width = math.max(1, math.floor(columns * width_ratio + 0.5))
          pcall(api.nvim_win_set_width, win, target_width)
        end

        local height_ratio = info.height_ratio
        if (not height_ratio or height_ratio <= 0) and info.height and editor_lines > 0 then
          height_ratio = info.height / editor_lines
        end
        if height_ratio and height_ratio > 0 then
          local target_height = math.max(1, math.floor(editor_lines * height_ratio + 0.5))
          pcall(api.nvim_win_set_height, win, target_height)
        end

        info.width = api.nvim_win_get_width(win)
        info.height = api.nvim_win_get_height(win)
      end
    end
  end
  update_ratios(data)
end

local function sanitize(text, fallback)
  if not text then return fallback end
  text = vim.trim(text)
  if text == "" then return fallback end
  text = text:gsub("[:/\\]+", "__")
  text = text:gsub("%s+", "_")
  text = text:gsub("[^%w%._-]", "_")
  text = text:gsub("__+", "__")
  if #text > 60 then text = text:sub(#text - 59) end
  return text
end

local function cwd_key(cwd)
  cwd = cwd or fn.getcwd()
  local slug = sanitize(cwd, "project")
  local hash = ""
  local ok, digest = pcall(fn.sha256, cwd)
  if ok and digest and digest ~= "" then hash = "_" .. digest:sub(1, 8) end
  return slug .. hash
end

local function project_dir(cwd, create)
  local dir = layout_root .. "/" .. cwd_key(cwd)
  if create then return ensure_dir(dir) end
  return dir
end

local function layout_path(cwd, name, create)
  local dir = project_dir(cwd, create)
  if not dir then return nil end
  local slug = sanitize(name or "default", "default")
  return dir .. "/" .. slug .. ".json"
end

local function restore_buffer_options(buf, info)
  if not info then return end
  if info.bufhidden then pcall(api.nvim_buf_set_option, buf, "bufhidden", info.bufhidden) end
  if info.swapfile ~= nil then pcall(api.nvim_buf_set_option, buf, "swapfile", info.swapfile) end
  if info.filetype and info.filetype ~= "" then pcall(api.nvim_buf_set_option, buf, "filetype", info.filetype) end
end

local function fallback_squad_restore(win, buf, state)
  vim.b[buf].squad_terminal = true
  vim.b[buf].squad_restored = true
  if state then vim.b[buf].squad_state = deepcopy(state) end
  vim.b[buf].miniindentscope_disable = true

  for _, key in ipairs { "<c-h>", "<c-j>", "<c-k>", "<c-l>" } do
    vim.keymap.set("t", key, key, { buffer = buf, nowait = true })
  end

  vim.keymap.set("n", "gf", function()
    local file = fn.findfile(fn.expand "<cfile>")
    if file ~= "" then
      vim.cmd "close"
      vim.cmd("e " .. file)
    end
  end, { buffer = buf })

  vim.api.nvim_create_autocmd({ "BufEnter", "TermEnter" }, {
    buffer = buf,
    callback = function()
      if not api.nvim_win_is_valid(win) then return end
      if api.nvim_get_current_buf() ~= buf then return end
      vim.schedule(function()
        if api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then vim.cmd.startinsert() end
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufLeave", "TermLeave" }, {
    buffer = buf,
    callback = function()
      if fn.mode() == "t" then vim.cmd.stopinsert() end
    end,
  })

  if state and state.display then pcall(api.nvim_win_set_option, win, "statusline", " " .. state.display .. " ") end
end

local function normalize_command(cmd)
  if cmd == nil then return nil end
  if type(cmd) == "string" then return cmd end
  if type(cmd) == "table" then
    local normalized = {}
    for _, part in ipairs(cmd) do
      normalized[#normalized + 1] = tostring(part)
    end
    return normalized
  end
  return tostring(cmd)
end

local function capture_window(winid, warnings)
  local buf = api.nvim_win_get_buf(winid)
  local buftype = api.nvim_buf_get_option(buf, "buftype")
  local file = api.nvim_buf_get_name(buf)
  local filetype = api.nvim_buf_get_option(buf, "filetype")
  local info = {
    winid = winid,
    buftype = buftype,
    filetype = filetype,
    width = api.nvim_win_get_width(winid),
    height = api.nvim_win_get_height(winid),
    focus = winid == api.nvim_get_current_win(),
  }

  local ok_bufhidden, bufhidden = pcall(api.nvim_buf_get_option, buf, "bufhidden")
  if ok_bufhidden then info.bufhidden = bufhidden end
  local ok_swapfile, swapfile = pcall(api.nvim_buf_get_option, buf, "swapfile")
  if ok_swapfile then info.swapfile = swapfile end

  info.view = api.nvim_win_call(winid, function()
    local ok, view = pcall(fn.winsaveview)
    if ok then return view end
  end)

  local scratchpad = rawget(_G, "Scratchpad")
  if
    not info.kind
    and scratchpad
    and type(scratchpad.is_scratch_buffer) == "function"
    and scratchpad.is_scratch_buffer(buf)
  then
    info.kind = "scratchpad"
    info.filetype = filetype
    info.buflisted = api.nvim_buf_get_option(buf, "buflisted")
    if type(scratchpad.capture) == "function" then
      local ok_capture, state = pcall(scratchpad.capture, winid, buf)
      if ok_capture then
        info.scratchpad = state
      else
        warnings[#warnings + 1] = string.format("layout: failed to capture scratchpad (%s)", state)
      end
    end
    if not info.scratchpad then info.kind = nil end
  end

  if info.kind == "scratchpad" then
    -- nothing else to classify
  elseif buftype == "" then
    if file == "" then
      info.kind = "empty"
      info.buflisted = api.nvim_buf_get_option(buf, "buflisted")
    else
      info.kind = "file"
      info.path = file
      info.buflisted = api.nvim_buf_get_option(buf, "buflisted")
      info.modified = api.nvim_buf_get_option(buf, "modified")
      if info.modified then
        warnings[#warnings + 1] = string.format(
          "layout: buffer %s has unsaved changes that will not be restored",
          fn.fnamemodify(file, ":~:.")
        )
      end
    end
  elseif buftype == "terminal" or filetype == "lazyterm" then
    info.kind = "terminal"
    local vars = vim.b[buf]
    local cmd = vars and vars.lazyterm_cmd or vars and vars.terminal_cmd
    if not cmd then
      local job_id = vars and vars.terminal_job_id
      if job_id then
        local ok, job = pcall(fn.jobinfo, job_id)
        if ok and type(job) == "table" then
          cmd = job.cmd
          info.term_cwd = job.cwd
        end
      end
    end
    info.command = normalize_command(cmd)
    info.term_title = vars and vars.term_title or nil
    info.term_lang = vars and vars.lazyterm_lang or nil
    info.term_dir = info.term_cwd or api.nvim_win_call(winid, function() return fn.getcwd() end)
    local squad_state = vars and vars.squad_state
    if squad_state then squad_state = deepcopy(squad_state) end
    if vars and (vars.squad_terminal or vars.squad_panel or squad_state) then
      info.squad = {
        terminal = vars.squad_terminal and true or nil,
        panel = vars.squad_panel,
        state = squad_state,
      }
      if info.squad.terminal == nil and info.squad.panel == nil and info.squad.state == nil then info.squad = nil end
    end
  else
    info.kind = "special"
    info.path = file
    info.buflisted = api.nvim_buf_get_option(buf, "buflisted")
  end

  local winopts = {}
  local opts = {
    "winfixwidth",
    "winfixheight",
    "cursorline",
    "cursorcolumn",
    "number",
    "relativenumber",
    "winhighlight",
    "statusline",
  }
  for _, opt in ipairs(opts) do
    local ok, value = pcall(api.nvim_win_get_option, winid, opt)
    if ok then winopts[opt] = value end
  end
  if next(winopts) then info.winopts = winopts end

  if info.kind ~= "terminal" then
    info.term_title = nil
    info.term_lang = nil
    info.term_dir = nil
  end

  return info
end

local function convert_layout(node, windows, warnings)
  local t = node[1]
  if t == "leaf" then
    local winid = node[2]
    local info = capture_window(winid, warnings)
    info.index = #windows + 1
    windows[info.index] = info
    return { type = "leaf", index = info.index }
  end

  local children = {}
  for _, child in ipairs(node[2]) do
    children[#children + 1] = convert_layout(child, windows, warnings)
  end
  return { type = t, children = children }
end

local function capture_layout()
  local warnings = {}
  local windows = {}
  local tree = convert_layout(fn.winlayout(), windows, warnings)
  if not tree or #windows == 0 then return nil, warnings end

  local current_win = api.nvim_get_current_win()
  local current_index
  local mapping = {}
  for _, info in ipairs(windows) do
    if info.winid == current_win then current_index = info.index end
    if info.winid and api.nvim_win_is_valid(info.winid) then
      mapping[info.index] = info.winid
      local buf = api.nvim_win_get_buf(info.winid)
      if buf and api.nvim_buf_is_valid(buf) then info.bufnr = buf end
    end
    info.winid = nil
  end

  local saved_at = os.time()

  local data = {
    version = Layout.version,
    saved_at = saved_at,
    saved_at_iso = os.date("!%Y-%m-%dT%H:%M:%SZ", saved_at),
    cwd = fn.getcwd(),
    layout = tree,
    windows = windows,
    current = current_index,
  }

  update_ratios(data)

  return data, warnings, mapping
end

local function sort_windows_by_orientation(windows, orientation)
  table.sort(windows, function(a, b)
    local pa = api.nvim_win_get_position(a)
    local pb = api.nvim_win_get_position(b)
    if not pa or not pb then return false end

    local pa_row, pa_col = pa[1], pa[2]
    local pb_row, pb_col = pb[1], pb[2]

    if orientation == "row" then
      if pa_col == pb_col then return pa_row < pb_row end
      return pa_col < pb_col
    end
    if pa_row == pb_row then return pa_col < pb_col end
    return pa_row < pb_row
  end)
end

local function build_layout(node, win, mapping)
  api.nvim_set_current_win(win)

  if node.type == "leaf" then
    mapping[node.index] = win
    return
  end

  local children = node.children or {}
  if #children == 0 then return end

  local child_wins = { win }
  for i = 2, #children do
    api.nvim_set_current_win(win)
    if node.type == "row" then
      vim.cmd "vsplit"
    else
      vim.cmd "split"
    end
    child_wins[i] = api.nvim_get_current_win()
  end

  sort_windows_by_orientation(child_wins, node.type)

  for index, child in ipairs(children) do
    build_layout(child, child_wins[index], mapping)
  end
end

local function set_winopts(win, opts)
  if not opts then return end
  for opt, value in pairs(opts) do
    pcall(api.nvim_win_set_option, win, opt, value)
  end
end

local function apply_window(info, win, notices)
  api.nvim_set_current_win(win)

  if info.kind == "file" and info.path then
    local ok, err = pcall(vim.cmd.edit, vim.fn.fnameescape(info.path))
    if not ok then
      notices[#notices + 1] = string.format("layout: failed to open %s (%s)", info.path, err)
      vim.cmd "enew"
    end
  elseif info.kind == "terminal" then
    vim.cmd "enew"
    local buf = api.nvim_get_current_buf()
    local default_bufhidden = info.bufhidden or "hide"
    api.nvim_buf_set_option(buf, "bufhidden", default_bufhidden)
    if info.swapfile ~= nil then pcall(api.nvim_buf_set_option, buf, "swapfile", info.swapfile) end
    vim.b[buf].miniindentscope_disable = true

    local term_opts = {}
    if info.squad and info.squad.state and info.squad.state.term_opts then
      term_opts = deepcopy(info.squad.state.term_opts) or {}
    end
    if info.term_dir and info.term_dir ~= "" and term_opts.cwd == nil then term_opts.cwd = info.term_dir end
    local cmd = info.command
    if type(cmd) == "table" and #cmd == 0 then cmd = nil end
    if cmd == nil or cmd == "" then cmd = vim.o.shell end
    local ok, job = pcall(fn.termopen, cmd, term_opts)
    if not ok or job <= 0 then
      notices[#notices + 1] =
        string.format("layout: failed to restart terminal (%s)", ok and "termopen returned 0" or job)
    else
      vim.b[buf].lazyterm_cmd = info.command
      if info.term_title then vim.b[buf].term_title = info.term_title end
      if info.term_lang then vim.b[buf].lazyterm_lang = info.term_lang end
      restore_buffer_options(buf, info)
      if info.squad then
        if info.squad.panel then vim.b[buf].squad_panel = info.squad.panel end
        if info.squad.terminal then vim.b[buf].squad_terminal = info.squad.terminal end
        if info.squad.state then vim.b[buf].squad_state = deepcopy(info.squad.state) end

        local restored = false
        local squad = rawget(_G, "Squad")
        if squad and type(squad.rehydrate_terminal) == "function" then
          local ok_restore, err = pcall(squad.rehydrate_terminal, win, buf, info.squad.state)
          if ok_restore then
            restored = true
          else
            notices[#notices + 1] = string.format("layout: squad restore fallback (%s)", err)
          end
        end

        if not restored then fallback_squad_restore(win, buf, info.squad.state) end
      end
    end
  elseif info.kind == "scratchpad" then
    vim.cmd "enew"
    local buf = api.nvim_get_current_buf()
    local scratchpad = rawget(_G, "Scratchpad")
    local restored = false
    if scratchpad and type(scratchpad.rehydrate) == "function" then
      local ok_restore, err = pcall(scratchpad.rehydrate, win, buf, info.scratchpad)
      if ok_restore then
        restored = true
      else
        notices[#notices + 1] = string.format("layout: scratchpad restore failed (%s)", err)
      end
    else
      notices[#notices + 1] = "layout: scratchpad restore fallback (scratchpad unavailable)"
    end
    if not restored then
      api.nvim_buf_set_option(buf, "bufhidden", info.bufhidden or "hide")
      api.nvim_buf_set_option(buf, "buftype", "nofile")
      api.nvim_buf_set_option(buf, "buflisted", false)
      api.nvim_buf_set_option(buf, "modifiable", false)
      api.nvim_buf_set_lines(buf, 0, -1, false, { "-- scratchpad state unavailable --" })
    end
    restore_buffer_options(buf, info)
  elseif info.kind == "empty" then
    vim.cmd "enew"
    local buf = api.nvim_get_current_buf()
    api.nvim_buf_set_option(buf, "bufhidden", info.bufhidden or "hide")
    if info.buflisted == 0 then api.nvim_buf_set_option(buf, "buflisted", false) end
  else
    vim.cmd "enew"
    local buf = api.nvim_get_current_buf()
    api.nvim_buf_set_option(buf, "bufhidden", info.bufhidden or "wipe")
    api.nvim_buf_set_option(buf, "buftype", "nofile")
    api.nvim_buf_set_option(buf, "buflisted", false)
    if info.path and info.path ~= "" then pcall(api.nvim_buf_set_name, buf, info.path) end
  end

  if info.view then pcall(fn.winrestview, info.view) end

  if info.width then pcall(api.nvim_win_set_width, win, info.width) end
  if info.height then pcall(api.nvim_win_set_height, win, info.height) end

  set_winopts(win, info.winopts)
end

local function restore_layout(data)
  if type(data) ~= "table" or type(data.layout) ~= "table" or type(data.windows) ~= "table" then
    Util.error "layout: invalid layout data"
    return
  end

  local notices = {}

  local ok_cmdheight, err_cmdheight = pcall(function() vim.o.cmdheight = 1 end)
  if not ok_cmdheight then
    notices[#notices + 1] = string.format("layout: failed to set cmdheight (%s)", err_cmdheight)
  end

  vim.cmd.stopinsert()
  vim.cmd [[silent! only]]

  local base_win = api.nvim_get_current_win()
  local mapping = {}
  build_layout(data.layout, base_win, mapping)

  local desired_views = {}
  for index, info in ipairs(data.windows) do
    local win = mapping[index]
    if win and api.nvim_win_is_valid(win) then
      apply_window(info, win, notices)
      info.bufnr = api.nvim_win_get_buf(win)
      info.view = api.nvim_win_call(win, function()
        local ok, view = pcall(fn.winsaveview)
        if ok then return view end
      end)
      desired_views[index] = info.view
    end
  end

  if next(mapping) then apply_ratios(data, mapping) end

  for index, win in pairs(mapping) do
    if api.nvim_win_is_valid(win) then
      local info = data.windows[index]
      if info then
        local view = desired_views[index]
        if view then pcall(fn.winrestview, view) end
        info.view = api.nvim_win_call(win, function()
          local ok, view_data = pcall(fn.winsaveview)
          if ok then return view_data end
        end)
      end
    end
  end

  for index, win in pairs(mapping) do
    if api.nvim_win_is_valid(win) then
      local info = data.windows[index]
      if info then info.bufnr = api.nvim_win_get_buf(win) end
    end
  end

  if data.current then
    local target = mapping[data.current]
    if target and api.nvim_win_is_valid(target) then api.nvim_set_current_win(target) end
  end

  if #notices > 0 then Util.warn(table.concat(notices, "\n")) end

  set_active_layout(data, mapping)
end

local function collect_valid_buffers(state)
  local buffers = {}
  local views = {}
  local mapping = state and state.mapping or {}
  if mapping then
    for index, win in pairs(mapping) do
      if api.nvim_win_is_valid(win) then
        local buf = api.nvim_win_get_buf(win)
        if buf and api.nvim_buf_is_valid(buf) then buffers[index] = buf end
        local view = api.nvim_win_call(win, function()
          local ok, view_data = pcall(fn.winsaveview)
          if ok then return view_data end
        end)
        if view then views[index] = view end
      end
    end
  end

  if vim.tbl_isempty(buffers) and state then
    for index, info in ipairs(state.data.windows or {}) do
      local buf = info and info.bufnr
      if buf and api.nvim_buf_is_valid(buf) then buffers[index] = buf end
    end
  end

  return buffers, views
end

local function redraw_internal(opts)
  if not active_layout or active_layout.tab ~= api.nvim_get_current_tabpage() then return false end
  local data = active_layout.data
  if not data or type(data.layout) ~= "table" then return false end

  local buffers, views = collect_valid_buffers(active_layout)
  if vim.tbl_isempty(buffers) then return false end

  vim.cmd.stopinsert()
  vim.cmd [[silent! only]]

  local base_win = api.nvim_get_current_win()
  local mapping = {}
  build_layout(data.layout, base_win, mapping)

  local notices = {}
  local desired_views = {}
  for index, win in pairs(mapping) do
    if api.nvim_win_is_valid(win) then
      local info = data.windows[index]
      if info then
        local buf = buffers[index]
        if buf and api.nvim_buf_is_valid(buf) then
          api.nvim_win_set_buf(win, buf)
          info.bufnr = buf
        else
          apply_window(info, win, notices)
          info.bufnr = api.nvim_win_get_buf(win)
        end
        set_winopts(win, info.winopts)
        desired_views[index] = views[index] or info.view
      end
    end
  end

  if next(mapping) then apply_ratios(data, mapping) end

  for index, win in pairs(mapping) do
    if api.nvim_win_is_valid(win) then
      local info = data.windows[index]
      if info then
        local view = desired_views[index]
        if view then pcall(fn.winrestview, view) end
        info.view = api.nvim_win_call(win, function()
          local ok, view_data = pcall(fn.winsaveview)
          if ok then return view_data end
        end)
        info.bufnr = api.nvim_win_get_buf(win)
      end
    end
  end

  if data.current then
    local target = mapping[data.current]
    if target and api.nvim_win_is_valid(target) then api.nvim_set_current_win(target) end
  end

  set_active_layout(data, mapping)
  if #notices > 0 then Util.warn(table.concat(notices, "\n")) end
  return true
end

function Layout.redraw(opts)
  if in_redraw then return false end
  in_redraw = true
  local ok, result = pcall(redraw_internal, opts)
  in_redraw = false
  if not ok then
    Util.error("layout: redraw failed - " .. result)
    return false
  end
  return result
end

local function schedule_redraw(reason)
  if pending_redraw or not active_layout then return end
  pending_redraw = true
  vim.defer_fn(function()
    pending_redraw = false
    if active_layout then Layout.redraw { reason = reason } end
  end, 50)
end

vim.api.nvim_create_autocmd("VimResized", {
  callback = function() schedule_redraw "resize" end,
})

vim.api.nvim_create_autocmd("WinResized", {
  callback = function() schedule_redraw "winresize" end,
})

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "cmdheight",
  callback = function()
    if active_layout and active_layout.data then update_ratios(active_layout.data) end
    schedule_redraw "cmdheight"
  end,
})

local function available_layouts(cwd)
  local dir = project_dir(cwd, false)
  if fn.isdirectory(dir) == 0 then return {} end
  local files = fn.globpath(dir, "*.json", false, true)
  local names = {}
  for _, file in ipairs(files) do
    local name = fn.fnamemodify(file, ":t")
    name = name:gsub("%.json$", "")
    names[#names + 1] = name
  end
  table.sort(names)
  return names
end

function Layout.save(name)
  local data, warnings, mapping = capture_layout()
  if not data then
    Util.warn "layout: nothing to save"
    return
  end

  local cwd = data.cwd
  local path = layout_path(cwd, name, true)
  if not path then
    Util.error "layout: unable to compute layout path"
    return
  end

  local persistable = deepcopy(data)
  for _, info in ipairs(persistable.windows) do
    if info then info.bufnr = nil end
  end

  local ok, encoded = pcall(json.encode, persistable)
  if not ok then
    Util.error("layout: failed to encode layout - " .. encoded)
    return
  end

  local success, err = pcall(fn.writefile, { encoded }, path)
  if not success then
    Util.error("layout: failed to write layout - " .. err)
    return
  end

  if warnings and #warnings > 0 then Util.warn(table.concat(warnings, "\n")) end

  Util.info(string.format("layout: saved %s", fn.fnamemodify(path, ":~")))

  set_active_layout(data, mapping)
end

function Layout.load(name)
  local cwd = fn.getcwd()
  local path = layout_path(cwd, name, false)
  if not path or fn.filereadable(path) == 0 then
    Util.warn(string.format("layout: layout '%s' not found for %s", name or "default", cwd))
    return
  end

  local ok, lines = pcall(fn.readfile, path)
  if not ok then
    Util.error("layout: failed to read layout - " .. lines)
    return
  end

  local content = table.concat(lines, "\n")
  local decoded_ok, data = pcall(json.decode, content)
  if not decoded_ok then
    Util.error("layout: failed to parse layout - " .. data)
    return
  end

  if type(data) ~= "table" or data.version ~= Layout.version then Util.warn "layout: layout version mismatch" end

  restore_layout(data)
  Util.info(string.format("layout: loaded %s", fn.fnamemodify(path, ":~")))
end

local function completion(arg_lead, cmd_line, _)
  local parts = vim.split(cmd_line, "%s+", { trimempty = true })
  local subcmd = parts[2]

  if not subcmd or (#parts == 2 and not cmd_line:match "%s$") then
    local options = { "save", "load", "redraw" }
    local matches = {}
    for _, option in ipairs(options) do
      if option:find("^" .. vim.pesc(arg_lead)) then matches[#matches + 1] = option end
    end
    return matches
  end

  if subcmd == "save" or subcmd == "load" then
    local matches = {}
    for _, name in ipairs(available_layouts(fn.getcwd())) do
      if name:find("^" .. vim.pesc(arg_lead)) then matches[#matches + 1] = name end
    end
    return matches
  end

  if subcmd == "redraw" then return {} end

  return {}
end

vim.api.nvim_create_user_command("Layout", function(opts)
  local args = opts.fargs
  local subcmd = args[1]
  if not subcmd then
    Util.warn "layout: expected 'save' or 'load'"
    return
  end

  if subcmd == "save" then
    Layout.save(args[2])
  elseif subcmd == "load" then
    Layout.load(args[2])
  elseif subcmd == "redraw" then
    if not Layout.redraw { reason = "command" } then Util.warn "layout: nothing to redraw" end
  else
    Util.warn("layout: unknown subcommand '" .. subcmd .. "'")
  end
end, {
  nargs = "*",
  complete = completion,
})

return Layout
