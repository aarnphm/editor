local M = {}

local H = {}

H.modes = setmetatable({
  n = { label = "N", hl = "SimpleStatuslineModeNormal" },
  v = { label = "V", hl = "SimpleStatuslineModeVisual" },
  V = { label = "VL", hl = "SimpleStatuslineModeVisual" },
  ["\22"] = { label = "VB", hl = "SimpleStatuslineModeVisual" },
  s = { label = "S", hl = "SimpleStatuslineModeVisual" },
  S = { label = "SL", hl = "SimpleStatuslineModeVisual" },
  ["\19"] = { label = "SB", hl = "SimpleStatuslineModeVisual" },
  i = { label = "I", hl = "SimpleStatuslineModeInsert" },
  R = { label = "R", hl = "SimpleStatuslineModeReplace" },
  c = { label = "C", hl = "SimpleStatuslineModeCommand" },
  r = { label = "P", hl = "SimpleStatuslineModeOther" },
  ["!"] = { label = "SH", hl = "SimpleStatuslineModeOther" },
  t = { label = "T", hl = "SimpleStatuslineModeOther" },
}, {
  __index = function() return { label = "?", hl = "SimpleStatuslineModeOther" } end,
})

H.diagnostic_levels = {
  { name = "ERROR", sign = "E" },
  { name = "WARN", sign = "W" },
  { name = "INFO", sign = "I" },
  { name = "HINT", sign = "H" },
}

local function winid() return tonumber(vim.g.statusline_winid) or vim.api.nvim_get_current_win() end

local function bufnr()
  local win = winid()
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) or vim.api.nvim_get_current_buf()
end

local function winwidth()
  local win = winid()
  return vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_width(win) or vim.o.columns
end

local function narrow(width) return winwidth() < width end

local function hl(group) return ("%%#%s#"):format(group) end

local function esc(value) return tostring(value or ""):gsub("%%", "%%%%") end

local function part(group, value)
  value = esc(value)
  return value ~= "" and (hl(group) .. " " .. value) or ""
end

local function clickable_part(group, handler, value)
  value = esc(value)
  if value == "" then return "" end
  return ("%s %%%d@v:lua.%s@%s%%T"):format(hl(group), winid(), handler, value)
end

