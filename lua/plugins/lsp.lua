-- local LSP keys setup
local K = {}

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
      { "gD", vim.lsp.buf.declaration, desc = "lsp: Goto declaration" },
      { "K", K.hover, desc = "lsp: Hover" },
      { "H", vim.lsp.buf.signature_help, desc = "lsp: Signature help", has = "signatureHelp" },
      { "gd", "<cmd>Glance definitions<cr>", desc = "lsp: Peek definition", has = "definition" },
      { "gR", "<cmd>Glance references<cr>", desc = "lsp: Show references", has = "definition" },
      { "gI", Util.telescope("lsp_implementations", { reuse_win = true }), desc = "lsp: Goto implementation" },
      { "gY", Util.telescope("lsp_type_definitions", { reuse_win = true }), desc = "lsp: Goto type definitions" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
      {
        "<leader>cA",
        function()
          vim.lsp.buf.code_action {
            context = {
              only = {
                "source",
              },
              diagnostics = {},
            },
          }
        end,
        desc = "Source Action",
        has = "codeAction",
      },
    }
    if Util.has "inc-rename.nvim" then
      K._keys[#K._keys + 1] = {
        "gr",
        function()
          local inc_rename = require "inc_rename"
          return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand "<cword>"
        end,
        expr = true,
        desc = "Rename",
        has = "rename",
      }
    else
      K._keys[#K._keys + 1] = { "gr", vim.lsp.buf.rename, desc = "Rename", has = "rename" }
    end
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

K.on_attach = function(cl, buffer)
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

-- Utility function to extend or override a config table, similar to the way
-- that Plugin.opts works.
---@param config table
---@param custom function | table | nil
local extend_or_override = function(config, custom, ...)
  if type(custom) == "function" then
    config = custom(config, ...) or config
  elseif custom then
    config = vim.tbl_deep_extend("force", config, custom) --[[@as table]]
  end
  return config
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
        mode = "background",
      },
    },
    config = function(_, opts) require("colorizer").setup(opts) end,
  },
  { "smjonas/inc-rename.nvim", cmd = "IncRename", config = true },
  {
    "kevinhwang91/nvim-ufo",
    name = "ufo",
    event = "BufReadPost",
    dependencies = { "kevinhwang91/promise-async" },
    ---@type UfoConfig
    opts = {
      preview = { win_config = { border = "none" } },
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰇘 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end,
      provider_selector = function(bufnr, filetype, buftype)
        --- cascade from lsp -> treesitter -> indent
        ---@param buf number
        ---@return Promise
        local cascadeSelector = function(buf)
          local handleFallbackException = function(err, providerName)
            if type(err) == "string" and err:match "UfoFallbackException" then
              return require("ufo").getFolds(buf, providerName)
            else
              return require("promise").reject(err)
            end
          end

          return require("ufo")
            .getFolds(buf, "lsp")
            :catch(function(err) return handleFallbackException(err, "treesitter") end)
            :catch(function(err) return handleFallbackException(err, "indent") end)
        end
        return cascadeSelector
      end,
    },
    config = function(_, opts)
      local ufo = require "ufo"
      ufo.setup(opts)

      vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "fold: open all" })
      vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "fold: close all" })
      vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds, { desc = "fold: open all except" })
      vim.keymap.set("n", "zm", ufo.closeFoldsWith, { desc = "fold: close all with" })
    end,
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
    "stevearc/aerial.nvim",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = function()
      local opts = {
        attach_mode = "global",
        backends = { "lsp", "treesitter", "markdown", "man" },
        show_guides = true,
        nav = { border = "single" },
        layout = {
          resize_to_content = false,
          win_opts = {
            winhl = "Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
            signcolumn = "yes",
            statuscolumn = " ",
          },
        },
        guides = {
          mid_item = "├╴",
          last_item = "└╴",
          nested_top = "│ ",
          whitespace = "  ",
        },
      }
      return opts
    end,
    keys = {
      { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Aerial (Symbols)" },
    },
    config = function(_, opts)
      require("aerial").setup(opts)
      if Util.has "telescope.nvim" then require("telescope").load_extension "aerial" end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      {
        "dnlhc/glance.nvim",
        cmd = "Glance",
        ---@type GlanceOpts
        opts = {
          border = { enable = true, top_char = "―", bottom_char = "―" },
          height = 20,
          zindex = 50,
          theme = { enable = false },
          hooks = {
            before_open = function(results, open, _, method)
              if #results == 0 then
                vim.notify(
                  "This method is not supported by any of the servers registered for the current buffer",
                  vim.log.levels.WARN,
                  { title = "Glance" }
                )
              elseif #results == 1 and method == "references" then
                vim.notify(
                  "The identifier under cursor is the only one found",
                  vim.log.levels.INFO,
                  { title = "Glance" }
                )
              else
                open(results)
              end
            end,
          },
        },
      },
      { "folke/neodev.nvim", opts = {} },
      { "folke/neoconf.nvim", cmd = "Neoconf", config = false, dependencies = { "nvim-lspconfig" } },
      { "b0o/SchemaStore.nvim", version = false, ft = { "json", "yaml", "yml" } },
    },
    ---@class PluginLspOptions
    opts = {
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = { enabled = true },
      capabilities = {
        workspace = {
          didChangeWatchedFiles = {
            dynamicRegistration = false,
          },
        },
        textDocument = {
          foldingRange = { -- nvim-ufo
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
        },
      },
      ---@type lspconfig.options
      servers = {
        bashls = {},
        marksman = {},
        spectral = {},
        jdtls = {},
        dockerls = {},
        taplo = {},
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
              misc = {
                parameters = {
                  -- "--log-level=trace",
                },
              },
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
        pyright = {
          mason = false,
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                typeCheckingMode = "strict",
                useLibraryCodeForTypes = true,
                diagnosticMode = "off",
                autoImportCompletions = true,
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
            if client.name == "ruff_lsp" then client.server_capabilities.hoverProvider = false end
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
          local function get_client(buf) return Util.lsp.get_clients({ name = "eslint", bufnr = buf })[1] end

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

      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        signs = true,
        underline = false,
        virtual_text = false,
        update_in_insert = true,
      })

      local servers = opts.servers
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        opts.capabilities or {},
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp_nvim_lsp.default_capabilities() or {}
      )

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
      if Util.lsp.get_config "denols" and Util.lsp.get_config "tsserver" then
        local is_deno = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")
        Util.lsp.disable("tsserver", is_deno)
        Util.lsp.disable("denols", function(root_dir) return not is_deno(root_dir) end)
      end
    end,
  },
}
