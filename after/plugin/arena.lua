local disabled_completion = {}

function disabled_completion.new() return setmetatable({}, { __index = disabled_completion }) end

function disabled_completion:enabled() return false end

function disabled_completion:get_completions(_, callback)
  callback { is_incomplete_forward = false, is_incomplete_backward = false, items = {} }
end

package.preload["arena.completion"] = function() return disabled_completion end

local function normalize_path(path)
  local expanded = vim.fn.expand(path)
  return vim.fs.normalize(vim.uv.fs_realpath(expanded) or expanded)
end

local ts_query
local ts_query_warned = false

local function arena_query()
  if ts_query then return ts_query end

  local ok, query = pcall(
    vim.treesitter.query.parse,
    "markdown",
    [[
  (list_item) @item
]]
  )
  if ok then
    ts_query = query
    return ts_query
  end

  if not ts_query_warned then
    ts_query_warned = true
    vim.schedule(function() vim.notify("arena-meta: markdown Treesitter parser unavailable", vim.log.levels.WARN) end)
  end
end

local arena_group = augroup "arena_meta"
local ARENA_PATH = normalize_path(vim.g.arena_path or "~/workspace/garden/content/are.na.md")
local ARENA_META_FIELD_ORDER = {
  "date",
  "tags",
  "pinned",
  "later",
  "socials",
  "view",
  "layout",
  "json",
  "sidebar",
  "coord",
  "importance",
  "accessed",
  "accessed_date",
  "source",
  "title",
}
local METADATA_PARENT_LOOKBACK = 1024

