local Util = require "utils"

local opts = {
  close_if_last_window = true,
  enable_diagnostics = false, -- default is set to true here.
  filesystem = {
    bind_to_cwd = false,
    use_libuv_file_watcher = true, -- use system level watcher for file change
    follow_current_file = { enabled = true },
    filtered_items = {
      visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
      hide_dotfiles = false,
      hide_gitignored = true,
      hide_by_name = {
        "node_modules",
        "pdm.lock",
      },
      hide_by_pattern = { -- uses glob style patterns
        "*.meta",
        "*/src/*/tsconfig.json",
        "*/.ruff_cache/*",
        "*/__pycache__/*",
      },
    },
  },
  event_handlers = {
    {
      event = "neo_tree_window_after_open",
      handler = function(args)
        if args.position == "left" or args.position == "right" then vim.cmd "wincmd =" end
      end,
    },
    {
      event = "neo_tree_window_after_close",
      handler = function(args)
        if args.position == "left" or args.position == "right" then vim.cmd "wincmd =" end
      end,
    },
    -- disable last status on neo-tree
    -- If I use laststatus, then uncomment this
    {
      event = "neo_tree_buffer_enter",
      handler = function() vim.opt_local.laststatus = 0 end,
    },
    {
      event = "neo_tree_buffer_leave",
      handler = function() vim.opt_local.laststatus = 2 end,
    },
  },
  always_show = { ".github" },
  window = {
    mappings = {
      ["<space>"] = "none", -- disable space since it is leader
      ["s"] = "split_with_window_picker",
      ["v"] = "vsplit_with_window_picker",
    },
  },
  default_component_configs = {
    indent = {
      with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
  },
}

local on_move = function(data) Util.on_rename(data.source, data.destination) end

local events = require "neo-tree.events"

vim.list_extend(opts.event_handlers, {
  { event = events.FILE_MOVED, handler = on_move },
  { event = events.FILE_RENAMED, handler = on_move },
})

require("neo-tree").setup(opts)

vim.api.nvim_create_autocmd("TermClose", {
  pattern = "*lazygit",
  callback = function()
    if package.loaded["neo-tree.sources.git_status"] then require("neo-tree.sources.git_status").refresh() end
  end,
})

vim.keymap.set(
  "n",
  "<C-n>",
  function() require("neo-tree.command").execute { toggle = true, dir = vim.loop.cwd() } end,
  { desc = "explorer: root dir" }
)
