local M = {}

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
---@return boolean
function M.have(what, query)
  what = what or vim.api.nvim_get_current_buf()
  what = type(what) == "number" and vim.bo[what].filetype or what
  local lang = vim.treesitter.language.get_lang(what)
  if lang == nil or M.get_installed()[lang] == nil then return false end
  if query and not M.have_query(lang, query) then return false end
  return true
end

function M.foldexpr() return M.have(nil, "folds") and vim.treesitter.foldexpr() or "0" end

function M.indentexpr() return M.have(nil, "indents") and require("nvim-treesitter").indentexpr() or -1 end

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

  local block_node = node
  while block_node do
    if CODE_BLOCK_NODES[block_node:type()] then return true end
    block_node = block_node:parent()
  end

  while node do
    if node:type() == "text_mode" then
      if check_parent then
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

function M.in_math()
  local node = vim.treesitter.get_node { ignore_injections = false }

  if vim.bo.filetype == "markdown" or vim.bo.filetype == "quarto" then
    local block_node = node
    while block_node do
      if CODE_BLOCK_NODES[block_node:type()] then return false end
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

function M.not_math() return M.in_text(true) end

return M
