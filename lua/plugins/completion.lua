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
        opts = { friendly_snippets = true, ignored_filetypes = { "git", "gitcommit" } },
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
            { path = "~/workspace/neovim-plugins/avante.nvim/lua", words = { "avante" } },
            { path = "luvit-meta/library", words = { "vim%.uv" } },
            { path = "lazy.nvim", words = { "Util" } },
          },
        },
      },
    },
    ---@return cmp.ConfigSchema
    opts = function()
      local cmp = require "cmp"
      local TC = require "cmp.types.cmp"
      local defaults = require "cmp.config.default"()
      local compare = require "cmp.config.compare"

      ---@type cmp.SelectOption
      local select_opts = { behavior = cmp.SelectBehavior.Select }

      return vim.tbl_deep_extend("force", defaults, {
        auto_brackets = { "python" },
        preselect = TC.PreselectMode.None,
        completion = { completeopt = "menu,menuone,noinsert" },
        snippet = { expand = function(item) return Util.cmp.expand(item.body) end },
        ---@type cmp.FormattingConfig
        formatting = {
          fields = { TC.ItemField.Menu, TC.ItemField.Abbr, TC.ItemField.Kind },
          expandable_indicator = true,
          format = function(_, item)
            local mini_icon = MiniIcons.get("lsp", item.kind or "")
            if vim.g.cmp_format == "symbol" then
              item.kind = mini_icon and mini_icon .. " " or item.kind
            elseif vim.g.cmp_format == "text_symbol" then
              item.kind = mini_icon and mini_icon .. " " .. item.kind or item.kind .. " "
            elseif vim.g.cmp_format == "text" then
              item.kind = item.kind
            else
              Util.error("cmp_format must be either 'symbol' or 'text_symbol'", { once = true, title = "LazyVim" })
            end

            local widths = {
              abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
              menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
            }

            for key, width in pairs(widths) do
              if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
              end
            end
            return item
          end,
        },
        experimental = {
          ghost_text = vim.g.ghost_text and { hl_group = "CmpGhostText" } or false,
        },
        sorting = {
          comparators = {
            compare.offset,
            compare.exact,
            -- copied from cmp-under
            ---@param entry1 cmp.Entry
            ---@param entry2 cmp.Entry
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
        enabled = function()
          local disabled = { gitcommit = true, TelescopePrompt = true, help = true, minifiles = true, Avante = true }
          return not disabled[vim.bo.filetype]
        end,
        mapping = cmp.mapping.preset.insert {
          ["<CR>"] = Util.cmp.confirm { select = true },
          ["<S-CR>"] = Util.cmp.confirm { select = true, behavior = TC.ConfirmBehavior.Replace },
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
              local line, col = unpack(vim.api.nvim_win_get_cursor(0))
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
        sources = cmp.config.sources {
          {
            name = "nvim_lsp",
            priority = 400,
            option = {
              markdown_oxide = {
                keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
              },
            },
          },
          { name = "snippets", priority = 300, group_index = 1 },
          { name = "supermaven", priority = 200, group_index = 2 },
          { name = "path" },
          { name = "buffer" },
          { name = "lazydev", group_index = 0 },
        },
      })
    end,
    main = "utils.cmp",
  },
}
