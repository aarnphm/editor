return {
  {
    "supermaven-inc/supermaven-nvim",
    lazy = true,
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
      },
      log_level = "warn",
      disable_inline_completion = true,
    },
  },
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "LspAttach",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "echasnovski/mini.icons",
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
          format = function(entry, item)
            local icon = nil
            local mini_icon, _, _ = require("mini.icons").get("lsp", item.kind)
            if mini_icon then icon = mini_icon .. " " end
            if icon then item.kind = icon .. item.kind end

            local widths = {
              abbr = vim.g.cmp and vim.g.cmp.widths.abbr or 40,
              menu = vim.g.cmp and vim.g.cmp.widths.menu or 30,
            }

            for key, width in pairs(widths) do
              if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
              end
            end
            return item
          end,
        },
        window = {
          completion = cmp.config.window.bordered { border = BORDER.impl "lsp" },
          documentation = cmp.config.window.bordered { border = BORDER.impl "docs" },
        },
        experimental = {
          ghost_text = vim.g.ghost_text and { hl_group = "CmpGhostText" } or false,
        },
        sorting = {
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
            compare.kind,
            compare.sort_text,
            compare.length,
            compare.order,
          },
        },
        matching = {
          disallow_fullfuzzy_matching = true,
        },
        enabled = function()
          local disabled = { gitcommit = true, TelescopePrompt = true, help = true, minifiles = true }
          return not disabled[vim.bo.filetype]
        end,
        mapping = cmp.mapping.preset.insert {
          ["<CR>"] = Util.cmp.confirm(),
          ["<S-CR>"] = Util.cmp.confirm { select = true, behavior = cmp.ConfirmBehavior.Replace },
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<Tab>"] = cmp.mapping(function(fallback)
            local has_words_before = function()
              local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
              return col ~= 0
                and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
            end

            if cmp.visible() then
              cmp.select_next_item(select_opts)
            elseif vim.snippet.active { direction = 1 } then
              vim.schedule(function() vim.snippet.jump(1) end)
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
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
          { name = "nvim_lsp", priority = 400, max_item_count = 50 },
          { name = "snippets", priority = 300 },
          { name = "supermaven", priority = 200, group_index = 1 },
          { name = "path", priority = 100 },
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
    main = "utils.cmp", ---@type simple.util.cmp
  },
}
