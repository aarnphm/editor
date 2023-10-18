--# selene: allow(global_usage)
_G.Util = require "utils"

_G.P = function(v)
  print(vim.inspect(v))
  return v
end

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

local get_branch = function()
  local branch = ""
  if vim.g.loaded_fugitive then
    branch = vim.fn.FugitiveHead()
  elseif vim.g.loaded_gitbranch then
    branch = vim.fn["gitbranch#name"]()
  elseif vim.b.gitsigns_head ~= nil then
    branch = vim.b.gitsigns_head
  end
  return branch ~= "" and fmt("(b: %s)", branch) or ""
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

-- I refuse to have a complex statusline, *proceeds to have a complex statusline* PepeLaugh (lualine is cool though.)
-- [hunk] [branch] [modified]  --------- [diagnostic] [filetype] [line:col] [heart]
_G.statusline = {
  git = function(args)
    local hunks, branch = get_hunks(), get_branch()
    if hunks == concat_hunks { 0, 0, 0 } and branch == "" then hunks = "" end
    if hunks ~= "" and branch ~= "" then branch = branch .. " " end
    return fmt("%s", table.concat { branch, hunks })
  end,
  diagnostic = function(args)
    local buf = vim.api.nvim_get_current_buf()
    return vim.diagnostic.get(buf)
        and fmt(
          "[W:%d | E:%d]",
          #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.WARN }),
          #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR })
        )
      or ""
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
  mode = function(args)
    local mi = modes[vim.fn.mode()]
    return is_truncated(args.trunc_width) and mi.short or mi.long
  end,
  modes = modes,
}
