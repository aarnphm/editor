local M = {}
local packer = nil

-- load plugin after entering vim ui
M.packer_lazy_load = function(plugin, timer)
  if plugin then
    timer = timer or 0
    if not packer then
      vim.cmd([[packadd packer.nvim]])
      packer = require("packer")
    end

    vim.defer_fn(function()
      packer.loader(plugin)
    end, timer)
  end
end

function M.gitui()
  local Terminal = require("toggleterm.terminal").Terminal
  local gitui = Terminal:new({
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
  })
  gitui:toggle()
end

function M.edit_root()
  local files = _G.__lazy.require_on_exported_call("telescope.builtin.git").files
  files({ cwd = vim.fn.stdpath("config") })
end

function M.reset_cache()
  local impatient = _G.__luacache
  if impatient then
    impatient.clear_cache()
  end
end

function M.reload()
  M:reset_cache()
  require("packer").sync()
  require("packer").compile(_G.__editor_global.data_dir .. "lua/_compiled.lua")
  vim.notify("Config reloaded and compiled.")
end

function M.hide_statusline()
  local hidden = {
    "help",
    "NvimTree",
    "terminal",
    "dashboard",
    "alpha",
  }
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
