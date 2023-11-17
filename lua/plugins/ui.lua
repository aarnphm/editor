return {
  {
    "j-hui/fidget.nvim",
    branch = "legacy",
    event = "LspAttach",
    config = true,
    opts = {
      window = { blend = 0 },
      sources = {
        ["conform"] = { ignore = true },
      },
      fmt = { max_messages = 3 },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "", -- for all buffers without a file type
          "alpha",
          "fugitive",
          "aerial",
          "git",
          "gitcommit",
          "help",
          "json",
          "log",
          "markdown",
          "neo-tree",
          "Outline",
          "startify",
          "TelescopePrompt",
          "txt",
          "undotree",
          "vimwiki",
          "vista",
          "lazyterm",
        },
        buftypes = { "terminal", "nofile", "quickfix", "prompt" },
      },
    },
    config = function(_, opts) require("ibl").setup(opts) end,
  },
}
