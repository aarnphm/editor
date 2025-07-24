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
  -- additional handwritten snippets
  tbl["omega"] = "\\omega$0"
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

return M

