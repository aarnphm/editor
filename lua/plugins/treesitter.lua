local ensure_installed = {
  "python",
  "ninja",
  "rst",
  "rust",
  "lua",
  "c",
  "diff",
  "cpp",
  "toml",
  "dockerfile",
  "bash",
  "css",
  "vim",
  "regex",
  "markdown",
  "markdown_inline",
  "yaml",
  "gitcommit",
  "git_config",
  "go",
  "typescript",
  "tsx",
  "query",
  "regex",
  "luap",
  "luadoc",
  "javascript",
  "proto",
}
return {
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },
  { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true, opts = { enable_autocmd = false } },
  {
    "nvim-treesitter/playground",
    lazy = true,
    cmd = { "TSPlaygroundToggle" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = { mode = "cursor" },
    keys = {
      {
        "<leader>ut",
        function()
          local tsc = require "treesitter-context"
          tsc.toggle()
          if Util.inject.get_upvalue(tsc.toggle, "enabled") then
            vim.notify("Enabled Treesitter Context", vim.log.levels.INFO, { title = "Option" })
          else
            vim.notify("Disabled Treesitter Context", vim.log.levels.WARN, { title = "Option" })
          end
        end,
        desc = "Toggle Treesitter Context",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    cmd = "TSUpdateSync",
    build = ":TSUpdate",
    event = "VeryLazy",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
          -- When in diff mode, we want to use the default
          -- vim text objects c & C instead of the treesitter ones.
          local move = require "nvim-treesitter.textobjects.move" ---@type table<string,fun(...)>
          local configs = require "nvim-treesitter.configs"
          for name, fn in pairs(move) do
            if name:find "goto" == 1 then
              move[name] = function(q, ...)
                if vim.wo.diff then
                  local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                  for key, query in pairs(config or {}) do
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
    },
    opts = {
      ensure_installed = ensure_installed,
      ignore_install = { "phpdoc" },
      indent = { enable = true },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = string.match(vim.g.simple_colorscheme, "catppuccin") ~= nil and false
          or { "markdown" },
      },
      context_commentstring = { enable = true, enable_autocmd = false },
      autotag = { enable = true },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
        },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-a>",
          node_incremental = "<C-a>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
    config = function(_, opts)
      if Util.has "SchemaStore.nvim" then vim.list_extend(opts.ensure_installed, { "json", "jsonc", "json5" }) end

      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then return false end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end

      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
