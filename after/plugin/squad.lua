-- Command:
-- :Squad vertical::[codex,claude,[...]]
--  here: it will create a vertical window layout, to the right, with two horizontally-split panels, for codex and claude-code
-- :Squad codex::2,claude::2
--  here: it will create a horizontal panel, to the bottom, with 4 vertical-split panels, 2 for codex, 2 for claude-code
-- :Squad codex::{model=gpt-5-codex},codex::{model=gpt-4o}
--  here: will follow similar layout scheme, but then each of the two codex panel, first one uses gpt-5-codex, the second one uses gpt-4o
-- :Squad codex::{model=gpt-5-codex}[Some prompt here]
--  here: will follow similar layout scheme, but additionally it will pass in the prompt here.
-- :Squad codex::{agent=true}
--  here: enables agent mode, passing --dangerously-bypass-approvals-and-sandbox for codex
-- :Squad claude::{agent=true}
--  here: enables agent mode, passing --allow-dangerously-skip-permissions for claude
-- :Squad left::[gemini,claude],right::[codex,cursor]
--  here: create left panel, with gemini and claude, and a right panel, with codex and cursor agent
--
--  Now, but should be using `codex` and `claude` respectively. We should only follow either AGENTS.md or CLAUDE.md
--  - If either one exists, then we should create a shallow ls to the other
--  - If both exists, then respect them, don't do anything.
--
--  For the laststatus bar of each terminal panel, we should then show the command specified here.
--
--  Contention idea:
--  - expose a lightweight, lock-free queue so codex/claude MCP clients can enqueue edits per-buffer.
--  - The same queue can later fan-out via a control panel buffer to accept/merge/cancel competing changes without
--    blocking streaming output if we add additional protocols in the future.
--  - Each queue item would include `{buf, range, agent, instructions, proposed_at}` so the control panel can surface
--    conflicting entries and allow the user to accept/merge/drop without stalling streaming output.
--  - How would we plumb the implementation?
--  Canonical command samples live in lua/utils/squad/spec.lua and are exercised by tests/run_squad_spec.lua.

if not _G.Util then return end

local Util = require "utils"
local async = require "plenary.async"
local async_util = require "plenary.async.util"
local scheduler = async_util.scheduler
local uv = vim.loop
local SquadDSL = require "utils.squad.dsl"
local SquadComplete = require "utils.squad.complete"

---@class SquadPanel
---@field name string
---@field prompt? string
---@field options table
---@field cmd string[]
---@field term_opts table

---@class SquadEntry
---@field win integer
---@field buf integer
---@field panel SquadPanel
---@field job? integer
---@field closed? boolean

local active_squad ---@type { entries: SquadEntry[], layout: table }?
local stop_squad ---@type fun(reason?: string, err?: string)|nil

local DEFAULT_LAYOUT = SquadDSL.DEFAULT_LAYOUT

local DEFAULT_CODEX_MODEL = "gpt-5.1"
local DEFAULT_CLAUDE_MODEL = "claude-sonnet-4-5-20250929"
local DEFAULT_CURSOR_MODEL = "composer-1"
local DEFAULT_GEMINI_MODEL = "gemini-3-pro"
local DEFAULT_SQUAD_SPEC = string.format("codex::1[model=%s]", DEFAULT_CODEX_MODEL)

local LAYOUT_ALIASES = SquadDSL.LAYOUT_ALIASES

local trim = SquadDSL.trim
local last_top_level_chunk = SquadDSL.last_top_level_chunk
local trailing_unmatched_segment = SquadDSL.trailing_unmatched_segment

local function parse_layout_and_agents(arg_line)
  return SquadDSL.parse_layout_and_agents(arg_line, {
    default_layout = DEFAULT_LAYOUT,
    layout_aliases = LAYOUT_ALIASES,
  })
end

local CODEX_MODELS = {
  "gpt-5.1-codex",
  "gpt-5.1",
  "gpt-5",
  "gpt-4.1",
  "gpt-4o",
  "o4-mini",
}

local CLAUDE_MODELS = {
  "sonnet",
  "opus",
  "haiku",
}

local CURSOR_MODELS = {
  "gpt-5",
  "gpt-5-codex",
  "composer-1",
  "sonnet-4.5",
  "sonnet-4.5-thinking",
}

local GEMINI_MODELS = {
  "gemini-3-pro",
  "gemini-2.5-flash",
  "gemini-2.5-flash-lite",
  "gemini-2.5-pro",
}

local AGENT_MODEL_SUGGESTIONS = {
  codex = CODEX_MODELS,
  claude = CLAUDE_MODELS,
  cursor = CURSOR_MODELS,
  gemini = GEMINI_MODELS,
}

local SquadCompleter = SquadComplete.new {
  layout_aliases = LAYOUT_ALIASES,
  agent_models = AGENT_MODEL_SUGGESTIONS,
}

