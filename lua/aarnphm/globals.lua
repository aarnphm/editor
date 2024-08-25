_G.Util = require "utils"

---@generic T
---Pretty print a value for better inspect. Under the hood it uses vim.inspect
---@param v T any type
---@return T
_G.P = function(v)
  print(vim.inspect(v))
  return v
end

_G.TABWIDTH = 2

---@alias Mode "simple" | "lsp" | "docs" | "hover" | "git"

---@class SingleBorder
---@field none FloatBorderEdges
---@field single FloatBorderEdgesWithHl
---

---@class SingleBorder
local M = {
  none = { "", "", "", "", "", "", "", "" },
  single = {
    simple = {
      { "┌", "Comment" },
      { "─", "Comment" },
      { "┐", "Comment" },
      { "│", "Comment" },
      { "┘", "Comment" },
      { "─", "Comment" },
      { "└", "Comment" },
      { "│", "Comment" },
    },
    lsp = {
      { "󱐋", "WarningMsg" },
      { "─", "Comment" },
      { "┐", "Comment" },
      { "│", "Comment" },
      { "┘", "Comment" },
      { "─", "Comment" },
      { "└", "Comment" },
      { "│", "Comment" },
    },
    docs = {
      { "󰄾", "DiagnosticHint" },
      { "─", "Comment" },
      { "┐", "Comment" },
      { "│", "Comment" },
      { "┘", "Comment" },
      { "─", "Comment" },
      { "└", "Comment" },
      { "│", "Comment" },
    },
    hover = {
      { "󰀵", "MiniIconsGrey" },
      { "─", "Comment" },
      { "┐", "Comment" },
      { "│", "Comment" },
      { "┘", "Comment" },
      { "─", "Comment" },
      { "└", "Comment" },
      { "│", "Comment" },
    },
    git = {
      { "󰊢", "MiniIconsRed" },
      { "─", "Comment" },
      { "┐", "Comment" },
      { "│", "Comment" },
      { "┘", "Comment" },
      { "─", "Comment" },
      { "└", "Comment" },
      { "│", "Comment" },
    },
  },
}

M.none = setmetatable(M.none, {
  __call = function(...) return M.none end,
})
M.single = setmetatable(M.single, {
  __call = function(_, t, override, start)
    t = t or "lsp"
    local target = M.single[t]
    if target == nil then
      Util.warn("Given border type `" .. t .. "` not found, falling back to none.")
      return M.none
    end
    -- Override the highlight color starting from the second item
    for i = start, #target do
      if type(target[i]) == "table" then target[i][2] = override or target[i][2] end
    end
    return target
  end,
})

---@param type? Mode type of border to be use
---@param override? string override hl for given buffer
---@param start? integer whether to start from 1 or 2
---@return FloatBorder
M.impl = function(type, override, start) return M[vim.g.border or "none"](type, override, start or 2) end

_G.BORDER = setmetatable(M, { __index = function() return M.impl() end })

_G.augroup = function(name) return vim.api.nvim_create_augroup(("simple_%s"):format(name), { clear = true }) end
_G.hi = function(name, opts)
  opts.default = opts.default or true
  opts.force = opts.force or true
  vim.api.nvim_set_hl(0, name, opts)
end

-- statusline and simple
local fmt = string.format

local H = {}

-- For more information see ":h buftype"
H.isnt_normal_buffer = function() return vim.bo.buftype ~= "" end

---@type fun(filetype?: string): string
H.get_icon = nil

H.ensure_get_icon = function()
  if H.get_icon ~= nil then
    -- Cache only once
    return
  elseif _G.MiniIcons ~= nil then
    -- Prefer 'mini.icons'
    H.get_icon = function(filetype) return _G.MiniIcons.get("filetype", filetype) end
  else
    -- Try falling back to 'nvim-web-devicons'
    local has_devicons, devicons = pcall(require, "nvim-web-devicons")
    if not has_devicons then return end
    H.get_icon = function() return (devicons.get_icon(vim.fn.expand "%:t", nil, { default = true })) end
  end
end

H.is_truncated = function(trunc_width)
  -- Use -1 to default to 'not truncated'
  local cur_width = vim.o.laststatus == 3 and vim.o.columns or vim.api.nvim_win_get_width(0)
  return cur_width < (trunc_width or -1)
end

