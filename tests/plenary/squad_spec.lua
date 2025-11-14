local SquadDSL = require "utils.squad.dsl"
local squad_spec = require "utils.squad.spec"

local function assert_subset(actual, expected)
  if not expected then return end
  for key, value in pairs(expected) do
    if type(value) == "table" and type(actual[key]) == "table" then
      assert_subset(actual[key], value)
    else
      assert.equals(value, actual[key])
    end
  end
end

describe("Squad DSL parser", function()
  for _, case in ipairs(squad_spec.parse_cases) do
    it("parses " .. case.label, function()
      local layout, agents = SquadDSL.parse_layout_and_agents(case.input)
      assert.is_not_nil(layout)
      assert.is_not_nil(agents)

      if case.layout then assert_subset(layout, case.layout) end
      assert.equals(#case.agents, #agents)

      for idx, expected in ipairs(case.agents) do
        local actual = agents[idx]
        assert.equals(expected.name, actual.name)
        if expected.count then assert.equals(expected.count, actual.count) end
        if expected.prompt then assert.equals(expected.prompt, actual.prompt) end
        if expected.position then assert.equals(expected.position, actual.position) end
        if expected.worktree then assert.equals(expected.worktree, actual.worktree) end
        if expected.options then
          for key, value in pairs(expected.options) do
            assert.equals(value, actual.options[key])
          end
        end
      end
    end)
  end
end)

describe("Squad single-agent helper", function()
  for _, case in ipairs(squad_spec.builder_cases) do
    it(case.label, function()
      local actual = SquadDSL.build_single_agent_spec(case.agent, case.input)
      assert.equals(case.expected, actual)
    end)
  end
end)
