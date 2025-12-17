local SquadDSL = require "utils.squad.dsl"
local SquadSpec = require "utils.squad.spec"

local Completion = {}
Completion.__index = Completion

local DEFAULT_OPTION_TEMPLATES = {
  "{count=}",
  "{model=}",
  "{agent=}",
  "{cwd=}",
  "{env=}",
  "{cmd=}",
  "{args=}",
  "{width=}",
  "{height=}",
}

local DEFAULT_OPTION_KEYS = {
  "count=",
  "model=",
  "agent=",
  "cwd=",
  "env=",
  "cmd=",
  "args=",
  "width=",
  "height=",
}

local function collect_spec_templates()
  local seen, out = {}, {}
  for _, case in ipairs(SquadSpec.parse_cases or {}) do
    local value = case.input
    if value and not seen[value] then
      table.insert(out, value)
      seen[value] = true
    end
  end
  table.sort(out)
  return out
end

local function collect_layout_completions(layout_aliases)
  local items = {}
  local seen = {}
  for alias in pairs(layout_aliases) do
    if not seen[alias] then
      table.insert(items, alias .. "::")
      seen[alias] = true
    end
  end
  table.sort(items)
  return items
end

local function sort_agent_names(names)
  table.sort(names)
  return names
end

function Completion.new(opts)
  opts = opts or {}
  local self = setmetatable({}, Completion)
  self.layout_aliases = opts.layout_aliases or SquadDSL.LAYOUT_ALIASES
  self.agent_models = opts.agent_models or {}
  if opts.agent_names then
    self.agent_names = sort_agent_names(vim.deepcopy(opts.agent_names))
  else
    self.agent_names = sort_agent_names(vim.tbl_keys(self.agent_models))
  end
  self.spec_templates = opts.spec_templates or collect_spec_templates()
  self.option_templates = opts.option_templates or vim.deepcopy(DEFAULT_OPTION_TEMPLATES)
  self.option_keys = opts.option_keys or vim.deepcopy(DEFAULT_OPTION_KEYS)
  self.layout_completions = opts.layout_completions or collect_layout_completions(self.layout_aliases)
  return self
end

local function sanitize_lead(lead)
  lead = (lead or ""):gsub("^%s+", "")
  if lead == "" then return "" end
  local last_break = 0
  for i = 1, #lead do
    local ch = lead:sub(i, i)
    if
      ch == ":"
      or ch == ","
      or ch == "["
      or ch == "]"
      or ch == "{"
      or ch == "}"
      or ch == "("
      or ch == ")"
      or ch == " "
    then
      last_break = i
    end
  end
  local result = lead:sub(last_break + 1)
  result = result:gsub("^[%]%}%)]*", "")
  return result
end

local function with_layout_prefix(prefix, text)
  text = text or ""
  if prefix == "" then return text end
  if text == "" then return prefix end
  return prefix .. text
end

local function prompt_payload_state(payload)
  payload = payload or ""
  local trimmed = payload:gsub("]%s*$", "")
  local needs_close = trimmed == payload
  return trimmed, needs_close
end

local function cmd_line_before_cursor(cmd_line, cursor_pos)
  if type(cmd_line) ~= "string" then return "" end
  if type(cursor_pos) ~= "number" then return cmd_line end

  if cursor_pos < 0 then cursor_pos = 0 end
  if cursor_pos > #cmd_line then cursor_pos = #cmd_line end

  return cmd_line:sub(1, cursor_pos)
end

