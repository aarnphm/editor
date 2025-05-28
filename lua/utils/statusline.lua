---@class lazyvim.util.statusline
local M = {}

local H = {}

-- For more information see ":h buftype"
H.isnt_normal_buffer = function() return vim.bo.buftype ~= "" end

---@type fun(filetype?: string): string
H.get_icon = nil

H.ensure_get_icon = function()
  -- Cache only once
  if H.get_icon ~= nil then return end
  H.get_icon = function(filetype) return require("mini.icons").get("filetype", filetype) end
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
  if vim.b.gitsigns_status_dict then
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
  return string.format("%s %s", icon, branch)
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

---@param buf_id number
H.compute_attached_lsp = function(buf_id) return string.rep("*", vim.tbl_count(vim.lsp.get_clients { bufnr = buf_id })) end

-- String representation of attached LSP clients per buffer id
---@type table<integer, string | nil>
H.attached_lsp = {}

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

      if H.is_truncated(args.trunc_width) then return #linters == 0 and "[󰦕]" or "[󱉶]" end

      if #linters == 0 then
        local counts = vim.tbl_count(names)
        return "[󰦕" .. (counts > 0 and " " .. string.rep("+", counts) or "") .. "]"
      end
      return "[󱉶 " .. table.concat(linters, "|") .. "]"
    end,
    lsp = function(args)
      local attached = H.attached_lsp[vim.api.nvim_get_current_buf()] or ""

      local icon = args.icon or "󰰎"
      if attached == "" then return string.format("[%s]", icon) end
      if H.is_truncated(args.trunc_width) then return string.format("[%s %d]", icon, #attached) end
      return string.format("[%s %s]", icon, attached)
    end,
    diagnostic = function(args)
      local buf = vim.api.nvim_get_current_buf()
      local count = vim.diagnostic.count(buf)
      if count == nil or (not vim.diagnostic.is_enabled { bufnr = buf }) then return "" end

      local severity, t = vim.diagnostic.severity, {}
      -- construct diagnostic info
      for _, level in ipairs(H.diagnostic_levels) do
        local n = count[severity[level.name]] or 0
        -- Add level info only if diagnostic is present
        if n > 0 then table.insert(t, string.format("%s %s", level.sign, n)) end
      end

      local icon = args.icon or ""
      if H.is_truncated(args.trunc_width) then return string.format("[%s %d]", icon, #t) end
      if #t == 0 then return string.format("[%s]", icon) end
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
      ---@type string
      local resolved_ft
      if H.get_icon ~= nil then
        resolved_ft = string.format("%s %s", H.get_icon(filetype), filetype)
      else
        resolved_ft = filetype
      end

      -- Construct output string if truncated or buffer is not normal
      if H.is_truncated(args.trunc_width) or vim.bo.buftype ~= "" then return resolved_ft end

      -- local icon = args.icon or "♥"
      -- Construct output string with extra file info
      return resolved_ft
    end,
    location = function()
      -- '%l:%2v:%-2{virtcol("$") - 1}' .. (" %s"):format(icon)
      -- local icon = args.icon or "♥"
      return "%-5.(%l:%c%V%) %P"
    end,
    mode = function(args)
      local mi = H.modes[vim.fn.mode()]
      local force_shorts = args.force_shorts or true
      local resolved = {
        md = H.is_truncated(args.trunc_width) and mi.short or (force_shorts and mi.short or mi.long),
        hl = mi.hl,
      }
      return ("%%#%s#[%s]"):format(resolved.hl, resolved.md)
    end,
    git = function(args)
      if H.isnt_normal_buffer() then return "" end
      local icon = args.icon or ""
      local head = H.get_branch(icon)
      local hunks = H.get_hunks()

      if H.is_truncated(args.trunc_width) then return string.format("[%s]", head) end

      if hunks == H.concat_hunks { 0, 0, 0 } and head == "" then hunks = "" end
      if hunks ~= "" and head ~= "" then head = head .. " " end
      return string.format("[%s]", table.concat { head, hunks })
    end,
  }
end

M.setup = function()
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(
      event,
      { group = augroup "statusline", pattern = pattern, callback = callback, desc = desc }
    )
  end
  local set_default_hl = function(name, data)
    data.default = true
    vim.api.nvim_set_hl(0, name, data)
  end

  set_default_hl("MiniStatuslineModeNormal", { link = "Cursor" })
  set_default_hl("MiniStatuslineModeInsert", { link = "DiffChange" })
  set_default_hl("MiniStatuslineModeVisual", { link = "DiffAdd" })
  set_default_hl("MiniStatuslineModeReplace", { link = "DiffDelete" })
  set_default_hl("MiniStatuslineModeCommand", { link = "DiffText" })
  set_default_hl("MiniStatuslineModeOther", { link = "IncSearch" })

  set_default_hl("MiniStatuslineDevinfo", { link = "StatusLine" })
  set_default_hl("MiniStatuslineFilename", { link = "StatusLineNC" })
  set_default_hl("MiniStatuslineFileinfo", { link = "StatusLine" })
  set_default_hl("MiniStatuslineInactive", { link = "StatusLineNC" })

  -- Use `schedule_wrap()` because at `LspDetach` server is still present
  local track_lsp = vim.schedule_wrap(function(data)
    H.attached_lsp[data.buf] = vim.api.nvim_buf_is_valid(data.buf) and H.compute_attached_lsp(data.buf) or nil
    vim.cmd "redrawstatus"
  end)
  au({ "LspAttach", "LspDetach" }, "*", track_lsp, "Track LSP clients")
end

return M
