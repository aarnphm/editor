local cwd = vim.fn.getcwd()
package.path = table.concat({ cwd .. "/lua/?.lua", cwd .. "/lua/?/init.lua", package.path }, ";")

local SquadDSL = require "utils.squad.dsl"
local squad_spec = require "utils.squad.spec"

local function assert_subset(actual, expected, context)
  if not expected then return end
  for key, value in pairs(expected) do
    local path = context and (context .. "." .. key) or key
    if type(value) == "table" and type(actual[key]) == "table" then
      assert_subset(actual[key], value, path)
    else
      assert(
        actual[key] == value,
        string.format("%s expected %s but got %s", path, vim.inspect(value), vim.inspect(actual[key]))
      )
    end
  end
end

for _, case in ipairs(squad_spec.parse_cases) do
  local layout, agents = SquadDSL.parse_layout_and_agents(case.input)
  assert(layout, "layout missing for " .. case.label)
  assert(agents, "agents missing for " .. case.label)
  if case.layout then assert_subset(layout, case.layout, case.label .. ".layout") end
  assert(#agents == #case.agents, string.format("%s expected %d agents got %d", case.label, #case.agents, #agents))
  for idx, expected in ipairs(case.agents) do
    local actual = agents[idx]
    assert(
      actual.name == expected.name,
      string.format("%s agent %d expected %s got %s", case.label, idx, expected.name, actual.name)
    )
    if expected.count then
      assert(actual.count == expected.count, string.format("%s agent %s count", case.label, expected.name))
    end
    if expected.prompt then
      assert(actual.prompt == expected.prompt, string.format("%s agent %s prompt", case.label, expected.name))
    end
    if expected.position then
      assert(actual.position == expected.position, string.format("%s agent %s position", case.label, expected.name))
    end
    if expected.worktree then
      assert(actual.worktree == expected.worktree, string.format("%s agent %s worktree", case.label, expected.name))
    end
    if expected.options then
      for key, value in pairs(expected.options) do
        assert(actual.options[key] == value, string.format("%s agent %s option %s", case.label, expected.name, key))
      end
    end
  end
end

for _, case in ipairs(squad_spec.builder_cases) do
  local output = SquadDSL.build_single_agent_spec(case.agent, case.input)
  assert(output == case.expected, string.format("builder %s expected %s got %s", case.label, case.expected, output))
end

print "[squad] spec verification passed"
