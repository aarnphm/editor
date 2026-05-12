local M = {}

local magic_prefixes = { ["\\v"] = true, ["\\m"] = true, ["\\M"] = true, ["\\V"] = true }

local function vim_regex(pattern)
  if #pattern < 2 or magic_prefixes[pattern:sub(1, 2)] then return vim.regex(pattern) end
  return vim.regex("\\v" .. pattern)
end

local compiled_regexes = setmetatable({}, {
  __index = function(regexes, pattern)
    local regex = vim_regex(pattern)
    regexes[pattern] = regex
    return regex
  end,
})

local function node_text(node, source)
  local ok, text = pcall(vim.treesitter.get_node_text, node, source)
  if ok then return text end
end

local function check_nodes(match, source, predicate, any, check)
  local nodes = match[predicate[2]]
  if not nodes or #nodes == 0 then return true end

  for _, node in ipairs(nodes) do
    local text = node_text(node, source)
    local result = text ~= nil and check(text, predicate)
    if any and result then
      return true
    elseif not any and not result then
      return false
    end
  end
  return not any
end

local function add_predicate(name, handler) vim.treesitter.query.add_predicate(name, handler, { force = true }) end

local function eq(match, _, source, predicate)
  local nodes = match[predicate[2]]
  if not nodes or #nodes == 0 then return true end

  for _, node in ipairs(nodes) do
    local text = node_text(node, source)
    if text == nil then return false end

    local expected = predicate[3]
    if type(expected) ~= "string" then
      local other = assert(match[expected])
      assert(#other == 1, "#eq? does not support comparison with captures on multiple nodes")
      expected = node_text(other[1], source)
      if expected == nil then return false end
    end

    if text ~= expected then return false end
  end
  return true
end

local function any_eq(match, _, source, predicate)
  local nodes = match[predicate[2]]
  if not nodes or #nodes == 0 then return true end

  for _, node in ipairs(nodes) do
    local text = node_text(node, source)
    if text ~= nil then
      local expected = predicate[3]
      if type(expected) ~= "string" then
        local other = assert(match[expected])
        assert(#other == 1, "#any-eq? does not support comparison with captures on multiple nodes")
        expected = node_text(other[1], source)
      end
      if expected ~= nil and text == expected then return true end
    end
  end
  return false
end

local function lua_match(match, _, source, predicate)
  return check_nodes(match, source, predicate, false, function(text, pred) return text:find(pred[3]) ~= nil end)
end

local function any_lua_match(match, _, source, predicate)
  return check_nodes(match, source, predicate, true, function(text, pred) return text:find(pred[3]) ~= nil end)
end

local function match(captures, _, source, predicate)
  return check_nodes(
    captures,
    source,
    predicate,
    false,
    function(text, pred) return compiled_regexes[pred[3]]:match_str(text) ~= nil end
  )
end

local function any_match(captures, _, source, predicate)
  return check_nodes(
    captures,
    source,
    predicate,
    true,
    function(text, pred) return compiled_regexes[pred[3]]:match_str(text) ~= nil end
  )
end

local function contains(captures, _, source, predicate)
  return check_nodes(captures, source, predicate, false, function(text, pred)
    for i = 3, #pred do
      if not text:find(pred[i], 1, true) then return false end
    end
    return true
  end)
end

local function any_contains(captures, _, source, predicate)
  return check_nodes(captures, source, predicate, true, function(text, pred)
    for i = 3, #pred do
      if text:find(pred[i], 1, true) then return true end
    end
    return false
  end)
end

local function any_of(captures, _, source, predicate)
  local nodes = captures[predicate[2]]
  if not nodes or #nodes == 0 then return true end

  predicate.string_set = predicate.string_set or {}
  if not next(predicate.string_set) then
    for i = 3, #predicate do
      predicate.string_set[predicate[i]] = true
    end
  end

  for _, node in ipairs(nodes) do
    local text = node_text(node, source)
    if text ~= nil and predicate.string_set[text] then return true end
  end
  return false
end

function M.setup()
  add_predicate("eq?", eq)
  add_predicate("any-eq?", any_eq)
  add_predicate("lua-match?", lua_match)
  add_predicate("any-lua-match?", any_lua_match)
  add_predicate("match?", match)
  add_predicate("any-match?", any_match)
  add_predicate("vim-match?", match)
  add_predicate("any-vim-match?", any_match)
  add_predicate("contains?", contains)
  add_predicate("any-contains?", any_contains)
  add_predicate("any-of?", any_of)
end

return M
