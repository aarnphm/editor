-- local LSP keys setup
local K = {}

local H = require "aarnphm.handlers"

---@type LazyKeysLspSpec[]|nil
K._keys = nil

---@alias LazyKeysLspSpec LazyKeysSpec|{has?:string}
---@alias LazyKeysLsp LazyKeys|{has?:string}

K.hover = function()
  local has_ufo, ufo = pcall(require, "ufo")
  if not has_ufo then vim.lsp.buf.hover() end
  local win_id = ufo.peekFoldedLinesUnderCursor()
  if not win_id then vim.lsp.buf.hover() end
end

K.get = function()
  if not K._keys then
    --@class PluginLspKeys
    K._keys = {
      { "gh", "<cmd>Telescope lsp_references<cr>", desc = "lsp: references" },
      { "K", K.hover, desc = "lsp: Hover" },
      { "H", vim.lsp.buf.signature_help, desc = "lsp: Signature help", has = "signatureHelp" },
      { "gd", H.definition, desc = "lsp: Peek definition", has = "definition" },
      { "gR", "<cmd>Glance references<cr>", desc = "lsp: Show references", has = "definition" },
      { "gI", H.implementation, desc = "lsp: Goto implementation" },
      { "gr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
    }
  end
  return K._keys
end

---@param method string
K.has = function(buffer, method)
  method = method:find "/" and method or "textDocument/" .. method
  local clients = Util.lsp.get_clients { bufnr = buffer }
  for _, client in ipairs(clients) do
    if client.supports_method(method) then return true end
  end
  return false
end

---@return (LazyKeys|{has?:string})[]
K.resolve = function(buffer)
  local Keys = require "lazy.core.handler.keys"
  if not Keys.resolve then return {} end
  local spec = K.get()
  local opts = Util.opts "nvim-lspconfig"
  local clients = Util.lsp.get_clients { bufnr = buffer }
  for _, client in ipairs(clients) do
    local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
    vim.list_extend(spec, maps)
  end
  return Keys.resolve(spec)
end

K.on_attach = function(_, buffer)
  local Keys = require "lazy.core.handler.keys"
  local keymaps = K.resolve(buffer)

  for _, keys in pairs(keymaps) do
    if not keys.has or K.has(buffer, keys.has) then
      ---@class LazyKeysBase
      local opts = Keys.opts(keys)
      opts.has = nil
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
    end
  end
end

K.diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function() go { severity = severity } end
end

return {
  {
    "NvChad/nvim-colorizer.lua",
    event = "LspAttach",
    opts = {
      filetypes = { "*" },
      user_default_options = {
        names = false, -- "Name" codes like Blue
        RRGGBBAA = true, -- #RRGGBBAA hex codes
        rgb_fn = true, -- CSS rgb() and rgba() functions
        hsl_fn = true, -- CSS hsl() and hsla() functions
        css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        sass = { enable = true, parsers = { "css" } },
        mode = "foreground",
      },
    },
    config = function(_, opts) require("colorizer").setup(opts) end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = { "lua-language-server", "mdx-analyzer", "ruff-lsp", "stylua", "shfmt", "mypy" },
      ui = { border = "single" },
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
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then p:install() end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    opts = {
      border = { enable = true, top_char = "―", bottom_char = "―" },
      height = 20,
      zindex = 50,
      theme = { enable = true },
      hooks = {
        before_open = function(results, open, _, method)
          if #results == 0 then
            Util.warn(
              "This method is not supported by any of the servers registered for the current buffer",
              { title = "Glance" }
            )
          elseif #results == 1 and method == "references" then
            Util.info("The identifier under cursor is the only one found", { title = "Glance" })
          else
            open(results)
          end
        end,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "folke/neodev.nvim", opts = {} },
      { "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
      { "b0o/SchemaStore.nvim", version = false, ft = { "json", "yaml", "yml" } },
    },
    ---@class PluginLspOptions
    opts = {
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = { enabled = false },
      ---@type lsp.ClientCapabilities
      capabilities = {
        workspace = {
          didChangeWatchedFiles = { dynamicRegistration = false },
        },
        textDocument = {
          -- nvim-ufo
          foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
          completion = {
            snippetSupport = true,
            resolveSupport = {
              properties = { "documentation", "detail", "additionalTextEdits" },
            },
          },
        },
      },
      servers = {
        bashls = {},
        marksman = {},
        spectral = {},
        jdtls = {},
        dockerls = {},
        taplo = {},
        gopls = {},
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
        ---@type lspconfig.options.tsserver
        tsserver = {
          keys = {
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action {
                  apply = true,
                  context = {
                    only = { "source.organizeImports.ts" },
                    diagnostics = {},
                  },
                }
              end,
              desc = "Organize Imports",
            },
            {
              "<leader>cR",
              function()
                vim.lsp.buf.code_action {
                  apply = true,
                  context = {
                    only = { "source.removeUnused.ts" },
                    diagnostics = {},
                  },
                }
              end,
              desc = "Remove Unused Imports",
            },
          },
          single_file_support = false,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
              format = {
                indentSize = vim.o.shiftwidth,
                convertTabsToSpaces = vim.o.expandtab,
                tabSize = vim.o.tabstop,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
              format = {
                indentSize = vim.o.shiftwidth,
                convertTabsToSpaces = vim.o.expandtab,
                tabSize = vim.o.tabstop,
              },
            },
          },
        },
        yamlls = {
          -- Have to add this for yamlls to understand that we support line folding
          capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
              },
            },
          },
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.yaml.schemas = vim.tbl_deep_extend(
              "force",
              new_config.settings.yaml.schemas or {},
              require("schemastore").yaml.schemas()
            )
          end,
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              keyOrdering = false,
              format = { enable = true, singleQuote = true, bracketSpacing = false, printWidth = 120 },
              validate = true,
              schemaStore = {
                -- Must disable built-in schemaStore support to use
                -- schemas from SchemaStore.nvim plugin
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = "",
              },
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
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              semantic = { enable = false },
              completion = { workspaceWord = true, callSnippet = "Both" },
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
                -- enable = false,
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
        matlab_ls = { settings = { matlab = { installPath = "/Applications/MATLAB_R2023a.app" } } },
        texlab = {
          keys = {
            { "<Leader>K", "<plug>(vimtex-doc-package)", desc = "Vimtex Docs", silent = true },
          },
        },
        rust_analyzer = {
          keys = {
            { "K", "<cmd>RustHoverActions<cr>", desc = "Hover Actions (Rust)" },
            { "<leader>cR", "<cmd>RustCodeAction<cr>", desc = "Code Action (Rust)" },
            { "<leader>dr", "<cmd>RustDebuggables<cr>", desc = "Run Debuggables (Rust)" },
          },
        },
        ruff_lsp = {
          keys = {
            {
              "<leader>co",
              function()
                vim.lsp.buf.code_action {
                  apply = true,
                  context = {
                    only = { "source.organizeImports" },
                    diagnostics = {},
                  },
                }
              end,
              desc = "Organize Imports",
            },
          },
        },
        ---@type lspconfig.options.pyright
        pyright = {
          mason = false,
          capabilities = {},
          settings = {
            python = {
              analysis = {
                logLevel = "Trace",
                autoImportCompletions = true,
                diagnosticMode = "openFilesOnly",
                autoSearchPaths = true,
                typeCheckingMode = "off",
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        eslint = {
          settings = {
            -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            workingDirectory = { mode = "auto" },
          },
        },
      },
      ---@type table<string, fun(lspconfig:any, options:_.lspconfig.options):boolean?>
      setup = {
        ruff_lsp = function()
          Util.lsp.on_attach(function(client, _)
            if client.name == "ruff_lsp" then
              client.server_capabilities.hoverProvider = false
              client.server_capabilities.documentFormattingProvider = false -- NOTE: disable ruff formatting because I don't like deterministic formatter  in python
            end
          end)
        end,
        rust_analyzer = function(_, opts)
          local rt_opts = Util.opts "rust-tools.nvim"
          require("rust-tools").setup(vim.tbl_deep_extend("force", rt_opts or {}, { server = opts }))
          return false
        end,
        jdtls = function() return true end, -- avoid duplicate servers
        yamlls = function()
          -- Neovim < 0.10 does not have dynamic registration for formatting
          if vim.fn.has "nvim-0.10" == 0 then
            Util.lsp.on_attach(function(client, _)
              if client.name == "yamlls" then client.server_capabilities.documentFormattingProvider = true end
            end)
          end
        end,
        clangd = function(_, opts)
          local clangd_opts = Util.opts "clangd_extensions.nvim"
          require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_opts or {}, { server = opts }))
          return false
        end,
        eslint = function()
          local formatter = Util.lsp.formatter {
            name = "eslint: lsp",
            primary = false,
            priority = 200,
            filter = "eslint",
          }

          -- register the formatter with LazyVim
          Util.format.register(formatter)
        end,
      },
    },
    ---@param opts PluginLspOptions
    config = function(_, opts)
      if Util.has "neoconf.nvim" then
        local plugin = require("lazy.core.config").spec.plugins["neoconf.nvim"]
        require("neoconf").setup(require("lazy.core.plugin").values(plugin, "opts", false))
      end

      Util.format.register(Util.lsp.formatter())

      -- setup ufo before everything else
      Util.lsp.on_attach(function(client, bufnr)
        local ok, ufo = pcall(require, "ufo")
        if ok then ufo.attach(bufnr) end
      end)
      -- setup keymaps
      Util.lsp.on_attach(function(cl, bufnr) K.on_attach(cl, bufnr) end)

      local register_capability = vim.lsp.handlers["client/registerCapability"]

      vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
        local ret = register_capability(err, res, ctx)
        local client_id = ctx.client_id
        ---@type lsp.Client|nil
        local cl = vim.lsp.get_client_by_id(client_id)
        local buffer = vim.api.nvim_get_current_buf()
        K.on_attach(cl, buffer)
        return ret
      end

      local inlay_hint = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint

      if opts.inlay_hints.enabled and inlay_hint then
        Util.lsp.on_attach(function(client, bufnr)
          if client.supports_method "textDocument/inlayHint" then inlay_hint(bufnr, true) end
        end)
      end

      vim.diagnostic.config {
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
          border = BORDER,
        },
      }

      -- NOTE: diagnostic config
      for _, type in pairs { { "Error", "✖" }, { "Warn", "▲" }, { "Hint", "⚑" }, { "Info", "●" } } do
        local hl = string.format("DiagnosticSign%s", type[1])
        vim.fn.sign_define(hl, { text = type[2], texthl = hl, numhl = hl })
      end

      vim.lsp.handlers["textDocument/publishDiagnostics"] =
        vim.lsp.with(vim.lsp.handlers["textDocument/publishDiagnostics"], {
          signs = { severity_limit = "Error" },
          virtual_text = { spacing = 2, severity_limit = "Error" },
          underline = false,
        })

      local servers = opts.servers
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      ---@type lsp.ClientCapabilities
      local capabilities = vim.tbl_deep_extend(
        "force",
        opts.capabilities or {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {}
      )
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      ---@param server string
      local setup = function(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
          flags = { debounce_text_changes = 500 },
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then return end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then return end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      -- get all the servers that are available through mason-lspconfig
      local have_mason, mlsp = pcall(require, "mason-lspconfig")
      local all_mslp_servers = {}
      if have_mason then
        all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      if have_mason then mlsp.setup { ensure_installed = ensure_installed, handlers = { setup } } end
    end,
  },
}
