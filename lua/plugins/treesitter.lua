return {
  { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true, opts = { enable_autocmd = false } },
  {
    "nvim-treesitter/playground",
    lazy = true,
    cmd = { "TSPlaygroundToggle" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = function()
      local tsc = require "treesitter-context"

      Util.toggle.map("<leader>ut", {
        name = "treesitter context",
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      })

      return { mode = "cursor", enable = false }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "VeryLazy", "LazyFile" },
    lazy = vim.fn.argc(-1) == 0,
    keys = {
      { "<c-space>", desc = "Increment Selection" },
      { "<bs>", desc = "Decrement Selection", mode = "x" },
    },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "go",
        "rust",
        "gitcommit",
        "gitignore",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      auto_install = false,
      -- parser_install_dir = rtp_path,
      ignore_install = { "phpdoc" },
      indent = { enable = true },
      highlight = {
        enable = true,
        disable = function(_, bufnr) return Util.is_bigfile(bufnr) end,
      },
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
    config = function()
      -- If treesitter is already loaded, we need to run config again for textobjects
      if Util.is_loaded "nvim-treesitter" then
        local opts = Util.opts "nvim-treesitter"
        require("nvim-treesitter.configs").setup { textobjects = opts.textobjects }
      end

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
  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    opts = { opts = { enable_close = true } },
  },
}
