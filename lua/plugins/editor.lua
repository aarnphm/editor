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
    url = "https://codeberg.org/andyg/leap.nvim",
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
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)")
      vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
      vim.keymap.set("n", "gs", "<Plug>(leap-from-window)")
    end,
  },
  {
    "MagicDuck/grug-far.nvim",
    opts = {
      headerMaxWidth = 50,
      windowCreationCommand = "botright vsplit",
    },
    cmd = "GrugFar",
    keys = {
      {
        "<LocalLeader>w",
        function() require("grug-far").open { transient = true, windowCreationCommand = "60vsplit" } end,
        mode = { "n", "v" },
        desc = "search: open and replace",
      },
      {
        "<LocalLeader>hw",
        function()
          require("grug-far").open {
            transient = true,
            windowCreationCommand = "topleft 60vsplit",
          }
        end,
        mode = { "n", "v" },
        desc = "search: open and replace (left)",
      },
      {
        "<LocalLeader>jw",
        function()
          require("grug-far").open {
            transient = true,
            instanceName = "far-below",
            windowCreationCommand = "botright 15split",
          }
        end,
        mode = { "n", "v" },
        desc = "search: open and replace (below)",
      },
      {
        "<Leader>w",
        function()
          local ext = vim.bo.buftype == "" and vim.fn.expand "%:e"
          require("grug-far").open {
            transient = true,
            windowCreationCommand = "60vsplit",
            prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
          }
        end,
        mode = { "n", "v" },
        desc = "search: open and replace (current filetype)",
      },
      {
        "<Leader>hw",
        function()
          local ext = vim.bo.buftype == "" and vim.fn.expand "%:e"
          require("grug-far").open {
            transient = true,
            windowCreationCommand = "topleft 60vsplit",
            prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
          }
        end,
        mode = { "n", "v" },
        desc = "search: open and replace (current filetype, left)",
      },
      {
        "<Leader>jw",
        function()
          local ext = vim.bo.buftype == "" and vim.fn.expand "%:e"
          require("grug-far").open {
            transient = true,
            instanceName = "far-below",
            windowCreationCommand = "botright 15split",
            prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
          }
        end,
        mode = { "n", "v" },
        desc = "search: open and replace (current filetype, below)",
      },
      {
        "<Leader>/",
        function()
          require("grug-far").open {
            transient = true,
            windowCreationCommand = "60vsplit",
            prefills = { search = vim.fn.expand "<cword>" },
          }
        end,
        mode = { "n", "v" },
        desc = "search: open and replace (cursor word)",
      },
      {
        "<Leader>h/",
        function()
          require("grug-far").open {
            transient = true,
            windowCreationCommand = "topleft 60vsplit",
            prefills = { search = vim.fn.expand "<cword>" },
          }
        end,
        mode = { "n", "v" },
        desc = "search: open and replace (cursor word, left)",
      },
      {
        "<Leader>j/",
        function()
          require("grug-far").open {
            transient = true,
            windowCreationCommand = "botright 15split",
            prefills = { search = vim.fn.expand "<cword>" },
          }
        end,
        mode = { "n", "v" },
        desc = "search: open and replace (cursor word, below)",
      },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "~/workspace/neovim-plugins/avante.nvim/lua", words = { "avante" } },
        { path = "~/workspace/neovim-plugins/surf.nvim/lua", words = { "surf" } },
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "conform.nvim", words = { "conform" } },
      },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {
      modes = {
        lsp = {
          win = { position = "right" },
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "trouble: diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "trouble: buffer diagnostics" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "trouble: symbols" },
      { "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "trouble: LSP references/definitions/..." },
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
        desc = "trouble: previous trouble/quickfix item",
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
        desc = "trouble: next trouble/quickfix item",
      },
    },
  },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoQuickFix", "TodoLocList" },
    event = "LazyFile",
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "todo: next" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "todo: previous" },
    },
  },
  {
    "folke/which-key.nvim",
    event = "LazyFile",
    lazy = true,
    enabled = true,
    opts_extend = { "spec" },
    opts = {
      win = { border = "single" },
      spec = {
        { "<BS>", desc = "treesitter: decrement selection", mode = "x" },
        { "<c-space>", desc = "treesiter: increment selection", mode = { "x", "n" } },
        {
          mode = { "n", "v" },
          { "<leader>a", group = "avante", icon = { icon = " ", color = "cyan" } },
          { "<leader><tab>", group = "tabs" },
          { "<leader>c", group = "code" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>h", group = "hunks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
          { "<leader>x", group = "dignostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
          {
            "<leader>b",
            group = "buffer",
            expand = function() return require("which-key.extras").expand.buf() end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function() return require("which-key.extras").expand.win() end,
          },
          -- better descriptions
          { "gx", desc = "util: open with system app" },
        },
      },
      disable = { ft = { "minifiles" } },
    },
    keys = {
      {
        "<leader>?",
        function() require("which-key").show { global = false } end,
        desc = "which-key: buffer keymaps",
      },
      {
        "<c-w><space>",
        function() require("which-key").show { keys = "<c-w>", loop = true } end,
        desc = "which-key: window hydra mode",
      },
    },
  },
  {
    "Bekaboo/dropbar.nvim",
    version = false,
    enabled = true,
    event = "LazyFile",
    ---@type dropbar_configs_t
    opts = {
      bar = {
        enable = function(buf, win, _)
          if
            not vim.api.nvim_buf_is_valid(buf)
            or not vim.api.nvim_win_is_valid(win)
            or vim.fn.win_gettype(win) ~= ""
            or vim.wo[win].winbar ~= ""
            or vim.tbl_contains({ "help", "Avante", "terminal" }, vim.bo[buf].ft)
          then
            return false
          end

          local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
          if stat and stat.size > Snacks.config.bigfile.size then return false end

          return vim.bo[buf].ft == "markdown"
            or pcall(vim.treesitter.get_parser, buf)
            or not vim.tbl_isempty(vim.lsp.get_clients {
              bufnr = buf,
              method = "textDocument/documentSymbol",
            })
        end,
        hover = false,
        sources = function(buf, _)
          local sources = require "dropbar.sources"
          local utils = require "dropbar.utils"
          if vim.bo[buf].ft == "markdown" then return { sources.markdown } end
          return { utils.source.fallback { sources.lsp, sources.treesitter } }
        end,
      },
    },
    config = function()
      vim.keymap.set("n", "<leader>;", '<cmd>lua require("dropbar.api").pick()<cr>', { desc = "dropbar: pick" })
    end,
  },
  {
    "stevearc/quicker.nvim",
    event = "LazyFile",
    keys = {
      {
        "<leader>xx",
        function()
          if #vim.fn.getqflist() > 0 then
            require("quicker").toggle()
          else
            Util.warn "Quickfix list is empty"
          end
        end,
        mode = { "n", "v" },
        desc = "qf: toggle quickfix",
      },
      {
        "<leader>xl",
        function()
          if #vim.fn.getloclist(vim.api.nvim_get_current_win()) > 0 then
            require("quicker").toggle { loclist = true }
          else
            Util.warn "Location list is empty"
          end
        end,
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
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    keys = {
      {
        "]h",
        function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            require("gitsigns.actions").nav_hunk "next"
          end
        end,
        desc = "git: next hunk",
      },
      {
        "[h",
        function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            require("gitsigns.actions").nav_hunk "prev"
          end
        end,
        desc = "git: prev hunk",
      },
      {
        "<leader>hb",
        function() require("gitsigns.actions").blame_line { full = true } end,
        desc = "git: blame line",
      },
      {
        "[H",
        function() require("gitsigns.actions").nav_hunk "first" end,
        desc = "git: first hunk",
      },
      {
        "[H",
        function() require("gitsigns.actions").nav_hunk "last" end,
        desc = "git: last hunk",
      },
      {
        "<leader>hp",
        function() require("gitsigns.actions").preview_hunk_inline() end,
        desc = "git: preview hunk inline",
      },
      {
        "<leader>hP",
        function() require("gitsigns.actions").preview_hunk() end,
        desc = "git: preview hunk",
      },
      { "<leader>hR", ":Gitsigns reset_buffer<CR>", desc = "git: reset buffer" },
      { "<leader>hS", ":Gitsigns stage_buffer<CR>", desc = "git: stage buffer" },
      { "<leader>hs", ":Gitsigns stage_hunk<CR>", mode = { "n", "v" }, desc = "git: stage hunk" },
      { "<leader>hr", ":Gitsigns reset_hunk<CR>", mode = { "n", "v" }, desc = "git: reset hunk" },
      { "<leader>hh", ":Gitsigns setqflist<CR>", mode = { "n", "v" }, desc = "git: set qflist" },
      { "ih", ":<C-U>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "git: select hunk" },
    },
    ---@type Gitsigns.Config
    opts = {
      numhl = true,
      attach_to_untracked = true,
      _new_sign_calc = true,
      _refresh_staged_on_update = true,
    },
  },
}