-- Custom `^V` and `^S` symbols to make this file appropriate for copy-paste
-- (otherwise those symbols are not displayed).
local CTRL_S = vim.api.nvim_replace_termcodes("<C-S>", true, true, true)
local CTRL_V = vim.api.nvim_replace_termcodes("<C-V>", true, true, true)
H.modes = setmetatable({
  ["n"] = { long = "NORMAL", short = "N", hl = "MiniStatuslineModeNormal" },
  ["v"] = { long = "VISUAL", short = "V", hl = "MiniStatuslineModeVisual" },
  ["V"] = { long = "V-LINE", short = "V-L", hl = "MiniStatuslineModeVisual" },
  [CTRL_V] = { long = "V-BLOCK", short = "V-B", hl = "MiniStatuslineModeVisual" },
  ["s"] = { long = "SELECT", short = "S", hl = "MiniStatuslineModeVisual" },
  ["S"] = { long = "S-LINE", short = "S-L", hl = "MiniStatuslineModeVisual" },
  [CTRL_S] = { long = "S-BLOCK", short = "S-B", hl = "MiniStatuslineModeVisual" },
  ["i"] = { long = "INSERT", short = "I", hl = "MiniStatuslineModeInsert" },
  ["R"] = { long = "REPLACE", short = "R", hl = "MiniStatuslineModeReplace" },
  ["c"] = { long = "COMMAND", short = "C", hl = "MiniStatuslineModeCommand" },
  ["r"] = { long = "PROMPT", short = "P", hl = "MiniStatuslineModeOther" },
  ["!"] = { long = "SHELL", short = "SH", hl = "MiniStatuslineModeOther" },
  ["t"] = { long = "TERMINAL", short = "T", hl = "MiniStatuslineModeOther" },
}, {
  -- By default return 'Unknown' but this shouldn't be needed
  __index = function() return { long = "UNKNOWN", short = "U", hl = "%#MiniStatuslineModeOther#" } end,
})

-- diagnostic levels

-- Showed diagnostic levels
H.diagnostic_levels = {
  { name = "ERROR", sign = "✖" },
  { name = "WARN", sign = "▲" },
  { name = "INFO", sign = "●" },
  { name = "HINT", sign = "⚑" },
}

H.diagnostic_get_count = function()
  ---@type table<vim.diagnostic.Severity?, integer>
  local res = {}
  for _, d in
    ipairs(vim.tbl_filter(
      ---@param d vim.Diagnostic
      function(d) return d.severity ~= nil end,
      vim.diagnostic.get(0)
    ))
  do
    res[d.severity] = (res[d.severity] or 0) + 1
  end
  return res
end

---@class SimpleStatuslineArgs
---@field icon string|nil
---@field trunc_width number|nil

-- I refuse to have a complex statusline, *proceeds to have a complex statusline* PepeLaugh (lualine is cool though.)
-- [hunk] [branch] [modified]  --------- [diagnostic] [filetype] [line:col] [heart]
---@return table<string, fun(args: SimpleStatuslineArgs): string | table<string, any>>
_G.make_statusline = function()
  return {
    lint = function(args)
      ---@module "lint"
      local lint
      ---@type boolean
      local ok

      if H.isnt_normal_buffer() then return "" end

      ok, lint = pcall(require, "lint")
      if not ok then return "" end

      local linters = lint.get_running()
      local names = lint._resolve_linter_by_ft(vim.bo.filetype)

      if H.is_truncated(args.trunc_width) then return #linters == 0 and "󰦕" or "󱉶" end

      if #linters == 0 then return "󰦕" .. " " .. string.rep("+", vim.tbl_count(names)) end
      return "󱉶 [" .. table.concat(linters, "|") .. "]"
    end,
    diagnostic = function(args)
      if H.is_truncated(args.trunc_width) or not vim.diagnostic.is_enabled { bufnr = 0 } then return "" end

      local count = H.diagnostic_get_count()
      local severity, t = vim.diagnostic.severity, {}
      -- construct diagnostic info
      for _, level in ipairs(H.diagnostic_levels) do
        local n = count[severity[level.name]] or 0
        -- Add level info only if diagnostic is present
        if n > 0 then table.insert(t, fmt("%s %s", level.sign, n)) end
      end

      local icon = args.icon or ""
      if vim.tbl_count(t) == 0 then return ("%s -"):format(icon) end
      return fmt("[%s %s]", icon, table.concat(t, " "))
    end,
    fileinfo = function(args)
      local filetype = vim.bo.filetype
      -- Don't show anything if can't detect file type or not inside a "normal buffer"
      if (filetype == "") or H.isnt_normal_buffer() then return "" end

      -- Add filetype icon
      H.ensure_get_icon()
      if H.get_icon ~= nil then filetype = H.get_icon(filetype) .. " " .. filetype end

      -- Construct output string if truncated or buffer is not normal
      if H.is_truncated(args.trunc_width) or vim.bo.buftype ~= "" then return filetype end

      -- Construct output string with extra file info
      return fmt("%s", filetype)
    end,
    location = function(_) return "%l:%v" end,
    ---@return {md:string, hl:string}
    mode = function(args)
      local mi = H.modes[vim.fn.mode()]
      return { md = mi.short, hl = mi.hl }
    end,
  }
end
