return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    cmd = "ConformInfo",
    init = function()
      -- install conforn formatter on VeryLazy
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
      format = {
        timeout_ms = 2000,
        async = false, -- not recommended to change
        quiet = false, -- not recommended to change
      },
      formatters_by_ft = {
        lua = { "stylua" },
        toml = { "taplo" },
        python = { "ruff_fix", "ruff_format" },
        zsh = { "beautysh" },
      },
      ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
      formatters = {
        injected = { options = { ignore_errors = true } },
        shfmt = {
          prepend_args = { "-i", "2", "-ci" },
        },
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
      "kdheepak/cmp-latex-symbols",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
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
          delete_check_events = "InsertLeave",
          ft_func = function() return vim.split(vim.bo.filetype, ".", { plain = true }) end,
        },
      },
      {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        build = ":Copilot auth",
        opts = {
          cmp = { enabled = true, method = "getCompletionsCycling" },
          panel = { enabled = false },
          suggestion = { enabled = true, auto_trigger = true },
          filetypes = {
            markdown = true,
            help = false,
            terraform = false,
            hgcommit = false,
            gitcommit = false,
            svn = false,
            cvs = false,
            ["dap-repl"] = false,
            octo = false,
            TelescopePrompt = false,
            big_file_disabled_ft = false,
            neogitCommitMessage = false,
          },
        },
        config = function(_, opts)
          vim.defer_fn(function() require("copilot").setup(opts) end, 100)
        end,
      },
    },
    opts = function()
      local check_backspace = function()
        local col = vim.fn.col "." - 1
        ---@diagnostic disable-next-line: param-type-mismatch
        local current_line = vim.fn.getline "."
        ---@diagnostic disable-next-line: undefined-field
        return col == 0 or current_line:sub(col, col):match "%s"
      end

      ---@param str string
      ---@return string
      local replace_termcodes = function(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      local cmp = require "cmp"
      local defaults = require "cmp.config.default"()

      ---@type cmp.ConfigSchema
      return {
        preselect = cmp.PreselectMode.Item,
        completion = { completeopt = "menu,menuone,noinsert" },
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        formatting = {
          fields = { "menu", "abbr", "kind" },
          format = require("lspkind").cmp_format { mode = "symbol", maxwidth = 50 },
        },
        window = { documentation = { border = "none", winhighlight = "Normal:Pmenu" } },
        sorting = defaults.sorting,
        experimental = { ghost_text = { hl_group = "CmpGhostText" } },
        mapping = cmp.mapping.preset.insert {
          ["<CR>"] = cmp.mapping.confirm { select = true },
          ["<S-CR>"] = cmp.mapping.confirm { select = true, behavior = cmp.ConfirmBehavior.Replace },
          ["<C-k>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
          ["<C-j>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
          ["<Tab>"] = function(fallback)
            if require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").accept()
            elseif cmp.visible() then
              cmp.select_next_item()
            elseif require("luasnip").expand_or_jumpable() then
              vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-expand-or-jump", "")
            elseif check_backspace() then
              vim.fn.feedkeys(replace_termcodes "<Tab>", "n")
            else
              fallback()
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif require("luasnip").jumpable(-1) then
              vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-jump-prev", "")
            else
              fallback()
            end
          end,
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
          { name = "emoji" },
          { name = "buffer" },
          { name = "latex_symbols" },
        },
      }
    end,
    ---@param opts cmp.ConfigSchema
    config = function(_, opts)
      local cmp = require "cmp"
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end
      if Util.has "clangd_extensions.nvim" then
        table.insert(opts.sorting.comparators, 1, require "clangd_extensions.cmp_scores")
      end
      cmp.setup(opts)
    end,
  },
}
