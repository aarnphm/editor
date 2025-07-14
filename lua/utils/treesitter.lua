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

local MATH_NODES = {
  displayed_equation = true,
  inline_formula = true,
  math_environment = true,
}

local TEXT_NODES = {
  text_mode = true,
  label_definition = true,
  label_reference = true,
}

local CODE_BLOCK_NODES = {
  fenced_code_block = true,
  indented_code_block = true,
}

function M.in_text(check_parent)
  local node = vim.treesitter.get_node { ignore_injections = false }

  -- Check for code blocks in any filetype
  local block_node = node
  while block_node do
    if CODE_BLOCK_NODES[block_node:type()] then
      return true -- If in a code block, always consider it text
    end
    block_node = block_node:parent()
  end

  while node do
    if node:type() == "text_mode" then
      if check_parent then
        -- For \text{}
        local parent = node:parent()
        if parent and MATH_NODES[parent:type()] then return false end
      end
      return true
    elseif MATH_NODES[node:type()] then
      return false
    end
    node = node:parent()
  end
  return true
end

M.in_math = function()
  local node = vim.treesitter.get_node { ignore_injections = false }
  local current_filetype = vim.bo.filetype

  -- Check if we are in a markdown file and inside a code block
  if current_filetype == "markdown" or current_filetype == "quarto" then
    local block_node = node
    while block_node do
      if CODE_BLOCK_NODES[block_node:type()] then
        return false -- If in a code block in markdown, never consider it math zone
      end
      block_node = block_node:parent()
    end
  end

  while node do
    if TEXT_NODES[node:type()] then
      return false
    elseif MATH_NODES[node:type()] then
      return true
    end
    node = node:parent()
  end
  return false
end

M.not_math = function() return M.in_text(true) end

return M
