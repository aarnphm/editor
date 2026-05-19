local blink = Util.pack.get "blink.cmp"

if not blink then return end

vim.api.nvim_create_autocmd(blink.event or "InsertEnter", {
  group = augroup "blink",
  once = true,
  callback = function()
    Util.pack.load "blink.cmp"
    local opts = {
      fuzzy = { implementation = "prefer_rust" },
      snippets = { preset = "default", expand = Util.cmp.expand },
      signature = { enabled = false },
      completion = {
        menu = {
          auto_show = true,
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon" }, { "label", "label_description", gap = 2 } },
            components = {
              label_description = { width = { max = 0 }, text = function(ctx) return ctx.label_description or "" end },
              kind_icon = {
                text = function(ctx) return require("mini.icons").get("lsp", ctx.kind) end,
                highlight = function(ctx)
                  local _, hl = require("mini.icons").get("lsp", ctx.kind)
                  return hl
                end,
              },
              kind = {
                highlight = function(ctx)
                  local _, hl = require("mini.icons").get("lsp", ctx.kind)
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
        default = { "lsp", "path", "snippets", "buffer", "stream_meta", "arena_meta" },
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
          stream_meta = {
            name = "Stream",
            module = "stream.completion",
            score_offset = 80,
            min_keyword_length = 0,
            async = true,
          },
          arena_meta = {
            name = "Arena",
            module = "arena.completion",
            score_offset = 80,
            min_keyword_length = 0,
            async = true,
          },
        },
      },
      keymap = {
        preset = "enter",
        ["<C-y>"] = { "select_and_accept" },
        ["<Up>"] = false,
        ["<Down>"] = false,
      },
    }
    require("blink.cmp").setup(opts)
  end,
})