local function tool_label(label, names)
  if #names == 0 then return "" end
  if #names == 1 then return label .. ":" .. names[1] end
  return narrow(145) and (label .. "+" .. #names) or (label .. ":" .. names[1] .. "+" .. (#names - 1))
end

local function filename()
  if vim.bo[bufnr()].buftype == "terminal" then return "%t" end
  return narrow(100) and "%t%m%r" or "%f%m%r"
end

local function fileinfo()
  local ft = vim.bo[bufnr()].filetype
  if ft == "" or vim.bo[bufnr()].buftype ~= "" then return "" end
  local encoding = vim.bo[bufnr()].fileencoding
  return not narrow(90) and encoding ~= "" and (ft .. " " .. encoding) or ft
end

local function branch()
  if vim.bo[bufnr()].buftype ~= "" then return "" end

  local head = vim.b[bufnr()].gitsigns_head
  if head and head ~= "" then return "git:" .. head end

  local summary = vim.b[bufnr()].minigit_summary_string
  if summary and summary ~= "" then return "git:" .. summary:gsub("%s*%b()", "") end

  return ""
end

local function dirty()
  if vim.bo[bufnr()].buftype ~= "" then return "" end

  local diff = vim.b[bufnr()].minidiff_summary_string or vim.b[bufnr()].gitsigns_status
  if diff and diff ~= "" then return diff end
  return vim.bo[bufnr()].modified and "+" or ""
end

local function hunk_summary(hunks)
  local summary = { added = 0, changed = 0, removed = 0, hunks = 0 }
  for _, hunk in ipairs(hunks or {}) do
    summary.hunks = summary.hunks + 1
    if hunk.type == "add" then
      summary.added = summary.added + hunk.added.count
    elseif hunk.type == "delete" then
      summary.removed = summary.removed + hunk.removed.count
    elseif hunk.type == "change" then
      local added, removed = hunk.added.count, hunk.removed.count
      local changed = math.min(added, removed)
      summary.changed = summary.changed + changed
      summary.added = summary.added + added - changed
      summary.removed = summary.removed + removed - changed
    end
  end
  return summary
end

local function diff_summary(summary)
  local items = {}
  if summary.hunks > 0 then items[#items + 1] = "#" .. summary.hunks end
  if summary.added > 0 then items[#items + 1] = "+" .. summary.added end
  if summary.changed > 0 then items[#items + 1] = "~" .. summary.changed end
  if summary.removed > 0 then items[#items + 1] = "-" .. summary.removed end
  return table.concat(items, " ")
end

local function staged()
  local buf = bufnr()
  if vim.bo[buf].buftype ~= "" then return "" end

  local cache_mod = package.loaded["gitsigns.cache"]
  local cache = cache_mod and cache_mod.cache and cache_mod.cache[buf]
  if not (cache and cache.hunks_staged and #cache.hunks_staged > 0) then return "" end

  local summary = diff_summary(hunk_summary(cache.hunks_staged))
  return summary ~= "" and ("staged:" .. summary) or ""
end

local function diagnostics()
  local buf = bufnr()
  if not vim.diagnostic.is_enabled { bufnr = buf } then return "" end

  local count = vim.diagnostic.count(buf)
  local severity = vim.diagnostic.severity
  local items = {}
  for _, level in ipairs(H.diagnostic_levels) do
    local n = count[severity[level.name]] or 0
    if n > 0 then items[#items + 1] = level.sign .. n end
  end

  return table.concat(items, " ")
end

local function lsp()
  if narrow(115) then return "" end

  local clients = {}
  for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr() }) do
    if client.name ~= "copilot" then clients[#clients + 1] = client.name end
  end
  if #clients == 0 then return "" end

  table.sort(clients)
  return tool_label("lsp", clients)
end

local function lint()
  if narrow(115) then return "" end

  local buf = bufnr()
  local names = Util.lint.names(buf)
  if #names == 0 then return "" end

  local running = Util.lint.running(buf)
  local active = #running > 0
  local label = active and "linting" or "lint"
  local display_names = active and running or names
  return tool_label(label, display_names), active and "SimpleStatuslineLintRunning" or "SimpleStatuslineLint"
end

local function formatter()
  if narrow(115) then return "" end

  local names = Util.lsp.formatter_names(bufnr())
  if #names == 0 then return "" end
  return tool_label("fmt", names)
end

local function recording()
  local reg = vim.fn.reg_recording()
  if reg ~= "" then return "rec:@" .. reg end

  reg = vim.fn.reg_executing()
  return reg ~= "" and ("run:@" .. reg) or ""
end

local function search()
  if vim.v.hlsearch == 0 or narrow(90) then return "" end

  local ok, count = pcall(vim.fn.searchcount, { recompute = false, maxcount = 999 })
  if not ok or not count or count.total == 0 then return "" end

  local current = count.current > count.maxcount and (">" .. count.maxcount) or count.current
  local total = count.total > count.maxcount and (">" .. count.maxcount) or count.total
  return ("%s/%s"):format(current, total)
end

local function mode()
  local current = H.modes[vim.fn.mode(1)]
  return current.label, current.hl
end

local detail_win ---@type integer?

local function target_buf(minwid)
  local win = tonumber(minwid)
  if win and vim.api.nvim_win_is_valid(win) then return vim.api.nvim_win_get_buf(win) end
  return vim.api.nvim_get_current_buf()
end

local function close_details()
  if detail_win and vim.api.nvim_win_is_valid(detail_win) then pcall(vim.api.nvim_win_close, detail_win, true) end
  detail_win = nil
end

local function clamp(value, min, max) return math.max(min, math.min(value, max)) end

local function detail_position(width, height)
  local mouse = vim.fn.getmousepos()
  local total_width = width + 2
  local total_height = height + 2
  local screenrow = tonumber(mouse.screenrow) or 0
  local screencol = tonumber(mouse.screencol) or 0

  if screenrow <= 1 then screenrow = math.max(1, vim.o.lines - vim.o.cmdheight) end
  if screencol <= 1 then screencol = math.floor(vim.o.columns / 2) end

  local row = math.max(0, screenrow - total_height - 1)
  local col = clamp(screencol - math.floor(total_width / 2) - 1, 0, math.max(0, vim.o.columns - total_width))
  return row, col
end

local function tool_root(buf) return Util.root.get { buf = buf } end

local function append_tool(lines, name, root)
  lines[#lines + 1] = "- " .. name
  if root and root ~= "" then lines[#lines + 1] = "  root: " .. root end
end

local function open_details(lines)
  close_details()

  local body = #lines > 0 and lines or { "- none" }

  local width = 0
  for _, line in ipairs(body) do
    width = math.max(width, #line + 2)
  end
  width = math.min(math.max(width, 34), math.max(20, vim.o.columns - 4))
  local height = math.min(#body, math.max(1, vim.o.lines - 4))
  local float_buf = vim.api.nvim_create_buf(false, true)
  local row, col = detail_position(width, height)

  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, body)
  vim.bo[float_buf].bufhidden = "wipe"
  vim.bo[float_buf].modifiable = false

  detail_win = vim.api.nvim_open_win(float_buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    border = "rounded",
    style = "minimal",
  })
  vim.wo[detail_win].cursorline = true
  vim.wo[detail_win].wrap = false

  vim.keymap.set("n", "q", close_details, { buffer = float_buf, silent = true })
  vim.keymap.set("n", "<Esc>", close_details, { buffer = float_buf, silent = true })
end

function M.show_lsp(minwid)
  local buf = target_buf(minwid)
  local fallback_root = tool_root(buf)
  local clients = {}
  for _, client in ipairs(vim.lsp.get_clients { bufnr = buf }) do
    if client.name ~= "copilot" then clients[#clients + 1] = client end
  end
  table.sort(clients, function(a, b) return a.name < b.name end)

  local lines = {}
  for _, client in ipairs(clients) do
    append_tool(lines, client.name, client.root_dir or (client.config and client.config.root_dir) or fallback_root)
  end

  open_details(lines)
end

function M.show_lint(minwid)
  local buf = target_buf(minwid)
  local root = tool_root(buf)
  local running = {}
  for _, name in ipairs(Util.lint.running(buf)) do
    running[name] = true
  end

  local lines = {}
  for _, name in ipairs(Util.lint.names(buf)) do
    append_tool(lines, running[name] and (name .. " (running)") or name, root)
  end

  open_details(lines)
end

function M.show_formatters(minwid)
  local buf = target_buf(minwid)
  local root = tool_root(buf)
  local lines = {}
  for _, name in ipairs(Util.lsp.formatter_names(buf)) do
    append_tool(lines, name, root)
  end

  open_details(lines)
end

function M.render()
  local mode_label, mode_hl = mode()
  local lint_status, lint_hl = lint()
  return table.concat {
    hl(mode_hl),
    " ",
    mode_label,
    " ",
    hl "SimpleStatusline",
    "%<",
    hl "SimpleStatuslineFile",
    " ",
    filename(),
    "%=",
    part("SimpleStatuslineAccent", branch()),
    part("SimpleStatuslineMuted", dirty()),
    part("SimpleStatuslineDebug", staged()),
    part("SimpleStatuslineWarn", diagnostics()),
    part("SimpleStatuslineMuted", recording()),
    part("SimpleStatuslineMuted", search()),
    clickable_part(lint_hl, "SimpleStatuslineClickLint", lint_status),
    clickable_part("SimpleStatuslineInfo", "SimpleStatuslineClickLsp", lsp()),
    clickable_part("SimpleStatuslineFormatter", "SimpleStatuslineClickFormatter", formatter()),
    part("SimpleStatuslineMuted", fileinfo()),
    hl "SimpleStatuslineLocation",
    " %l:%c %p%% ",
  }
end

local default_highlights = {
  SimpleStatusline = "StatusLine",
  SimpleStatuslineModeNormal = "Cursor",
  SimpleStatuslineModeInsert = "DiffChange",
  SimpleStatuslineModeVisual = "DiffAdd",
  SimpleStatuslineModeReplace = "DiffDelete",
  SimpleStatuslineModeCommand = "DiffText",
  SimpleStatuslineModeOther = "IncSearch",
  SimpleStatuslineAccent = "StatusLine",
  SimpleStatuslineWarn = "StatusLine",
  SimpleStatuslineFile = "StatusLine",
  SimpleStatuslineInfo = "StatusLine",
  SimpleStatuslineFormatter = "StatusLine",
  SimpleStatuslineLint = "StatusLine",
  SimpleStatuslineLintRunning = "StatusLine",
  SimpleStatuslineMuted = "StatusLineNC",
  SimpleStatuslineLocation = "StatusLine",
}

for name, link in pairs(default_highlights) do
  vim.api.nvim_set_hl(0, name, { link = link, default = true })
end

_G.SimpleStatusline = M
_G.SimpleStatuslineClickFormatter = function(minwid) M.show_formatters(minwid) end
_G.SimpleStatuslineClickLint = function(minwid) M.show_lint(minwid) end
_G.SimpleStatuslineClickLsp = function(minwid) M.show_lsp(minwid) end
vim.o.statusline = "%!v:lua.SimpleStatusline.render()"
