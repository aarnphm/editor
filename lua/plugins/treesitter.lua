local ensure_installed = {
  "python",
  "rst",
  "lua",
  "c",
  "diff",
  "cpp",
  "toml",
  "bash",
  "regex",
  "markdown",
  "markdown_inline",
  "yaml",
  "gitcommit",
  "git_config",
  "query",
  "regex",
  "luap",
  "luadoc",
  "proto",
}
return {
  { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true, opts = { enable_autocmd = false } },
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    cmd = "TSUpdateSync",
    build = ":TSUpdate",
    event = "VeryLazy",
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
      indent = { enable = true },
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
