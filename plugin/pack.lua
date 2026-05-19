if not vim.pack then return end

local function pack_get()
  local ok, plugins = pcall(vim.pack.get, nil, { info = false })
  if not ok then
    vim.notify("vim.pack.get failed: " .. plugins, vim.log.levels.ERROR, { title = "vim.pack" })
    return {}
  end
  return plugins
end

local function complete_pack_names(arg_lead)
  local matches = {}
  for _, plugin in ipairs(pack_get()) do
    local name = plugin.spec and plugin.spec.name
    if name and name:sub(1, #arg_lead) == arg_lead then table.insert(matches, name) end
  end
  table.sort(matches)
  return matches
end

local profile_buf
local source_stack = {}
local source_events = {}
local source_event_id = 0
local source_group = augroup "pack_profile_source"

local function ms(value) return ("%8.2f"):format(value or 0) end

local function now() return vim.uv.hrtime() / 1000000 end

local function source_info(path)
  if not path or path == "" then return nil end
  path = Util.norm(vim.fn.fnamemodify(path, ":p"))
  local config = Util.norm(vim.fn.stdpath "config")
  local config_prefix = config .. "/"
  if path:sub(1, #config_prefix) == config_prefix then
    local rel = path:sub(#config_prefix + 1)
    if rel:match "^after/plugin/" or rel:match "^plugin/" then return rel, "config" end
  end

  local plugin, rel = path:match "/site/pack/[^/]+/opt/([^/]+)/(.+)$"
  if plugin and (rel:match "^plugin/" or rel:match "^after/plugin/" or rel:match "^colors/") then
    return ("%s/%s"):format(plugin, rel), "pack"
  end
end

local function record_source(event)
  local label, kind = source_info(event.path)
  if not label then return end

  source_event_id = source_event_id + 1
  event.id = source_event_id
  event.label = label
  event.kind = kind
  event.self_ms = math.max(event.elapsed_ms - event.child_ms, 0)
  source_events[#source_events + 1] = event
end

vim.api.nvim_create_autocmd("SourcePre", {
  group = source_group,
  callback = function(event)
    source_stack[#source_stack + 1] = {
      path = event.file,
      phase = vim.v.vim_did_enter == 0 and "startup" or "runtime",
      started_ms = now(),
      child_ms = 0,
    }
  end,
})

vim.api.nvim_create_autocmd("SourcePost", {
  group = source_group,
  callback = function(event)
    local source = table.remove(source_stack)
    if not source or source.path ~= event.file then return end

    source.elapsed_ms = now() - source.started_ms
    local parent = source_stack[#source_stack]
    if parent then parent.child_ms = parent.child_ms + source.elapsed_ms end
    record_source(source)
  end,
})

local function profile_summary(events)
  local total_ms = 0
  local self_ms = 0
  for _, event in ipairs(events) do
    total_ms = total_ms + (event.elapsed_ms or 0)
    self_ms = self_ms + (event.self_ms or event.elapsed_ms or 0)
  end
  return total_ms, self_ms
end

local function profile_source_events(opts)
  local events = {}
  for _, event in ipairs(source_events) do
    if opts.bang or event.phase == "startup" then events[#events + 1] = vim.deepcopy(event) end
  end
  return events
end

local function sort_by_self(events, name)
  table.sort(events, function(a, b)
    local a_time = a.self_ms or a.elapsed_ms or 0
    local b_time = b.self_ms or b.elapsed_ms or 0
    if a_time == b_time then return (a[name] or "") < (b[name] or "") end
    return a_time > b_time
  end)
end

local function profile_lines(opts)
  if not (Util.pack and Util.pack.profile) then return { "PackProfile unavailable" } end

  local events = Util.pack.profile { all = opts.bang }
  local sources = profile_source_events(opts)
  sort_by_self(events, "name")
  sort_by_self(sources, "label")

  local total_ms, self_ms = profile_summary(events)
  local source_total_ms, source_self_ms = profile_summary(sources)
  local scope = opts.bang and "all loads" or "startup loads"
  local lines = {
    ("vim.pack profile (%s)"):format(scope),
    ("loads: %d plugins, %.2fms self, %.2fms total"):format(#events, self_ms, total_ms),
    ("sources: %d scripts, %.2fms self, %.2fms total"):format(#sources, source_self_ms, source_total_ms),
    "",
    "plugin loads",
    ("%-30s %8s %8s %8s %8s  %s"):format("plugin", "total", "self", "packadd", "config", "phase"),
  }

  for _, event in ipairs(events) do
    local name = event.ok and event.name or (event.name .. " !")
    lines[#lines + 1] = ("%-30s %s %s %s %s  %s"):format(
      name,
      ms(event.elapsed_ms),
      ms(event.self_ms),
      ms(event.packadd_ms),
      ms(event.config_ms),
      event.phase
    )
    if event.error then lines[#lines + 1] = "  error: " .. tostring(event.error):gsub("\n.*", "") end
  end

  if #events == 0 then lines[#lines + 1] = "No plugin loads recorded yet." end

  lines[#lines + 1] = ""
  lines[#lines + 1] = opts.bang and "profiled sources" or "startup sources"
  lines[#lines + 1] = ("%-50s %8s %8s  %s"):format("script", "total", "self", "kind")
  for _, source in ipairs(sources) do
    lines[#lines + 1] = ("%-50s %s %s  %s"):format(
      source.label,
      ms(source.elapsed_ms),
      ms(source.self_ms),
      source.kind
    )
  end

  if #sources == 0 then lines[#lines + 1] = "No startup scripts recorded yet." end
  return lines
end

local function set_profile_lines(buf, lines)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function show_profile(opts)
  if profile_buf and vim.api.nvim_buf_is_valid(profile_buf) then
    local win = vim.fn.bufwinid(profile_buf)
    if win == -1 then
      vim.cmd "botright 16split"
      vim.api.nvim_win_set_buf(0, profile_buf)
    else
      vim.api.nvim_set_current_win(win)
    end
  else
    vim.cmd "botright 16new"
    profile_buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(profile_buf, "vim.pack://profile")
    vim.bo[profile_buf].buftype = "nofile"
    vim.bo[profile_buf].bufhidden = "wipe"
    vim.bo[profile_buf].swapfile = false
    vim.bo[profile_buf].filetype = "startuptime"
  end

  set_profile_lines(profile_buf, profile_lines(opts))
end

vim.api.nvim_create_user_command("PackStatus", function()
  local lines = {}
  for _, plugin in ipairs(pack_get()) do
    local marker = plugin.active and "*" or " "
    local spec = plugin.spec or {}
    local rev = plugin.rev and plugin.rev:sub(1, 8) or "unlocked"
    table.insert(lines, ("%s %-30s %-10s %s"):format(marker, spec.name or "?", rev, spec.src or ""))
  end

  if #lines == 0 then
    vim.notify("No vim.pack plugins are registered", vim.log.levels.INFO, { title = "vim.pack" })
    return
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "vim.pack" })
end, { desc = "vim.pack: show managed plugins" })

vim.api.nvim_create_user_command("PackUpdate", function(opts)
  if Util.pack and Util.pack.begin_maintenance then Util.pack.begin_maintenance() end
  local names = #opts.fargs > 0 and opts.fargs or nil
  vim.pack.update(names, {
    force = opts.bang,
    target = "version",
  })
end, {
  bang = true,
  nargs = "*",
  complete = complete_pack_names,
  desc = "vim.pack: update plugins",
})

vim.api.nvim_create_user_command("PackBuild", function(opts)
  if not (Util.pack and Util.pack.build) then
    vim.notify("PackBuild unavailable", vim.log.levels.ERROR, { title = "vim.pack" })
    return
  end

  local names = #opts.fargs > 0 and opts.fargs or nil
  local built = Util.pack.build(names)
  if #built == 0 then
    vim.notify("No build hooks matched", vim.log.levels.INFO, { title = "vim.pack" })
    return
  end
  vim.notify("Built: " .. table.concat(built, ", "), vim.log.levels.INFO, { title = "vim.pack" })
end, {
  nargs = "*",
  complete = complete_pack_names,
  desc = "vim.pack: run plugin build hooks",
})

vim.api.nvim_create_user_command("PackProfile", function(opts) show_profile(opts) end, {
  bang = true,
  desc = "vim.pack: show plugin load profile",
})
