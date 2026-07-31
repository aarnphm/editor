local function normalize_path(path)
  local expanded = vim.fn.expand(path)
  return vim.fs.normalize(vim.uv.fs_realpath(expanded) or expanded)
end

local STREAM_PATH = normalize_path(vim.g.stream_path or "~/workspace/garden/content/stream.md")
local DEFAULT_STREAM_TAGS = { "life" }
local STREAM_ENTRY_FLAGS = { private = true, draft = true, protected = true }
local STREAM_ENTRY_FLAG_ORDER = { "private", "draft", "protected" }
local STREAM_META_FIELD_ORDER = {
  "date",
  "tags",
  "socials",
  "description",
  "importance",
  "private",
  "draft",
  "protected",
}
local METADATA_PARENT_LOOKBACK = 1024

local function is_stream(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then return false end
  return normalize_path(name) == STREAM_PATH
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

local function leading_spaces(line) return #(line:match "^(%s*)" or "") end

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

local function metadata_parent(bufnr, line_idx, indent)
  local start = math.max(line_idx - METADATA_PARENT_LOOKBACK, 1)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start - 1, line_idx - 1, false)

  for offset = #lines, 1, -1 do
    local line = lines[offset]
    if not line:match "^%s*$" then
      local parent_indent = leading_spaces(line)
      if parent_indent < indent and line:match "^%s*%- " then
        if is_meta_line(line) then return start + offset - 1, parent_indent end
        return nil
      end
    end
  end

  return nil
end

local function collect_ebnf_meta_keys(lines)
  local keys = {}
  local fm_end = frontmatter_end(lines)
  if fm_end == 0 then return keys end

  for idx = 1, fm_end do
    local key = lines[idx]:match '"%- ([a-z][a-z0-9_-]*):"'
    if key then keys[key] = true end
  end

  return keys
end

