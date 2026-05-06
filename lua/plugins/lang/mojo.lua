local function register_mojo_parser()
  require("nvim-treesitter.parsers").mojo = {
    install_info = {
      url = "https://github.com/lsh/tree-sitter-mojo",
      revision = "03966fb3f209bea86844aab3bd0f2158a5a8bb8d",
      queries = "queries",
    },
  }
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      vim.filetype.add {
        extension = {
          mojo = "mojo",
          ["🔥"] = "mojo",
        },
      }
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("mojo_treesitter_parser", { clear = true }),
        pattern = "TSUpdate",
        callback = register_mojo_parser,
      })
      pcall(register_mojo_parser)
    end,
    ---@param opts TSConfig
    opts = function(_, opts)
      register_mojo_parser()
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "mojo") then table.insert(opts.ensure_installed, "mojo") end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        mojo = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    ---@param opts conform.setupOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.mojo = { "mojo_format", timeout_ms = 20000 }

      opts.formatters = opts.formatters or {}
      opts.formatters.mojo_format = vim.tbl_deep_extend("force", opts.formatters.mojo_format or {}, {
        command = "mojo",
        args = { "format", "-q", "$FILENAME" },
        stdin = false,
      })
    end,
  },
}
