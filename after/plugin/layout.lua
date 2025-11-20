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

local Layout = { version = 2 }

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

local function detect_layout_hint(node)
  local t = node[1]
  if t == "leaf" then return nil end
  if t == "row" then return "horizontal" end
  if t == "col" then return "vertical" end
  for _, child in ipairs(node[2] or {}) do
    local hint = detect_layout_hint(child)
    if hint then return hint end
  end
  return nil
end

local function extract_windows_ordered(node, result)
  local t = node[1]
  if t == "leaf" then
    result[#result + 1] = node[2]
    return
  end
  for _, child in ipairs(node[2] or {}) do
    extract_windows_ordered(child, result)
  end
end

local function capture_layout()
  local warnings = {}
  local layout_tree = fn.winlayout()

  local winids = {}
  extract_windows_ordered(layout_tree, winids)

  if #winids == 0 then return nil, warnings end

  local terminals = {}
  local files = {}
  local current_win = api.nvim_get_current_win()
  local focus_index = nil
  local mapping = {}

  for idx, winid in ipairs(winids) do
    if not api.nvim_win_is_valid(winid) then goto continue end

    local buf = api.nvim_win_get_buf(winid)
    local buftype = api.nvim_buf_get_option(buf, "buftype")
    local file = api.nvim_buf_get_name(buf)
    local filetype = api.nvim_buf_get_option(buf, "filetype")

    if winid == current_win then focus_index = #terminals + #files end

    if buftype == "terminal" or filetype == "lazyterm" then
      local vars = vim.b[buf]
      local cmd = vars and vars.lazyterm_cmd or vars and vars.terminal_cmd

      if not cmd then
        local job_id = vars and vars.terminal_job_id
        if job_id then
          local ok, job = pcall(fn.jobinfo, job_id)
          if ok and type(job) == "table" then cmd = job.cmd end
        end
      end

      local term_cwd = nil
      local job_id = vars and vars.terminal_job_id
      if job_id then
        local ok, job = pcall(fn.jobinfo, job_id)
        if ok and type(job) == "table" then term_cwd = job.cwd end
      end
      term_cwd = term_cwd or api.nvim_win_call(winid, function() return fn.getcwd() end)

      local squad_state = vars and vars.squad_state
      if squad_state then squad_state = deepcopy(squad_state) end

      local entry = {
        command = normalize_command(cmd),
        cwd = term_cwd,
      }

      if squad_state then
        entry.squad_state = squad_state
        local squad_panel = vars and vars.squad_panel
        if squad_panel then entry.agent = squad_panel end
      end

      if squad_state and squad_state.term_opts and squad_state.term_opts.env then
        entry.env = squad_state.term_opts.env
      end

      terminals[#terminals + 1] = entry
      mapping[idx] = winid
    elseif buftype == "" and file ~= "" then
      local pos = api.nvim_win_get_cursor(winid)
      local entry = {
        path = file,
        line = pos[1],
        col = pos[2],
      }

      local modified = api.nvim_buf_get_option(buf, "modified")
      if modified then
        warnings[#warnings + 1] = string.format(
          "layout: buffer %s has unsaved changes that will not be restored",
          fn.fnamemodify(file, ":~:.")
        )
      end

      files[#files + 1] = entry
      mapping[idx] = winid
    end

    ::continue::
  end

  if #terminals == 0 and #files == 0 then return nil, warnings end

  local layout_hint = detect_layout_hint(layout_tree) or "vertical"
  local saved_at = os.time()

  local data = {
    version = Layout.version,
    saved_at = saved_at,
    saved_at_iso = os.date("!%Y-%m-%dT%H:%M:%SZ", saved_at),
    cwd = fn.getcwd(),
    terminals = terminals,
    files = files,
    layout_hint = layout_hint,
    focus_index = focus_index,
  }

  return data, warnings, mapping
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
  if type(data) ~= "table" then
    Util.error "layout: invalid layout data"
    return
  end

  local terminals = data.terminals or {}
  local files = data.files or {}
  local layout_hint = data.layout_hint or "vertical"
  local focus_index = data.focus_index

  if #terminals == 0 and #files == 0 then
    Util.warn "layout: nothing to restore"
    return
  end

  local notices = {}

  vim.cmd.stopinsert()
  vim.cmd [[silent! only]]

  local windows = {}
  local first_win = api.nvim_get_current_win()
  windows[1] = first_win

  local total_items = #terminals + #files
  local split_cmd = layout_hint == "horizontal" and "split" or "vsplit"

  for i = 2, total_items do
    api.nvim_set_current_win(windows[1])
    vim.cmd(split_cmd)
    windows[i] = api.nvim_get_current_win()
  end

  local item_idx = 1
  for _, term_entry in ipairs(terminals) do
    local win = windows[item_idx]
    if win and api.nvim_win_is_valid(win) then
      api.nvim_set_current_win(win)
      vim.cmd "enew"
      local buf = api.nvim_get_current_buf()

      api.nvim_buf_set_option(buf, "bufhidden", "hide")
      vim.b[buf].miniindentscope_disable = true

      local term_opts = {}
      if term_entry.cwd then term_opts.cwd = term_entry.cwd end
      if term_entry.env then term_opts.env = term_entry.env end

      local cmd = term_entry.command
      if type(cmd) == "table" and #cmd == 0 then cmd = nil end
      if cmd == nil or cmd == "" then cmd = vim.o.shell end

      local ok, job = pcall(fn.termopen, cmd, term_opts)
      if not ok or job <= 0 then
        notices[#notices + 1] =
          string.format("layout: failed to restart terminal (%s)", ok and "termopen returned 0" or job)
      else
        vim.b[buf].lazyterm_cmd = term_entry.command

        if term_entry.squad_state then
          vim.b[buf].squad_state = deepcopy(term_entry.squad_state)

          if term_entry.agent then vim.b[buf].squad_panel = term_entry.agent end

          local restored = false
          local squad = rawget(_G, "Squad")
          if squad and type(squad.rehydrate_terminal) == "function" then
            local ok_restore, err = pcall(squad.rehydrate_terminal, win, buf, term_entry.squad_state)
            if ok_restore then
              restored = true
            else
              notices[#notices + 1] = string.format("layout: squad restore fallback (%s)", err)
            end
          end

          if not restored then fallback_squad_restore(win, buf, term_entry.squad_state) end
        end
      end
    end
    item_idx = item_idx + 1
  end

  for _, file_entry in ipairs(files) do
    local win = windows[item_idx]
    if win and api.nvim_win_is_valid(win) then
      api.nvim_set_current_win(win)
      local ok, err = pcall(vim.cmd.edit, vim.fn.fnameescape(file_entry.path))
      if not ok then
        notices[#notices + 1] = string.format("layout: failed to open %s (%s)", file_entry.path, err)
        vim.cmd "enew"
      else
        if file_entry.line and file_entry.col then
          pcall(api.nvim_win_set_cursor, win, { file_entry.line, file_entry.col })
        elseif file_entry.line then
          pcall(api.nvim_win_set_cursor, win, { file_entry.line, 0 })
        end
      end
    end
    item_idx = item_idx + 1
  end

  if focus_index and windows[focus_index + 1] and api.nvim_win_is_valid(windows[focus_index + 1]) then
    api.nvim_set_current_win(windows[focus_index + 1])
  end

  if #notices > 0 then Util.warn(table.concat(notices, "\n")) end
end

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
  local data, warnings = capture_layout()
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

  local ok, encoded = pcall(json.encode, data)
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

  restore_layout(data)
  Util.info(string.format("layout: loaded %s", fn.fnamemodify(path, ":~")))
end

local function completion(arg_lead, cmd_line, _)
  local parts = vim.split(cmd_line, "%s+", { trimempty = true })
  local subcmd = parts[2]

  if not subcmd or (#parts == 2 and not cmd_line:match "%s$") then
    local options = { "save", "load" }
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
  else
    Util.warn("layout: unknown subcommand '" .. subcmd .. "'")
  end
end, {
  nargs = "*",
  complete = completion,
})

return Layout