function Completion:complete(arg_lead, cmd_line, cursor_pos)
  local suggestions = {}
  local seen = {}

  cmd_line = cmd_line_before_cursor(cmd_line or "", cursor_pos)

  local after_cmd = cmd_line:match "^%s*:%S+%s*(.*)$" or ""
  local spec = SquadDSL.trim(after_cmd)

  local layout_prefix = ""
  if spec:sub(1, 2) == "::" then
    layout_prefix = "::"
    spec = SquadDSL.trim(spec:sub(3))
  else
    local head, rest = spec:match "^([%a%-_]+)::(.*)$"
    if head and self.layout_aliases[head] and head ~= "left" and head ~= "right" then
      layout_prefix = head .. "::"
      spec = SquadDSL.trim(rest or "")
    end
  end

  local segment = SquadDSL.trailing_unmatched_segment(spec, "[", "]")
  local chunk_source
  if segment == nil or segment == "" then
    chunk_source = spec
  else
    chunk_source = segment
  end

  local raw_current = SquadDSL.trim(chunk_source)
  local current = raw_current
  current = current:gsub("^%[", "")
  current = current:gsub("]%s*$", "")
  current = current:gsub("^,", "")
  current = SquadDSL.trim(current)

  local prefix_before_current
  if current == "" then
    prefix_before_current = with_layout_prefix(layout_prefix, spec)
  else
    local before_len = #spec - #current
    if before_len < 0 then before_len = 0 end
    if before_len == 0 then
      prefix_before_current = with_layout_prefix(layout_prefix, "")
    else
      prefix_before_current = with_layout_prefix(layout_prefix, spec:sub(1, before_len))
    end
  end

  local base_lead = sanitize_lead(arg_lead)
  local inside_brackets = segment ~= nil
  local layout_group_mode = layout_prefix ~= "" and spec:sub(1, 1) == "["

  local function add(value, opts)
    opts = opts or {}
    local needle = opts.needle
    if needle == nil then needle = base_lead end
    if needle ~= "" and not vim.startswith(value, needle) then return end
    local suffix = opts.suffix or ""
    local candidate
    if opts.absolute then
      candidate = value .. suffix
    else
      candidate = (prefix_before_current or "") .. (opts.keep or "") .. value .. suffix
    end
    if not seen[candidate] then
      seen[candidate] = true
      table.insert(suggestions, candidate)
    end
  end

  local function add_agent_completions(opts)
    opts = opts or {}
    local suffix = opts.suffix
    if suffix == nil then suffix = (inside_brackets or opts.keep and opts.keep:sub(-1) == "[") and "" or "::" end
    for _, agent in ipairs(self.agent_names) do
      add(agent .. suffix, { keep = opts.keep, suffix = opts.trailing, needle = opts.needle })
    end
  end

  local function add_option_templates(agent)
    for _, template in ipairs(self.option_templates) do
      add(template, { keep = agent .. "::" })
    end
    add("2", { keep = agent .. "::" })
  end

  if spec == "" then
    for _, template in ipairs(self.spec_templates or {}) do
      add(template)
    end
    for _, alias in ipairs(self.layout_completions) do
      add(alias)
    end
    add_agent_completions()
    return suggestions
  end

  if current == "" then
    if layout_group_mode then
      add_agent_completions { suffix = "" }
      add_agent_completions { suffix = "]" }
      add_agent_completions { suffix = "," }
      return suggestions
    end
    add_agent_completions()
    if not inside_brackets and layout_prefix == "" then
      for _, alias in ipairs(self.layout_completions) do
        add(alias)
      end
    end
    return suggestions
  end

  local prompt_agent, prompt_payload = raw_current:match "^([%w%-%._/]+)%[(.*)$"
  if prompt_agent and not raw_current:find "::" then
    local trimmed_payload, needs_close = prompt_payload_state(prompt_payload)
    local function add_prompt(value, opts)
      opts = opts or {}
      local suffix = opts.suffix
      if suffix == nil and needs_close then suffix = "]" end
      add(value, { keep = prompt_agent .. "[", suffix = suffix })
    end
    add_prompt 'args=""'
    add_prompt 'args="Use previous instructions"'
    if trimmed_payload == "" then add_prompt 'args="/worktree,"' end
    return suggestions
  end

  local name, remainder = current:match "^([^:]+)::(.*)$"
  if not name or name == "" then
    add_agent_completions()
    if layout_prefix == "" and not inside_brackets then
      for _, alias in ipairs(self.layout_completions) do
        add(alias)
      end
    end
    return suggestions
  end

  remainder = SquadDSL.trim(remainder or "")
  if remainder:sub(1, 1) == "[" then
    local keep = name .. "::["
    local needs_close = remainder:sub(-1) ~= "]"
    add_agent_completions { keep = keep, suffix = needs_close and "]" or "" }
    add_agent_completions { keep = keep, suffix = "," }
    return suggestions
  end

  if remainder == "" then
    add_option_templates(name)
    return suggestions
  end

  if remainder:sub(1, 1) ~= "{" then
    add(name .. "::" .. remainder .. "{}")
    return suggestions
  end

  local inside = remainder:sub(2)
  inside = inside:gsub("^%s*", "")
  local pending = SquadDSL.last_top_level_chunk(inside)
  pending = pending:gsub("^,", "")
  pending = SquadDSL.trim(pending)

  local key, value_part = pending:match "^([%w_]+)=(.*)$"
  if not key and pending == "model" then
    key, value_part = "model", ""
  end

  local prefix_keep
  if pending == "" then
    prefix_keep = current
  else
    local before_len = #current - #pending
    if before_len < 0 then before_len = 0 end
    if before_len == 0 then
      prefix_keep = current
    else
      prefix_keep = current:sub(1, before_len)
    end
  end

  if key == "model" then
    local typed = SquadDSL.trim(value_part or "")
    local target_models = self.agent_models[name] or {}
    for _, model in ipairs(target_models) do
      if typed == "" or vim.startswith(model, typed) then add("model=" .. model, { keep = prefix_keep }) end
    end
    if typed ~= "" then add("model=" .. typed, { keep = prefix_keep }) end
    return suggestions
  end

  if key == "agent" then
    local typed = SquadDSL.trim(value_part or "")
    for _, val in ipairs { "true", "false" } do
      if typed == "" or vim.startswith(val, typed) then add("agent=" .. val, { keep = prefix_keep }) end
    end
    return suggestions
  end

  for _, value in ipairs(self.option_keys) do
    add(value, { keep = prefix_keep })
  end

  if pending ~= "" and not pending:find "=" then
    for _, value in ipairs(self.option_keys) do
      add(pending .. value, { keep = prefix_keep })
    end
  end

  return suggestions
end

return Completion
