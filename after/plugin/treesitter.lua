local Util = require "utils"

local opts = {
  ensure_installed = {
    "python",
    "ninja",
    "rst",
    "rust",
    "lua",
    "c",
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
    "go",
    "typescript",
    "tsx",
    "query",
    "regex",
    "luap",
    "luadoc",
    "javascript",
    "proto",
  },
  ignore_install = { "phpdoc" },
  indent = { enable = true },
  highlight = { enable = true },
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
}

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
