return {
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    enabled = false,
    opts = { progress = { display = { render_limit = 3, done_ttl = 2 } } },
  },
  {
    "folke/noice.nvim",
    event = "LazyFile",
    dependencies = { "MunifTanjim/nui.nvim" },
    enabled = true,
    opts = {
      presets = {
        bottom_search = false,
        command_palette = false,
        long_message_to_split = true,
        lsp_doc_border = false,
      },
      cmdline = { view = "cmdline" },
      messages = { view = "mini", view_history = "split" },
      views = {
        split = { size = "15%" },
        popup = { disable = true },
        confirm = { disable = true },
        hover = { position = { row = 2, col = 2 } },
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
    },
  },
  {
    "folke/which-key.nvim",
    event = "LazyFile",
    lazy = true,
    opts_extend = { "spec" },
    opts = function()
      local max_width = vim.o.columns
      return {
        ---@type wk.Win.opts
        win = {
          width = math.floor(0.614 * max_width),
        },
        spec = {
          { "<BS>", desc = "treesitter: decrement selection", mode = "x" },
          { "<c-space>", desc = "treesiter: increment selection", mode = { "x", "n" } },
          {
            mode = { "n", "v" },
            { "<leader>a", group = "avante", icon = { icon = " ", color = "cyan" } },
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
      }
    end,
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
