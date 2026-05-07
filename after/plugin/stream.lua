local STREAM_PATH = vim.fs.normalize(vim.fn.expand(vim.g.stream_path or "~/workspace/garden/content/stream.md"))
local DEFAULT_STREAM_TAGS = { "life" }
local STREAM_ENTRY_FLAGS = { private = true, draft = true, protected = true }
local STREAM_ENTRY_FLAG_ORDER = { "private", "draft", "protected" }

local function is_stream(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then return false end
  local real = vim.uv.fs_realpath(name) or name
  return vim.fs.normalize(real) == STREAM_PATH
end

local stream_group = augroup "stream_meta"

local function frontmatter_end(lines)
  if not lines[1] or not lines[1]:match "^%-%-%-%s*$" then return 0 end
  for i = 2, #lines do
    if lines[i]:match "^%-%-%-%s*$" then return i end
  end
  return 0
end

---@param lines string[]
---@param start_idx integer 1-based inclusive start index to begin scanning sections
---@return { start: integer, stop: integer }[]
local function collect_sections(lines, start_idx)
  local sections = {}
  local idx = math.max(start_idx, 1)
  local total = #lines

  while idx <= total do
    while idx <= total and (lines[idx]:match "^%s*$" or lines[idx]:match "^%-%-%-%s*$") do
      idx = idx + 1
    end
    if idx > total then break end

    local section_start = idx
    local stop = total
    for j = idx, total do
      if lines[j]:match "^%-%-%-%s*$" then
        stop = j - 1
        break
      end
    end
    if stop >= section_start then table.insert(sections, { start = section_start, stop = stop }) end

    idx = (stop >= total) and (total + 1) or (stop + 2)
  end

  return sections
end

local function current_datetime()
  local now = os.time()
  local local_t = os.date("*t", now)
  local tz = os.date("%z", now) or "+0000"
  local sign = tz:sub(1, 1)
  local hours = tz:sub(2, 3)
  local minutes = tz:sub(4, 5)
  local offset = string.format("GMT%s%s:%s", sign, hours, minutes)
  return string.format(
    "%04d-%02d-%02d %02d:%02d:%02d %s",
    local_t.year,
    local_t.month,
    local_t.day,
    local_t.hour,
    local_t.min,
    local_t.sec,
    offset
  )
end

local function build_meta_lines(datetime, next_line, meta)
  meta = meta or {}
  local tags = meta.tags or DEFAULT_STREAM_TAGS
  local flags = meta.flags or {}

  local lines = {
    "- [meta]:",
    "  - date: " .. datetime,
    "  - tags:",
  }
  for _, tag in ipairs(tags) do
    table.insert(lines, "    - " .. tag)
  end
  for _, flag in ipairs(STREAM_ENTRY_FLAG_ORDER) do
    if flags[flag] then table.insert(lines, "  - " .. flag .. ": true") end
  end
  if next_line and next_line:match "^%s*$" then return lines end
  table.insert(lines, "")
  return lines
end

local function is_meta_line(line) return line and line:match "^%s*%- %[[Mm]eta%]%s*:" ~= nil end

local function ensure_stream_meta(bufnr, initial_tick)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  if vim.api.nvim_buf_get_changedtick(bufnr) ~= initial_tick then return end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #lines == 0 then return end

  local fm_end = frontmatter_end(lines)
  local sections = collect_sections(lines, (fm_end > 0) and (fm_end + 1) or 1)
  if #sections == 0 then return end

  local modifications = {}

  for _, section in ipairs(sections) do
    local heading_idx
    local first_line = lines[section.start]
    if first_line and first_line:match "^%s*#+%s+" then heading_idx = section.start end

    local insert_idx = heading_idx and (heading_idx + 1) or section.start
    if insert_idx > section.stop + 1 then insert_idx = section.stop + 1 end

    local check_idx = insert_idx
    while check_idx <= section.stop and lines[check_idx]:match "^%s*$" do
      check_idx = check_idx + 1
    end

    local meta_at_top = check_idx <= section.stop and is_meta_line(lines[check_idx])
    if meta_at_top then goto continue end

    local existing_elsewhere = false
    for idx = check_idx, section.stop do
      if is_meta_line(lines[idx]) then
        existing_elsewhere = true
        break
      end
    end
    if existing_elsewhere then goto continue end

    local next_line = lines[insert_idx]
    local meta_lines = build_meta_lines(current_datetime(), next_line)
    table.insert(modifications, {
      row = insert_idx - 1,
      lines = meta_lines,
    })

    ::continue::
  end

  if #modifications == 0 then return end

  table.sort(modifications, function(a, b) return a.row > b.row end)

  for _, mod in ipairs(modifications) do
    vim.api.nvim_buf_set_lines(bufnr, mod.row, mod.row, false, mod.lines)
  end

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    if vim.bo[bufnr].modified then
      vim.api.nvim_buf_call(bufnr, function() vim.cmd "silent! keepjumps noautocmd write" end)
    end
  end)
end

