require "aarnphm" -- default setup
if vim.g.vscode then return end -- NOTE: compatible block with vscode

local utils = require "utils"

-- bootstrap logics
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  }
end
vim.opt.runtimepath:prepend(lazypath)

local colorscheme = vim.NIL ~= vim.env.SIMPLE_COLORSCHEME and vim.env.SIMPLE_COLORSCHEME or "rose-pine"
local background = vim.NIL ~= vim.env.SIMPLE_BACKGROUND and vim.env.SIMPLE_BACKGROUND or "dark"

require("lazy").setup({
  -- NOTE: utilities
  "lewis6991/impatient.nvim",
  "nvim-lua/plenary.nvim",
  "jghauser/mkdir.nvim",
  "nvim-tree/nvim-web-devicons",
  {
    "stevearc/dressing.nvim",
    opts = {
      input = {
        enabled = true,
        override = function(config) return vim.tbl_deep_extend("force", config, { col = -1, row = 0 }) end,
      },
      select = { enabled = true, backend = "telescope", trim_prompt = true },
    },
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.input(...)
      end
    end,
    config = true,
  },
  -- NOTE: cozy colorscheme
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    opts = {
      disable_italics = true,
      dark_variant = "main",
      highlight_groups = {
        Comment = { fg = "muted", italic = true },
        StatusLine = { fg = "rose", bg = "iris", blend = 10 },
        StatusLineNC = { fg = "subtle", bg = "surface" },
        TelescopeBorder = { fg = "highlight_high" },
        TelescopeNormal = { fg = "subtle" },
        TelescopePromptNormal = { fg = "text" },
        TelescopeSelection = { fg = "text" },
        TelescopeSelectionCaret = { fg = "iris" },
      },
    },
  },
  -- NOTE: nice git integration and UI
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    opts = {
      numhl = true,
      watch_gitdir = { interval = 1000, follow_files = true },
      current_line_blame = true,
      current_line_blame_opts = { delay = 1000, virtual_text_pos = "eol" },
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      word_diff = false,
      diff_opts = { internal = true },
      on_attach = function(bufnr)
        local actions = require "gitsigns.actions"
        local kmap = function(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc }) end
        kmap("n", "]h", actions.next_hunk, "git: next hunk")
        kmap("n", "[h", actions.prev_hunk, "git: prev hunk")
        kmap("n", "<leader>hu", actions.undo_stage_hunk, "git: undo stage hunk")
        kmap("n", "<leader>hR", actions.reset_buffer, "git: reset buffer")
        kmap("n", "<leader>hS", actions.stage_buffer, "git: stage buffer")
        kmap("n", "<leader>hp", actions.preview_hunk, "git: preview hunk")
        kmap("n", "<leader>hd", actions.diffthis, "git: diff this")
        kmap("n", "<leader>hD", function() actions.diffthis "~" end, "git: diff this ~")
        kmap("n", "<leader>hb", function() actions.blame_line { full = true } end, "git: blame Line")
        kmap({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "git: stage hunk")
        kmap({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "git: reset hunk")
        kmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  -- NOTE: exit fast af
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      timeout = 200,
      clear_empty_lines = true,
      keys = "<Esc>",
    },
  },
  -- NOTE: treesitter-based dependencies
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    cmd = { "TSUpdateSync" },
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "windwp/nvim-ts-autotag",
      "nvim-treesitter/playground",
      { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true, opts = { enable_autocmd = false } },
    },
  },
  -- NOTE: comments, you say what?
  {
    "numToStr/Comment.nvim",
    lazy = true,
    event = "BufReadPost",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = true,
  },
  -- NOTE: mini libraries of deps because it is light and easy to use.
  { "echasnovski/mini.colors", version = false },
  { "echasnovski/mini.bufremove", version = false },
  { "echasnovski/mini.ai", event = "InsertEnter", dependencies = { "nvim-treesitter-textobjects" } },
  { "echasnovski/mini.align", event = "VeryLazy" },
  { "echasnovski/mini.pairs", event = "VeryLazy", opts = {} },
  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        {
          opts.mappings.add,
          desc = "Add surrounding",
          mode = { "n", "v" },
        },
        { opts.mappings.delete, desc = "Delete surrounding" },
        { opts.mappings.find, desc = "Find right surrounding" },
        { opts.mappings.find_left, desc = "Find left surrounding" },
        { opts.mappings.highlight, desc = "Highlight surrounding" },
        { opts.mappings.replace, desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m) return m[1] and #m[1] > 0 end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "sa", -- Add surrounding in Normal and Visual modes
        delete = "sd", -- Delete surrounding
        find = "sf", -- Find surrounding (to the right)
        find_left = "sF", -- Find surrounding (to the left)
        highlight = "sh", -- Highlight surrounding
        replace = "sr", -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`
      },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      debounce = 200,
      indent = {
        char = "│",
        tab_char = "│",
        smart_indent_cap = true,
        priority = 2,
      },
      whitespace = { remove_blankline_trail = true },
      -- Note: The `scope` field requires treesitter to be set up
      scope = {
        enabled = true,
        char = "┃",
        show_start = false,
        show_end = false,
        injected_languages = true,
        priority = 1000,
        include = {
          node_type = {
            ["*"] = {
              "argument_list",
              "arguments",
              "assignment_statement",
              "Block",
              "chunk",
              "class",
              "ContainerDecl",
              "dictionary",
              "do_block",
              "do_statement",
              "element",
              "except",
              "FnCallArguments",
              "for",
              "for_statement",
              "function",
              "function_declaration",
              "function_definition",
              "if_statement",
              "IfExpr",
              "IfStatement",
              "import",
              "InitList",
              "list_literal",
              "method",
              "object",
              "ParamDeclList",
              "repeat_statement",
              "selector",
              "SwitchExpr",
              "table",
              "table_constructor",
              "try",
              "tuple",
              "type",
              "var",
              "while",
              "while_statement",
              "with",
            },
          },
        },
      },
      exclude = {
        filetypes = {
          "", -- for all buffers without a file type
          "alpha",
          "big_file_disabled_ft",
          "dashboard",
          "dotooagenda",
          "flutterToolsOutline",
          "fugitive",
          "git",
          "gitcommit",
          "help",
          "json",
          "log",
          "markdown",
          "NvimTree",
          "Outline",
          "peekaboo",
          "startify",
          "TelescopePrompt",
          "todoist",
          "txt",
          "undotree",
          "vimwiki",
          "vista",
        },
        buftypes = { "terminal", "nofile", "quickfix", "prompt" },
      },
    },
  },
  -- NOTE: easily jump to any location and enhanced f/t motions for Leap
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
    keys = {
      -- { "s", mode = { "n", "x", "o" }, desc = "motion: Leap forward to" },
      -- { "S", mode = { "n", "x", "o" }, desc = "motion: Leap backward to" },
      { "gs", mode = { "n", "x", "o" }, desc = "motion: Leap from windows" },
    },
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
  -- NOTE: better UI components
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      { "junegunn/fzf", lazy = true, build = ":call fzf#install()" },
    },
    config = true,
  },
  -- NOTE: folke is neovim's tpope
  { "folke/paint.nvim", event = "BufReadPost", config = true },
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
    opts = { use_diagnostic_signs = true },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "folke/which-key.nvim",
    event = "BufReadPost",
    opts = { plugins = { presets = { operators = false } } },
    config = function(_, opts) require("which-key").setup(opts) end,
  },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
  },
  -- NOTE: fuzzy finder ftw
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
  },
  { "RRethy/vim-illuminate", event = { "BufReadPost", "BufNewFile" }, lazy = true },
  -- NOTE: better nvim-tree.lua
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    branch = "v3.x",
    deactivate = function() vim.cmd [[Neotree close]] end,
    init = function()
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then require "neo-tree" end
      end
    end,
    dependencies = {
      { "MunifTanjim/nui.nvim", lazy = true },
      "nvim-lua/plenary.nvim",
      {
        "s1n7ax/nvim-window-picker",
        lazy = true,
        opts = {
          autoselect_one = true,
          include_current = false,
          filter_rules = {
            -- filter using buffer options
            bo = {
              -- if the file type is one of following, the window will be ignored
              filetype = { "neo-tree", "neo-tree-popup", "notify" },
              -- if the buffer type is one of following, the window will be ignored
              buftype = { "terminal", "quickfix", "Scratch" },
            },
          },
        },
        config = function(_, opts) require("window-picker").setup(opts) end,
      },
    },
  },
  -- NOTE: Chad colorizer
  {
    "NvChad/nvim-colorizer.lua",
    event = "LspAttach",
    config = function()
      require("colorizer").setup {
        filetypes = { "*" },
        user_default_options = {
          names = false, -- "Name" codes like Blue
          RRGGBBAA = true, -- #RRGGBBAA hex codes
          rgb_fn = true, -- CSS rgb() and rgba() functions
          hsl_fn = true, -- CSS hsl() and hsla() functions
          css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
          sass = { enable = true, parsers = { "css" } },
          mode = "background",
        },
      }
    end,
  },
  -- NOTE: spectre for magic search and replace
  { "nvim-pack/nvim-spectre", event = "BufReadPost", cmd = "Spectre" },
  -- NOTE: nice winbar
  {
    "Bekaboo/dropbar.nvim",
    config = true,
    enabled = vim.fn.has "nvim-0.10" == 1,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      icons = {
        enable = true,
        ui = {
          bar = { separator = "  ", extends = "…" },
          menu = { separator = " ", indicator = "  " },
        },
      },
    },
  },
  -- NOTE: lspconfig
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    init = function()
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      { "williamboman/mason.nvim", cmd = "Mason", build = ":MasonUpdate" },
      {
        "dnlhc/glance.nvim",
        cmd = "Glance",
        lazy = true,
        config = true,
        opts = {
          border = { enable = true },
          height = 20,
          zindex = 50,
          preview_win_opts = {
            cursorline = true,
            number = true,
            wrap = true,
          },
          list = {
            position = "right",
            width = 0.33, -- 33% width relative to the active window, min 0.1, max 0.5
          },
        },
      },
      "hrsh7th/cmp-nvim-lsp",
      { "folke/neodev.nvim", config = true, ft = "lua" },
      { "folke/neoconf.nvim", cmd = "Neoconf", config = true, dependencies = { "nvim-lspconfig" } },
      { "b0o/SchemaStore.nvim", version = false, ft = { "json", "yaml", "yml" } },
    },
    ---@class PluginLspOptions
    opts = {
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = { enabled = false },
      -- add any global capabilities here
      capabilities = {},
      -- Enable this to show formatters used in a notification
      -- Useful for debugging formatter issues
      notify = false,
      -- options for vim.lsp.buf.format
      -- `bufnr` and `filter` is handled by the formatter,
      -- but can be also overridden when specified
      format = { formatting_options = nil, timeout_ms = nil },
      ---@type lspconfig.options
      servers = {
        jsonls = {
          -- lazy-load schemastore when needed
          on_new_config = function(config)
            config.settings.json.schemas = config.settings.json.schemas or {}
            vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
          end,
          settings = {
            json = {
              format = { enable = true },
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          -- lazy-load schemastore when needed
          on_new_config = function(config)
            if utils.has "SchemaStore" then config.settings.yaml.schemas = require("schemastore").yaml.schemas() end
          end,
          settings = { yaml = { hover = true, validate = true, completion = true } },
        },
        lua_ls = {
          settings = {
            Lua = {
              format = {
                enable = true,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                },
              },
              completion = { callSnippet = "Replace" },
              hint = { enable = true, setType = true },
              runtime = {
                version = "LuaJIT",
                special = { reload = "require" },
              },
              diagnostics = {
                globals = { "vim" },
                disable = { "different-requires" },
              },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              semantic = { enable = false },
            },
          },
        },
        bashls = {},
        marksman = {},
        spectral = {},
        taplo = {},
        pyright = {
          flags = { debounce_text_changes = 500 },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "WORKSPACE",
              ".git",
              "Pipfile",
              "pyrightconfig.json",
              "setup.py",
              "setup.cfg",
              "pyproject.toml",
              "requirements.txt"
            )(fname) or require("lspconfig.util").path.dirname(fname)
          end,
          settings = {
            python = {
              autoImportCompletions = true,
              autoSearchPaths = true,
              diagnosticMode = "workspace", -- workspace
              useLibraryCodeForTypes = true,
            },
          },
        },
      },
      ---@type table<string, fun(lspconfig:any, options:_.lspconfig.options):boolean?>
      setup = {},
    },
    ---@param opts PluginLspOptions
    config = function(client, opts)
      local lspconfig = require "lspconfig"
      utils.on_attach(function(cl, bufnr) require("keymaps").on_attach(cl, bufnr) end)
      local register_capability = vim.lsp.handlers["client/registerCapability"]

      vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
        local ret = register_capability(err, res, ctx)
        local client_id = ctx.client_id
        ---@type lsp.Client
        local cl = vim.lsp.get_client_by_id(client_id)
        local buffer = vim.api.nvim_get_current_buf()
        require("keymaps").on_attach(cl, buffer)
        return ret
      end

      local inlay_hint = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint

      if opts.inlay_hints.enabled and inlay_hint then
        utils.on_attach(function(client, bufnr)
          if client.supports_method "textDocument/inlayHint" then inlay_hint(bufnr, true) end
        end)
      end

      utils.on_attach(function(cl, bufnr)
        if cl.supports_method "textDocument/publishDiagnostics" then
          vim.lsp.handlers["textDocument/publishDiagnostics"] =
            vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
              signs = true,
              underline = true,
              virtual_text = false,
              update_in_insert = true,
            })
        end
      end)

      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        opts.capabilities or {}
      )

      local mason_handler = function(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
          flags = { debounce_text_changes = 150 },
        }, opts.servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](lspconfig, server_opts) then return end
        elseif opts.setup["*"] then
          if opts.setup["*"](lspconfig, server_opts) then return end
        else
          lspconfig[server].setup(server_opts)
        end
      end

      local have_mason, mason_lspconfig = pcall(require, "mason-lspconfig")
      local available = {}
      if have_mason then available = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package) end

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(opts.servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- NOTE: servers that are isolated should be setup manually.
          if server_opts.isolated then
            ensure_installed[#ensure_installed + 1] = server
          else
            -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
            if server_opts.mason == false or not vim.tbl_contains(available, server) then
              mason_handler(server)
            else
              ensure_installed[#ensure_installed + 1] = server
            end
          end
        end
      end

      if have_mason then
        mason_lspconfig.setup { ensure_installed = ensure_installed, handlers = { mason_handler } }
      end
    end,
  },
  -- NOTE: Setup completions.
  {
    "hrsh7th/nvim-cmp",
    version = false,
    lazy = false,
    event = "InsertEnter",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-emoji",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        build = (not jit.os:find "Windows")
            and "echo -e 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
          or nil,
        config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
        opts = { history = true, delete_check_events = "TextChanged" },
      },
    },
  },
}, {
  install = { colorscheme = { colorscheme } },
  defaults = { lazy = true },
  change_detection = { notify = false },
  concurrency = vim.loop.os_uname() == "Darwin" and 30 or nil,
  checker = { enable = true },
  ui = { border = "single" },
})

vim.o.background = background
vim.cmd.colorscheme(colorscheme)
-- NOTE: this should only be run on Terminal.app
-- require("mini.colors").get_colorscheme():add_cterm_attributes():apply()
-- vim.opt.termguicolors = false
