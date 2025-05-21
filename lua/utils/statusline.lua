---@class lazyvim.util.statusline
local M = {}

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

H.concat_hunks = function(hunks)
  return vim.tbl_isempty(hunks) and ""
    or table.concat({
      string.format("+%d", hunks[1]),
      string.format("~%d", hunks[2]),
      string.format("-%d", hunks[3]),
    }, " ")
end

H.get_hunks = function()
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
  return H.concat_hunks(hunks)
end

H.get_branch = function(icon)
  local branch = ""
  if vim.b.gitsigns_head ~= nil then
    branch = vim.b.gitsigns_head
  elseif vim.g.loaded_fugitive then
    branch = vim.fn.FugitiveHead()
  elseif vim.g.loaded_gitbranch then
    branch = vim.fn["gitbranch#name"]()
  end
  return branch ~= "" and string.format("(%s %s)", icon, branch) or ""
end

-- Custom `^V` and `^S` symbols to make this file appropriate for copy-paste
-- (otherwise those symbols are not displayed).
H.modes = setmetatable({
  ["n"] = { long = "NORMAL", short = "N", hl = "MiniStatuslineModeNormal" },
  ["v"] = { long = "VISUAL", short = "V", hl = "MiniStatuslineModeVisual" },
  ["V"] = { long = "V-LINE", short = "V-L", hl = "MiniStatuslineModeVisual" },
  -- equiv to vim.api.nvim_replace_termcodes("<C-V>", true, true, true)
  ["\22"] = { long = "V-BLOCK", short = "V-B", hl = "MiniStatuslineModeVisual" },
  ["s"] = { long = "SELECT", short = "S", hl = "MiniStatuslineModeVisual" },
  ["S"] = { long = "S-LINE", short = "S-L", hl = "MiniStatuslineModeVisual" },
  -- equiv to vim.api.nvim_replace_termcodes("<C-S>", true, true, true)
  ["\19"] = { long = "S-BLOCK", short = "S-B", hl = "MiniStatuslineModeVisual" },
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
M.generate = function()
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
        if n > 0 then table.insert(t, string.format("%s %s", level.sign, n)) end
      end

      local icon = args.icon or ""
      if vim.tbl_count(t) == 0 then return ("%s -"):format(icon) end
      return string.format("[%s %s]", icon, table.concat(t, " "))
    end,
    filename = function(args)
      if vim.bo.buftype == "terminal" then
        return "%t"
      elseif H.is_truncated(args.trunc_width) then
        -- File name with 'truncate', 'modified', 'readonly' flags
        -- Use relative path if truncated
        return "%f%m%r"
      else
        -- Use fullpath if not truncated
        return "%F%m%r"
      end
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
      return string.format("%s", filetype)
    end,
    location = function(args)
      -- '%l:%2v:%-2{virtcol("$") - 1}' .. (" %s"):format(icon)
      local icon = args.icon or "♥"
      return "%-5.(%l:%c%V%) %P" .. (" %s"):format(icon)
    end,
    ---@return {md:string, hl:string}
    mode = function()
      local mi = H.modes[vim.fn.mode()]
      return { md = mi.short, hl = mi.hl }
    end,
    git = function(args)
      if H.isnt_normal_buffer() then return "" end
      local icon = args.icon or ""
      local head = H.get_branch(icon)
      local hunks = H.get_hunks()

      if hunks == H.concat_hunks { 0, 0, 0 } and head == "" then hunks = "" end
      if hunks ~= "" and head ~= "" then head = head .. " " end
      return string.format("%s", table.concat { head, hunks })
    end,
  }
end

return M
