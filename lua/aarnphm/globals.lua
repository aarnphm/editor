--# selene: allow(global_usage)
_G.Util = require "utils"

_G.P = function(v)
  print(vim.inspect(v))
  return v
end

_G.TABWIDTH = 2
_G.BORDER = "none"

_G.augroup = function(name) return vim.api.nvim_create_augroup(("simple_%s"):format(name), { clear = true }) end

-- statusline and simple
local fmt = string.format

-- NOTE: git
local concat_hunks = function(hunks)
  return vim.tbl_isempty(hunks) and ""
    or table.concat({
      fmt("+%d", hunks[1]),
      fmt("~%d", hunks[2]),
      fmt("-%d", hunks[3]),
    }, " ")
end

local get_hunks = function()
  local hunks = {}
  if vim.g.loaded_gitgutter then
    hunks = vim.fn.GitGutterGetHunkSummary()
  elseif vim.b.gitsigns_status_dict then
    hunks = {
      vim.b.gitsigns_status_dict.added,
      vim.b.gitsigns_status_dict.changed,
      vim.b.gitsigns_status_dict.removed,
    }
  end
  return concat_hunks(hunks)
end

local get_branch = function(icon)
  local branch = ""
  if vim.b.gitsigns_head ~= nil then
    branch = vim.b.gitsigns_head
  elseif vim.g.loaded_fugitive then
    branch = vim.fn.FugitiveHead()
  elseif vim.g.loaded_gitbranch then
    branch = vim.fn["gitbranch#name"]()
  end
  return branch ~= "" and fmt("(%s %s)", icon, branch) or ""
end

-- For more information see ":h buftype"
local isnt_normal_buffer = function() return vim.bo.buftype ~= "" end

local get_filetype_icon = function()
  -- Have this `require()` here to not depend on plugin initialization order
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if not has_devicons then return "" end

  local file_name, file_ext = vim.fn.expand "%:t", vim.fn.expand "%:e"
  return devicons.get_icon(file_name, file_ext, { default = true })
end

local is_truncated = function(trunc_width)
  -- Use -1 to default to 'not truncated'
  local cur_width = vim.o.laststatus == 3 and vim.o.columns or vim.api.nvim_win_get_width(0)
  return cur_width < (trunc_width or -1)
end

-- Custom `^V` and `^S` symbols to make this file appropriate for copy-paste
-- (otherwise those symbols are not displayed).
local CTRL_S = vim.api.nvim_replace_termcodes("<C-S>", true, true, true)
local CTRL_V = vim.api.nvim_replace_termcodes("<C-V>", true, true, true)
local modes = setmetatable({
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

local diagnostic_levels = {
  { id = vim.diagnostic.severity.ERROR, sign = "E" },
  { id = vim.diagnostic.severity.WARN, sign = "W" },
  { id = vim.diagnostic.severity.INFO, sign = "I" },
  { id = vim.diagnostic.severity.HINT, sign = "H" },
}

local get_diagnostic_count = function(id) return #vim.diagnostic.get(0, { severity = id }) end

---@class SimpleStatuslineArgs
---@field icon string|nil
---@field trunc_width number|nil

-- I refuse to have a complex statusline, *proceeds to have a complex statusline* PepeLaugh (lualine is cool though.)
-- [hunk] [branch] [modified]  --------- [diagnostic] [filetype] [line:col] [heart]
---@type table<string, fun(args: SimpleStatuslineArgs): string>
_G.statusline = {
  git = function(args)
    if isnt_normal_buffer() then return "" end
    local icon = args.icon or ""
    local head = get_branch(icon)
    local hunks = get_hunks()

    if hunks == concat_hunks { 0, 0, 0 } and head == "" then hunks = "" end
    if hunks ~= "" and head ~= "" then head = head .. " " end
    return fmt("%s", table.concat { head, hunks })
  end,
  diagnostic = function(args)
    local hasnt_attached_client = next(Util.lsp.get_clients {}) == nil
    local dont_show_lsp = is_truncated(args.trunc_width) or isnt_normal_buffer() or hasnt_attached_client
    if dont_show_lsp then return "" end

    -- construct diagnostic info
    local t = {}
    for _, level in ipairs(diagnostic_levels) do
      local n = get_diagnostic_count(level.id)
      -- Add level info only if diagnostic is present
      if n > 0 then table.insert(t, string.format(" %s:%s", level.sign, n)) end
    end

    local icon = args.icon or ""
    if vim.tbl_count(t) == 0 then return ("%s -"):format(icon) end
    return fmt("[%s %s]", icon, table.concat(t, " |"))
  end,
  filetype = function(args)
    local filetype = vim.bo.filetype
    -- Don't show anything if can't detect file type or not inside a "normal buffer"
    if (filetype == "") or isnt_normal_buffer() then return "" end

    -- Add filetype icon
    local icon = get_filetype_icon()
    if icon ~= "" then filetype = string.format("%s %s", icon, filetype) end
    return filetype
  end,
  filename = function(args)
    -- In terminal always use plain name
    if vim.bo.buftype == "terminal" then
      return "%t"
    elseif is_truncated(args.trunc_width) then
      -- File name with 'truncate', 'modified', 'readonly' flags
      -- Use relative path if truncated
      return "%f%m%r"
    else
      -- Use fullpath if not truncated
      return "%F%m%r"
    end
  end,
  location = function(args)
    local icon = args.icon or "♥ "
    if is_truncated(args.trunc_width) then return "%l:%2v" .. (" %s"):format(icon) end
    return '%l:%2v:%-2{virtcol("$") - 1}' .. (" %s"):format(icon)
  end,
  mode = function(args)
    local mi = modes[vim.fn.mode()]
    return is_truncated(args.trunc_width) and mi.short or mi.long
  end,
  modes = modes,
}
