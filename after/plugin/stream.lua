local STREAM_PATH = vim.fs.normalize(vim.fn.expand "~/workspace/garden/content/stream.md")

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

local function build_meta_lines(datetime, next_line)
  local meta = {
    "- [meta]:",
    "  - date: " .. datetime,
    "  - tags:",
    "    - life",
  }
  if next_line and next_line:match "^%s*$" then return meta end
  table.insert(meta, "")
  return meta
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
