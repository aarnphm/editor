local cwd = vim.fn.getcwd()
package.path = table.concat({ cwd .. "/lua/?.lua", cwd .. "/lua/?/init.lua", package.path }, ";")

local SquadDSL = require "utils.squad.dsl"
local SquadComplete = require "utils.squad.complete"

local completer = SquadComplete.new {
  layout_aliases = SquadDSL.LAYOUT_ALIASES,
  agent_models = {
    codex = { "gpt-5-codex", "gpt-4o" },
    claude = { "sonnet", "haiku" },
    cursor = { "composer-1" },
    gemini = { "gemini-2.5-pro" },
  },
}

local cases = {
  {
    label = "layout bracket agent",
    cmd_line = ":Squad vertical::[",
    lead = "",
    expect_fragment = "vertical::[codex",
  },
  {
    label = "agent option brace",
    cmd_line = ":Squad codex::{",
    lead = "",
    expect_fragment = "codex::{model=",
  },
  {
    label = "prompt args bracket",
    cmd_line = ":Squad codex[",
    lead = "",
    expect_fragment = 'codex[args=""',
  },
  {
    label = "spec template surfaced",
    cmd_line = ":Squad ",
    lead = "",
    expect_fragment = "vertical::[codex,claude]",
  },
}

local function has_fragment(items, fragment)
  for _, item in ipairs(items) do
    if item:find(fragment, 1, true) then return true end
  end
  return false
end

for _, case in ipairs(cases) do
  local result = completer:complete(case.lead or "", case.cmd_line, 0)
  assert(
    has_fragment(result, case.expect_fragment),
    string.format("completion %s missing `%s`", case.label, case.expect_fragment)
  )
end

print "[squad] completion verification passed"
