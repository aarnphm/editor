return {
  {
    "stevearc/dressing.nvim",
    lazy = true,
    opts = {
      input = { border = vim.g.border or "single" },
      builtin = { border = vim.g.border or "single" },
    },
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.input(...)
      end
    end,
  },
  {
    "folke/noice.nvim",
    event = "LazyFile",
    enabled = true,
    depdendencies = { { "MunifTanjim/nui.nvim", lazy = true } },
    ---@type NoiceConfig
    opts = {
      presets = {
        bottom_search = true,
        command_palette = false,
        long_message_to_split = true,
        lsp_doc_border = false,
      },
      cmdline = { view = "cmdline" },
      views = {
        split = { size = "20%" },
        popup = { border = { style = BORDER.impl() } },
        confirm = { border = { style = BORDER.impl "hover" } },
        hover = { border = { style = BORDER.impl "docs" }, position = { row = 2, col = 2 } },
        cmdline_input = { border = { style = BORDER.impl() } },
        cmdline_popup = { border = { style = BORDER.impl() } },
        mini = { border = { style = BORDER.none } },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
              { find = "%d+L, %d+B" },
              { find = "Starting Supermaven" },
              { find = "Supermaven Free Tier" },
              { find = "Supermaven Pro Tier" },
            },
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = "lsp",
            kind = "progress",
            cond = function(message)
              local client = vim.tbl_get(message.opts, "progress", "client")
              return client == "nil_ls"
            end,
          },
          opts = { skip = true },
        },
      },
      lsp = {
        override = {
          -- override the default lsp markdown formatter with Noice
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          -- override the lsp markdown formatter with Noice
          ["vim.lsp.util.stylize_markdown"] = true,
          -- override cmp documentation with Noice (needs the other options to work)
          ["cmp.entry.get_documentation"] = true,
        },
        message = { view = "messages" },
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "LazyFile",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      spec = {
        { "<BS>", desc = "treesitter: decrement selection", mode = "x" },
        { "<c-space>", desc = "treesiter: increment selection", mode = { "x", "n" } },
        {
          mode = { "n", "v" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>c", group = "code" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>h", group = "hunks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
          { "<leader>x", group = "dignostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
          {
            "<leader>b",
            group = "buffer",
            expand = function() return require("which-key.extras").expand.buf() end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function() return require("which-key.extras").expand.win() end,
          },
          -- better descriptions
          { "gx", desc = "util: open with system app" },
        },
      },
      disable = { ft = { "minifiles" } },
    },
    keys = {
      {
        "<leader>?",
        function() require("which-key").show { global = false } end,
        desc = "which-key: buffer keymaps",
      },
      {
        "<c-w><space>",
        function() require("which-key").show { keys = "<c-w>", loop = true } end,
        desc = "which-key: window hydra mode",
      },
    },
  },
}
