return {
  {
    "supermaven-inc/supermaven-nvim",
    lazy = true,
    event = "LazyFile",
    opts = {
      ignore_filetypes = {
        gitcommit = true,
        hgcommit = true,
        TelescopePrompt = true,
        ministarter = true,
        nofile = true,
        startup = true,
        Trouble = true,
      },
      log_level = "warn",
      disable_inline_completion = true,
    },
  },
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "onsails/lspkind.nvim",
      {
        "garymjr/nvim-snippets",
        opts = {
          friendly_snippets = true,
          ignored_filetypes = { "git" },
        },
        dependencies = { "rafamadriz/friendly-snippets" },
      },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        cmd = "LazyDev",
        opts = {
          dependencies = {
            -- Manage libuv types with lazy. Plugin will never be loaded
            { "Bilal2453/luvit-meta", lazy = true },
          },
          library = {
            { path = "luvit-meta/library", words = { "vim%.uv" } },
            { path = "lazy.nvim", words = { "Util" } },
          },
        },
      },
    },
    ---@return cmp.ConfigSchema
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      local cmp = require "cmp"
      local defaults = require "cmp.config.default"()
      local compare = require "cmp.config.compare"

      local windows = cmp.config.window.bordered {
        border = BORDER,
        side_padding = 0,
        scrollbar = true,
        zindex = 30,
        winhighlight = "Normal:Normal,FloatBorder:Normal",
      }

      local select_opts = { behavior = cmp.SelectBehavior.Select }

      local forward_cmpl = function(fallback)
        local col = vim.fn.col "." - 1

        if cmp.visible() then
          cmp.select_next_item(select_opts)
        elseif vim.snippet.active { direction = 1 } then
          vim.schedule(function() vim.snippet.jump(1) end)
        elseif col == 0 or vim.fn.getline("."):sub(col, col):match "%s" then
          fallback()
        else
          cmp.complete()
        end
      end
      local backward_cmpl = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item(select_opts)
        elseif vim.snippet.active { direction = -1 } then
          vim.schedule(function() vim.snippet.jump(-1) end)
        else
          fallback()
        end
      end

      ---@type cmp.ConfigSchema
      return vim.tbl_deep_extend("force", defaults, {
        auto_brackets = { "python" },
        preselect = cmp.PreselectMode.None,
        completion = { completeopt = "menu,menuone,noinsert" },
        snippet = { expand = function(item) return Util.cmp.expand(item.body) end },
        formatting = {
          fields = { "menu", "abbr", "kind" },
          expandable_indicator = true,
          format = require("lspkind").cmp_format {
            mode = "symbol",
            max_width = 10,
            symbol_map = {
              Supermaven = "",
            },
          },
        },
        experimental = {
          ghost_text = vim.g.ghost_text and {
            hl_group = "CmpGhostText",
          } or false,
        },
        window = { completion = windows, documentation = windows },
        sorting = {
          priority_weight = 2,
          comparators = {
            compare.offset,
            compare.exact,
            compare.scopes,
            compare.score,
            -- copied from cmp-under
            ---@type cmp.ComparatorFunctor
            function(entry1, entry2)
              local _, entry1_under = entry1.completion_item.label:find "^_+"
              local _, entry2_under = entry2.completion_item.label:find "^_+"
              entry1_under = entry1_under or 0
              entry2_under = entry2_under or 0
              if entry1_under > entry2_under then
                return false
              elseif entry1_under < entry2_under then
                return true
              end
            end,
            compare.kind,
            compare.sort_text,
            compare.length,
            compare.order,
          },
        },
        enabled = function()
          local disabled = { gitcommit = true, TelescopePrompt = true, help = true, minifiles = true }
          return not disabled[vim.bo.filetype]
        end,
        mapping = cmp.mapping.preset.insert {
          ["<CR>"] = Util.cmp.confirm { select = true },
          ["<S-CR>"] = Util.cmp.confirm { select = true, behavior = cmp.ConfirmBehavior.Replace },
          ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
          ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<Tab>"] = cmp.mapping(forward_cmpl, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(backward_cmpl, { "i", "s" }),
        },
        sources = cmp.config.sources {
          { name = "path", priority = 200 },
          { name = "supermaven" },
          { name = "nvim_lsp", priority = 400, keyword_length = 3, max_item_count = 200 },
          { name = "snippets", keyword_length = 2, priority = 300 },
          { name = "buffer", priority = 100 },
          { name = "lazydev", group_index = 0 },
        },
      })
    end,
    main = "utils.cmp",
  },
}
