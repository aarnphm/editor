local M = {}

local create_term = function(config)
  vim.cmd([[packadd toggleterm]])
  local ft = require("toggleterm.terminal").Terminal:new(config)
  ft:toggle()
end

M.create_float_term = function()
  local config = {
    hidden = true,
    direction = "float",
    float_opts = {
      border = "double",
    },
    on_open = function(term)
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  }
  create_term(config)
end

M._split = function(s, delim)
  local res = {}
  for match in (s .. delim):gmatch("(.-)" .. delim) do
    table.insert(res, match)
  end
  return res
end

M.gitui = function()
  local config = {
    cmd = "gitui",
    hidden = true,
    direction = "float",
    float_opts = {
      border = "double",
    },
    on_open = function(term)
      vim.cmd([[startinsert!]])
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  }
  create_term(config)
end

M.reset_cache = function()
  local ok, impatient = pcall(require, "impatient")
  if ok then
    impatient.clear_cache()
  end
end

local hidden = {
  "help",
  "NvimTree",
  "terminal",
  "Scratch",
  "quickfix",
  "Trouble",
}

M.hide_statusline = function()
  local shown = {}
  local buftype = vim.api.nvim_buf_get_option(0, "ft")

  -- shown table from config has the highest priority
  if vim.tbl_contains(shown, buftype) then
    vim.api.nvim_set_option("laststatus", 3)
    return
  end

  if vim.tbl_contains(hidden, buftype) then
    vim.api.nvim_set_option("laststatus", 0)
    return
  end

  vim.api.nvim_set_option("laststatus", 3)
end

return M
