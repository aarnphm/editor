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

M._installed = nil ---@type table<string,boolean>?
M._queries = {} ---@type table<string,boolean>

---@param update boolean?
function M.get_installed(update)
  if update then
    M._installed, M._queries = {}, {}
    for _, lang in ipairs(require("nvim-treesitter").get_installed "parsers") do
      M._installed[lang] = true
    end
  end
  return M._installed or {}
end

---@param lang string
---@param query string
function M.have_query(lang, query)
  local key = lang .. ":" .. query
  if M._queries[key] == nil then M._queries[key] = vim.treesitter.query.get(lang, query) ~= nil end
  return M._queries[key]
end

---@param what string|number|nil
---@param query? string
---@overload fun(buf?:number):boolean
---@overload fun(ft:string):boolean
---@return boolean
function M.have(what, query)
  what = what or vim.api.nvim_get_current_buf()
  what = type(what) == "number" and vim.bo[what].filetype or what --[[@as string]]
  local lang = vim.treesitter.language.get_lang(what)
  if lang == nil or M.get_installed()[lang] == nil then return false end
  if query and not M.have_query(lang, query) then return false end
  return true
end

function M.foldexpr() return M.have(nil, "folds") and vim.treesitter.foldexpr() or "0" end

function M.indentexpr() return M.have(nil, "indents") and require("nvim-treesitter").indentexpr() or -1 end

---@return string?
local function win_find_cl()
  local path = "C:/Program Files (x86)/Microsoft Visual Studio"
  local pattern = "*/*/VC/Tools/MSVC/*/bin/Hostx64/x64/cl.exe"
  return vim.fn.globpath(path, pattern, true, true)[1]
end

---@return boolean ok, lazyvim.util.treesitter.Health health
function M.check()
  local is_win = vim.fn.has "win32" == 1
  ---@param tool string
  ---@param win boolean?
  local function have(tool, win) return (win == nil or is_win == win) and vim.fn.executable(tool) == 1 end

  local have_cc = vim.env.CC ~= nil or have("cc", false) or have("cl", true) or (is_win and win_find_cl() ~= nil)

  if not have_cc and is_win and vim.fn.executable "gcc" == 1 then
    vim.env.CC = "gcc"
    have_cc = true
  end

  ---@class lazyvim.util.treesitter.Health: table<string,boolean>
  local ret = {
    ["tree-sitter (CLI)"] = have "tree-sitter",
    ["C compiler"] = have_cc,
    tar = have "tar",
    curl = have "curl",
  }
  local ok = true
  for _, v in pairs(ret) do
    ok = ok and v
  end
  return ok, ret
end

---@param cb fun()
function M.build(cb)
  M.ensure_treesitter_cli(function(_, err)
    local ok, health = M.check()
    if ok then
      return cb()
    else
      local lines = { "Unmet requirements for **nvim-treesitter** `main`:" }
      local keys = vim.tbl_keys(health) ---@type string[]
      table.sort(keys)
      for _, k in pairs(keys) do
        lines[#lines + 1] = ("- %s `%s`"):format(health[k] and "✅" or "❌", k)
      end
      vim.list_extend(lines, {
        "",
        "See the requirements at [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter/tree/main?tab=readme-ov-file#requirements)",
        "Run `:checkhealth nvim-treesitter` for more information.",
      })
      if vim.fn.has "win32" == 1 and not health["C compiler"] then
        lines[#lines + 1] = "Install a C compiler with `winget install --id=BrechtSanders.WinLibs.POSIX.UCRT -e`"
      end
      vim.list_extend(lines, err and { "", err } or {})
      Util.error(lines, { title = "treesitter" })
    end
  end)
end

---@param cb fun(ok:boolean, err?:string)
function M.ensure_treesitter_cli(cb)
  if vim.fn.executable "tree-sitter" == 1 then return cb(true) end

  -- try installing with mason
  if not pcall(require, "mason") then
    return cb(false, "`mason.nvim` is disabled in your config, so we cannot install it automatically.")
  end

  -- check again since we might have installed it already
  if vim.fn.executable "tree-sitter" == 1 then return cb(true) end

  local mr = require "mason-registry"
  mr.refresh(function()
    local p = mr.get_package "tree-sitter-cli"
    if not p:is_installed() then
      Util.info "Installing `tree-sitter-cli` with `mason.nvim`..."
      p:install(
        nil,
        vim.schedule_wrap(function(success)
          if success then
            Util.info "Installed `tree-sitter-cli` with `mason.nvim`."
            cb(true)
          else
            cb(false, "Failed to install `tree-sitter-cli` with `mason.nvim`.")
          end
        end)
      )
    end
  end)
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
