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
      local cmp = require "cmp"
      local defaults = require "cmp.config.default"()
      local compare = require "cmp.config.compare"

      local select_opts = { behavior = cmp.SelectBehavior.Select }

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
            symbol_map = { Supermaven = "" },
          },
        },
        experimental = {
          ghost_text = vim.g.ghost_text and { hl_group = "CmpGhostText" } or false,
        },
        sorting = vim.tbl_deep_extend("force", defaults.sorting, {
          {
            comparators = {
              compare.offset,
              compare.exact,
              ---@type cmp.ComparatorFunction
              function(entry1, entry2)
                ---@type number
                local diff
                if entry1.completion_item.score and entry2.completion_item.score then
                  diff = (entry2.completion_item.score * entry2.score) - (entry1.completion_item.score * entry1.score)
                else
                  diff = entry2.score - entry1.score
                end
                return diff < 0
              end,
              compare.sort_text,
              compare.score,
              compare.recently_used,
              compare.locality,
              compare.kind,
              -- copied from cmp-under
              ---@type cmp.ComparatorFunction
              function(entry1, entry2)
                local _, e1_under = entry1.completion_item.label:find "^_+"
                local _, e2_under = entry2.completion_item.label:find "^_+"
                e1_under = e1_under or 0
                e2_under = e2_under or 0
                if e1_under > e2_under then
                  return false
                elseif e1_under < e2_under then
                  return true
                end
              end,
              compare.length,
              compare.order,
            },
          },
        }),
        matching = {
          disallow_fullfuzzy_matching = true,
        },
        enabled = function()
          local disabled = { gitcommit = true, TelescopePrompt = true, help = true, minifiles = true }
          return not disabled[vim.bo.filetype]
        end,
        mapping = cmp.mapping.preset.insert {
          ["<CR>"] = Util.cmp.confirm { select = true },
          ["<S-CR>"] = Util.cmp.confirm { select = true, behavior = cmp.ConfirmBehavior.Replace },
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<Tab>"] = cmp.mapping(function(fallback)
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
          end, { "i", "s" }),
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
        sources = cmp.config.sources {
          { name = "nvim_lsp", priority = 400 },
          { name = "path", priority = 200 },
          { name = "supermaven" },
          { name = "snippets", priority = 300 },
          { name = "lazydev", group_index = 0 },
          {
            name = "buffer",
            option = {
              get_bufnrs = function() return vim.api.nvim_buf_line_count(0) < 7500 and vim.api.nvim_list_bufs() or {} end,
            },
          },
        },
      })
    end,
    main = "utils.cmp",
  },
}
