---@return table<string,string>
local function load_latex_snippets()
  local path = vim.fn.stdpath "config" .. "/snippets/latex.json"
  local fd = io.open(path, "r")
  if not fd then return {} end
  local content = fd:read "*a"
  fd:close()
  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok or type(data) ~= "table" then return {} end
  local tbl = {}
  for _, item in pairs(data) do
    local prefixes = {}
    if type(item.prefix) == "table" then
      prefixes = item.prefix
    elseif type(item.prefix) == "string" then
      prefixes = { item.prefix }
    end
    local body
    if type(item.body) == "table" then
      body = table.concat(item.body, "\n")
    elseif type(item.body) == "string" then
      body = item.body
    end
    if body then
      for _, p in ipairs(prefixes) do
        tbl[p] = body
      end
    end
  end
  return tbl
end

local M = {}

---@type table<string, any>
M._snippets = nil

---@param trigger string
---@param body string
local function expand(trigger, body)
  -- Delete the trigger text before expanding.
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local bufnr = 0
  vim.api.nvim_buf_set_text(bufnr, row - 1, col - #trigger, row - 1, col, { "" })
  -- Move cursor to start of removed trigger
  vim.api.nvim_win_set_cursor(0, { row, col - #trigger })
  vim.snippet.expand(body)
end

vim.keymap.set("i", "<Tab>", function()
  if M._snippets == nil then M._snippets = load_latex_snippets() end

  -- inside snippets
  if vim.snippet.active { direction = 1 } then
    vim.schedule(function() vim.snippet.jump(1) end)
    return
  end

  -- not math, then returns per usual
  if Util.treesitter.not_math() then return "\t" end

  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col "." - 1
  local prefix = line:sub(1, col):match "(%w+)$"
  if prefix and M._snippets[prefix] then
    expand(prefix, M._snippets[prefix])
    return
  end
  return "\t"
end, { expr = true, silent = true, buffer = true, desc = "snippet: expand or indent" })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  if vim.snippet.active { direction = -1 } then
    vim.schedule(function() vim.snippet.jump(-1) end)
    return
  end
  return "<S-Tab>"
end, { expr = true, silent = true, buffer = true, desc = "snippet: jump backwards" })

vim.keymap.set("i", "<D-k>", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "[[]]" })
  vim.api.nvim_win_set_cursor(0, { row, col + 2 })
end, { buffer = true, desc = "wikilink: insert" })

local _md_heading_ns = vim.api.nvim_create_namespace "md_headings_popup"

local function _md_collect_headings()
  local buf = 0
  local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown", {})
  if not ok or not parser then return {} end
  local trees = parser:parse()
  if not trees or not trees[1] then return {} end
  local root = trees[1]:root()
  if not root then return {} end
  local query = vim.treesitter.query.parse(
    "markdown",
    [[
    (atx_heading) @h
    (setext_heading) @h
  ]]
  )
  ---@type {line: string, level: integer, text: string}[]
  local items = {}
  for _, node in query:iter_captures(root, buf, 0, -1) do
    local start_row, _, end_row, _ = node:range()
    local text = ""
    local level = 1
    if node:type() == "atx_heading" then
      local line = (vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1] or "")
      local hashes = line:match "^%s*(#+)"
      if hashes then level = #hashes end
      line = line:gsub("^%s*#+%s*", "")
      line = line:gsub("%s*#+%s*$", "")
      text = vim.trim(line)
    else
      local first = (vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1] or "")
      local underline = (vim.api.nvim_buf_get_lines(buf, end_row - 1, end_row, false)[1] or "")
      if underline:match "^%s*=+%s*$" then
        level = 1
      elseif underline:match "^%s*-+%s*$" then
        level = 2
      end
      text = vim.trim(first)
    end
    if text ~= "" then table.insert(items, { line = start_row, level = level, text = text }) end
  end
  table.sort(items, function(a, b) return a.line < b.line end)
  return items
end

