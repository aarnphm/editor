return {
  {
    "Bekaboo/dropbar.nvim",
    enabled = vim.fn.has "nvim-0.10" == 1,
    event = { "BufReadPre", "BufNewFile" },
    ---@type dropbar_configs_t
    opts = {
      general = {
        ---@type boolean|fun(buf:integer, win: integer): boolean
        enable = function(buf, win) return not vim.api.nvim_win_get_config(win).zindex and not vim.wo[win].diff end,
      },
      icons = {
        enable = true,
        ui = {
          bar = { separator = "  ", extends = "…" },
          menu = { separator = " ", indicator = "  " },
        },
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = Util.lazy_file_events,
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
