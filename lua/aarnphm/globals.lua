--# selene: allow(global_usage)
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

-- I refuse to have a complex statusline, *proceeds to have a complex statusline* PepeLaugh (lualine is cool though.)
-- [hunk] [branch] [modified]  --------- [diagnostic] [filetype] [line:col] [heart]
_G.statusline = {
  git = function()
    local hunks, branch = get_hunks(), get_branch()
    if hunks == concat_hunks { 0, 0, 0 } and branch == "" then hunks = "" end
    if hunks ~= "" and branch ~= "" then branch = branch .. " " end
    return fmt("%s", table.concat { branch, hunks })
  end,
  diagnostic = function()
    local buf = vim.api.nvim_get_current_buf()
    return vim.diagnostic.get(buf)
        and fmt(
          "[W:%d | E:%d]",
          #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.WARN }),
          #vim.diagnostic.get(buf, { severity = vim.diagnostic.severity.ERROR })
        )
      or ""
  end,
}
