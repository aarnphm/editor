return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    ---@type copilot_config
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = false,
        debounce = 75,
        keymap = {
          accept = "<M-CR>",
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      filetypes = {
        markdown = true,
        sh = function()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then return false end
          return true
        end,
      },
      server_opts_overrides = {
        settings = {
          advanced = {
            inlineSuggestCount = 3,
          },
        },
      },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "~/workspace/neovim-plugins/avante.nvim/lua", words = { "avante" } },
        { path = "~/workspace/neovim-plugins/surf.nvim/lua", words = { "surf" } },
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "conform.nvim", words = { "conform" } },
      },
    },
  },
  {
    "saghen/blink.cmp",
    version = false,
    build = "nix run .#build-plugin",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "moyiz/blink-emoji.nvim",
    },
    event = "InsertEnter",
    opts_extend = { "sources.completion.enabled_providers", "sources.default" },
    ---@type blink.cmp.Config
    opts = {
      fuzzy = { implementation = "prefer_rust" },
      appearance = { kind_icons = { Copilot = "" } },
      snippets = { expand = function(snippet) return Util.cmp.expand(snippet) end },
      signature = { enabled = false },
      completion = {
        menu = {
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
            components = {
              label_description = { width = { max = 40 }, text = function(ctx) return ctx.label_description or "" end },
            },
            padding = 0,
            gap = 1,
          },
        },
        accept = { auto_brackets = { enabled = false } },
        documentation = { auto_show = false, auto_show_delay_ms = 200 },
        ghost_text = { enabled = vim.g.ghost_text },
        trigger = { show_in_snippet = false },
        list = {
          selection = {
            preselect = function() return not require("blink.cmp").snippet_active { direction = 1 } end,
          },
        },
      },
      cmdline = { enabled = false },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "emoji" },
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          snippets = {
            opts = {
              ignored_filetypes = { "git", "gitcommit" },
              extended_filetypes = { markdown = { "latex" } },
            },
          },
          emoji = {
            module = "blink-emoji",
            name = "Emoji",
            score_offset = 15,
            opts = { insert = true },
            should_show_items = function() return vim.tbl_contains({ "gitcommit", "markdown" }, vim.o.filetype) end,
          },
        },
      },
      keymap = {
        preset = "super-tab",
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          Util.cmp.map { "snippet_forward", "ai_accept" },
          "fallback",
        },
      },
    },
  },
}
