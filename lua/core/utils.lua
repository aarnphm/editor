local api = vim.api
local M = {}

local create_term = function(config)
  api.nvim_command([[packadd toggleterm]])
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
      api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  }
  create_term(config)
end

M.project_files = function()
  local opts = {} -- define here if you want to define something
  vim.fn.system("git rev-parse --is-inside-work-tree")
  if vim.v.shell_error == 0 then
    require("telescope.builtin").git_files(opts)
  else
    require("telescope.builtin").find_files(opts)
  end
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
      api.nvim_command([[startinsert!]])
      api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
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
  local buftype = api.nvim_buf_get_option(0, "ft")

  -- shown table from config has the highest priority
  if vim.tbl_contains(shown, buftype) then
    api.nvim_set_option("laststatus", 3)
    return
  end

  if vim.tbl_contains(hidden, buftype) then
    api.nvim_set_option("laststatus", 0)
    return
  end

  api.nvim_set_option("laststatus", 3)
end

return M
