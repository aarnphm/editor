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
      "Kaiser-Yang/blink-cmp-avante",
      "moyiz/blink-emoji.nvim",
      { "saghen/blink.compat", opts = {}, version = false },
    },
    event = "InsertEnter",
    opts_extend = { "sources.completion.enabled_providers", "sources.compat", "sources.default" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      fuzzy = { implementation = "prefer_rust" },
      appearance = {
        use_nvim_cmp_as_default = true,
        kind_icons = { Copilot = "" },
        nerd_font_variant = "mono", -- "normal" | "mono"
      },
      snippets = {
        expand = function(snippet) return Util.cmp.expand(snippet) end,
      },
      signature = { enabled = false },
      completion = {
        menu = {
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } },
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
            preselect = function(ctx) return not require("blink.cmp").snippet_active { direction = 1 } end,
          },
        },
      },
      cmdline = { enabled = false },
      sources = {
        compat = {},
        default = { "lsp", "path", "snippets", "buffer", "lazydev", "emoji", "avante" },
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
          avante = {
            module = "blink-cmp-avante",
            name = "Avante",
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
    ---@param opts blink.cmp.Config | { sources: { compat: string[] } }
    config = function(_, opts)
      -- setup compat sources
      local enabled = opts.sources.default
      for _, source in ipairs(opts.sources.compat or {}) do
        opts.sources.providers[source] = vim.tbl_deep_extend(
          "force",
          { name = source, module = "blink.compat.source" },
          opts.sources.providers[source] or {}
        )
        if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then table.insert(enabled, source) end
      end

      -- Unset custom prop to pass blink.cmp validation
      opts.sources.compat = nil

      -- check if we need to override symbol kinds
      for _, provider in pairs(opts.sources.providers or {}) do
        ---@cast provider blink.cmp.SourceProviderConfig|{kind?:string}
        if provider.kind then
          local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
          local kind_idx = #CompletionItemKind + 1

          CompletionItemKind[kind_idx] = provider.kind
          ---@diagnostic disable-next-line: no-unknown
          CompletionItemKind[provider.kind] = kind_idx

          ---@type fun(ctx: blink.cmp.Context, items: blink.cmp.CompletionItem[]): blink.cmp.CompletionItem[]
          local transform_items = provider.transform_items
          ---@param ctx blink.cmp.Context
          ---@param items blink.cmp.CompletionItem[]
          provider.transform_items = function(ctx, items)
            items = transform_items and transform_items(ctx, items) or items
            for _, item in ipairs(items) do
              item.kind = kind_idx or item.kind
            end
            return items
          end

          -- Unset custom prop to pass blink.cmp validation
          provider.kind = nil
        end
      end

      require("blink.cmp").setup(opts)
    end,
  },
}
