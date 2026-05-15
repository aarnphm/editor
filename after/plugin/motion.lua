local map = vim.keymap.set

local function leap()
  Util.pack.load "leap.nvim"
  return require "leap"
end

local function ft_opts(forward, backward)
  return require("leap.user").with_traversal_keys(forward, backward, {
    labels = "",
    safe_labels = vim.fn.mode(1):match "o" and "" or nil,
    vim_opts = { ["go.ignorecase"] = false },
  })
end

local function leap_ft(forward, backward, args)
  args = args or {}
  return function()
    leap().leap(vim.tbl_deep_extend("force", {
      inputlen = 1,
      inclusive = true,
      opts = ft_opts(forward, backward),
    }, args))
  end
end

local function leap_to(args)
  return function() leap().leap(type(args) == "function" and args() or vim.deepcopy(args)) end
end

local function line_start_targets(win, skip_range)
  local info = vim.fn.getwininfo(win)[1]
  local cursor = vim.api.nvim_win_get_cursor(win)[1]
  local cursor_row = vim.fn.screenpos(win, cursor, 1).row
  local targets = {}
  skip_range = skip_range or 2

  local line = info.topline
  while line <= info.botline do
    local fold_end = vim.fn.foldclosedend(line)
    if fold_end ~= -1 then
      line = fold_end + 1
    else
      if math.abs(line - cursor) > skip_range then targets[#targets + 1] = { pos = { line, 1 } } end
      line = line + 1
    end
  end

  table.sort(targets, function(left, right)
    local left_row = vim.fn.screenpos(win, left.pos[1], left.pos[2]).row
    local right_row = vim.fn.screenpos(win, right.pos[1], right.pos[2]).row
    return math.abs(cursor_row - left_row) < math.abs(cursor_row - right_row)
  end)

  return targets
end

local function leap_line_start()
  local win = vim.api.nvim_get_current_win()
  leap().leap { windows = { win }, targets = line_start_targets(win) }
end

local function linewise_leap_line_start()
  if vim.fn.mode(1) ~= "V" then vim.cmd.normal { "V", bang = true } end
  leap_line_start()
end

local function leap_treesitter()
  leap()
  require("leap.treesitter").select {
    opts = require("leap.user").with_traversal_keys("a", "A"),
  }
end

local function leap_treesitter_linewise()
  leap()
  vim.cmd.normal { "V", bang = true }
  require("leap.treesitter").select()
end

local modes = { "n", "x", "o" }
local function plug(lhs, rhs, desc) map(modes, lhs, rhs, { desc = desc }) end

plug("s", leap_to { inclusive = true }, "motion: leap forward to")
plug("S", leap_to { backward = true }, "motion: leap backward to")
map(
  "n",
  "gs",
  leap_to(function() return { windows = require("leap.user").get_enterable_windows() } end),
  { desc = "motion: leap from window" }
)

plug("f", leap_ft("f", "F"), "motion: leap forward to char")
plug("F", leap_ft("f", "F", { backward = true }), "motion: leap backward to char")
plug("t", leap_ft("t", "T", { offset = -1 }), "motion: leap forward till char")
plug("T", leap_ft("t", "T", { backward = true, offset = 1 }), "motion: leap backward till char")

plug("ga", leap_treesitter, "motion: leap treesitter")
plug("gA", leap_treesitter_linewise, "motion: leap treesitter (linewise)")
map({ "x", "o" }, "|", linewise_leap_line_start, { desc = "motion: leap line start" })
