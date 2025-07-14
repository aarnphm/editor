---@class lazyvim.util.treesitter
local M = {}

M.goto_prev_node = function()
  local ts_utils = require "nvim-treesitter.ts_utils"
  local node = ts_utils.get_node_at_cursor()
  if not node then return end
  local dest_node = ts_utils.get_previous_node(node, true, true)
  if not dest_node then
    local cur_node = node:parent() ---@as TSNode
    while cur_node do
      dest_node = ts_utils.get_previous_node(cur_node, false, false)
      if dest_node then break end
      cur_node = cur_node:parent() ---@as TSNode
    end
  end
  if not dest_node then return end
  ts_utils.goto_node(dest_node)
end

M.goto_next_node = function()
  local ts_utils = require "nvim-treesitter.ts_utils"
  local node = ts_utils.get_node_at_cursor()
  if not node then return end
  local dest_node = ts_utils.get_next_node(node, true, true)
  if not dest_node then
    local cur_node = node:parent()
    while cur_node do
      dest_node = ts_utils.get_next_node(cur_node, false, false)
      if dest_node then break end
      cur_node = cur_node:parent()
    end
  end
  if not dest_node then return end
  ts_utils.goto_node(dest_node)
end

M.goto_parent_node = function()
  local ts_utils = require "nvim-treesitter.ts_utils"
  local node = ts_utils.get_node_at_cursor()
  if not node then return end
  local dest_node = node:parent()
  if not dest_node then return end
  ts_utils.goto_node(dest_node)
end

M.goto_child_node = function()
  local ts_utils = require "nvim-treesitter.ts_utils"
  local node = ts_utils.get_node_at_cursor()
  if not node then return end
  local dest_node = ts_utils.get_named_children(node)[1]
  if not dest_node then return end
  ts_utils.goto_node(dest_node)
end

---@param opts TSConfig
M.setup = function(opts)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
  end

  map({ "n", "v", "o", "i" }, "<A-o>", M.goto_parent_node, "treesitter: goto parent node")
  map({ "n", "v", "o", "i" }, "<A-i>", M.goto_child_node, "treesitter: goto child node")
  map({ "n", "v", "o", "i" }, "<A-n>", M.goto_next_node, "treesitter: goto next node")
  map({ "n", "v", "o", "i" }, "<A-p>", M.goto_prev_node, "treesitter: goto prev node")

  if type(opts.ensure_installed) == "table" then opts.ensure_installed = Util.dedup(opts.ensure_installed) end

  require("nvim-treesitter.configs").setup(opts)
end

return M
