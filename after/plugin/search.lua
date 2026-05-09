-- grug-far.nvim
local grug_loaded = false
local function grug()
  if not grug_loaded then
    pcall(vim.api.nvim_del_user_command, "GrugFar")
    Util.pack.load "grug-far.nvim"
    grug_loaded = true
  end
  return require "grug-far"
end

local function grug_ext_filter()
  local ext = vim.bo.buftype == "" and vim.fn.expand "%:e"
  return ext and ext ~= "" and "*." .. ext or nil
end

local function open_grug(opts)
  opts = vim.tbl_extend("force", { transient = true }, opts or {})
  grug().open(opts)
end

vim.api.nvim_create_user_command("GrugFar", function(opts)
  grug()
  local command = "GrugFar"
  if opts.bang then command = command .. "!" end
  if opts.args ~= "" then command = command .. " " .. opts.args end
  vim.cmd(command)
end, { nargs = "*", bang = true, desc = "grug-far: open" })

vim.keymap.set(
  { "n", "v" },
  "<LocalLeader>w",
  function() open_grug { windowCreationCommand = "60vsplit" } end,
  { desc = "search: open and replace" }
)
vim.keymap.set(
  { "n", "v" },
  "<LocalLeader>hw",
  function() open_grug { windowCreationCommand = "topleft 60vsplit" } end,
  { desc = "search: open and replace (left)" }
)
vim.keymap.set(
  { "n", "v" },
  "<LocalLeader>jw",
  function() open_grug { instanceName = "far-below", windowCreationCommand = "botright 15split" } end,
  { desc = "search: open and replace (below)" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>w",
  function()
    open_grug {
      windowCreationCommand = "60vsplit",
      prefills = { filesFilter = grug_ext_filter() },
    }
  end,
  { desc = "search: open and replace (current filetype)" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>hw",
  function()
    open_grug {
      windowCreationCommand = "topleft 60vsplit",
      prefills = { filesFilter = grug_ext_filter() },
    }
  end,
  { desc = "search: open and replace (current filetype, left)" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>jw",
  function()
    open_grug {
      instanceName = "far-below",
      windowCreationCommand = "botright 15split",
      prefills = { filesFilter = grug_ext_filter() },
    }
  end,
  { desc = "search: open and replace (current filetype, below)" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>/",
  function()
    open_grug {
      windowCreationCommand = "60vsplit",
      prefills = { search = vim.fn.expand "<cword>" },
    }
  end,
  { desc = "search: open and replace (cursor word)" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>h/",
  function()
    open_grug {
      windowCreationCommand = "topleft 60vsplit",
      prefills = { search = vim.fn.expand "<cword>" },
    }
  end,
  { desc = "search: open and replace (cursor word, left)" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>j/",
  function()
    open_grug {
      windowCreationCommand = "botright 15split",
      prefills = { search = vim.fn.expand "<cword>" },
    }
  end,
  { desc = "search: open and replace (cursor word, below)" }
)
