return {
  {
    "supermaven-inc/supermaven-nvim",
    lazy = true,
    enabled = function() return vim.g.agent_backend == "supermaven" end,
    event = "LazyFile",
    build = ":SupermavenUsePro",
    opts = {
      ignore_filetypes = {
        gitcommit = true,
        hgcommit = true,
        TelescopePrompt = true,
        ministarter = true,
        nofile = true,
        startup = true,
        Trouble = true,
        Avante = true,
      },
      log_level = "warn",
      disable_inline_completion = true,
      disable_keymaps = true,
    },
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    build = ":Copilot auth",
    enabled = function() return vim.g.agent_backend == "copilot" end,
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
    dependencies = {
      -- Manage libuv types with lazy. Plugin will never be loaded
      { "Bilal2453/luvit-meta", lazy = true },
      { "justinsgithub/wezterm-types", lazy = true },
    },
    opts = {
      library = {
        { path = "~/workspace/neovim-plugins/avante.nvim/lua", words = { "avante" } },
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        { path = "wezterm-types", mods = { "wezterm" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },
  {
    "saghen/blink.cmp",
    version = false,
    build = "cargo build --release",
    enabled = function() return vim.g.completion_backend == "blink.cmp" end,
    dependencies = {
      "rafamadriz/friendly-snippets",
      -- add blink.compat to dependencies
      -- { "saghen/blink.compat", opts = {} },
    },
    event = "InsertEnter",
    opts_extend = { "sources.completion.enabled_providers" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      fuzzy = { prebuilt_binaries = { download = false, force_version = "v0.6.2" } },
      appearance = {
        use_nvim_cmp_as_default = true,
        kind_icons = { Copilot = "" },
        nerd_font_variant = "mono", -- "normal" | "mono"
      },
      signature = { enabled = false, max_width = 30 },
      ghost_text = { enabled = vim.g.ghost_text },
      completion = {
        menu = {
          draw = {
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } },
            padding = 0,
            gap = 1,
            components = {
              label_description = { width = { max = 40 }, text = function(ctx) return ctx.label_description or "" end },
            },
          },
        },
      },
      -- experimental auto-brackets support
      accept = { auto_brackets = { enabled = false } },
      sources = {
        completion = {
          -- remember to enable your providers here
          enabled_providers = { "lsp", "snippets", "path", "buffer", "lazydev" },
        },
        providers = {
          lsp = {
            -- dont show LuaLS require statements when lazydev has items
            fallback_for = { "lazydev" },
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
          },
          snippets = {
            opts = {
              ignored_filetypes = { "git", "gitcommit" },
              extended_filetypes = { markdown = { "latex" } },
            },
          },
        },
      },
      keymap = {
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    enabled = function() return vim.g.completion_backend == "nvim-cmp" end,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "FelipeLema/cmp-async-path",
      "kdheepak/cmp-latex-symbols",
      "otter.nvim",
    },
    ---@return cmp.ConfigSchema
    opts = function()
      local cmp = require "cmp"
      local TC = require "cmp.types.cmp"
      local defaults = require "cmp.config.default"()

      ---@type cmp.SelectOption
      local select_opts = { behavior = cmp.SelectBehavior.Select }

      local sources = {
        {
          name = "nvim_lsp",
          option = {
            markdown_oxide = {
              keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
            },
          },
        },
        { name = "snippets", group_index = 1 },
        { name = "buffer", group_index = 1 },
        { name = "async_path", group_index = 1 },
        { name = "latex_symbols", group_index = 2, option = { strategy = 0 } },
        { name = "lazydev", group_index = 0 },
      }

      if Util.has "supermaven-nvim" then
        table.insert(sources, {
          name = "supermaven",
          group_index = 2,
          entry_filter = function(_, ctx)
            local entries = ctx.visible_entries
            if not entries then return false end
            -- Only show supermaven entries if there are other visible entries
            return #entries > 0
          end,
        })
      end

      return vim.tbl_deep_extend("force", defaults, {
        auto_brackets = {},
        preselect = TC.PreselectMode.None,
        completion = {
          autocomplete = vim.g.enable_autocomplete and { TC.TriggerEvent.TextChanged } or false,
          completeopt = "menu,menuone,noinsert",
        },
        ---@type cmp.WindowConfig
        window = {
          documentation = {
            max_height = 40,
            max_width = 40,
            border = { "", "", "", " ", "", "", "", "" },
            winhighlight = "FloatBorder:NormalFloat",
            winblend = vim.o.pumblend,
          },
        },
        view = { entries = { name = "custom", selection_order = "near_cursor" } },
        snippet = { expand = function(item) return Util.cmp.expand(item.body) end },
        ---@type cmp.FormattingConfig
        formatting = {
          fields = { TC.ItemField.Menu, TC.ItemField.Abbr, TC.ItemField.Kind },
          expandable_indicator = true,
          format = function(entry, item)
            ---@type string
            local mini_icon = MiniIcons.get("lsp", item.kind or "")
            item.kind = mini_icon and mini_icon .. " " or item.kind
            item.menu = ({
              supermaven = "[MVN]",
              copilot = "[CPL]",
              nvim_lsp = "[LSP]",
              nvim_lua = "[LUA]",
              snippets = "[SNP]",
              buffer = "[BUF]",
              async_path = "[DIR]",
              latex_symbols = "[LTX]",
            })[entry.source.name]

            ---@type table<"abbr"|"menu", integer>
            local widths = { abbr = 20, menu = 40 }

            for key, width in pairs(widths) do
              if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
              end
            end
            return item
          end,
        },
        experimental = { ghost_text = vim.g.ghost_text and { hl_group = "CmpGhostText" } or false },
        enabled = function()
          local disabled_filetype = {
            gitcommit = true,
            TelescopePrompt = true,
            help = true,
            minifiles = true,
          }

          local disabled = not disabled_filetype[vim.bo.filetype]
          disabled = disabled or (vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt")
          disabled = disabled or (vim.fn.reg_recording() ~= "")
          disabled = disabled or (vim.fn.reg_executing() ~= "")
          return disabled
        end,
        mapping = cmp.mapping.preset.insert {
          ["<CR>"] = Util.cmp.confirm(),
          ["<S-CR>"] = Util.cmp.confirm { behavior = TC.ConfirmBehavior.Replace },
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ---@type cmp.MappingFunction
          ["<Tab>"] = cmp.mapping(function(fallback)
            local has_words_before = function()
              local col = vim.fn.col "." - 1
              return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
            end

            if cmp.visible() then
              cmp.select_next_item(select_opts)
            elseif vim.snippet.active { direction = 1 } then
              vim.schedule(function() vim.snippet.jump(1) end)
            elseif has_words_before() then
              fallback()
            else
              cmp.complete()
            end
          end, { "i", "s" }),
          ---@type cmp.MappingFunction
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item(select_opts)
            elseif vim.snippet.active { direction = -1 } then
              vim.schedule(function() vim.snippet.jump(-1) end)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = cmp.config.sources(sources),
      })
    end,
    main = "utils.cmp",
  },
}