local RESERVED_OPTION_KEYS = {
  count = true,
  model = true,
  cwd = true,
  env = true,
  cmd = true,
  args = true,
  width = true,
  height = true,
  agent = true,
}

-- worktree configuration
local WORKTREE_BASE_DIR = vim.env.SQUAD_WORKTREE_DIR or (vim.fn.stdpath "state" .. "/squad/worktrees")
local WORKTREE_STATE_FILE = vim.fn.stdpath "state" .. "/squad/worktree-state.json"
local WORKTREE_NAME_PATTERN = "^[%w][%w%-_]*$"

local function format_command_display(cmd)
  local parts = {}
  for _, part in ipairs(cmd) do
    part = tostring(part)
    if part:find "%s" then
      parts[#parts + 1] = string.format('"%s"', part)
    else
      parts[#parts + 1] = part
    end
  end
  return table.concat(parts, " ")
end

local function normalize_env(env)
  if type(env) ~= "table" then return nil end
  local normalized = {}
  for k, v in pairs(env) do
    if type(k) == "string" and k ~= "" then normalized[k] = tostring(v) end
  end
  return normalized
end

local function combine_env(defaults, env)
  local result = {}

  if type(defaults) == "table" then
    for key, value in pairs(defaults) do
      if type(key) == "string" and key ~= "" and value ~= nil then result[key] = tostring(value) end
    end
  end

  local normalized = normalize_env(env)
  if normalized then
    for key, value in pairs(normalized) do
      result[key] = value
    end
  end

  if vim.tbl_isempty(result) then return nil end
  return result
end

-- worktree state management
local function ensure_worktree_state_dir()
  local dir = vim.fn.fnamemodify(WORKTREE_STATE_FILE, ":h")
  if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
end

local function load_worktree_state()
  if vim.fn.filereadable(WORKTREE_STATE_FILE) == 0 then return { worktrees = {} } end

  local ok, content = pcall(vim.fn.readfile, WORKTREE_STATE_FILE)
  if not ok or not content then return { worktrees = {} } end

  local json_str = table.concat(content, "\n")
  ok, content = pcall(vim.fn.json_decode, json_str)
  if not ok or type(content) ~= "table" then return { worktrees = {} } end

  return content
end

local function save_worktree_state(state)
  if type(state) ~= "table" then return false end

  ensure_worktree_state_dir()
  local ok, json_str = pcall(vim.fn.json_encode, state)
  if not ok then return false end

  ok = pcall(vim.fn.writefile, { json_str }, WORKTREE_STATE_FILE)
  return ok
end

local function get_worktree_path(name)
  if not name or name == "" then return nil end
  return WORKTREE_BASE_DIR .. "/" .. name
end

local function validate_worktree_name(name)
  if not name or name == "" then return false, "worktree name cannot be empty" end

  if not name:match(WORKTREE_NAME_PATTERN) then
    return false,
      string.format(
        "invalid worktree name `%s`: must start with alphanumeric and contain only alphanumeric, dash, or underscore",
        name
      )
  end

  return true
end

local function register_worktree(name, path, branch, agent)
  local state = load_worktree_state()
  state.worktrees = state.worktrees or {}

  if not state.worktrees[name] then
    state.worktrees[name] = {
      path = path,
      branch = branch,
      agents = { agent },
      created_at = os.time(),
      last_used = os.time(),
    }
  else
    state.worktrees[name].last_used = os.time()
    local agents = state.worktrees[name].agents or {}
    local found = false
    for _, a in ipairs(agents) do
      if a == agent then
        found = true
        break
      end
    end
    if not found then table.insert(agents, agent) end
    state.worktrees[name].agents = agents
  end

  save_worktree_state(state)
end

-- git worktree operations
local function is_git_repo()
  local result = vim.fn.system "git rev-parse --is-inside-work-tree 2>/dev/null"
  return vim.v.shell_error == 0 and trim(result) == "true"
end

local function get_git_root()
  if not is_git_repo() then return nil end
  local root = vim.fn.system "git rev-parse --show-toplevel 2>/dev/null"
  if vim.v.shell_error ~= 0 then return nil end
  return trim(root)
end

local function git_worktree_list()
  local result = vim.fn.system "git worktree list --porcelain 2>/dev/null"
  if vim.v.shell_error ~= 0 then return {} end

  local worktrees = {}
  local current = {}

  for line in result:gmatch "[^\r\n]+" do
    if line:match "^worktree " then
      if current.path then table.insert(worktrees, current) end
      current = { path = trim(line:sub(10)) }
    elseif line:match "^branch " then
      current.branch = trim(line:sub(8))
    end
  end

  if current.path then table.insert(worktrees, current) end

  return worktrees
end

local function worktree_exists(path)
  local worktrees = git_worktree_list()
  for _, wt in ipairs(worktrees) do
    if wt.path == path then return true, wt.branch end
  end
  return false
end

local function create_worktree(name, source_path)
  local ok, err = validate_worktree_name(name)
  if not ok then return nil, err end

  local path = get_worktree_path(name)
  if not path then return nil, "failed to determine worktree path" end

  -- check if worktree already exists
  local exists, existing_branch = worktree_exists(path)
  if exists then return path, existing_branch end

  -- ensure worktree directory exists
  local base_dir = vim.fn.fnamemodify(path, ":h")
  if vim.fn.isdirectory(base_dir) == 0 then vim.fn.mkdir(base_dir, "p") end

  -- create worktree with new branch
  local branch = "squad/" .. name
  local cmd = string.format("git worktree add -b %s %s 2>&1", vim.fn.shellescape(branch), vim.fn.shellescape(path))
  local result = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    -- branch might already exist, try without -b
    cmd = string.format("git worktree add %s %s 2>&1", vim.fn.shellescape(path), vim.fn.shellescape(branch))
    result = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then return nil, string.format("failed to create worktree: %s", trim(result)) end
  end

  return path, branch
end

-- agent context setup
local function path_exists(path)
  if type(path) ~= "string" or path == "" then return false end
  local stat = uv.fs_lstat(path)
  return stat ~= nil
end

local function safe_symlink(source, target)
  if not path_exists(source) then return false end

  local source_real = uv.fs_realpath(source) or source
  local target_stat = uv.fs_lstat(target)

  if target_stat then
    local existing = uv.fs_realpath(target)
    if existing == source_real then return true end
    vim.fn.delete(target, "rf")
  end

  local parent = vim.fn.fnamemodify(target, ":h")
  if parent ~= "" and parent ~= target and vim.fn.isdirectory(parent) == 0 then vim.fn.mkdir(parent, "p") end

  local source_stat = uv.fs_lstat(source_real) or uv.fs_lstat(source)
  local flags
  if source_stat and source_stat.type == "directory" then
    flags = uv.constants and uv.constants.UV_FS_SYMLINK_DIR or 1
  elseif source_stat and source_stat.type == "file" then
    flags = uv.constants and uv.constants.UV_FS_SYMLINK_FILE or 0
  end

  local ok, err = uv.fs_symlink(source, target, flags)
  if ok then return true end

  -- fallback to shell command when libuv symlink fails (e.g. older platforms)
  local cmd = string.format("ln -s %s %s", vim.fn.shellescape(source), vim.fn.shellescape(target))
  vim.fn.system(cmd)
  if vim.v.shell_error == 0 then return true end

  if err then Util.warn(string.format("squad: symlink failed for %s -> %s (%s)", source, target, err)) end
  return false
end

local function safe_copy(source, target)
  if vim.fn.filereadable(source) == 0 and vim.fn.isdirectory(source) == 0 then return false end

  if vim.fn.filereadable(target) == 1 or vim.fn.isdirectory(target) == 1 then
    -- skip if target already exists
    return true
  end

  local cmd = vim.fn.isdirectory(source) == 1 and "cp -r %s %s" or "cp %s %s"
  cmd = string.format(cmd, vim.fn.shellescape(source), vim.fn.shellescape(target))
  vim.fn.system(cmd)
  return vim.v.shell_error == 0
end

local function setup_claude_context(worktree_path, source_path)
  local warnings = {}

  -- symlink .claude directory if it exists
  local source_claude_path = source_path .. "/.claude"
  if path_exists(source_claude_path) then
    local target_claude_path = worktree_path .. "/.claude"
    if not safe_symlink(source_claude_path, target_claude_path) then
      table.insert(warnings, "failed to symlink .claude")
    end
  end

  -- symlink CLAUDE.md if it exists
  local source_claude_md = source_path .. "/CLAUDE.md"
  if vim.fn.filereadable(source_claude_md) == 1 then
    local target_claude_md = worktree_path .. "/CLAUDE.md"
    if not safe_symlink(source_claude_md, target_claude_md) then
      table.insert(warnings, "failed to symlink CLAUDE.md")
    end
  end

  return warnings
end

local function setup_codex_context(worktree_path, source_path)
  local warnings = {}

  -- copy AGENTS.md if it exists
  local source_agents_md = source_path .. "/AGENTS.md"
  if vim.fn.filereadable(source_agents_md) == 1 then
    local target_agents_md = worktree_path .. "/AGENTS.md"
    if not safe_copy(source_agents_md, target_agents_md) then table.insert(warnings, "failed to copy AGENTS.md") end
  end

  return warnings
end

local function setup_cursor_context(worktree_path, source_path)
  local warnings = {}

  -- prefer CURSOR.md when available, otherwise fall back to AGENTS.md
  local source_cursor_md = source_path .. "/CURSOR.md"
  if vim.fn.filereadable(source_cursor_md) == 1 then
    local target_cursor_md = worktree_path .. "/CURSOR.md"
    if not safe_copy(source_cursor_md, target_cursor_md) then table.insert(warnings, "failed to copy CURSOR.md") end
  else
    local fallback_agents_md = source_path .. "/AGENTS.md"
    if vim.fn.filereadable(fallback_agents_md) == 1 then
      local target_agents_md = worktree_path .. "/AGENTS.md"
      if not safe_copy(fallback_agents_md, target_agents_md) then
        table.insert(warnings, "failed to copy AGENTS.md")
      end
    end
  end

  return warnings
end

local function setup_gemini_context(worktree_path, source_path)
  local warnings = {}

  -- prefer CURSOR.md when available, otherwise fall back to AGENTS.md
  local source_cursor_md = source_path .. "/GEMINI.md"
  if vim.fn.filereadable(source_cursor_md) == 1 then
    local target_cursor_md = worktree_path .. "/GEMINI.md"
    if not safe_copy(source_cursor_md, target_cursor_md) then table.insert(warnings, "failed to copy GEMINI.md") end
  else
    local fallback_agents_md = source_path .. "/AGENTS.md"
    if vim.fn.filereadable(fallback_agents_md) == 1 then
      local target_agents_md = worktree_path .. "/AGENTS.md"
      if not safe_copy(fallback_agents_md, target_agents_md) then
        table.insert(warnings, "failed to copy AGENTS.md")
      end
    end
  end

  return warnings
end

local function setup_agent_context(worktree_path, agent, source_path)
  if agent == "claude" then
    return setup_claude_context(worktree_path, source_path)
  elseif agent == "codex" then
    return setup_codex_context(worktree_path, source_path)
  elseif agent == "cursor" then
    return setup_cursor_context(worktree_path, source_path)
  elseif agent == "gemini" then
    return setup_gemini_context(worktree_path, source_path)
  end
  return {}
end

local function handle_entry_closed(entry)
  entry.closed = true
  if not active_squad or not active_squad.entries then return end
  for _, existing in ipairs(active_squad.entries) do
    if not existing.closed then return end
  end
  active_squad = nil
end

local function apply_terminal_mappings(buf)
  vim.keymap.set("t", "<c-h>", "<c-h>", { buffer = buf, nowait = true })
  vim.keymap.set("t", "<c-j>", "<c-j>", { buffer = buf, nowait = true })
  vim.keymap.set("t", "<c-k>", "<c-k>", { buffer = buf, nowait = true })
  vim.keymap.set("t", "<c-l>", "<c-l>", { buffer = buf, nowait = true })
  -- vim.keymap.set("t", "<c-d>", function()
  --   if stop_squad then stop_squad "manual" end
  -- end, { buffer = buf, nowait = true })
  -- vim.keymap.set("n", "<c-d>", function()
  --   if stop_squad then stop_squad "manual" end
  -- end, { buffer = buf, nowait = true })
  vim.keymap.set("n", "gf", function()
    local f = vim.fn.findfile(vim.fn.expand "<cfile>")
    if f ~= "" then
      vim.cmd "close"
      vim.cmd("e " .. f)
    end
  end, { buffer = buf })
end

local function apply_terminal_autocmds(entry)
  local buf = entry.buf
  local win = entry.win
  if not buf or not win then return end

  vim.b[buf].squad_terminal = true

  vim.api.nvim_create_autocmd({ "BufEnter", "TermEnter" }, {
    buffer = buf,
    callback = function()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      if vim.bo[buf].buftype ~= "terminal" then return end
      if not vim.api.nvim_win_is_valid(win) then return end
      if vim.api.nvim_get_current_buf() ~= buf then return end
      if not (active_squad and active_squad.entries) and not vim.b[buf].squad_restored then return end
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then vim.cmd.startinsert() end
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufLeave", "TermLeave" }, {
    buffer = buf,
    callback = function()
      if vim.fn.mode() == "t" then vim.cmd.stopinsert() end
    end,
  })
end

local function create_scratch_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.b[buf].miniindentscope_disable = true
  return buf
end

local function build_agent_command(panel)
  local name = panel.name
  local opts = panel.options or {}
  local default_env

  if name == "codex" then default_env = { RUST_LOG = "debug" } end

  if type(opts.cmd) == "table" and #opts.cmd > 0 then
    local cmd = vim.deepcopy(opts.cmd)
    local term_opts = { cwd = opts.cwd, env = combine_env(default_env, opts.env) }
    return cmd, term_opts
  elseif type(opts.cmd) == "string" and opts.cmd ~= "" then
    return { opts.cmd }, { cwd = opts.cwd, env = combine_env(default_env, opts.env) }
  end

  local cmd
  if name == "codex" then
    if not opts.model then opts.model = DEFAULT_CODEX_MODEL end
    cmd = { "codex", "--enable", "web_search_request" }
  elseif name == "claude" then
    if not opts.model then opts.model = DEFAULT_CLAUDE_MODEL end
    cmd = { "claude" }
  elseif name == "cursor" then
    if not opts.model then opts.model = DEFAULT_CURSOR_MODEL end
    cmd = { "cursor-agent" }
  elseif name == "gemini" then
    if not opts.model and DEFAULT_GEMINI_MODEL then opts.model = DEFAULT_GEMINI_MODEL end
    cmd = { "gemini" }
  else
    return nil, string.format("squad: unsupported agent `%s`", name)
  end

  local extra_args = {}

  local function add_flag(flag_name, value)
    if value == nil or value == "" then
      table.insert(extra_args, "--" .. flag_name:gsub("_", "-"))
    else
      table.insert(extra_args, "--" .. flag_name:gsub("_", "-"))
      table.insert(extra_args, tostring(value))
    end
  end

  if opts.model then add_flag("model", opts.model) end

  -- Add agent-specific dangerous flags if agent=true
  if opts.agent then
    if name == "codex" then
      table.insert(extra_args, "--dangerously-bypass-approvals-and-sandbox")
    elseif name == "claude" then
      table.insert(extra_args, "--allow-dangerously-skip-permissions")
    elseif name == "cursor" then
      table.insert(extra_args, "--force")
      table.insert(extra_args, "--approve-mcps")
      table.insert(extra_args, "--browser")
    elseif name == "gemini" then
      table.insert(extra_args, "--yolo")
    end
  end

  -- Pass through any additional options (except reserved ones) via args.
  for key, value in pairs(opts) do
    if not RESERVED_OPTION_KEYS[key] and key ~= "model" then add_flag(key, value) end
  end

  if opts.args then
    if type(opts.args) == "table" then
      for _, value in ipairs(opts.args) do
        table.insert(extra_args, tostring(value))
      end
    elseif type(opts.args) == "string" and opts.args ~= "" then
      table.insert(extra_args, opts.args)
    end
  end

  for _, arg in ipairs(extra_args) do
    table.insert(cmd, arg)
  end

  if panel.prompt and panel.prompt ~= "" then table.insert(cmd, panel.prompt) end

  local term_opts = {
    cwd = opts.cwd,
    env = combine_env(default_env, opts.env),
  }

  return cmd, term_opts
end

local function setup_terminal_window(entry, layout)
  local win = entry.win
  local buf = entry.buf
  local panel = entry.panel

  if not vim.api.nvim_win_is_valid(win) then return nil, "squad: window no longer exists" end
  if not vim.api.nvim_buf_is_valid(buf) then return nil, "squad: buffer no longer exists" end

  local cmd = panel.cmd
  local term_opts = panel.term_opts or {}

  vim.api.nvim_set_current_win(win)
  vim.api.nvim_win_set_buf(win, buf)
  pcall(vim.api.nvim_win_set_option, win, "cursorline", false)
  pcall(vim.api.nvim_win_set_option, win, "cursorcolumn", false)
  pcall(vim.api.nvim_win_set_option, win, "number", false)
  pcall(vim.api.nvim_win_set_option, win, "relativenumber", false)
  pcall(vim.api.nvim_win_set_option, win, "winhighlight", "CursorLine:Normal,CursorLineNr:CursorLineNr")

  vim.bo[buf].modifiable = true
  vim.bo[buf].modified = false
  vim.bo[buf].filetype = "lazyterm"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  vim.b[buf].lazyterm_cmd = cmd
  vim.b[buf].miniindentscope_disable = true
  vim.b[buf].squad_panel = panel.name

  local display = format_command_display(cmd)
  pcall(vim.api.nvim_win_set_option, win, "statusline", " " .. display .. " ")

  local persisted_term_opts
  if type(term_opts) == "table" then
    if term_opts.cwd then persisted_term_opts = { cwd = term_opts.cwd } end
    if type(term_opts.env) == "table" then
      persisted_term_opts = persisted_term_opts or {}
      local env_copy = {}
      for key, value in pairs(term_opts.env) do
        if type(key) == "string" and key ~= "" and value ~= nil then env_copy[key] = tostring(value) end
      end
      if not vim.tbl_isempty(env_copy) then
        persisted_term_opts.env = env_copy
      elseif not persisted_term_opts then
        persisted_term_opts = nil
      end
    end
  end

  vim.b[buf].squad_state = {
    panel = panel.name,
    prompt = panel.prompt,
    layout = layout.mode,
    position = layout.position,
    display = display,
    term_opts = persisted_term_opts,
  }

  local job_opts = vim.tbl_deep_extend("force", {}, term_opts)
  job_opts.cwd = job_opts.cwd or Util.root()

  local ok, job_or_err = pcall(function()
    return vim.api.nvim_buf_call(buf, function() return vim.fn.termopen(cmd, job_opts) end)
  end)
  local term_job = ok and job_or_err or -1
  local term_err = ok and nil or job_or_err
  if term_job <= 0 then
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
      if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
    end)
    handle_entry_closed(entry)
    return nil, string.format("squad: failed to start `%s`%s", display, term_err and (": " .. term_err) or "")
  end

  entry.job = term_job

  apply_terminal_mappings(buf)
  apply_terminal_autocmds(entry)

  vim.api.nvim_create_autocmd("TermClose", {
    once = true,
    buffer = buf,
    callback = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
        vim.cmd.redraw()
      end)
      handle_entry_closed(entry)
    end,
  })

  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    buffer = buf,
    callback = function()
      if not vim.api.nvim_win_is_valid(win) then return end
      local target = vim.api.nvim_get_current_win()
      if target ~= win then return end
      pcall(vim.api.nvim_win_set_option, target, "cursorline", false)
      pcall(vim.api.nvim_win_set_option, target, "cursorcolumn", false)
    end,
  })

  if layout.mode == "horizontal" then
    pcall(vim.api.nvim_win_set_option, win, "winfixheight", true)
  else
    pcall(vim.api.nvim_win_set_option, win, "winfixwidth", true)
  end

  return true
