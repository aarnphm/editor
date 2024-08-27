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
      disable_keymaps = true,
    },
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    lazy = true,
    version = false,
    build = ":Copilot auth",
    keys = {
      {
        "<C-k>",
        function()
          return Util.is_loaded "copilot.lua" and require("copilot.suggestion").toggle_auto_trigger() or "<C-k>"
        end,
        expr = true,
        silent = true,
        mode = "i",
      },
    },
    opts = {
      cmp = { enabled = false, method = "getCompletionsCycling" },
      panel = { enabled = false },
      suggestion = { enabled = false, auto_trigger = false },
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
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "FelipeLema/cmp-async-path",
      {
        "garymjr/nvim-snippets",
        opts = { friendly_snippets = true, ignored_filetypes = { "git", "gitcommit" } },
        dependencies = { "rafamadriz/friendly-snippets" },
      },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        cmd = "LazyDev",
        dependencies = {
          -- Manage libuv types with lazy. Plugin will never be loaded
          { "Bilal2453/luvit-meta", lazy = true },
        },
        opts = {
          library = {
            { path = "~/workspace/neovim-plugins/avante.nvim/lua", words = { "avante" } },
            { path = "luvit-meta/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    ---@return cmp.ConfigSchema
    opts = function()
      local cmp = require "cmp"
      local TC = require "cmp.types.cmp"
      local defaults = require "cmp.config.default"()

      ---@type cmp.SelectOption
      local select_opts = { behavior = cmp.SelectBehavior.Select }

      return vim.tbl_deep_extend("force", defaults, {
        auto_brackets = { "python" },
        preselect = TC.PreselectMode.None,
        completion = { completeopt = "menu,menuone,noinsert" },
        ---@type cmp.WindowConfig
        window = {
          documentation = {
            max_height = 20,
            max_width = 40,
            border = { "", "", "", " ", "", "", "", "" },
            winhighlight = "FloatBorder:NormalFloat",
            winblend = vim.o.pumblend,
          },
        },
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
              nvim_lsp = "[LSP]",
              nvim_lua = "[LUA]",
              snippets = "[SNP]",
              buffer = "[BUF]",
              async_path = "[DIR]",
              latex_symbols = "[LTX]",
            })[entry.source.name]

            ---@type table<"abbr"|"menu", integer>
            local widths = { abbr = 20, menu = 10 }

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
        enabled = function()
          local disabled_filetype = {
            gitcommit = true,
            TelescopePrompt = true,
            help = true,
            minifiles = true,
            Avante = true,
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
              local line, col = unpack(vim.api.nvim_win_get_cursor(0))
              return col ~= 0
                and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
            end

            local supermaven = require "supermaven-nvim.completion_preview"

            if cmp.visible() then
              cmp.select_next_item(select_opts)
            elseif vim.snippet.active { direction = 1 } then
              vim.schedule(function() vim.snippet.jump(1) end)
            elseif vim.g.enable_agent_inlay and supermaven.has_suggestion() then
              supermaven.on_accept_suggestion()
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
            option = {
              markdown_oxide = {
                keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
              },
            },
          },
          { name = "snippets", group_index = 1 },
          { name = "supermaven", group_index = 2 },
          { name = "async_path" },
          { name = "buffer" },
          { name = "lazydev", group_index = 0 },
        },
      })
    end,
    main = "utils.cmp",
  },
}
