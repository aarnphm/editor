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
local TRAINING_LOG_TAGS = { "life", "o/training" }

local stream_meta_query

local function get_stream_meta_query()
  if stream_meta_query then return stream_meta_query end

  local ok, query = pcall(
    vim.treesitter.query.parse,
    "markdown",
    [[
  (section
    (list
      (list_item) @meta))
]]
  )
  if not ok then return nil end

  stream_meta_query = query
  return stream_meta_query
end

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
  if meta.description then table.insert(lines, "  - description: " .. meta.description) end
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

local function tokenize_stream_entry_args(raw_args)
  local args = {}
  local token = {}
  local token_started = false
  local quoted = false
  local escaped = false

  local function push_token()
    if not token_started then return end
    table.insert(args, table.concat(token))
    token = {}
    token_started = false
  end

  for idx = 1, #raw_args do
    local char = raw_args:sub(idx, idx)
    if escaped then
      table.insert(token, char)
      token_started = true
      escaped = false
    elseif char == "\\" then
      escaped = true
      token_started = true
    elseif char == '"' then
      quoted = not quoted
      token_started = true
    elseif char:match "%s" and not quoted then
      push_token()
    else
      table.insert(token, char)
      token_started = true
    end
  end

  if escaped then table.insert(token, "\\") end
  if quoted then return nil, "has an unterminated double-quoted value" end

  push_token()
  return args
end

local function parse_stream_entry_args(raw_args)
  local args, tokenize_err = tokenize_stream_entry_args(raw_args)
  if not args then return nil, "Sadd " .. tokenize_err end

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
      elseif key == "description" then
        if value == "" then return nil, "Sadd description= needs text" end
        parsed.description = value
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

local function primary_paragraph(node)
  for child in node:iter_children() do
    local type = child:type()
    if type == "paragraph" then return child end
    if
      type ~= "list_marker_minus"
      and type ~= "list_marker_plus"
      and type ~= "list_marker_star"
      and type ~= "block_continuation"
    then
      break
    end
  end
end

local function first_line_text(bufnr, node)
  local paragraph = primary_paragraph(node)
  if not paragraph then return "" end

  local text = vim.treesitter.get_node_text(paragraph, bufnr)
  if not text then return "" end

  return vim.trim(vim.split(text, "\n", { plain = true, trimempty = true })[1] or "")
end

local function child_list(node)
  for child in node:iter_children() do
    if child:type() == "list" then return child end
  end
end

local function parse_meta_node(bufnr, node)
  if not first_line_text(bufnr, node):lower():match "^%[meta%]%s*:%s*$" then return nil end

  local fields = child_list(node)
  if not fields then return nil end

  local meta = { tags = {} }
  for field in fields:iter_children() do
    if field:type() ~= "list_item" then goto continue end

    local key, value = first_line_text(bufnr, field):match "^([%w_-]+):%s*(.*)$"
    key = key and key:lower() or nil
    if key == "tags" then
      local tags = child_list(field)
      if tags then
        for tag_node in tags:iter_children() do
          if tag_node:type() == "list_item" then
            local tag = first_line_text(bufnr, tag_node):lower()
            if tag ~= "" then meta.tags[tag] = true end
          end
        end
      end
    elseif key == "description" then
      meta.description = value
    end

    ::continue::
  end

  return meta
end

local function next_training_log_description(bufnr)
  local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown", {})
  if not parser_ok or not parser then return nil, "Strain requires the Markdown Treesitter parser" end

  local parse_ok, trees = pcall(function() return parser:parse() end)
  local tree = parse_ok and trees and trees[1] or nil
  if not tree then return nil, "Strain could not parse the stream buffer" end

  local query = get_stream_meta_query()
  if not query then return nil, "Strain could not compile its Markdown Treesitter query" end

  for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    if query.captures[id] ~= "meta" then goto continue end

    local meta = parse_meta_node(bufnr, node)
    if meta and meta.tags[TRAINING_LOG_TAGS[1]] and meta.tags[TRAINING_LOG_TAGS[2]] and meta.description then
      local digits = meta.description:lower():match "training%s+log%s+(%d+)"
      local number = digits and tonumber(digits) or nil
      if number then
        local next_number = tostring(number + 1)
        local width = math.max(#digits, #next_number)
        return ("training log %0" .. width .. "d"):format(number + 1)
      end
    end

    ::continue::
  end

  return nil, "Strain could not find a numbered training log tagged life and o/training"
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
    Util.error(("could not open stream %s: %s"):format(STREAM_PATH, err), { title = "stream" })
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

local function insert_stream_entry(entry, bufnr)
  bufnr = bufnr or edit_stream_buffer()
  if not bufnr then return end
  if vim.bo[bufnr].buftype ~= "" then return end
  if not vim.bo[bufnr].modifiable then
    Util.error("stream buffer is not modifiable", { title = "stream" })
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

local function add_stream_entry(opts)
  local entry, err = parse_stream_entry_args(opts.args)
  if not entry then
    Util.error(err, { title = "stream" })
    return
  end

  insert_stream_entry(entry)
end

local function add_strain_entry(opts)
  local title, title_err = tokenize_stream_entry_args(opts.args)
  if not title then
    Util.error("Strain " .. title_err, { title = "stream" })
    return
  end

  local title_text = vim.trim(table.concat(title, " "))
  if title_text == "" then
    Util.error("Strain needs a title", { title = "stream" })
    return
  end

  local bufnr = edit_stream_buffer()
  if not bufnr then return end

  local description, description_err = next_training_log_description(bufnr)
  if not description then
    Util.error(description_err, { title = "stream" })
    return
  end

  insert_stream_entry({
    title = title_text,
    tags = vim.deepcopy(TRAINING_LOG_TAGS),
    flags = {},
    description = description,
  }, bufnr)
end

local function complete_stream_entry_args(arg_lead)
  local completions = {
    "tag=",
    "tags=",
    'description="',
    "private",
    "private=true",
    "draft=true",
    "protected=true",
  }
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

vim.api.nvim_create_user_command("Strain", add_strain_entry, {
  nargs = "+",
  desc = "stream: add the next numbered training log",
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
