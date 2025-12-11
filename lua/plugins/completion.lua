return {
  {
    "saghen/blink.cmp",
    version = false,
    build = "cargo build --release",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "moyiz/blink-emoji.nvim",
    },
    event = "InsertEnter",
    opts_extend = { "sources.default" },
    ---@type blink.cmp.Config
    opts = {
      fuzzy = { implementation = "rust" },
      appearance = { kind_icons = { Copilot = "" } },
      snippets = { expand = function(snippet) return Util.cmp.expand(snippet) end },
      signature = { enabled = false },
      completion = {
        menu = {
          auto_show = false,
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon" }, { "kind" }, { "label", "label_description", gap = 2 } },
            components = {
              label_description = { width = { max = 0 }, text = function(ctx) return ctx.label_description or "" end },
              kind_icon = {
                text = function(ctx)
                  local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                  return kind_icon
                end,
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
              kind = {
                -- (optional) use highlights from mini.icons
                highlight = function(ctx)
                  local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
            },
            padding = 0,
            gap = 1,
          },
        },
        accept = { auto_brackets = { enabled = false } },
        documentation = { auto_show = false, auto_show_delay_ms = 200 },
        trigger = { show_in_snippet = true },
        list = {
          selection = {
            preselect = function() return not require("blink.cmp").snippet_active { direction = 1 } end,
            auto_insert = false,
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
        preset = "default",
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          "fallback",
        },
        ["<Up>"] = false,
        ["<Down>"] = false,
      },
    },
  },
}
