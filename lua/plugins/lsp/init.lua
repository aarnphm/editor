return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = { "stylua", "shfmt", "typos", "beautysh", "selene", "hadolint", "oxlint", "markdownlint" },
      ui = { border = BORDER.impl() },
      max_concurrent_installers = 10,
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require "mason-registry"
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require("lazy.core.handler.event").trigger {
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          }
        end, 100)
      end)
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then p:install() end
        end
      end)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    ---@class PluginLspOptions
    opts = {
      -- options for vim.diagnostic.config()
      ---@type vim.diagnostic.config.Opts
      diagnostics = {
        severity_sort = true,
        underline = false,
        update_in_insert = false,
        virtual_text = false,
        float = {
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          focusable = false,
          focus = false,
          format = function(diagnostic) return string.format("%s (%s)", diagnostic.message, diagnostic.source) end,
          source = "if_many",
          border = BORDER.none,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "✖",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "⚑",
            [vim.diagnostic.severity.INFO] = "●",
          },
        },
      },
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = true,
        exclude = { "vue", "typescriptreact", "typescript", "javascript" },
      },
      -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the code lenses.
      codelens = { enabled = false },
      -- Enable lsp cursor word highlighting
      document_highlight = { enabled = true },
      capabilities = {
        workspace = {
          didChangeWatchedFiles = { dynamicRegistration = false },
          fileOperations = { didRename = true, willRename = true },
        },
        textDocument = {
          completion = {
            snippetSupport = true,
            resolveSupport = {
              properties = { "documentation", "detail", "additionalTextEdits" },
            },
            completionItem = {
              documentationFormat = { "markdown", "plaintext" },
              snippetSupport = true,
              preselectSupport = true,
              insertReplaceSupport = true,
              labelDetailsSupport = true,
              deprecatedSupport = true,
              commitCharactersSupport = true,
              tagSupport = { valueSet = { 1 } },
              resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits" } },
            },
          },
        },
      },
      -- all of the server below will be installed by default
      servers = {
        bashls = {},
        markdown_oxide = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = { dynamicRegistration = true },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
                special = { reload = "require" },
              },
              telemetry = { enable = false },
              semantic = { enable = true },
              completion = { workspaceWord = true, callSnippet = "Replace" },
              hover = { expandAlias = false },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = true,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
        eslint = {
          settings = {
            -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            workingDirectories = { mode = "auto" },
          },
        },
      },
      setup = {
        eslint = function(server, opts)
          -- register the formatter with Util
          Util.format.register(Util.lsp.formatter {
            name = "lsp: eslint",
            primary = false,
            priority = 200,
            filter = "eslint",
          })

          opts.autostart = #vim.fs.find({
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.yaml",
            ".eslintrc.yml",
            ".eslintrc.json",
            "eslint.config.js",
            "eslint.config.mjs",
            "eslint.config.cjs",
            "eslint.config.ts",
            "eslint.config.mts",
            "eslint.config.cts",
          }, { path = vim.api.nvim_buf_get_name(0), upward = true }) > 0
          require("lspconfig")[server].setup(opts)
          return true
        end,
      },
    },
    ---@param opts PluginLspOptions
    config = function(_, opts)
      Util.format.register(Util.lsp.formatter())
      Util.toggle.setup()

      Util.lsp.setup(opts.document_highlight)

      -- inlay hints
      if opts.inlay_hints.enabled then
        Util.lsp.on_supports_method("textDocument/inlayHint", function(_, buffer)
          if
            vim.api.nvim_buf_is_valid(buffer)
            and vim.bo[buffer].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end)
      end

      -- code lens
      if opts.codelens.enabled and vim.lsp.codelens then
        Util.lsp.on_supports_method("textDocument/codeLens", function(_, buffer)
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = buffer,
            callback = vim.lsp.codelens.refresh,
          })
        end)
      end

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      Util.toggle.map(
        "<leader>uD",
        Util.toggle.wrap {
          name = "inline diagnostics",
          get = function() return vim.g.inline_diagnostics end,
          set = function(state)
            vim.g.inline_diagnostics = state
            vim.diagnostic.config(vim.tbl_deep_extend("force", opts.diagnostics, {
              signs = { min = "Error" },
              virtual_text = state and { spacing = 2, min = "Error" } or false,
              underline = false,
            }))
          end,
        }
      )

      local servers = opts.servers
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      ---@type lsp.ClientCapabilities
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {},
        opts.capabilities or {}
      )

      ---@diagnostic disable-next-line: no-unknown
      require("lspconfig.ui.windows").default_options.border = BORDER.impl()

      ---@param server string
      local server_setup = function(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
          flags = { debounce_text_changes = 300 },
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then return end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then return end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      -- get all the servers that are available through mason-lspconfig
      local have_mlsp, mlsp = pcall(require, "mason-lspconfig")
      local all_mlsp_servers = {}
      if have_mlsp then
        all_mlsp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(all_mlsp_servers, server) then
            server_setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      if have_mlsp then mlsp.setup { ensure_installed = ensure_installed, handlers = { server_setup } } end
    end,
  },
}
