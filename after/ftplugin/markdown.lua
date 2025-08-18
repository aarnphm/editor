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
  Util.cmp.expand(body)
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
  if Util.has "blink.cmp" then require("blink.cmp").show { providers = { "lsp" } } end
end, { buffer = true, desc = "wikilink: insert" })

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
  local lines = {}
  local l2i = {}
  local max_length = 0
  for i, it in ipairs(items) do
    local label = i <= 26 and string.char(96 + i) or " "
    local indent = string.rep("  ", math.max(it.level - 1, 0))
    local line = (i <= 26 and (label .. " ") or "  ") .. indent .. it.text
    lines[i] = line
    if #line > max_length then max_length = #line end
    if i <= 26 then l2i[label] = i end
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  local width = math.min(max_length + 2, math.max(20, math.floor(vim.o.columns * 0.8)))
  local height = math.min(#lines, math.max(5, math.floor(vim.o.lines * 0.6)))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.max(0, vim.o.columns - width - 2)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })
  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.api.nvim_win_set_option(win, "cursorline", true)
  local jump_to_index = function(idx)
    if not idx or not items[idx] then return end
    local target = items[idx]
    pcall(vim.api.nvim_win_close, win, true)
    if vim.api.nvim_win_is_valid(src_win) then vim.api.nvim_set_current_win(src_win) end
    pcall(vim.api.nvim_win_set_cursor, src_win, { target.line + 1, 0 })
    vim.cmd "normal! zvzz"
  end
  for label, idx in pairs(l2i) do
    vim.keymap.set("n", label, function() jump_to_index(idx) end, { buffer = buf, nowait = true, silent = true })
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
  vim.keymap.set(
    "n",
    "<Esc>",
    function() pcall(vim.api.nvim_win_close, win, true) end,
    { buffer = buf, nowait = true, silent = true }
  )
end

vim.keymap.set(
  "n",
  "ghh",
  _md_open_headings_popup,
  { buffer = true, silent = true, desc = "markdown: headings quick jump" }
)

return M
