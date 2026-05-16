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
  if #clients == 1 then return "lsp:" .. clients[1] end
  return narrow(145) and ("lsp+" .. #clients) or ("lsp:" .. clients[1] .. "+" .. (#clients - 1))
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
  local text = ""

  if #display_names == 1 then
    text = label .. ":" .. display_names[1]
  else
    text = narrow(145) and (label .. "+" .. #display_names) or (label .. ":" .. table.concat(display_names, ","))
  end

  return text, active and "SimpleStatuslineLintRunning" or "SimpleStatuslineLint"
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

function M.render()
  local mode_label, mode_hl = mode()
  local lint_status, lint_hl = lint()
  return table.concat {
    hl(mode_hl),
    " ",
    mode_label,
    " ",
    hl "SimpleStatusline",
    part("SimpleStatuslineAccent", branch()),
    part("SimpleStatuslineMuted", dirty()),
    part("SimpleStatuslineWarn", diagnostics()),
    "%<",
    hl "SimpleStatuslineFile",
    " ",
    filename(),
    "%=",
    part("SimpleStatuslineMuted", recording()),
    part("SimpleStatuslineMuted", search()),
    part(lint_hl, lint_status),
    part("SimpleStatuslineInfo", lsp()),
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
  SimpleStatuslineLint = "StatusLine",
  SimpleStatuslineLintRunning = "StatusLine",
  SimpleStatuslineMuted = "StatusLineNC",
  SimpleStatuslineLocation = "StatusLine",
}

for name, link in pairs(default_highlights) do
  vim.api.nvim_set_hl(0, name, { link = link, default = true })
end

_G.SimpleStatusline = M
vim.o.statusline = "%!v:lua.SimpleStatusline.render()"
