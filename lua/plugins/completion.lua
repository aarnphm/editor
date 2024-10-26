return {
  {
    "supermaven-inc/supermaven-nvim",
    lazy = true,
    enabled = true,
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
    opts = {
      panel = { enabled = false },
      suggestion = { enabled = true },
      filetypes = {
        markdown = true,
        help = true,
        sh = function()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then return false end
          return true
        end,
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
      "kdheepak/cmp-latex-symbols",
      "otter.nvim",
      {
        "garymjr/nvim-snippets",
        opts = {
          friendly_snippets = true,
          ignored_filetypes = { "git", "gitcommit" },
          extended_filetypes = { markdown = { "latex" } },
        },
        dependencies = "rafamadriz/friendly-snippets",
      },
      {
        "Saecki/crates.nvim",
        lazy = true,
        event = "BufRead Cargo.toml",
        opts = { completion = { cmp = { enabled = true } } },
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

      local sources = {
        {
          name = "nvim_lsp",
          keyword_length = 3,
          priority = 1000,
          option = {
            markdown_oxide = {
              keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
            },
          },
        },
        { name = "snippets", priority = 500, group_index = 1 },
        { name = "buffer", priority = 250, group_index = 1 },
        { name = "async_path", group_index = 1 },
        { name = "latex_symbols", option = { strategy = 0 } },
        { name = "supermaven", group_index = 2 },
        { name = "lazydev", group_index = 0 },
      }
      -- check if buffer is a toml file and filename is Cargo.toml
      if vim.bo.filetype == "toml" and vim.fn.expand "%:t" == "Cargo.toml" then
        sources[#sources + 1] = { name = "crates" }
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
              copilot = "[CPL]",
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
