local M = {}

function M.foldtext()
  return table.concat({
    vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)[1],
    (" 󰁂 %d"):format(vim.v.foldend - vim.v.foldstart),
  }, " ")
end

function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    if vim.bo[buf].filetype == "" then return "0" end
    vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
  end
  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

---@return {fg?:string}?
function M.fg(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  local fg = hl and hl.fg or hl.foreground
  return fg and { fg = string.format("#%06x", fg) } or nil
end

return M
