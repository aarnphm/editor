return {
  {
    "ggandor/flit.nvim",
    opts = { labeled_modes = "nx" },
    keys = function()
      ---@type LazyKeysSpec[]
      local ret = {}
      for _, key in ipairs { "f", "F", "t", "T" } do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
      end
      return ret
    end,
  },
  {
    "ggandor/leap.nvim",
    keys = {
      { "s", mode = { "n", "x", "o" }, desc = "motion: leap forward to" },
      { "S", mode = { "n", "x", "o" }, desc = "motion: leap backward to" },
      -- Linewise.
      {
        "gA",
        'V<cmd>lua require("leap.treesitter").select()<cr>',
        mode = { "n", "x", "o" },
        desc = "motion: leap treesiter (linewise)",
      },
      {
        "ga",
        function()
          local sk = vim.deepcopy(require("leap").opts.special_keys) ---@type LeapSpecialKeys
          -- The items in `special_keys` can be both strings or tables - the
          -- shortest workaround might be the below one:
          sk.next_target = vim.fn.flatten(vim.list_extend({ "a" }, { sk.next_target }))
          sk.prev_target = vim.fn.flatten(vim.list_extend({ "A" }, { sk.prev_target }))

          require("leap.treesitter").select { opts = { special_keys = sk } }
        end,
        mode = { "n", "x", "o" },
        desc = "motion: leap treesitter",
      },
      { "|", "V<cmd>lua Util.motion.leap_line_start()<cr>", mode = "o", desc = "motion: leap line start (linewise)" },
      -- For maximum comfort, force linewise selection in the mappings:
      {
        "|",
        function()
          -- Only force V if not already in it (otherwise it would exit Visual mode).
          if vim.fn.mode(1) ~= "V" then vim.cmd "normal! V" end
          Util.motion.leap_line_start()
        end,
        mode = "x",
        desc = "motion: leap line start",
      },
    },
    opts = {
      max_highlighted_traversal_targets = 15,
    },
    ---@param opts LeapOpts
    config = function(_, opts)
      ---@type Leap
      local leap = require "leap"
      for key, val in pairs(opts) do
        leap.opts[key] = val
      end
      leap.add_default_mappings(true)

      vim.keymap.del({ "x", "o" }, "x")
      vim.keymap.del({ "x", "o" }, "X")
    end,
  },
  { "tpope/vim-repeat", lazy = false },
  {
    "Bekaboo/dropbar.nvim",
    version = false,
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    ---@type dropbar_configs_t
    opts = {
      general = {
        enable = function(buf, win, _)
          return vim.api.nvim_buf_is_valid(buf)
            and vim.api.nvim_win_is_valid(win)
            and vim.wo[win].winbar == ""
            and vim.fn.win_gettype(win) == ""
            and vim.bo[buf].ft ~= "help"
            and vim.bo[buf].ft ~= "Avante"
            and ((pcall(vim.treesitter.get_parser, buf)) and true or false)
        end,
      },
    },
    config = function(_, opts)
      vim.keymap.set("n", "<leader>B", '<cmd>lua require("dropbar.api").pick()<cr>', { desc = "dropbar: pick" })
      require("dropbar").setup(opts)
    end,
  },
  -- search/replace in multiple files
  {
    "MagicDuck/grug-far.nvim",
    opts = {
      headerMaxWidth = 50,
      windowCreationCommand = "botright vsplit",
    },
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require "grug-far"
          local ext = vim.bo.buftype == "" and vim.fn.expand "%:e"
          grug.grug_far {
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          }
        end,
        mode = { "n", "v" },
        desc = "search: open and replace",
      },
      {
        "<leader>sw",
        function()
          local grug = require "grug-far"
          grug.grug_far {
            transient = true,
            prefills = { search = vim.fn.expand "<cword>" },
          }
        end,
        mode = { "n", "v" },
        desc = "search: open and replace (cursor word)",
      },
    },
  },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTelescope" },
    event = "LazyFile",
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "todo: next" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "todo: previous" },
    },
  },
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    init = function()
      -- install conform formatter on VeryLazy
      Util.on_very_lazy(function()
        Util.format.register {
          name = "conform.nvim",
          priority = 100,
          primary = true,
          format = function(buf) require("conform").format { bufnr = buf } end,
          sources = function(buf)
            local ret = require("conform").list_formatters(buf)
            ---@param v conform.FormatterInfo
            return vim.tbl_map(function(v) return v.name end, ret)
          end,
        }
      end)
    end,
    keys = {
      {
        "<leader>cF",
        function() require("conform").format { formatters = { "injected" }, timeout_ms = 3000 } end,
        mode = { "n", "v" },
        desc = "format: injected langs",
      },
    },
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false, -- not recommended to change
        quiet = false, -- not recommended to change
        lsp_format = "fallback", -- not recommended to change
      },
      formatters_by_ft = {
        lua = { "stylua" },
        toml = { "taplo" },
        proto = { "buf", "protolint" },
        zsh = { "beautysh", fallback = true },
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
        injected = {
          options = { ignore_errors = true },
          lang_to_ext = {
            bash = "sh",
            c_sharp = "cs",
            elixir = "exs",
            javascript = "js",
            julia = "jl",
            latex = "tex",
            markdown = "md",
            python = "py",
            ruby = "rb",
            rust = "rs",
            teal = "tl",
            typescript = "ts",
          },
        },
        beautysh = { prepend_args = { "-i", "2" } },
      },
    },
  },
  -- outline
  {
    "hedyhli/outline.nvim",
    keys = { { "<leader>cs", "<cmd>Outline<cr>", desc = "outline: toggle" } },
    cmd = "Outline",
    opts = function()
      local defaults = require("outline.config").defaults
      local opts = {
        symbols = {
          ---@type {string: outline.Symbol }
          icons = {},
        },
        outline_window = { width = 25 },
        keymaps = {
          up_and_jump = "<up>",
          down_and_jump = "<down>",
        },
      }

      for kind, symbol in pairs(defaults.symbols.icons) do
        local mini_icon, hl, _ = MiniIcons.get("lsp", kind:lower())
        opts.symbols.icons[kind] = vim.tbl_deep_extend("force", defaults.symbols.icons[kind], {
          icon = mini_icon and mini_icon or symbol.icon,
          hl = mini_icon and hl or symbol.hl,
        })
      end
      return opts
    end,
  },
  -- quickfix
  {
    "folke/trouble.nvim",
    version = false,
    opts = {
      modes = {
        lsp = {
          win = { type = "split", position = "right" },
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "trouble: diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "trouble: buffer diagnostics" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "trouble: location list" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "trouble: quickfix list" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").prev { skip_groups = true, jump = true }
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then vim.notify(err, vim.log.levels.ERROR) end
          end
        end,
        desc = "trouble: previous item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next { skip_groups = true, jump = true }
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then vim.notify(err, vim.log.levels.ERROR) end
          end
        end,
        desc = "trouble: next item",
      },
    },
    cmd = "Trouble",
  },
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      auto_enable = true,
      auto_resize_height = true, -- highly recommended enable
      preview = {
        auto_preview = true,
        win_height = 12,
        win_vheight = 12,
        border = vim.g.border,
        show_title = true,
        should_preview_cb = function(bufnr, _) return not Util.is_bigfile(bufnr) end,
      },
      -- make `drop` and `tab drop` to become preferred
      func_map = {
        drop = "o",
        openc = "O",
        split = "<C-s>",
        tabdrop = "<C-t>",
        ptogglemode = "z,",
      },
      filter = {
        fzf = {
          action_for = { ["ctrl-s"] = "split", ["ctrl-t"] = "tab drop" },
          extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
        },
      },
    },
  },
  {
    "stevearc/quicker.nvim",
    event = "LazyFile",
    keys = {
      {
        "<leader>q",
        function() require("quicker").toggle() end,
        mode = { "n", "v" },
        desc = "qf: toggle quickfix",
      },
      {
        "<leader>l",
        function() require("quicker").toggle { loclist = true } end,
        mode = { "n", "v" },
        desc = "qf: toggle loclist",
      },
    },
    opts = {
      opts = {
        buflisted = false,
        number = true,
        relativenumber = true,
        signcolumn = "auto",
        winfixheight = true,
        wrap = false,
      },
      on_qf = function(bufnr)
        Util.safe_keymap_set(
          "n",
          "<Leader>Q",
          function() require("quicker.context").refresh() end,
          { desc = "quickfix: refresh buffer", buffer = bufnr }
        )
      end,
      keys = {
        {
          ">",
          function() require("quicker").expand { before = 2, after = 2, add_to_existing = true } end,
          desc = "qf: expand context",
        },
        {
          "<",
          function() require("quicker").collapse() end,
          desc = "qf: collapse context",
        },
      },
    },
  },
}
