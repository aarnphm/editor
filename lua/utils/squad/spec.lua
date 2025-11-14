local M = {}

M.parse_cases = {
  {
    label = "vertical layout alias (bracket)",
    input = "vertical::[codex,claude]",
    layout = { mode = "vertical", position = "right" },
    agents = {
      { name = "codex", count = 1 },
      { name = "claude", count = 1 },
    },
  },
  {
    label = "vertical layout alias (bare)",
    input = "vertical::codex,claude",
    layout = { mode = "vertical", position = "right" },
    agents = {
      { name = "codex", count = 1 },
      { name = "claude", count = 1 },
    },
  },
  {
    label = "count shorthand",
    input = "codex::2,claude::2",
    agents = {
      { name = "codex", count = 2 },
      { name = "claude", count = 2 },
    },
  },
  {
    label = "model overrides per panel",
    input = "codex::{model=gpt-5-codex},codex::{model=gpt-4o}",
    agents = {
      { name = "codex", options = { model = "gpt-5-codex" } },
      { name = "codex", options = { model = "gpt-4o" } },
    },
  },
  {
    label = "prompt payload",
    input = "codex::{model=gpt-5-codex}[Some prompt here]",
    agents = {
      { name = "codex", prompt = "Some prompt here", options = { model = "gpt-5-codex" } },
    },
  },
  {
    label = "agent flags",
    input = "codex::{agent=true},claude::{agent=true}",
    agents = {
      { name = "codex", options = { agent = true } },
      { name = "claude", options = { agent = true } },
    },
  },
  {
    label = "left right grouping",
    input = "left::[gemini,claude],right::[codex,cursor]",
    layout = { split_groups = true, mode = "vertical" },
    agents = {
      { name = "gemini", position = "left" },
      { name = "claude", position = "left" },
      { name = "codex", position = "right" },
      { name = "cursor", position = "right" },
    },
  },
  {
    label = "worktree inline",
    input = "claude/tools::{model=haiku}",
    agents = {
      { name = "claude", worktree = "tools", options = { model = "haiku" } },
    },
  },
}

M.builder_cases = {
  {
    label = "defaults to bare agent",
    agent = "codex",
    input = "",
    expected = "codex",
  },
  {
    label = "wraps raw text as args",
    agent = "codex",
    input = "explain the code",
    expected = 'codex[args="explain the code"]',
  },
  {
    label = "propagates layout alias",
    agent = "codex",
    input = "horizontal",
    expected = "horizontal::codex",
  },
  {
    label = "passes through options",
    agent = "claude",
    input = "{model=haiku}",
    expected = "claude::{model=haiku}",
  },
}

return M
