return {
  {
    "nvim-treesitter/playground",
    lazy = true,
    cmd = "TSPlaygroundToggle",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = { mode = "cursor", enable = true, max_lines = 8 },
    keys = {
      {
        "[c",
        function() require("treesitter-context").go_to_context(vim.v.count1) end,
        silent = true,
        desc = "treesitter: go to next context",
      },
      {
        "]c",
        function() require("treesitter-context").go_to_context(-vim.v.count1) end,
        silent = true,
        desc = "treesitter: go to previous context",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "LazyFile", "VeryLazy" },
    branch = "master",
    lazy = vim.fn.argc(-1) == 0,
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treesitter** module to be loaded in time.
      -- Luckily, the only things that those plugins need are the custom queries, which we make available
      -- during startup.
      require("lazy.core.loader").add_to_rtp(plugin)
      require "nvim-treesitter.query_predicates"
    end,
    keys = {
      { "<c-space>", desc = "Increment Selection" },
      { "<bs>", desc = "Decrement Selection", mode = "x" },
    },
    opts = {
      ensure_installed = "all",
      auto_install = true,
      ignore_install = { "phpdoc" },
      indent = { enable = true },
      highlight = { enable = true },
      injections = {
        enable = true,
        languages = { manim = "python" },
      },
      textobjects = {
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]b"] = { query = "@code_cell.inner", desc = "next code block" },
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[b"] = { query = "@code_cell.inner", desc = "previous code block" },
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
          },
        },
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["ib"] = { query = "@code_cell.inner", desc = "in block" },
            ["ab"] = { query = "@code_cell.outer", desc = "around block" },
            ["af"] = { query = "@function.outer", desc = "outer function" },
            ["if"] = { query = "@function.inner", desc = "inner function" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>sbl"] = "@code_cell.outer",
          },
          swap_previous = {
            ["<leader>sbh"] = "@code_cell.outer",
          },
        },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-a>",
          node_incremental = "<C-a>",
          scope_incremental = "<C-i>",
          node_decremental = "<bs>",
        },
      },
    },
    main = "utils.treesitter",
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "LazyFile",
    enabled = true,
    branch = "master",
    config = function()
      -- If treesitter is already loaded, we need to run config again for textobjects
      if Util.is_loaded "nvim-treesitter" then
        local opts = Util.opts "nvim-treesitter"
        require("nvim-treesitter.configs").setup { textobjects = opts.textobjects }
      end

      -- When in diff mode, we want to use the default
      -- vim text objects c & C instead of the treesitter ones.
      local move = require "nvim-treesitter.textobjects.move" ---@type table<string,fun(...)>
      local config = require "nvim-treesitter.configs"
      for name, fn in pairs(move) do
        if name:find "goto" == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local cfg = config.get_module("textobjects.move")[name] ---@type table<string,string>
              for key, query in pairs(cfg or {}) do
                if q == query and key:find "[%]%[][cC]" then
                  vim.cmd("normal! " .. key)
                  return
                end
              end
            end
            return fn(q, ...)
          end
        end
      end
    end,
  },
}
