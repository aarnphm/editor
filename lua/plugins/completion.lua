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
            local Plugin = require "lazy.core.plugin"
            local opts = Plugin.values(plugin, "opts", false)
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
      format = { timeout_ms = 2000, async = false, quiet = true },
      formatters_by_ft = {
        lua = { "stylua" },
        toml = { "taplo" },
        proto = { { "buf", "protolint" } },
        zsh = { "beautysh" },
        sh = { "beautysh" },
        markdown = { "prettier" },
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
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "onsails/lspkind.nvim",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-emoji",
      { "saecki/crates.nvim", event = { "BufRead Cargo.toml" }, opts = { src = { cmp = { enabled = true } } } },
      {
        "L3MON4D3/LuaSnip",
        dependencies = {
          "rafamadriz/friendly-snippets",
          config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
        },
        keys = {
          {
            "<tab>",
            function() return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>" end,
            expr = true,
            silent = true,
            mode = "i",
          },
          { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
          { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
        },
        build = (not jit.os:find "Windows")
            and "echo -e 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
          or nil,
        config = function(_, opts)
          require("luasnip").setup(opts)
          require("luasnip.loaders.from_vscode").lazy_load()
          require("luasnip.loaders.from_lua").lazy_load { paths = vim.fn.stdpath "config" .. "/snippets/" }
          vim.api.nvim_create_user_command(
            "LuaSnipEdit",
            function() require("luasnip.loaders.from_lua").edit_snippet_files() end,
            {}
          )
        end,
        opts = {
          history = true,
          -- Event on which to check for exiting a snippet's region
          region_check_events = "InsertEnter",
          delete_check_events = "TextChanged",
          ft_func = function() return vim.split(vim.bo.filetype, ".", { plain = true }) end,
        },
      },
      {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        version = false,
        event = "InsertEnter",
        build = ":Copilot auth",
        opts = {
          cmp = { enabled = true, method = "getCompletionsCycling" },
          panel = { enabled = false },
          suggestion = { enabled = true, auto_trigger = true },
          filetypes = {
            markdown = true,
            help = false,
            hgcommit = false,
            gitcommit = false,
            svn = false,
            cvs = false,
            TelescopePrompt = false,
            big_file_disabled_ft = false,
            neogitCommitMessage = false,
          },
        },
      },
    },
    ---@return cmp.ConfigSchema
    opts = function()
      ---@param str string
      ---@return string
      local replace_termcodes = function(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      local cmp = require "cmp"
      local compare = require "cmp.config.compare"

      local select_opts = { behavior = cmp.SelectBehavior.Select }
      return {
        preselect = cmp.PreselectMode.Item,
        completion = { completeopt = "menuone,noselect" },
        matching = { disallow_partial_fuzzy_matching = false },
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        formatting = {
          fields = { "menu", "abbr", "kind" },
          format = require("lspkind").cmp_format { mode = "symbol", maxwidth = 50 },
        },
        window = {
          completion = { border = BORDER },
          documentation = {
            border = BORDER,
            winhighlight = "Normal:CmpDocumentation,FloatBorder:CmpDocumentation,Search:None",
            side_padding = 1,
          },
        },
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
        experimental = { ghost_text = { hl_group = "CmpGhostText" } },
        mapping = cmp.mapping.preset.insert {
          ["<CR>"] = cmp.mapping.confirm { select = true },
          ["<S-CR>"] = cmp.mapping.confirm { select = true, behavior = cmp.ConfirmBehavior.Replace },
          ["<C-k>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
          ["<C-j>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
          ["<localleader>["] = cmp.mapping(function(fallback)
            if require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").next()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<localleader>]"] = cmp.mapping(function(fallback)
            if require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").prev()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            local col = vim.fn.col "." - 1
            if require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").accept()
            elseif cmp.visible() then
              cmp.select_next_item(select_opts)
            elseif require("luasnip").expand_or_jumpable() then
              vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-expand-or-jump", "")
            elseif col == 0 or vim.fn.getline("."):sub(col, col):match "%s" then
              fallback()
            else
              cmp.complete()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").accept()
            elseif cmp.visible() then
              cmp.select_prev_item(select_opts)
            elseif require("luasnip").jumpable(-1) then
              vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-jump-prev", "")
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = {
          { name = "path", priority = 250 },
          { name = "nvim_lsp", keyword_length = 3, max_item_count = 350 },
          { name = "buffer", keyword_length = 3 },
          { name = "luasnip", keyword_length = 2 },
          { name = "emoji" },
        },
      }
    end,
    ---@param opts cmp.ConfigSchema
    config = function(_, opts)
      local cmp = require "cmp"
      local buf = vim.api.nvim_get_current_buf()
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end
      if Util.has "clangd_extensions.nvim" and vim.tbl_contains({ "c", "cpp", "hpp", "h" }, vim.bo[buf].filetype) then
        table.insert(opts.sorting.comparators, 1, require "clangd_extensions.cmp_scores")
      end

      cmp.setup(opts)

      -- special cases with crates.nvim
      vim.api.nvim_create_autocmd({ "BufRead" }, {
        group = augroup "cmp_source_cargo",
        pattern = "Cargo.toml",
        callback = function() cmp.setup.buffer { sources = { { name = "crates" } } } end,
      })
    end,
  },
}
