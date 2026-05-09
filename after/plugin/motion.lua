-- leap.nvim
Util.pack.load "leap.nvim"

local leap = require "leap"
leap.opts["max_highlighted_traversal_targets"] = 15

local function leap_ft_safe_labels()
  local mode = vim.fn.mode(1)
  if mode == "n" or mode == "v" or mode == "V" or mode == "\22" then return nil end
  return ""
end

local function leap_ft(args)
  leap.leap(vim.tbl_deep_extend("keep", args, {
    inputlen = 1,
    inclusive = true,
    opts = {
      labels = "",
      safe_labels = leap_ft_safe_labels(),
      vim_opts = { ["go.ignorecase"] = false },
    },
  }))
end

local function prepend_leap_key(key, keys)
  local ret = { key }
  if type(keys) == "table" then
    vim.list_extend(ret, keys)
  else
    ret[#ret + 1] = keys
  end
  return ret
end

local function leap_line_start(skip_range)
  local win = vim.api.nvim_get_current_win()
  local info = vim.fn.getwininfo(win)[1]
  local cur_line = vim.fn.line "."
  local cur_screen_row = vim.fn.screenpos(win, cur_line, 1).row
  local targets = {}
  skip_range = skip_range or 2

  local line = info.topline
  while line <= info.botline do
    local fold_end = vim.fn.foldclosedend(line)
    if fold_end ~= -1 then
      line = fold_end + 1
    else
      if line < cur_line - skip_range or line > cur_line + skip_range then
        targets[#targets + 1] = { pos = { line, 1 } }
      end
      line = line + 1
    end
  end

  table.sort(targets, function(left, right)
    local left_row = vim.fn.screenpos(win, left.pos[1], left.pos[2]).row
    local right_row = vim.fn.screenpos(win, right.pos[1], right.pos[2]).row
    return math.abs(cur_screen_row - left_row) < math.abs(cur_screen_row - right_row)
  end)

  leap.leap { target_windows = { win }, targets = targets }
end

local clever = require("leap.user").with_traversal_keys
local clever_f = clever("f", "F")
local clever_t = clever("t", "T")
vim.keymap.set(
  { "n", "x", "o" },
  "f",
  function() leap_ft { opts = clever_f } end,
  { desc = "motion: leap forward to char" }
)
vim.keymap.set(
  { "n", "x", "o" },
  "F",
  function() leap_ft { backward = true, opts = clever_f } end,
  { desc = "motion: leap backward to char" }
)
vim.keymap.set(
  { "n", "x", "o" },
  "t",
  function() leap_ft { offset = -1, opts = clever_t } end,
  { desc = "motion: leap forward till char" }
)
vim.keymap.set(
  { "n", "x", "o" },
  "T",
  function() leap_ft { backward = true, offset = 1, opts = clever_t } end,
  { desc = "motion: leap backward till char" }
)
vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", { desc = "motion: leap forward to" })
vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", { desc = "motion: leap backward to" })
vim.keymap.set("n", "gs", "<Plug>(leap-from-window)", { desc = "motion: leap from window" })
vim.keymap.set({ "n", "x", "o" }, "ga", function()
  local keys = vim.deepcopy(leap.opts.keys)
  keys.next_target = prepend_leap_key("a", keys.next_target)
  keys.prev_target = prepend_leap_key("A", keys.prev_target)
  require("leap.treesitter").select { opts = { keys = keys } }
end, { desc = "motion: leap treesitter" })
vim.keymap.set(
  { "n", "x", "o" },
  "gA",
  'V<cmd>lua require("leap.treesitter").select()<cr>',
  { desc = "motion: leap treesitter (linewise)" }
)
vim.keymap.set("o", "|", function()
  vim.cmd "normal! V"
  leap_line_start()
end, { desc = "motion: leap line start (linewise)" })
vim.keymap.set("x", "|", function()
  if vim.fn.mode(1) ~= "V" then vim.cmd "normal! V" end
  leap_line_start()
end, { desc = "motion: leap line start" })
