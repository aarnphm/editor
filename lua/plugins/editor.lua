return {
  {
    "ggandor/flit.nvim",
    opts = { labeled_modes = "nx" },
    ---@diagnostic disable-next-line: assign-type-mismatch
    keys = function()
      ---@type table<string, LazyKeys[]>
      local ret = {}
      for _, key in ipairs { "f", "F", "t", "T" } do
        ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
      end
      return ret
    end,
  },
  {
    "ggandor/leap.nvim",
    keys = { { "gs", mode = { "n", "x", "o" }, desc = "motion: Leap from windows" } },
    config = function(_, opts)
      local leap = require "leap"
      for key, val in pairs(opts) do
        leap.opts[key] = val
      end
      leap.add_default_mappings(true)
      vim.keymap.del({ "x", "o" }, "x")
      vim.keymap.del({ "x", "o" }, "X")
    end,
  },
  { "tpope/vim-repeat", event = "VeryLazy" },
  -- search/replace in multiple files
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
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
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "todo: telescope" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "todo: filter (todo/fix/fixme)" },
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
        shfmt = { prepend_args = { "-i", "2", "-ci" } },
        beautysh = { prepend_args = { "-i", "2" } },
      },
    },
    config = function(_, opts) require("conform").setup(opts) end,
  },
  -- outline
  {
    "hedyhli/outline.nvim",
    keys = { { "<leader>cs", "<cmd>Outline<cr>", desc = "outline: toggle" } },
    cmd = "Outline",
    opts = function()
      local defaults = require("outline.config").defaults
      local opts = {
        symbols = { icons = {} },
        keymaps = {
          up_and_jump = "<up>",
          down_and_jump = "<down>",
        },
      }

      for kind, symbol in pairs(defaults.symbols.icons) do
        local mini_icon, hl, _ = require("mini.icons").get("lsp", kind:lower())
        opts.symbols.icons[kind] = {
          icon = mini_icon and mini_icon or symbol.icon,
          hl = mini_icon and hl or symbol.hl,
        }
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
        delay_syntax = 80,
        border = BORDER.get(),
        show_title = false,
        should_preview_cb = function(bufnr, _)
          local ret = true
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local fsize = vim.fn.getfsize(bufname)
          if fsize > vim.g.bigfile_size then
            -- skip file size greater than 100k
            ret = false
          elseif bufname:match "^fugitive://" then
            -- skip fugitive buffer
            ret = false
          end
          return ret
        end,
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
