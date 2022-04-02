local M = {}
local lazy = require("lazy")

local hidden = {
  "help",
  "NvimTree",
  "terminal",
  "dashboard",
}

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

M.install_treesitter = function()
  vim.cmd([[packadd nvim-treesitter]])

  local parser_dir = require("nvim-treesitter.utils").get_parser_install_dir()

  local function is_installed(lang)
    -- print(vim.fn.filereadable(require("nvim-treesitter.utils").get_parser_install_dir() .. __editor_global.path_sep .. vim.api.nvim_buf_get_option(0, "ft") .. ".so"))
    return vim.fn.filereadable(parser_dir .. __editor_global.path_sep .. lang .. ".so") > 0
  end

  local buftype = vim.api.nvim_buf_get_option(0, "ft")

  if vim.tbl_contains(hidden, buftype) then
    return
  end

  if not is_installed(buftype) then
    vim.cmd("TSInstall " .. buftype)
  end
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

function M.edit_root()
  local files = lazy.require_on_exported_call("telescope.builtin.git").files
  files({ cwd = vim.fn.stdpath("config") })
end

function M.reset_cache()
  local ok, impatient = pcall(require, "impatient")
  if ok then
    impatient.clear_cache()
  end
end

function M.reload()
  require("core.pack").sync()
  require("core.pack").compile()
  vim.notify("Config reloaded and compiled.")
end

function M.hide_statusline()
  local shown = {}
  local buftype = vim.api.nvim_buf_get_option(0, "ft")

  -- shown table from config has the highest priority
  if vim.tbl_contains(shown, buftype) then
    vim.api.nvim_set_option("laststatus", 2)
    return
  end

  if vim.tbl_contains(hidden, buftype) then
    vim.api.nvim_set_option("laststatus", 0)
    return
  end

  vim.api.nvim_set_option("laststatus", 2)
end

return M