end

local function create_horizontal_layout(panels, layout)
  if #panels == 0 then return {} end

  local height = layout.height or DEFAULT_LAYOUT.height
  local entries = {}

  for index, panel in ipairs(panels) do
    local win
    if index == 1 then
      vim.cmd "botright new"
      win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_height(win, height)
      pcall(vim.api.nvim_win_set_option, win, "winfixheight", true)
    else
      local previous = entries[#entries]
      if previous and vim.api.nvim_win_is_valid(previous.win) then vim.api.nvim_set_current_win(previous.win) end
      vim.cmd "vsplit"
      win = vim.api.nvim_get_current_win()
      pcall(vim.api.nvim_win_set_option, win, "winfixheight", true)
    end

    local buf = create_scratch_buffer()
    vim.api.nvim_win_set_buf(win, buf)
    pcall(vim.api.nvim_win_set_option, win, "cursorline", false)
    pcall(vim.api.nvim_win_set_option, win, "cursorcolumn", false)
    pcall(vim.api.nvim_win_set_option, win, "number", false)
    pcall(vim.api.nvim_win_set_option, win, "relativenumber", false)

    entries[#entries + 1] = {
      win = win,
      buf = buf,
      panel = panel,
      closed = false,
    }
  end

  return entries
end

local function create_vertical_layout(panels, layout)
  if #panels == 0 then return {} end

  local width = layout.width or DEFAULT_LAYOUT.width
  local position = layout.position or DEFAULT_LAYOUT.position or "right"
  local source_win = vim.api.nvim_get_current_win()
  local entries = {}

  if layout.split_groups then
    local left_panels = {}
    local right_panels = {}

    for _, panel in ipairs(panels) do
      if panel.position == "left" then
        table.insert(left_panels, panel)
      elseif panel.position == "right" then
        table.insert(right_panels, panel)
      else
        table.insert(left_panels, panel)
      end
    end

    local function create_group(group_panels, group_position)
      local group_entries = {}
      for index, panel in ipairs(group_panels) do
        local win
        if index == 1 then
          if source_win and vim.api.nvim_win_is_valid(source_win) then vim.api.nvim_set_current_win(source_win) end
          vim.cmd "vnew"
          if group_position == "left" then
            vim.cmd "wincmd H"
          else
            vim.cmd "wincmd L"
          end
          win = vim.api.nvim_get_current_win()
          vim.api.nvim_win_set_width(win, width)
          pcall(vim.api.nvim_win_set_option, win, "winfixwidth", true)
        else
          local previous = group_entries[#group_entries]
          if previous and vim.api.nvim_win_is_valid(previous.win) then vim.api.nvim_set_current_win(previous.win) end
          vim.cmd "belowright split"
          win = vim.api.nvim_get_current_win()
          pcall(vim.api.nvim_win_set_option, win, "winfixwidth", true)
        end

        local buf = create_scratch_buffer()
        vim.api.nvim_win_set_buf(win, buf)
        vim.api.nvim_win_set_width(win, width)
        pcall(vim.api.nvim_win_set_option, win, "cursorline", false)
        pcall(vim.api.nvim_win_set_option, win, "cursorcolumn", false)
        pcall(vim.api.nvim_win_set_option, win, "number", false)
        pcall(vim.api.nvim_win_set_option, win, "relativenumber", false)

        group_entries[#group_entries + 1] = {
          win = win,
          buf = buf,
          panel = panel,
          closed = false,
        }
      end
      return group_entries
    end

    if #left_panels > 0 then
      local left_entries = create_group(left_panels, "left")
      for _, entry in ipairs(left_entries) do
        entries[#entries + 1] = entry
      end
    end

    if #right_panels > 0 then
      local right_entries = create_group(right_panels, "right")
      for _, entry in ipairs(right_entries) do
        entries[#entries + 1] = entry
      end
    end
  else
    for index, panel in ipairs(panels) do
      local win
      if index == 1 then
        vim.cmd "vnew"
        if position == "left" then
          vim.cmd "wincmd H"
        else
          vim.cmd "wincmd L"
        end
        win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_width(win, width)
        pcall(vim.api.nvim_win_set_option, win, "winfixwidth", true)
      else
        local previous = entries[#entries]
        if previous and vim.api.nvim_win_is_valid(previous.win) then vim.api.nvim_set_current_win(previous.win) end
        vim.cmd "belowright split"
        win = vim.api.nvim_get_current_win()
        pcall(vim.api.nvim_win_set_option, win, "winfixwidth", true)
      end

      local buf = create_scratch_buffer()
      vim.api.nvim_win_set_buf(win, buf)
      vim.api.nvim_win_set_width(win, width)
      pcall(vim.api.nvim_win_set_option, win, "cursorline", false)
      pcall(vim.api.nvim_win_set_option, win, "cursorcolumn", false)
      pcall(vim.api.nvim_win_set_option, win, "number", false)
      pcall(vim.api.nvim_win_set_option, win, "relativenumber", false)

      entries[#entries + 1] = {
        win = win,
        buf = buf,
        panel = panel,
        closed = false,
      }
    end
  end

  return entries
end

local function create_layout(panels, layout)
  if layout.mode == "vertical" then
    return create_vertical_layout(panels, layout)
  else
    return create_horizontal_layout(panels, layout)
  end
end

local function prepare_panels(agent_specs, layout)
  local panels = {}
  for _, spec in ipairs(agent_specs) do
    local base_options = spec.options or {}
    if base_options.agent == nil then base_options.agent = true end
    for _ = 1, spec.count or 1 do
      local panel = {
        name = spec.name,
        prompt = spec.prompt,
        options = vim.deepcopy(base_options),
        position = spec.position,
      }

      local cmd, term_opts_or_err = build_agent_command(panel)
      if not cmd then return nil, term_opts_or_err end

      panel.cmd = cmd
      panel.term_opts = term_opts_or_err or {}

      panels[#panels + 1] = panel
    end
  end

  return panels
end

local function launch_terminal_panels(entries, layout)
  active_squad = {
    entries = entries,
    layout = layout,
  }

  async.void(function()
    for _, entry in ipairs(entries) do
      scheduler()
      entry.stream_prefix = entry.panel.name
      entry.history = entry.history or {}
      local ok, err = setup_terminal_window(entry, layout)
      if not ok then
        if err then Util.error(err) end
        if stop_squad then stop_squad("error", err) end
        return
      end
    end

    scheduler()
    local first = entries[1]
    if first and vim.api.nvim_win_is_valid(first.win) then
      vim.api.nvim_set_current_win(first.win)
      vim.cmd "startinsert"
    end
  end)()
end

stop_squad = function(reason)
  if not active_squad or not active_squad.entries then return end
  local squad = active_squad
  active_squad = nil

  for _, entry in ipairs(squad.entries) do
    entry.closed = true
    if entry.job and entry.job > 0 then pcall(vim.fn.jobstop, entry.job) end
    if entry.win and vim.api.nvim_win_is_valid(entry.win) then pcall(vim.api.nvim_win_close, entry.win, true) end
    if entry.buf and vim.api.nvim_buf_is_valid(entry.buf) then
      pcall(vim.api.nvim_buf_delete, entry.buf, { force = true })
    end
  end

  if reason == "manual" then Util.info "squad: stopped" end

  vim.schedule(function() pcall(vim.cmd.redraw) end)
end

local function run_squad(args_line)
  local trimmed = trim(args_line or "")
  if trimmed == "" then
    args_line = DEFAULT_SQUAD_SPEC
  else
    args_line = trimmed
  end

  local layout, agent_specs_or_err = parse_layout_and_agents(args_line)
  if not layout then
    Util.error(agent_specs_or_err)
    return
  end

  local panels, panel_err = prepare_panels(agent_specs_or_err, layout)
  if not panels then
    Util.error(panel_err)
    return
  end

  if #panels == 0 then
    Util.warn "squad: nothing to launch"
    return
  end

  local entries = create_layout(panels, layout)
  if not entries or #entries == 0 then
    Util.warn "squad: nothing to launch"
    return
  end

  launch_terminal_panels(entries, layout)
end

local function run_squad_wktr(args_line)
  -- check if we're in a git repo
  if not is_git_repo() then
    Util.error "squad wktr: not in a git repository"
    return
  end

  local git_root = get_git_root()
  if not git_root then
    Util.error "squad wktr: failed to determine git root"
    return
  end

  -- parse layout and agents
  local layout, agent_specs_or_err = parse_layout_and_agents(args_line)
  if not layout then
    Util.error(agent_specs_or_err)
    return
  end

  -- validate and setup worktrees
  local has_worktree = false
  local worktree_map = {}

  for _, spec in ipairs(agent_specs_or_err) do
    if spec.worktree then
      has_worktree = true

      -- validate worktree name
      local ok, err = validate_worktree_name(spec.worktree)
      if not ok then
        Util.error(err)
        return
      end

      -- check for duplicate worktree assignments
      if worktree_map[spec.worktree] then
        if worktree_map[spec.worktree] ~= spec.name then
          Util.error(
            string.format("squad wktr: worktree `%s` cannot be shared between different agents", spec.worktree)
          )
          return
        end
      else
        worktree_map[spec.worktree] = spec.name
      end

      -- create or verify worktree
      local worktree_path, branch = create_worktree(spec.worktree, git_root)
      if not worktree_path then
        Util.error(branch) -- branch contains error message
        return
      end

      -- setup agent context
      local warnings = setup_agent_context(worktree_path, spec.name, git_root)
      for _, warning in ipairs(warnings) do
        Util.warn(string.format("squad wktr: %s", warning))
      end

      -- set cwd to worktree path
      spec.options = spec.options or {}
      spec.options.cwd = worktree_path

      -- register worktree
      register_worktree(spec.worktree, worktree_path, branch, spec.name)

      Util.info(string.format("squad wktr: using worktree `%s` for %s at %s", spec.worktree, spec.name, worktree_path))
    end
  end

  -- reject if no worktrees were specified
  if not has_worktree then
    Util.error "squad wktr: no worktrees specified (use regular :Squad command instead)"
    return
  end

  -- prepare panels
  local panels, panel_err = prepare_panels(agent_specs_or_err, layout)
  if not panels then
    Util.error(panel_err)
    return
  end

  if #panels == 0 then
    Util.warn "squad wktr: nothing to launch"
    return
  end

  -- create layout and launch
  local entries = create_layout(panels, layout)
  if not entries or #entries == 0 then
    Util.warn "squad wktr: nothing to launch"
    return
  end

  launch_terminal_panels(entries, layout)
end

local function squad_complete(arg_lead, cmd_line, cursor_pos)
  return SquadCompleter:complete(arg_lead, cmd_line, cursor_pos)
end

_G.Squad = _G.Squad or {}

function _G.Squad.rehydrate_terminal(win, buf, state)
  if not win or not buf then return end
  if not vim.api.nvim_win_is_valid(win) or not vim.api.nvim_buf_is_valid(buf) then return end
  vim.b[buf].squad_restored = true
  if state then vim.b[buf].squad_state = vim.deepcopy(state) end
  apply_terminal_mappings(buf)
  apply_terminal_autocmds { buf = buf, win = win }
  if state and state.display then
    pcall(vim.api.nvim_win_set_option, win, "statusline", " " .. state.display .. " ")
  end
end

vim.api.nvim_create_user_command("Squad", function(opts)
  local args = opts.args or ""
  local trimmed = trim(args)

  -- check if first argument is wktr subcommand
  if trimmed:match "^wktr%s+" or trimmed == "wktr" then
    local wktr_args = trim(trimmed:sub(5)) -- remove "wktr" prefix
    run_squad_wktr(wktr_args)
  else
    run_squad(args)
  end
end, {
  desc = "launch multiple agents in a shared terminal layout (use 'wktr' subcommand for worktrees)",
  nargs = "*",
  complete = squad_complete,
})

vim.api.nvim_create_user_command(
  "Codex",
  function(opts) run_squad(SquadDSL.build_single_agent_spec("codex", opts.args, { layout_aliases = LAYOUT_ALIASES })) end,
  {
    desc = "launch a single Codex squad terminal",
    nargs = "*",
  }
)

vim.api.nvim_create_user_command(
  "Claude",
  function(opts) run_squad(SquadDSL.build_single_agent_spec("claude", opts.args, { layout_aliases = LAYOUT_ALIASES })) end,
  {
    desc = "launch a single Claude squad terminal",
    nargs = "*",
  }
)

vim.api.nvim_create_user_command(
  "Cursor",
  function(opts) run_squad(SquadDSL.build_single_agent_spec("cursor", opts.args, { layout_aliases = LAYOUT_ALIASES })) end,
  {
    desc = "launch a single Cursor squad terminal",
    nargs = "*",
  }
)

vim.api.nvim_create_user_command(
  "Gemini",
  function(opts) run_squad(SquadDSL.build_single_agent_spec("gemini", opts.args, { layout_aliases = LAYOUT_ALIASES })) end,
  {
    desc = "launch a single Gemini squad terminal",
    nargs = "*",
  }
)
