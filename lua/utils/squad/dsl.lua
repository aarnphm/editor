local M = {}

M.DEFAULT_LAYOUT = {
  mode = "vertical",
  height = 22,
  width = 70,
  position = "right",
}

M.LAYOUT_ALIASES = {
  horizontal = { mode = "horizontal" },
  bottom = { mode = "horizontal" },
  vertical = { mode = "vertical" },
  right = { mode = "vertical", position = "right" },
  left = { mode = "vertical", position = "left" },
  side = { mode = "vertical" },
}

local function trim(str)
  if type(str) ~= "string" then return str end
  return (str:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function split_top_level(str, sep)
  sep = sep or ","
  local result = {}
  local buf = {}
  local depth_brace = 0
  local depth_bracket = 0
  local depth_paren = 0

  for i = 1, #str do
    local ch = str:sub(i, i)
    if ch == "{" then
      depth_brace = depth_brace + 1
    elseif ch == "}" and depth_brace > 0 then
      depth_brace = depth_brace - 1
    elseif ch == "[" then
      depth_bracket = depth_bracket + 1
    elseif ch == "]" and depth_bracket > 0 then
      depth_bracket = depth_bracket - 1
    elseif ch == "(" then
      depth_paren = depth_paren + 1
    elseif ch == ")" and depth_paren > 0 then
      depth_paren = depth_paren - 1
    end

    if ch == sep and depth_brace == 0 and depth_bracket == 0 and depth_paren == 0 then
      result[#result + 1] = trim(table.concat(buf))
      buf = {}
    else
      buf[#buf + 1] = ch
    end
  end

  if #buf > 0 then result[#result + 1] = trim(table.concat(buf)) end
  return result
end

local function last_top_level_chunk(str, sep)
  sep = sep or ","
  local depth_brace = 0
  local depth_bracket = 0
  local depth_paren = 0
  local last_index = 1

  for i = 1, #str do
    local ch = str:sub(i, i)
    if ch == "{" then
      depth_brace = depth_brace + 1
    elseif ch == "}" and depth_brace > 0 then
      depth_brace = depth_brace - 1
    elseif ch == "[" then
      depth_bracket = depth_bracket + 1
    elseif ch == "]" and depth_bracket > 0 then
      depth_bracket = depth_bracket - 1
    elseif ch == "(" then
      depth_paren = depth_paren + 1
    elseif ch == ")" and depth_paren > 0 then
      depth_paren = depth_paren - 1
    end

    if ch == sep and depth_brace == 0 and depth_bracket == 0 and depth_paren == 0 then last_index = i + 1 end
  end

  return trim(str:sub(last_index))
end

local function trailing_unmatched_segment(str, open, close)
  local depth = 0
  for i = #str, 1, -1 do
    local ch = str:sub(i, i)
    if ch == close then
      depth = depth + 1
    elseif ch == open then
      if depth == 0 then return str:sub(i + 1) end
      depth = depth - 1
    end
  end
  return nil
end

local function parse_value(raw)
  raw = trim(raw)
  local first = raw:sub(1, 1)
  local last = raw:sub(-1)
  if (first == '"' and last == '"') or (first == "'" and last == "'") then return raw:sub(2, -2) end
  if raw == "true" then return true end
  if raw == "false" then return false end
  return raw
end

local function extract_prompt(spec)
  spec = trim(spec)
  if spec == nil or spec == "" then return spec, nil end
  if spec:sub(-1) ~= "]" then return spec, nil end

  local depth = 0
  for i = #spec, 1, -1 do
    local ch = spec:sub(i, i)
    if ch == "]" then
      depth = depth + 1
    elseif ch == "[" then
      depth = depth - 1
      if depth == 0 then
        local before = spec:sub(1, i - 1)
        local prompt = spec:sub(i + 1, -2)
        return trim(before), prompt
      end
    end
  end

  return spec, nil
end

local function parse_options(raw)
  raw = trim(raw or "")
  if raw == "" then return {} end

  if raw:match "^%d+$" then return { count = tonumber(raw) } end

  if raw:sub(1, 1) ~= "{" or raw:sub(-1) ~= "}" then
    return nil, string.format("squad: unable to parse options `%s`", raw)
  end

  local body = raw:sub(2, -2)
  local opts = {}
  for _, chunk in ipairs(split_top_level(body, ",")) do
    if chunk ~= "" then
      local key, value = chunk:match "^([^=]+)=(.+)$"
      if not key then return nil, string.format("squad: invalid option `%s`", chunk) end
      key = trim(key)
      opts[key] = parse_value(value)
    end
  end

  if opts.count ~= nil then opts.count = tonumber(opts.count) end

  return opts
end

local function parse_agent_spec(raw)
  raw = trim(raw or "")
  if raw == nil or raw == "" then return nil, "squad: empty agent specification" end

  local without_prompt, prompt = extract_prompt(raw)
  local name, rest = without_prompt:match "^([^:]+)::(.+)$"
  if not name then
    local leading, inline_opts = without_prompt:match "^(.-)(%b{})%s*$"
    if leading and inline_opts then
      name = leading
      rest = inline_opts
    else
      name = without_prompt
    end
  end

  name = trim(name)
  if not name or name == "" then return nil, "squad: missing agent name" end

  local worktree
  local slash_pos = name:find "/"
  if slash_pos then
    worktree = trim(name:sub(slash_pos + 1))
    name = trim(name:sub(1, slash_pos - 1))
    if worktree == "" then worktree = nil end
  end

  local opts, err
  if rest then
    opts, err = parse_options(rest)
    if not opts then return nil, err end
  else
    opts = {}
  end

  if prompt and prompt ~= "" then
    if prompt:sub(1, 1) == "/" then
      local comma_pos = prompt:find ","
      if comma_pos then
        worktree = trim(prompt:sub(2, comma_pos - 1))
        prompt = trim(prompt:sub(comma_pos + 1))
      else
        worktree = trim(prompt:sub(2))
        prompt = nil
      end
    elseif prompt:find "=" then
      local inline_opts = select(1, parse_options("{" .. prompt .. "}"))
      if inline_opts then
        opts = vim.tbl_deep_extend("force", opts, inline_opts)
        prompt = nil
      end
    end
  end

  local count = tonumber(opts.count) or tonumber(opts.replicas) or 1
  if count < 1 then count = 1 end
  opts.count = nil
  opts.replicas = nil

  return {
    name = name,
    prompt = prompt,
    options = opts,
    count = count,
    worktree = worktree,
  }
end

function M.parse_agent_spec(raw) return parse_agent_spec(raw) end

function M.parse_layout_and_agents(arg_line, opts)
  opts = opts or {}
  local default_layout = opts.default_layout or M.DEFAULT_LAYOUT
  local layout_aliases = opts.layout_aliases or M.LAYOUT_ALIASES

  local input = trim(arg_line or "")
  if input == "" then return nil, "squad: no agent specification provided" end

  local layout = vim.deepcopy(default_layout)
  local rest
  local layout_alias

  if input:sub(1, 2) == "::" then
    rest = trim(input:sub(3))
  else
    local candidate_alias, layout_rest = input:match "^([%a%-_]+)::(.*)$"
    if candidate_alias and layout_aliases[candidate_alias] then
      layout = vim.tbl_deep_extend("force", layout, layout_aliases[candidate_alias])
      rest = trim(layout_rest or "")
      layout_alias = candidate_alias
    else
      rest = input
    end
  end

  rest = rest or ""

  if layout_alias and (layout_alias == "left" or layout_alias == "right") then
    if rest:match "^%s*%[" then
      layout = vim.deepcopy(default_layout)
      rest = input
      layout_alias = nil
    end
  end

  local function parse_grouped_specs(spec_str)
    local groups = {}
    local chunks = split_top_level(spec_str, ",")

    local function append_agent(fragment, position)
      fragment = trim(fragment)
      if fragment == "" then return true end
      local spec, err = parse_agent_spec(fragment)
      if not spec then return nil, err end
      if position then spec.position = position end
      groups[#groups + 1] = spec
      return true
    end

    for _, chunk in ipairs(chunks) do
      chunk = trim(chunk)
      if chunk == "" then goto continue end

      if chunk:sub(1, 1) == "[" and chunk:sub(-1) == "]" then
        local inner = trim(chunk:sub(2, -2))
        if inner ~= "" then
          for _, agent_fragment in ipairs(split_top_level(inner, ",")) do
            local ok, err = append_agent(agent_fragment)
            if not ok then return nil, err end
          end
        end
        goto continue
      end

      local side, group_content = chunk:match "^(%a+)%s*::(.+)$"
      side = side and side:lower()
      if side == "left" or side == "right" then
        local inner = trim(group_content)
        if inner:sub(1, 1) == "[" and inner:sub(-1) == "]" then inner = trim(inner:sub(2, -2)) end

        if inner ~= "" then
          for _, agent_fragment in ipairs(split_top_level(inner, ",")) do
            local ok, err = append_agent(agent_fragment, side)
            if not ok then return nil, err end
          end
        end
        goto continue
      end

      local ok, err = append_agent(chunk)
      if not ok then return nil, err end
      ::continue::
    end

    return groups, nil
  end

  local agent_specs, parse_err = parse_grouped_specs(rest)

  if not agent_specs and layout_alias and (layout_alias == "left" or layout_alias == "right") then
    layout = vim.deepcopy(default_layout)
    rest = input
    agent_specs, parse_err = parse_grouped_specs(rest)
    if agent_specs and not vim.tbl_isempty(agent_specs) then layout_alias = nil end
  end

  if not agent_specs then return nil, parse_err or "squad: failed to parse agent specifications" end

  if #agent_specs == 0 then return nil, "squad: no valid agent specification found" end

  local has_left = false
  local has_right = false
  for _, spec in ipairs(agent_specs) do
    if spec.position == "left" then has_left = true end
    if spec.position == "right" then has_right = true end
  end

  if has_left or has_right then
    layout.mode = "vertical"
    if has_left and has_right then
      layout.split_groups = true
    elseif has_left then
      layout.position = "left"
    elseif has_right then
      layout.position = "right"
    end
  end

  return layout, agent_specs
end

function M.build_single_agent_spec(agent, raw_args, opts)
  opts = opts or {}
  local layout_aliases = opts.layout_aliases or M.LAYOUT_ALIASES

  local payload = trim(raw_args or "")
  local layout_prefix = ""
  local remainder = payload

  local function set_layout(token, rest)
    if not token or token == "" then return false end
    local normalized = token:lower()
    if not layout_aliases[normalized] then return false end
    layout_prefix = normalized .. "::"
    remainder = trim(rest or "")
    return true
  end

  if remainder ~= "" then
    local token, rest = remainder:match "^([%w%-_]+)::(.*)$"
    if not set_layout(token, rest) then
      if not set_layout(remainder, "") then
        local first, rest_words = remainder:match "^([%w%-_]+)%s+(.+)$"
        if first then set_layout(first, rest_words) end
      end
    end
  end

  local spec = agent
  if remainder == "" then return layout_prefix .. spec end

  local lower_remainder = remainder:lower()
  if lower_remainder == agent then return layout_prefix .. remainder end
  if lower_remainder:sub(1, #agent + 2) == agent .. "::" then return layout_prefix .. remainder end

  if remainder:sub(1, 2) == "::" then return layout_prefix .. spec .. remainder end

  if remainder:sub(1, 1) == "{" then return layout_prefix .. string.format("%s::%s", spec, remainder) end

  if remainder:sub(1, 1) == "[" then return layout_prefix .. spec .. remainder end

  local escaped = remainder:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n")
  return layout_prefix .. string.format('%s[args="%s"]', spec, escaped)
end

M.trim = trim
M.split_top_level = split_top_level
M.last_top_level_chunk = last_top_level_chunk
M.trailing_unmatched_segment = trailing_unmatched_segment
M.parse_value = parse_value
M.extract_prompt = extract_prompt
M.parse_options = parse_options

return M