local function is_target(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then return false end
  return normalize_path(name) == ARENA_PATH
end

local function frontmatter_end(lines)
  if not lines[1] or not lines[1]:match "^%-%-%-%s*$" then return -1 end
  for i = 2, #lines do
    if lines[i]:match "^%-%-%-%s*$" then return i - 1 end -- zero-based
  end
  return -1
end

local function current_date() return os.date "%m/%d/%Y" end

local function leading_spaces(line) return #(line:match "^(%s*)" or "") end

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
  if fm_end < 1 then return keys end

  for idx = 1, fm_end do
    local key_rule = lines[idx]:match "^%s*key%s*=%s*(.+)"
    if key_rule then
      for key in key_rule:gmatch '"([a-z][a-z0-9_-]*)"' do
        keys[key] = true
      end
    end
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
  for _, key in ipairs(ARENA_META_FIELD_ORDER) do
    present[key] = true
  end

  local keys = {}
  local used = {}
  for _, key in ipairs(ARENA_META_FIELD_ORDER) do
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

  if key == "date" or key == "accessed" or key == "accessed_date" then
    return prefix .. key .. ": " .. current_date()
  end
  if key == "tags" then return prefix .. "tags: [${1}]" end
  if key == "socials" then return prefix .. "socials:\n" .. child_indent .. "- ${1:site}: ${2:url}" end
  if key == "pinned" or key == "later" or key == "json" or key == "sidebar" then return prefix .. key .. ": true" end
  if key == "view" or key == "layout" then return prefix .. key .. ": ${1:list}" end
  if key == "coord" then return prefix .. "coord: [${1:lat}, ${2:lng}]" end
  if key == "importance" then return prefix .. "importance: ${1:5}" end

  return prefix .. key .. ": "
end

local function arena_meta_context(ctx)
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

  local _, parent_indent = metadata_parent(ctx.bufnr, line_idx, #indent)
  if not parent_indent then return nil end

  return {
    indent = indent,
    include_bullet = include_bullet,
    replace_start = replace_start,
    replace_end = cursor_col,
    detail = parent_indent == 0 and "arena channel metadata" or "arena block metadata",
  }
end

local arena_completion = {}

function arena_completion.new() return setmetatable({ meta_key_cache = nil }, { __index = arena_completion }) end

function arena_completion:enabled() return is_target(vim.api.nvim_get_current_buf()) end

function arena_completion:get_trigger_characters() return { "-", " " } end

local function completion_response(keys, meta_context, cursor)
  local kind = require("blink.cmp.types").CompletionItemKind.Property
  local items = {}

  for idx, key in ipairs(keys) do
    table.insert(items, {
      label = key .. ":",
      kind = kind,
      filterText = key,
      sortText = ("%03d_%s"):format(idx, key),
      detail = meta_context.detail,
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

function arena_completion:get_completions(ctx, callback)
  local empty = { is_incomplete_forward = false, is_incomplete_backward = false, items = {} }
  if not is_target(ctx.bufnr) then
    callback(empty)
    return
  end

  local meta_context = arena_meta_context(ctx)
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

package.preload["arena.completion"] = function() return arena_completion end

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
  local first = vim.split(text, "\n", { plain = true, trimempty = true })[1] or ""
  first = vim.trim(first)
  if first:sub(1, 1) == "\\" then first = first:sub(2) end
  return first
end

local function analyze_children(bufnr, node)
  local child_list = nil
  local first_child_row = nil
  local has_meta = false

  for child in node:iter_children() do
    if child:type() == "list" then
      child_list = child
      for sub in child:iter_children() do
        if sub:type() == "list_item" then
          first_child_row = first_child_row or select(1, sub:start())
          local text = first_line_text(bufnr, sub):lower()
          if text:match "^%[meta%]%s*:%s*" or text:match "^%[meta%]%s*$" then
            has_meta = true
            break
          end
        end
      end
      if has_meta then break end
    end
  end

  return has_meta, child_list, first_child_row
end

local function build_insert_lines(indent, date)
  local child_indent = indent .. "  "
  local date_indent = child_indent .. "  "
  return {
    child_indent .. "- [meta]:",
    date_indent .. "- date: " .. date,
    date_indent .. "- tags: []",
  }
end

local function ensure_arena_meta(bufnr, initial_tick, auto_save)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  if vim.api.nvim_buf_get_changedtick(bufnr) ~= initial_tick then return end

  local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown", {})
  if not parser_ok or not parser then return end

  local tree = parser:parse()[1]
  if not tree then return end
  local query = arena_query()
  if not query then return end

  local root = tree:root()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local fm_end = frontmatter_end(lines)
  local date = current_date()
  local modifications = {}

  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    if query.captures[id] ~= "item" then goto continue end
    local sr, sc = node:start()
    if sr <= fm_end then goto continue end

    local parent = node:parent()
    if not parent or parent:type() ~= "list" then goto continue end
    local scope = parent:parent()
    while scope and scope:type() == "block_quote" do
      scope = scope:parent()
    end
    if scope and scope:type() == "list_item" then goto continue end

    local text = first_line_text(bufnr, node)
    if text == "" then goto continue end
    local normalized = text:lower()
    if normalized:sub(1, 1) == "\\" then normalized = normalized:sub(2) end
    if normalized:match "^%[meta%]%s*:%s*" or normalized:match "^date:%s*" then goto continue end

    local has_meta, child_list, first_child_row = analyze_children(bufnr, node)
    if has_meta then goto continue end

    local base_indent = string.rep(" ", sc)
    local insert_row
    if child_list then
      local list_row = child_list:start()
      insert_row = first_child_row or list_row
    else
      local end_row = node:end_()
      insert_row = end_row
    end

    if insert_row then table.insert(modifications, {
      row = insert_row,
      indent = base_indent,
    }) end

    ::continue::
  end

  if #modifications == 0 then return end

  table.sort(modifications, function(a, b) return a.row > b.row end)

  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor[1] - 1

  for _, mod in ipairs(modifications) do
    local lines_to_insert = build_insert_lines(mod.indent, date)
    local existing = vim.api.nvim_buf_get_lines(bufnr, mod.row, mod.row + 1, false)[1]
    if existing and existing:match "^%s*$" then vim.api.nvim_buf_set_lines(bufnr, mod.row, mod.row + 1, false, {}) end
    vim.api.nvim_buf_set_lines(bufnr, mod.row, mod.row, false, lines_to_insert)
    if mod.row <= cursor_row then cursor_row = cursor_row + #lines_to_insert end
  end

  pcall(vim.api.nvim_win_set_cursor, 0, { cursor_row + 1, cursor[2] })

  if auto_save then
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
      if vim.bo[bufnr].modified then
        vim.api.nvim_buf_call(bufnr, function() vim.cmd "silent! keepjumps noautocmd write" end)
      end
    end)
  end
end

local pending_arena = {}

local function schedule_arena_meta(bufnr, auto_save, delay)
  if pending_arena[bufnr] then
    pending_arena[bufnr]:stop()
    pending_arena[bufnr] = nil
  end

  local tick = vim.api.nvim_buf_get_changedtick(bufnr)
  pending_arena[bufnr] = vim.defer_fn(function()
    pending_arena[bufnr] = nil
    ensure_arena_meta(bufnr, tick, auto_save)
  end, delay)
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = arena_group,
  pattern = "*.md",
  callback = function(ev)
    if not is_target(ev.buf) then return end
    if vim.bo[ev.buf].buftype ~= "" then return end
    if not vim.bo[ev.buf].modifiable then return end
    schedule_arena_meta(ev.buf, true, 50)
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = arena_group,
  pattern = "*.md",
  callback = function(ev)
    if not is_target(ev.buf) then return end
    if vim.bo[ev.buf].buftype ~= "" then return end
    if not vim.bo[ev.buf].modifiable then return end
    schedule_arena_meta(ev.buf, false, 100)
  end,
})
