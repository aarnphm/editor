local ok, TS_QUERY = pcall(
  vim.treesitter.query.parse,
  "markdown",
  [[
  (list_item) @item
]]
)
if not ok then
  vim.schedule(function() vim.notify("arena-meta: markdown Treesitter parser unavailable", vim.log.levels.WARN) end)
  return
end

local arena_group = augroup "arena_meta"

local TARGETS = (function()
  local roots = {}
  local main = vim.fs.normalize(vim.fn.expand "~/workspace/garden/content/are.na.md")
  local legacy = vim.fs.normalize(vim.fn.expand "~/workspace/garden/content/are.na")
  roots[main] = true
  roots[legacy] = true
  return roots
end)()

local function is_target(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then return false end
  local real = vim.uv.fs_realpath(name) or name
  real = vim.fs.normalize(real)
  return TARGETS[real] or false
end

local function frontmatter_end(lines)
  if not lines[1] or not lines[1]:match "^%-%-%-%s*$" then return -1 end
  for i = 2, #lines do
    if lines[i]:match "^%-%-%-%s*$" then return i - 1 end -- zero-based
  end
  return -1
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
          if text:match "^_meta:%s*" or text:match "^_meta%s*$" then
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
    child_indent .. "- \\_meta:",
    date_indent .. "- date: " .. date,
  }
end

local function ensure_arena_meta(bufnr, initial_tick)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  if vim.api.nvim_buf_get_changedtick(bufnr) ~= initial_tick then return end

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown", {})
  if not ok or not parser then return end

  local tree = parser:parse()[1]
  if not tree then return end
  local root = tree:root()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local fm_end = frontmatter_end(lines)
  local date = os.date "%m/%d/%Y"
  local modifications = {}

  for id, node in TS_QUERY:iter_captures(root, bufnr, 0, -1) do
    if TS_QUERY.captures[id] ~= "item" then goto continue end
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
    if normalized:match "^_meta:%s*" or normalized:match "^date:%s*" then goto continue end

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

  for _, mod in ipairs(modifications) do
    local lines_to_insert = build_insert_lines(mod.indent, date)
    local existing = vim.api.nvim_buf_get_lines(bufnr, mod.row, mod.row + 1, false)[1]
    if existing and existing:match "^%s*$" then vim.api.nvim_buf_set_lines(bufnr, mod.row, mod.row + 1, false, {}) end
    vim.api.nvim_buf_set_lines(bufnr, mod.row, mod.row, false, lines_to_insert)
  end

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    if vim.bo[bufnr].modified then
      vim.api.nvim_buf_call(bufnr, function() vim.cmd "silent! keepjumps noautocmd write" end)
    end
  end)
end

vim.api.nvim_create_autocmd("BufWritePost", {
  group = arena_group,
  pattern = "*.md",
  callback = function(ev)
    if not is_target(ev.buf) then return end
    if vim.bo[ev.buf].buftype ~= "" then return end
    if not vim.bo[ev.buf].modifiable then return end
    local tick = vim.api.nvim_buf_get_changedtick(ev.buf)
    vim.schedule(function() ensure_arena_meta(ev.buf, tick) end)
  end,
})