local function _md_open_headings_popup()
  local src_win = vim.api.nvim_get_current_win()
  local items = _md_collect_headings()
  if #items == 0 then return end
  ---@type string[]
  local lines = {}
  local max_length = 0
  for i, it in ipairs(items) do
    local indent = string.rep("  ", math.max(it.level - 1, 0))
    local line = indent .. it.text
    lines[i] = line
    if #line > max_length then max_length = #line end
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  local width = math.min(max_length + 2, math.max(20, math.floor(vim.o.columns * 0.8)))
  local height = math.min(#lines, math.max(5, math.floor(vim.o.lines * 0.6)))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = 2
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })
  vim.api.nvim_set_option_value("wrap", false, { win = win })
  vim.api.nvim_set_option_value("cursorline", true, { win = win })
  ---@type table<string, table<any>>
  local groups = {}
  for i, it in ipairs(items) do
    ---@type string[]
    local initials = {}
    local seen = {}
    local function add_initial(str)
      if not str then return end
      local ch = str:match "%a"
      if not ch then return end
      ch = ch:lower()
      if seen[ch] then return end
      seen[ch] = true
      table.insert(initials, ch)
    end
    local trimmed = vim.trim(it.text)
    local link_inside = trimmed:match "^%[%[([^%]]+)%]%]"
    if link_inside then
      ---@type string
      local before_alias = link_inside:match "^[^|]+"
      add_initial(before_alias)
      if before_alias then
        for segment in before_alias:gmatch "[^/]+" do
          add_initial(segment)
        end
      end
      local alias = link_inside:match "|(.+)$"
      if alias then add_initial(alias) end
    else
      add_initial(trimmed)
    end
    for _, init in ipairs(initials) do
      groups[init] = groups[init] or {}
      local exists = false
      for _, idx in ipairs(groups[init]) do
        if idx == i then
          exists = true
          break
        end
      end
      if not exists then table.insert(groups[init], i) end
    end
  end
  local jump_to_index = function(idx)
    if not idx or not items[idx] then return end
    local target = items[idx]
    pcall(vim.api.nvim_win_close, win, true)
    if vim.api.nvim_win_is_valid(src_win) then vim.api.nvim_set_current_win(src_win) end
    pcall(vim.api.nvim_win_set_cursor, src_win, { target.line + 1, 0 })
    vim.cmd "normal! zvzz"
  end
  local second_active = false
  local second_keys_set = {}
  local second_extmarks = {}
  local function clear_second()
    if #second_extmarks > 0 then
      for _, id in ipairs(second_extmarks) do
        pcall(vim.api.nvim_buf_del_extmark, buf, _md_heading_ns, id)
      end
    end
    second_extmarks = {}
    if #second_keys_set > 0 then
      for _, k in ipairs(second_keys_set) do
        pcall(vim.keymap.del, "n", k, { buffer = buf })
      end
    end
    second_keys_set = {}
    second_active = false
  end
  local second_choice_keys = {
    "a",
    "s",
    "d",
    "f",
    "l",
    "h",
    "g",
    "u",
    "i",
    "o",
    "p",
    "w",
    "e",
    "r",
    "t",
    "y",
    "c",
    "v",
    "b",
    "n",
    "m",
    "x",
    "z",
  }
  local function enter_second(init)
    local list = groups[init]
    if not list or #list <= 1 then return end
    clear_second()
    second_active = true
    local mid = math.ceil(#lines / 2)
    table.sort(list, function(a, b)
      local da = math.abs(a - mid)
      local db = math.abs(b - mid)
      if da ~= db then return da < db end
      return a > b
    end)
    local assigned = {}
    for i, idx in ipairs(list) do
      local key = second_choice_keys[i]
      if not key then break end
      table.insert(second_keys_set, key)
      assigned[idx] = key
      vim.keymap.set("n", key, function()
        clear_second()
        jump_to_index(idx)
      end, { buffer = buf, nowait = true, silent = true })
    end
    for idx, key in pairs(assigned) do
      local id = vim.api.nvim_buf_set_extmark(buf, _md_heading_ns, idx - 1, 0, {
        virt_text = { { key .. " ", "IncSearch" } },
        virt_text_pos = "overlay",
        virt_text_win_col = 0,
      })
      table.insert(second_extmarks, id)
    end
  end
  local function on_first(char)
    local list = groups[char]
    if not list or #list == 0 then return end
    if #list == 1 then
      jump_to_index(list[1])
    else
      enter_second(char)
    end
  end

  local function move_cursor(delta)
    local cur = vim.api.nvim_win_get_cursor(win)
    local new_row = math.max(1, math.min(#lines, cur[1] + delta))
    if new_row ~= cur[1] then vim.api.nvim_win_set_cursor(win, { new_row, 0 }) end
  end

  vim.keymap.set("n", "j", function() move_cursor(1) end, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "k", function() move_cursor(-1) end, { buffer = buf, nowait = true, silent = true })
  for byte = string.byte "a", string.byte "z" do
    local ch = string.char(byte)
    if ch ~= "j" and ch ~= "k" then
      vim.keymap.set("n", ch, function()
        if second_active then return end
        on_first(ch)
      end, { buffer = buf, nowait = true, silent = true })
    end
  end
  vim.keymap.set("n", "<CR>", function()
    local cur = vim.api.nvim_win_get_cursor(win)[1]
    jump_to_index(cur)
  end, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set(
    "n",
    "q",
    function() pcall(vim.api.nvim_win_close, win, true) end,
    { buffer = buf, nowait = true, silent = true }
  )
  vim.keymap.set("n", "<Esc>", function()
    if second_active then
      clear_second()
    else
      pcall(vim.api.nvim_win_close, win, true)
    end
  end, { buffer = buf, nowait = true, silent = true })
end

vim.keymap.set(
  "n",
  "gh",
  _md_open_headings_popup,
  { buffer = true, silent = true, desc = "markdown: headings quick jump" }
)

---@param line string
---@return { indent: string, current: string, next: string, rest: string }?
local function _md_list_parts(line)
  local indent, marker = line:match "^(%s*)([%-%+%*]%s+%[[ xX%-]%]%s+)"
  if indent then
    local rest = line:sub(#indent + #marker + 1)
    return { indent = indent, current = marker, next = marker, rest = rest }
  end

  indent, marker = line:match "^(%s*)([%-%+%*]%s+)"
  if indent then
    local rest = line:sub(#indent + #marker + 1)
    return { indent = indent, current = marker, next = marker, rest = rest }
  end

  local num, sep
  indent, num, sep = line:match "^(%s*)(%d+)([.)])%s+"
  if indent then
    local current = string.format("%s%s ", num, sep)
    local next_marker = string.format("%d%s ", tonumber(num) + 1, sep)
    local rest = line:sub(#indent + #current + 1)
    return { indent = indent, current = current, next = next_marker, rest = rest }
  end
end

---@param opts? { blockquote_only?: boolean }
local function _md_smart_cr(opts)
  opts = opts or {}
  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  if not opts.blockquote_only then
    local parts = _md_list_parts(line)
    if parts then
      if parts.rest:match "^%s*$" and col >= #line then
        return vim.api.nvim_replace_termcodes("<C-u>" .. parts.indent .. "<CR>", true, false, true)
      end

      return vim.api.nvim_replace_termcodes("<CR>" .. parts.next, true, false, true)
    end
  end

  local bq_prefix = line:match "^%s*>+%s*"
  if bq_prefix then return vim.api.nvim_replace_termcodes("<CR>" .. bq_prefix, true, false, true) end

  return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
end

vim.keymap.set("i", "<CR>", _md_smart_cr, { buffer = true, expr = true, desc = "markdown: continue list" })
vim.keymap.set(
  "i",
  "<S-CR>",
  function() return _md_smart_cr { blockquote_only = true } end,
  { buffer = true, expr = true, desc = "markdown: continue blockquote" }
)

local function _md_insert_emdash() return "—" end

vim.keymap.set(
  "i",
  "<S-M-->",
  _md_insert_emdash,
  { buffer = true, expr = true, desc = "markdown: insert em dash (Option+Shift+-)" }
)
vim.keymap.set(
  "i",
  "<M-->",
  _md_insert_emdash,
  { buffer = true, expr = true, desc = "markdown: insert em dash (Option+-)" }
)

---@param url string
---@return string
local function _md_clean_url(url)
  local base, fragment = url:match "^(.-)(#.*)$"
  if not base then
    base = url
    fragment = ""
  end

  local before_query, query = base:match "^(.-)%?(.*)$"
  if not before_query then return base .. fragment end

  local kept = {}
  for part in query:gmatch "[^&]+" do
    local name = part:match "^([^=]+)"
    if name ~= "curius" then table.insert(kept, part) end
  end
  if #kept == 0 then return before_query .. fragment end
  return before_query .. "?" .. table.concat(kept, "&") .. fragment
end

---@param text string
---@return string
local function _md_clean_url_token(text)
  local url, suffix = text:match "^(.+)([.,;:!?])$"
  if not url then return _md_clean_url(text) end
  return _md_clean_url(url) .. suffix
end

---@param text string
---@return string
local function _md_clean_pasted_urls(text)
  text = text:gsub("https?://[^%s<>()%[%]{}\"']+", _md_clean_url_token)
  text = text:gsub("www%.[^%s<>()%[%]{}\"']+", _md_clean_url_token)
  return text
end

---@param lines string[]
---@return string[]
local function _md_transform_paste(lines)
  local raw = table.concat(lines or {}, "\n")
  local cleaned = _md_clean_pasted_urls(raw)
  if cleaned == raw then return lines end
  return vim.split(cleaned, "\n", { plain = true, trimempty = false })
end

local _md_paste_hook_version = 2

if vim.g._md_paste_hook_version ~= _md_paste_hook_version then
  vim.g._md_paste_hook_version = _md_paste_hook_version

  vim.paste = (function(overridden)
    local chunked = ""

    return function(lines, phase)
      phase = phase or -1

      -- don't mess with cmdline pastes, it gets weird fast.
      if vim.fn.getcmdtype() ~= "" then return overridden(lines, phase) end

      local buf = vim.api.nvim_get_current_buf()
      if vim.bo[buf].filetype ~= "markdown" then return overridden(lines, phase) end

      local is_first_chunk = phase < 2
      local is_last_chunk = phase == -1 or phase == 3

      if is_first_chunk then chunked = "" end
      chunked = chunked .. table.concat(lines, "\n")

      if not is_last_chunk then return true end

      local transformed = _md_transform_paste(vim.split(chunked, "\n", { plain = true, trimempty = false }))
      chunked = ""
      return overridden(transformed, -1)
    end
  end)(vim.paste)
end

return M
