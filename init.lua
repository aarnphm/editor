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
        WindowPickerStatusLine = { fg = "rose", bg = "iris", blend = 10 },
        WindowPickerStatusLineNC = { fg = "subtle", bg = "surface" },
        GlanceWinBarTitle = { fg = "rose", bg = "iris", blend = 10 },
        GlanceWinBarFilepath = { fg = "subtle", bg = "surface" },
        GlanceWinBarFilename = { fg = "love", bg = "surface" },
        GlancePreviewNormal = { fg = "highlight_high" },
        GlancePreviewMatch = { fg = "love" },
        IblScope = { fg = "rose" },
      },
    },
  },
  { "lewis6991/gitsigns.nvim", event = "BufReadPost" },
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = { timeout = 200, clear_empty_lines = true, keys = "<Esc>" },
  },
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
  {
    "numToStr/Comment.nvim",
    lazy = true,
    event = "BufReadPost",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = true,
  },
  { "j-hui/fidget.nvim", lazy = true, event = "LspAttach", config = true, opts = { fmt = { max_messages = 3 } } },
  { "echasnovski/mini.colors", version = false },
  { "echasnovski/mini.bufremove", version = false },
  { "echasnovski/mini.ai", event = "InsertEnter", dependencies = { "nvim-treesitter-textobjects" } },
  { "echasnovski/mini.align", event = "VeryLazy" },
  { "echasnovski/mini.trailspace", event = "VeryLazy" },
  { "echasnovski/mini.pairs", event = "VeryLazy", opts = {} },
  { "echasnovski/mini.surround", event = "VeryLazy", config = true },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
  },
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
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      { "junegunn/fzf", lazy = true, build = ":call fzf#install()" },
    },
    config = true,
  },
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
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
      },
    },
  },
  { "RRethy/vim-illuminate", event = { "BufReadPost", "BufNewFile" }, lazy = true },
  { "nvim-pack/nvim-spectre", event = "BufReadPost", cmd = "Spectre" },
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
        name = "window-picker",
        lazy = true,
        opts = {
          autoselect_one = true,
          include_current = false,
          filter_rules = {
            bo = {
              filetype = { "neo-tree", "neo-tree-popup", "notify" },
              buftype = { "terminal", "quickfix", "Scratch" },
            },
          },
        },
      },
    },
  },
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
  {
    "Bekaboo/dropbar.nvim",
    config = true,
    enabled = vim.fn.has "nvim-0.10" == 1,
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "williamboman/mason.nvim", cmd = "Mason", build = ":MasonUpdate" },
      {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        init = function() vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" end,
      },
      { "dnlhc/glance.nvim", cmd = "Glance", lazy = true },
      { "folke/neodev.nvim", config = true, ft = "lua" },
      { "folke/neoconf.nvim", cmd = "Neoconf", config = true, dependencies = { "nvim-lspconfig" } },
      { "saecki/crates.nvim", event = { "BufRead Cargo.toml" }, config = true },
      {
        "simrat39/rust-tools.nvim",
        ft = "rust",
        dependencies = { "nvim-lua/plenary.nvim" },
        lazy = true,
        opts = {
          tools = {
            -- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
            reload_workspace_from_cargo_toml = true,
            inlay_hints = {
              auto = true,
              other_hints_prefix = ":: ",
              only_current_line = true,
              show_parameter_hints = false,
            },
          },
          server = {
            standalone = true,
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  loadOutDirsFromCheck = true,
                  buildScripts = { enable = true },
                },
                diagnostics = {
                  disabled = { "unresolved-proc-macro" },
                  enableExperimental = true,
                },
                checkOnSave = { command = "clippy" },
                procMacro = { enable = true },
              },
            },
          },
        },
        config = function(_, opts)
          local get_rust_adapters = function()
            if vim.loop.os_uname().sysname == "Windows_NT" then
              return {
                type = "executable",
                command = "lldb-vscode",
                name = "rt_lldb",
              }
            end
            local codelldb_extension_path = vim.fn.stdpath "data" .. "/mason/packages/codelldb/extension"
            local codelldb_path = codelldb_extension_path .. "/adapter/codelldb"
            local extension = ".so"
            if vim.loop.os_uname().sysname == "Darwin" then extension = ".dylib" end
            local liblldb_path = codelldb_extension_path .. "/lldb/lib/liblldb" .. extension
            return require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
          end

          local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
          local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            has_cmp and cmp_nvim_lsp.default_capabilities() or {},
            opts.server.capabilities or {}
          )
          opts.server.capabilities = capabilities
          opts.dap = { adapter = get_rust_adapters() }
          require("rust-tools").setup(opts)
        end,
      },
      {
        "p00f/clangd_extensions.nvim",
        ft = { "c", "cpp", "hpp", "h" },
        dependencies = { "neovim/nvim-lspconfig" },
        lazy = true,
        opts = {
          -- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/clangd.lua
          server = {
            single_file_support = true,
            filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
            capabilities = {
              offsetEncoding = { "utf-8" },
              textDocument = {
                completion = {
                  completionItem = {
                    commitCharactersSupport = true,
                    deprecatedSupport = true,
                    insertReplaceSupport = true,
                    labelDetailsSupport = true,
                    preselectSupport = true,
                    resolveSupport = {
                      properties = { "documentation", "detail", "additionalTextEdits" },
                    },
                    snippetSupport = false,
                    tagSupport = {
                      valueSet = { 1 },
                    },
                  },
                },
              },
            },
          },
        },
        config = function(_, opts)
          local lspconfig = require "lspconfig"
          local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
          local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            has_cmp and cmp_nvim_lsp.default_capabilities() or {},
            opts.server.capabilities or {}
          )

          local switch_source_header_splitcmd = function(bufnr, splitcmd)
            bufnr = lspconfig.util.validate_bufnr(bufnr)
            local params = { uri = vim.uri_from_bufnr(bufnr) }

            local clangd_client = lspconfig.util.get_active_client_by_name(bufnr, "clangd")

            if clangd_client then
              clangd_client.request("textDocument/switchSourceHeader", params, function(err, result)
                if err then error(tostring(err)) end
                if not result then
                  error("Corresponding file can’t be determined", vim.log.levels.ERROR)
                  return
                end
                vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
              end)
            else
              error(
                "Method textDocument/switchSourceHeader is not supported by any active server on this buffer",
                vim.log.levels.ERROR
              )
            end
          end

          opts.server.commands = {
            ClangdSwitchSourceHeader = {
              function() switch_source_header_splitcmd(0, "edit") end,
              description = "cpp: Open source/header in current buffer",
            },
            ClangdSwitchSourceHeaderVSplit = {
              function() switch_source_header_splitcmd(0, "vsplit") end,
              description = "cpp: Open source/header in a new vsplit",
            },
            ClangdSwitchSourceHeaderSplit = {
              function() switch_source_header_splitcmd(0, "split") end,
              description = "cpp: Open source/header in a new split",
            },
          }

          local get_binary_path_list = function(binaries)
            local get_binary_path = function(binary)
              local path = nil
              if vim.loop.os_uname().sysname == "Windows_NT" then
                path = vim.fn.trim(vim.fn.system("where " .. binary))
              else
                path = vim.fn.trim(vim.fn.system("which " .. binary))
              end
              if vim.v.shell_error ~= 0 then path = nil end
              return path
            end

            local path_list = {}
            for _, binary in ipairs(binaries) do
              local path = get_binary_path(binary)
              if path then table.insert(path_list, path) end
            end
            return table.concat(path_list, ",")
          end

          opts.server.cmd = {
            "clangd",
            "-j=12",
            "--enable-config",
            "--background-index",
            "--pch-storage=memory",
            -- You MUST set this arg ↓ to your c/cpp compiler location (if not included)!
            "--query-driver="
              .. get_binary_path_list {
                "clang++",
                "clang",
                "gcc",
                "g++",
              },
            "--clang-tidy",
            "--all-scopes-completion",
            "--completion-style=detailed",
            "--header-insertion-decorators",
            "--header-insertion=iwyu",
            "--limit-references=3000",
            "--limit-results=350",
          }

          opts.server.capabilities = capabilities

          require("clangd_extensions").setup(opts)
        end,
      },
      { "b0o/SchemaStore.nvim", version = false, ft = { "json", "yaml", "yml" } },
    },
    ---@class PluginLspOptions
    opts = {
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = { enabled = false },
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
          settings = {
            python = {
              autoImportCompletions = true,
              autoSearchPaths = true,
              diagnosticMode = "workspace", -- workspace
              useLibraryCodeForTypes = true,
              typeCheckingMode = "strict", -- off, basic, strict
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
          root_dir = require("lspconfig.util").root_pattern ".git",
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
    event = "InsertEnter",
    lazy = false,
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
      {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
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
  },
}, {
  install = { colorscheme = { colorscheme } },
  defaults = { lazy = true },
  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {
      reset = true,
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "man",
      },
    },
  },
  change_detection = { notify = false },
  concurrency = vim.loop.os_uname() == "Darwin" and 30 or nil,
  checker = { enable = true },
  ui = { border = "none" },
})

vim.o.background = background
vim.cmd.colorscheme(colorscheme)

-- NOTE: this should only be run on Terminal.app
-- require("mini.colors").get_colorscheme():add_cterm_attributes():apply()
-- vim.opt.termguicolors = false
