return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = { "lua-language-server", "ruff", "stylua", "shfmt", "mypy", "gofumpt", "goimports" },
      ui = { border = BORDER },
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
      border = { enable = true },
      height = 20,
      zindex = 50,
      theme = { enable = true },
      hooks = {
        before_open = function(results, open, _, method)
          if #results == 0 then
            Util.warn("This method is not supported by any of the servers registered for the current buffer", { title = "Glance" })
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
    event = "LazyFile",
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "b0o/SchemaStore.nvim", version = false, ft = { "json", "yaml", "yml" } },
    },
    ---@class PluginLspOptions
    opts = {
      -- options for vim.diagnostic.config()
      ---@type vim.diagnostic.Opts
      diagnostics = {
        severity_sort = true,
        underline = false,
        update_in_insert = true,
        virtual_text = false,
        float = {
          close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
          focusable = false,
          focus = false,
          format = function(diagnostic) return string.format("%s (%s)", diagnostic.message, diagnostic.source) end,
          source = "if_many",
          border = BORDER,
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
        exclude = { "vue" },
      },
      -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the code lenses.
      codelens = { enabled = false },
      -- Enable lsp cursor word highlighting
      capabilities = {
        workspace = {
          didChangeWatchedFiles = { dynamicRegistration = false },
        },
        textDocument = {
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
        markdown_oxide = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = { dynamicRegistration = true },
            },
          },
        },
        taplo = {},
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                fieldalignment = true,
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
        vtsls = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          keys = {
            {
              "gD",
              function()
                local params = vim.lsp.util.make_position_params()
                Util.lsp.execute {
                  command = "typescript.goToSourceDefinition",
                  arguments = { params.textDocument.uri, params.position },
                  open = true,
                }
              end,
              desc = "lsp: goto source definition",
            },
            {
              "gR",
              function()
                Util.lsp.execute {
                  command = "typescript.findAllFileReferences",
                  arguments = { vim.uri_from_bufnr(0) },
                  open = true,
                }
              end,
              desc = "lsp: file references",
            },
            {
              "<leader>co",
              Util.lsp.action["source.organizeImports"],
              desc = "lsp: organize imports",
            },
            {
              "<leader>cM",
              Util.lsp.action["source.addMissingImports.ts"],
              desc = "lsp: add missing imports",
            },
            {
              "<leader>cu",
              Util.lsp.action["source.removeUnused.ts"],
              desc = "lsp: remove unused imports",
            },
            {
              "<leader>cD",
              Util.lsp.action["source.fixAll.ts"],
              desc = "lsp: fix all diagnostics",
            },
            {
              "<leader>cV",
              function() Util.lsp.execute { command = "typescript.selectTypeScriptVersion" } end,
              desc = "lsp: select TS workspace version",
            },
          },
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
        },
        tailwindcss = {
          -- exclude a filetype from the default_config
          filetypes_exclude = { "markdown" },
          -- add additional filetypes to the default_config
          filetypes_include = {},
          -- to fully override the default_config, change the below
          -- filetypes = {}
        },
        jsonls = {
          -- lazy-load schemastore when needed
          on_new_config = function(config)
            config.settings.json.schemas = config.settings.json.schemas or {}
            vim.tbl_deep_extend("force", config.settings.json.schemas, require("schemastore").json.schemas())
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
            config.settings.yaml.schemas = config.settings.yaml.schemas or {}
            vim.tbl_deep_extend("force", config.settings.yaml.schemas, require("schemastore").yaml.schemas())
          end,
          -- Have to add this for yamlls to understand that we support line folding
          capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
              },
            },
          },
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
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          init_options = { settings = { logLevel = "error" } },
          keys = {
            {
              "<leader>co",
              Util.lsp.action["source.organizeImports"],
              desc = "lsp: organize imports",
            },
          },
        },
        ruff_lsp = {
          keys = {
            {
              "<leader>co",
              Util.lsp.action["source.organizeImports"],
              desc = "lsp: organize imports",
            },
          },
        },
        nil_ls = {
          settings = {
            ["nil"] = {
              formatting = {
                command = { "nix fmt" },
              },
              nix = {
                maxMemoryMB = 4092,
                flake = {
                  autoArchive = false,
                  autoEvalInputs = true,
                },
              },
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                autoImportCompletions = true,
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
            workingDirectories = { mode = "auto" },
          },
        },
      },
      setup = {
        ruff = function()
          Util.lsp.on_attach(function(client, _)
            if client.name == "ruff" then
              client.server_capabilities.hoverProvider = false
              client.server_capabilities.documentFormattingProvider = false -- NOTE: disable ruff formatting because I don't like deterministic formatter  in python
            end
          end, "ruff")
        end,
        taplo = function()
          Util.lsp.on_attach(function(client, _)
            if client.name == "taplo" then client.server_capabilities.documentFormattingProvider = false end
          end)
        end,
        yamlls = function()
          Util.lsp.on_attach(function(client, _)
            if client.name == "yamlls" then client.server_capabilities.documentFormattingProvider = true end
          end)
        end,
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
        vtsls = function(_, opts)
          Util.lsp.on_attach(function(client, _)
            client.commands["_typescript.moveToFileRefactoring"] = function(command, ctx)
              ---@type string, string, lsp.Range
              local action, uri, range = unpack(command.arguments)

              local function move(newf)
                client.request("workspace/executeCommand", {
                  command = command.command,
                  arguments = { action, uri, range, newf },
                })
              end

              local fname = vim.uri_to_fname(uri)
              client.request("workspace/executeCommand", {
                command = "typescript.tsserverRequest",
                arguments = {
                  "getMoveToRefactoringFileSuggestions",
                  {
                    file = fname,
                    startLine = range.start.line + 1,
                    startOffset = range.start.character + 1,
                    endLine = range["end"].line + 1,
                    endOffset = range["end"].character + 1,
                  },
                },
              }, function(_, result)
                ---@type string[]
                local files = result.body.files
                table.insert(files, 1, "Enter new path...")
                vim.ui.select(files, {
                  prompt = "Select move destination:",
                  format_item = function(f) return vim.fn.fnamemodify(f, ":~:.") end,
                }, function(f)
                  if f and f:find "^Enter new path" then
                    vim.ui.input({
                      prompt = "Enter move destination:",
                      default = vim.fn.fnamemodify(fname, ":h") .. "/",
                      completion = "file",
                    }, function(newf) return newf and move(newf) end)
                  elseif f then
                    move(f)
                  end
                end)
              end)
            end
          end, "vtsls")
          -- copy typescript settings to javascript
          opts.settings.javascript = vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
        end,
        tailwindcss = function(_, opts)
          local tw = require "lspconfig.server_configurations.tailwindcss"
          opts.filetypes = opts.filetypes or {}

          -- Add default filetypes
          vim.list_extend(opts.filetypes, tw.default_config.filetypes)

          -- Remove excluded filetypes
          --- @param ft string
          opts.filetypes = vim.tbl_filter(function(ft) return not vim.tbl_contains(opts.filetypes_exclude or {}, ft) end, opts.filetypes)

          -- Additional settings for Phoenix projects
          opts.settings = {
            tailwindCSS = {
              includeLanguages = {
                elixir = "html-eex",
                eelixir = "html-eex",
                heex = "html-eex",
              },
            },
          }

          -- Add additional filetypes
          vim.list_extend(opts.filetypes, opts.filetypes_include or {})
        end,
        gopls = function()
          -- workaround for gopls not supporting semanticTokensProvider
          -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
          Util.lsp.on_attach(function(client, _)
            if client.name == "gopls" then
              if not client.server_capabilities.semanticTokensProvider then
                local semantic = client.config.capabilities.textDocument.semanticTokens
                client.server_capabilities.semanticTokensProvider = {
                  full = true,
                  legend = {
                    tokenTypes = semantic.tokenTypes,
                    tokenModifiers = semantic.tokenModifiers,
                  },
                  range = true,
                }
              end
            end
          end)
          -- end workaround
        end,
      },
    },
    ---@param opts PluginLspOptions
    config = function(_, opts)
      Util.format.register(Util.lsp.formatter())

      Util.lsp.setup()

      -- inlay hints
      if opts.inlay_hints.enabled then
        Util.lsp.on_supports_method("textDocument/inlayHint", function(client, buffer)
          if vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == "" and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype) then
            vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
          end
        end)
      end

      -- code lens
      if opts.codelens.enabled and vim.lsp.codelens then
        Util.lsp.on_supports_method("textDocument/codeLens", function(client, buffer)
          vim.lsp.codelens.refresh()
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            buffer = buffer,
            callback = vim.lsp.codelens.refresh,
          })
        end)
      end

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      if vim.g.inline_diagnostics then
        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.handlers["textDocument/publishDiagnostics"], {
          signs = { min = "Error" },
          virtual_text = { spacing = 2, min = "Error" },
          underline = false,
        })
      end

      local servers = opts.servers
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      ---@type lsp.ClientCapabilities
      local capabilities = vim.tbl_deep_extend("force", opts.capabilities or {}, vim.lsp.protocol.make_client_capabilities(), has_cmp and cmp_nvim_lsp.default_capabilities() or {}, {
        textDocument = { completion = { completionItem = { snippetSupport = true } } },
        workspace = { didChangeWatchedFiles = { dynamicRegistration = false } },
      })

      require("lspconfig.ui.windows").default_options.border = BORDER

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
      local all_mslp_servers = {}
      if have_mlsp then all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package) end

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
            server_setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      if have_mlsp then mlsp.setup { ensure_installed = ensure_installed, handlers = { server_setup } } end

      if Util.lsp.is_enabled "denols" and Util.lsp.is_enabled "vtsls" then
        local is_deno = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")
        Util.lsp.disable("vtsls", is_deno)
        Util.lsp.disable("denols", function(root_dir, config)
          if not is_deno(root_dir) then config.settings.deno.enable = false end
          return false
        end)
      end
    end,
  },
}
