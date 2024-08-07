return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    cmd = "ConformInfo",
    init = function()
      -- install conform formatter on VeryLazy
      Util.on_very_lazy(function()
        Util.format.register {
          name = "conform.nvim",
          priority = 100,
          primary = true,
          format = function(buf)
            local plugin = require("lazy.core.config").plugins["conform.nvim"]
            local opts = require("lazy.core.plugin").values(plugin, "opts", false)
            require("conform").format(Util.merge(opts.format, { bufnr = buf }))
          end,
          sources = function(buf)
            local ret = require("conform").list_formatters(buf)
            ---@param v conform.FormatterInfo
            return vim.tbl_map(function(v) return v.name end, ret)
          end,
        }
      end)
    end,
    opts = {
      format = { timeout_ms = 3000, async = false, quiet = false, lsp_fallback = true },
      formatters_by_ft = {
        lua = { "stylua" },
        toml = { "taplo" },
        proto = { { "buf", "protolint" } },
        zsh = { "beautysh" },
        python = { "ruff_fix" },
        sh = { "shfmt" },
        markdown = { "prettier" },
        go = { "goimports", "gofumpt" },
        ["javascript"] = { "prettier" },
        ["javascriptreact"] = { "prettier" },
        ["typescript"] = { "prettier" },
        ["typescriptreact"] = { "prettier" },
        ["css"] = { "prettier" },
        ["scss"] = { "prettier" },
        ["less"] = { "prettier" },
        ["html"] = { "prettier" },
        ["json"] = { "prettier" },
        ["jsonc"] = { "prettier" },
        ["yaml"] = { "prettier" },
      },
      ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
      formatters = {
        injected = { options = { ignore_errors = true } },
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
        beautysh = { prepend_args = { "-i", "2" } },
      },
    },
    config = function(_, opts) require("conform").setup(opts) end,
  },
  {
    "supermaven-inc/supermaven-nvim",
    event = "LazyFile",
    opts = {
      ignore_filetypes = {
        gitcommit = true,
        hgcommit = true,
        vimrc = true,
        TelescopePrompt = true,
        ministarter = true,
        nofile = true,
        startup = true,
      },
      disable_inline_completion = true,
      log_level = "warn",
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
      "hrsh7th/cmp-emoji",
      {
        "garymjr/nvim-snippets",
        opts = {
          friendly_snippets = true,
          ignored_filetypes = { "git" },
        },
        dependencies = { "rafamadriz/friendly-snippets" },
      },
    },
    ---@return cmp.ConfigSchema
    opts = function()
      ---@param str string
      ---@return string
      local replace_termcodes = function(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      local cmp = require "cmp"
      local defaults = require "cmp.config.default"()
      local compare = require "cmp.config.compare"

      local windows = cmp.config.window.bordered {
        border = BORDER,
        side_padding = 0,
        scrollbar = false,
        zindex = 30,
        winhighlight = "Normal:Normal,FloatBorder:Normal",
      }

      local select_opts = { behavior = cmp.SelectBehavior.Select }
      ---@type cmp.ConfigSchema
      return vim.tbl_deep_extend("force", defaults, {
        completion = { completeopt = "menu,menuone,noinsert,noselect" },
        snippet = { expand = function(item) return Util.cmp.expand(item.body) end },
        formatting = {
          fields = { "menu", "abbr", "kind" },
          expandable_indicator = true,
          format = require("lspkind").cmp_format {
            mode = "symbol",
            max_width = 30,
            symbol_map = {
              Supermaven = "",
            },
          },
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        window = { completion = windows, documentation = windows },
        sorting = {
          priority_weight = 2,
          comparators = {
            compare.offset,
            compare.exact,
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
          local disabled = { gitcommit = true, TelescopePrompt = true }
          return not disabled[vim.bo.filetype]
        end,
        mapping = cmp.mapping.preset.insert {
          ["<CR>"] = Util.cmp.confirm { select = true },
          ["<S-CR>"] = Util.cmp.confirm { select = true, behavior = cmp.ConfirmBehavior.Replace },
          ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
          ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
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
          { name = "path", priority = 250 },
          { name = "nvim_lsp", priority = 200, keyword_length = 3, max_item_count = 350 },
          { name = "snippets", keyword_length = 2, priority = 100 },
          { name = "buffer", keyword_length = 3 },
          { name = "supermaven" },
          { name = "emoji" },
          { name = "lazydev", group_index = 0 },
        },
      })
    end,
    main = "utils.cmp",
  },
}