local function is_stream_identifier(value) return value:match "^[a-z][a-z0-9-]*$" ~= nil end

local function parse_stream_tags(value)
  local tags = {}

  for raw_tag in value:gmatch "[^,]+" do
    local tag = vim.trim(raw_tag):lower()
    if tag ~= "" then
      if not is_stream_identifier(tag) then return nil, ("invalid stream tag `%s`"):format(vim.trim(raw_tag)) end
      table.insert(tags, tag)
    end
  end

  if #tags == 0 then return nil, "Sadd tag= needs at least one tag" end
  return tags
end

local function parse_stream_bool(value)
  if value == nil or value == "" then return true end

  local normalized = value:lower()
  if normalized == "true" or normalized == "1" or normalized == "yes" or normalized == "on" then return true end
  if normalized == "false" or normalized == "0" or normalized == "no" or normalized == "off" then return false end

  return nil
end

local function parse_stream_entry_args(args)
  local parsed = {
    tags = DEFAULT_STREAM_TAGS,
    flags = {},
  }

  for _, arg in ipairs(args) do
    local key, value = arg:match "^([%w_-]+)=(.*)$"
    if key then
      key = key:lower()
      if key == "tag" or key == "tags" then
        local tags, err = parse_stream_tags(value)
        if not tags then return nil, err end
        parsed.tags = tags
      elseif STREAM_ENTRY_FLAGS[key] then
        local flag_value = parse_stream_bool(value)
        if flag_value == nil then return nil, ("Sadd %s= expects true or false"):format(key) end
        parsed.flags[key] = flag_value or nil
      else
        return nil, ("unknown Sadd option `%s`"):format(key)
      end
    else
      local flag = arg:lower()
      if not STREAM_ENTRY_FLAGS[flag] then return nil, ("unknown Sadd option `%s`"):format(arg) end
      parsed.flags[flag] = true
    end
  end

  return parsed
end

local function build_stream_entry_lines(entry)
  local lines = {
    "## untitled",
    "",
  }
  vim.list_extend(lines, build_meta_lines(current_datetime(), "", entry))
  table.insert(lines, "")
  local body_line = #lines
  table.insert(lines, "---")
  table.insert(lines, "")
  return lines, body_line
end

local function edit_stream_buffer()
  if is_stream(0) then return vim.api.nvim_get_current_buf() end

  local ok, err = pcall(vim.cmd, "keepalt edit " .. vim.fn.fnameescape(STREAM_PATH))
  if not ok then
    vim.notify(("Sadd could not open %s: %s"):format(STREAM_PATH, err), vim.log.levels.ERROR)
    return nil
  end

  return vim.api.nvim_get_current_buf()
end

local function stream_insert_row(lines)
  local fm_end = frontmatter_end(lines)
  local sections = collect_sections(lines, (fm_end > 0) and (fm_end + 1) or 1)
  if sections[1] then return sections[1].start - 1 end
  return #lines
end

local function add_stream_entry(opts)
  local entry, err = parse_stream_entry_args(opts.fargs)
  if not entry then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  local bufnr = edit_stream_buffer()
  if not bufnr then return end
  if vim.bo[bufnr].buftype ~= "" then return end
  if not vim.bo[bufnr].modifiable then
    vim.notify("Sadd stream buffer is not modifiable", vim.log.levels.ERROR)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local row = stream_insert_row(lines)
  local entry_lines, body_line = build_stream_entry_lines(entry)
  local previous_line = lines[row]
  if previous_line and not previous_line:match "^%s*$" then
    table.insert(entry_lines, 1, "")
    body_line = body_line + 1
  end

  vim.api.nvim_buf_set_lines(bufnr, row, row, false, entry_lines)

  vim.api.nvim_win_set_cursor(0, { row + body_line, 0 })
  vim.cmd "startinsert"
end

local function complete_stream_entry_args(arg_lead)
  local completions = { "tag=", "tags=", "private", "private=true", "draft=true", "protected=true" }
  local matches = {}

  for _, completion in ipairs(completions) do
    if completion:sub(1, #arg_lead) == arg_lead then table.insert(matches, completion) end
  end

  return matches
end

vim.api.nvim_create_user_command("Sadd", add_stream_entry, {
  nargs = "*",
  complete = complete_stream_entry_args,
  desc = "stream: add a new stream entry",
})

local pending_stream = {}

vim.api.nvim_create_autocmd("BufWritePost", {
  group = stream_group,
  pattern = "*.md",
  callback = function(ev)
    if not is_stream(ev.buf) then return end
    if vim.bo[ev.buf].buftype ~= "" then return end
    if not vim.bo[ev.buf].modifiable then return end

    if pending_stream[ev.buf] then
      pending_stream[ev.buf]:stop()
      pending_stream[ev.buf] = nil
    end

    local tick = vim.api.nvim_buf_get_changedtick(ev.buf)
    pending_stream[ev.buf] = vim.defer_fn(function()
      pending_stream[ev.buf] = nil
      ensure_stream_meta(ev.buf, tick)
    end, 50)
  end,
})
