---@class simple.util.treesitter
local M = {}

function M.goto_prev_node()
  local ts_utils = require "nvim-treesitter.ts_utils"
  local node = ts_utils.get_node_at_cursor()
  if not node then return end
  local dest_node = ts_utils.get_previous_node(node, true, true)
  if not dest_node then
    local cur_node = node:parent()
    while cur_node do
      dest_node = ts_utils.get_previous_node(cur_node, false, false)
      if dest_node then break end
      cur_node = cur_node:parent()
    end
  end
  if not dest_node then return end
  ts_utils.goto_node(dest_node)
end

function M.goto_next_node()
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

function M.goto_parent_node()
  local ts_utils = require "nvim-treesitter.ts_utils"
  local node = ts_utils.get_node_at_cursor()
  if not node then return end
  local dest_node = node:parent()
  if not dest_node then return end
  ts_utils.goto_node(dest_node)
end

function M.goto_child_node()
  local ts_utils = require "nvim-treesitter.ts_utils"
  local node = ts_utils.get_node_at_cursor()
  if not node then return end
  local dest_node = ts_utils.get_named_children(node)[1]
  if not dest_node then return end
  ts_utils.goto_node(dest_node)
end

---@param opts TSConfig
function M.setup(opts)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
  end

  map({ "n", "v", "o", "i" }, "<A-o>", M.goto_parent_node, "treesitter: goto parent node")
  map({ "n", "v", "o", "i" }, "<A-o>", M.goto_child_node, "treesitter: goto child node")
  map({ "n", "v", "o", "i" }, "<A-o>", M.goto_next_node, "treesitter: goto next node")
  map({ "n", "v", "o", "i" }, "<A-o>", M.goto_prev_node, "treesitter: goto prev node")

  require("nvim-treesitter.configs").setup(opts)
end

return M