local function collect_seen_meta_keys(lines)
  local keys = {}
  local stack = {}

  for _, line in ipairs(lines) do
    if line:match "^%s*$" then goto continue end

    local indent = leading_spaces(line)
    while #stack > 0 and stack[#stack].indent >= indent do
      table.remove(stack)
    end

    local key = line:match "^%s*%- ([a-z][a-z0-9_-]*):"
    local parent = stack[#stack]
    if key and parent and is_meta_line(parent.line) then keys[key] = true end

    if line:match "^%s*%- " then table.insert(stack, {
      indent = indent,
      line = line,
    }) end

    ::continue::
  end

  return keys
end

local function ordered_meta_keys(lines)
  local present = collect_ebnf_meta_keys(lines)
  for key in pairs(collect_seen_meta_keys(lines)) do
    present[key] = true
  end
  for _, key in ipairs(STREAM_META_FIELD_ORDER) do
    present[key] = true
  end

  local keys = {}
  local used = {}
  for _, key in ipairs(STREAM_META_FIELD_ORDER) do
    if present[key] then
      table.insert(keys, key)
      used[key] = true
    end
  end

  local extras = vim.tbl_keys(present)
  table.sort(extras)
  for _, key in ipairs(extras) do
    if not used[key] then table.insert(keys, key) end
  end

  return keys
end

local function meta_completion_text(key, indent, include_bullet)
  local prefix = include_bullet and "- " or ""
  local child_indent = indent .. "  "

  if key == "date" then return prefix .. "date: " .. current_datetime() end
  if key == "tags" then return prefix .. "tags:\n" .. child_indent .. "- ${1:life}" end
  if key == "socials" then return prefix .. "socials:\n" .. child_indent .. "- ${1:site}:${2:handle}" end
  if STREAM_ENTRY_FLAGS[key] then return prefix .. key .. ": true" end

  return prefix .. key .. ": "
end

local function stream_meta_context(ctx)
  local cursor = ctx.cursor or vim.api.nvim_win_get_cursor(0)
  local line_idx = cursor[1]
  local line = ctx.line or vim.api.nvim_buf_get_lines(ctx.bufnr, line_idx - 1, line_idx, false)[1] or ""
  local cursor_col = cursor[2]
  local before = line:sub(1, cursor_col)
  local indent = before:match "^(%s*)"
  if not indent then return nil end

  local bullet_prefix = before:match "^(%s*)%- %s*[%w_-]*$"
  local replace_start
  local include_bullet

  if bullet_prefix then
    indent = bullet_prefix
    replace_start = #indent + 2
    include_bullet = false
  elseif before:match "^%s*[%w_-]*$" then
    replace_start = #indent
    include_bullet = true
  else
    return nil
  end

  local parent_idx, parent_indent = metadata_parent(ctx.bufnr, line_idx, #indent)
  if not parent_idx then return nil end

  return {
    indent = indent,
    include_bullet = include_bullet,
    replace_start = replace_start,
    replace_end = cursor_col,
    scope = parent_indent == 0 and "section" or "item",
  }
end

local stream_completion = {}

function stream_completion.new() return setmetatable({ meta_key_cache = nil }, { __index = stream_completion }) end

function stream_completion:enabled() return is_stream(vim.api.nvim_get_current_buf()) end

function stream_completion:get_trigger_characters() return { "-", " " } end

local function completion_response(keys, meta_context, cursor)
  local kind = require("blink.cmp.types").CompletionItemKind.Property
  local detail = meta_context.scope == "item" and "stream item metadata" or "stream section metadata"
  local items = {}

  for idx, key in ipairs(keys) do
    table.insert(items, {
      label = key .. ":",
      kind = kind,
      filterText = key,
      sortText = ("%03d_%s"):format(idx, key),
      detail = detail,
      insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
      textEdit = {
        newText = meta_completion_text(key, meta_context.indent, meta_context.include_bullet),
        range = {
          start = { line = cursor[1] - 1, character = meta_context.replace_start },
          ["end"] = { line = cursor[1] - 1, character = meta_context.replace_end },
        },
      },
    })
  end

  return {
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = items,
  }
end

function stream_completion:get_completions(ctx, callback)
  local empty = { is_incomplete_forward = false, is_incomplete_backward = false, items = {} }
  if not is_stream(ctx.bufnr) then
    callback(empty)
    return
  end

  local meta_context = stream_meta_context(ctx)
  if not meta_context then
    callback(empty)
    return
  end

  local tick = vim.api.nvim_buf_get_changedtick(ctx.bufnr)
  local cache = self.meta_key_cache
  if cache and cache.bufnr == ctx.bufnr and cache.tick == tick then
    callback(completion_response(cache.keys, meta_context, ctx.cursor))
    return
  end

  local cancelled = false
  vim.schedule(function()
    if cancelled or not vim.api.nvim_buf_is_valid(ctx.bufnr) then return end
    if vim.api.nvim_buf_get_changedtick(ctx.bufnr) ~= tick then return end

    local lines = vim.api.nvim_buf_get_lines(ctx.bufnr, 0, -1, false)
    local keys = ordered_meta_keys(lines)
    self.meta_key_cache = {
      bufnr = ctx.bufnr,
      tick = tick,
      keys = keys,
    }
    callback(completion_response(keys, meta_context, ctx.cursor))
  end)

  return function() cancelled = true end
end

package.preload["stream.completion"] = function() return stream_completion end

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

local function is_stream_tag(value)
  if value == "" or value:sub(1, 1) == "/" or value:sub(-1) == "/" or value:find("//", 1, true) then return false end

  for segment in value:gmatch "[^/]+" do
    if not segment:match "^[a-z][a-z0-9-]*$" then return false end
  end

  return true
end

local function parse_stream_tags(value)
  local tags = {}

  for raw_tag in value:gmatch "[^,]+" do
    local tag = vim.trim(raw_tag):lower()
    if tag ~= "" then
      if not is_stream_tag(tag) then return nil, ("invalid stream tag `%s`"):format(vim.trim(raw_tag)) end
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
  local title = {}

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
      if STREAM_ENTRY_FLAGS[flag] then
        parsed.flags[flag] = true
      else
        table.insert(title, arg)
      end
    end
  end

  parsed.title = table.concat(title, " ")
  return parsed
end

local function build_stream_entry_lines(entry)
  local lines = {
    "## " .. (entry.title ~= "" and entry.title or "untitled"),
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
    Util.error(("Sadd could not open %s: %s"):format(STREAM_PATH, err), { title = "stream" })
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
    Util.error(err, { title = "stream" })
    return
  end

  local bufnr = edit_stream_buffer()
  if not bufnr then return end
  if vim.bo[bufnr].buftype ~= "" then return end
  if not vim.bo[bufnr].modifiable then
    Util.error("Sadd stream buffer is not modifiable", { title = "stream" })
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
