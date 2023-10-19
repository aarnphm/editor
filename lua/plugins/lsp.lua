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
      { "<leader>d", vim.diagnostic.open_float, desc = "lsp: show line diagnostics" },
      { "gR", "<cmd>Telescope lsp_references<cr>", desc = "lsp: references" },
      { "gD", vim.lsp.buf.declaration, desc = "lsp: Goto declaration" },
      { "]d", K.diagnostic_goto(true), desc = "lsp: Next diagnostic" },
      { "[d", K.diagnostic_goto(false), desc = "lsp: Prev diagnostic" },
      { "]e", K.diagnostic_goto(true, "ERROR"), desc = "lsp: Next error" },
      { "[e", K.diagnostic_goto(false, "ERROR"), desc = "lsp: Prev error" },
      { "]w", K.diagnostic_goto(true, "WARN"), desc = "lsp: Next warning" },
      { "[w", K.diagnostic_goto(false, "WARN"), desc = "lsp: Prev warning" },
      { "K", K.hover, desc = "Hover" },
      { "gd", "<cmd>Glance definitions<cr>", desc = "lsp: Peek definition", has = "definition" },
      { "gh", "<cmd>Glance references<cr>", desc = "lsp: Show references", has = "definition" },
      { "gr", vim.lsp.buf.rename, desc = "lsp: rename", has = "rename" },
    }
  end
  return K._keys
end

---@param method string
K.has = function(buffer, method)
  method = method:find "/" and method or "textDocument/" .. method
  local clients = Util.get_clients { bufnr = buffer }
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
  local clients = Util.get_clients { bufnr = buffer }
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
  {
    "kevinhwang91/nvim-ufo",
    name = "ufo",
    event = "BufReadPost",
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
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
        ---@param bufnr number
        ---@return Promise
        local cascadeSelector = function(bufnr)
          local handleFallbackException = function(err, providerName)
            if type(err) == "string" and err:match "UfoFallbackException" then
              return require("ufo").getFolds(bufnr, providerName)
            else
              return require("promise").reject(err)
            end
          end

          return require("ufo")
            .getFolds(bufnr, "lsp")
            :catch(function(err) return handleFallbackException(err, "treesitter") end)
            :catch(function(err) return handleFallbackException(err, "indent") end)
        end
        return cascadeSelector
      end,
    },
    init = function()
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "fold: open all" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "fold: close all" })
      vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "fold: open all except" })
      vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "fold: close all with" })
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {
      bind = true,
      -- TODO: Remove the following line when nvim-cmp#1613 gets resolved
      check_completion_visible = false,
      floating_window = true,
      floating_window_above_cur_line = true,
      hi_parameter = "Search",
      hint_enable = false,
      transparency = nil, -- disabled by default, allow floating win transparent value 1~100
      wrap = true,
      zindex = 45, -- avoid overlap with nvim.cmp
      handler_opts = { border = "none" },
      auto_close_after = 15000,
    },
    config = function(_, opts) require("lsp_signature").setup(opts) end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = { "lua-language-server", "mypy", "mdx-analyzer", "ruff-lsp", "stylua", "shfmt" },
      ui = { border = "none" },
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
          border = { enable = false, top_char = "―", bottom_char = "―" },
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
      { "folke/neodev.nvim", config = true, ft = "lua" },
      { "folke/neoconf.nvim", cmd = "Neoconf", config = true, dependencies = { "nvim-lspconfig" } },
      { "saecki/crates.nvim", event = { "BufRead Cargo.toml" }, config = true },
      {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = function() vim.fn["mkdp#util#install"]() end,
        keys = {
          {
            "<leader>cp",
            ft = "markdown",
            "<cmd>MarkdownPreviewToggle<cr>",
            desc = "Markdown Preview",
          },
        },
        config = function() vim.cmd [[do FileType]] end,
      },
      {
        "lukas-reineke/headlines.nvim",
        opts = function()
          local opts = {}
          for _, ft in ipairs { "markdown", "norg", "rmd", "org" } do
            opts[ft] = {
              headline_highlights = {},
              fat_headlines = true,
              fat_headline_upper_string = "█",
              fat_headline_lower_string = "█",
            }
            for i = 1, 6 do
              table.insert(opts[ft].headline_highlights, "Headline" .. i)
            end
          end
          return opts
        end,
        ft = { "markdown", "norg", "rmd", "org" },
      },
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
      { "b0o/SchemaStore.nvim", version = false, ft = { "json", "yaml", "yml" } },
    },
    ---@class PluginLspOptions
    opts = {
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = { enabled = false },
      capabilities = {
        offsetEncoding = { "utf-16" },
        textDocument = {
          foldingRange = { -- nvim-ufo
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
          completion = {
            completionItem = {
              documentationFormat = { "markdown", "plaintext" },
              snippetSupport = true,
              preselectSupport = true,
              insertReplaceSupport = true,
              labelDetailsSupport = true,
              deprecatedSupport = true,
              commitCharactersSupport = true,
              tagSupport = { valueSet = { 1 } },
              resolveSupport = {
                properties = {
                  "documentation",
                  "detail",
                  "additionalTextEdits",
                },
              },
            },
          },
        },
      },
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
              format = {
                enable = true,
              },
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
        taplo = {
          keys = {
            "K",
            function()
              if vim.fn.expand "%:t" == "Cargo.toml" and require("crates").popup_available() then
                require("crates").show_popup()
              else
                K.hover()
              end
            end,
            desc = "lsp: Show Crate Documentation",
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
                diagnosticMode = "workspace",
                autoImportCompletions = true,
              },
            },
          },
        },
      },
      ---@type table<string, fun(lspconfig:any, options:_.lspconfig.options):boolean?>
      setup = {
        ruff_lsp = function()
          Util.on_attach(function(client, _)
            if client.name == "ruff_lsp" then client.server_capabilities.hoverProvider = false end
          end)
        end,
        rust_analyzer = function(_, opts)
          local rt_opts = require("lazyvim.util").opts "rust-tools.nvim"
          require("rust-tools").setup(vim.tbl_deep_extend("force", rt_opts or {}, { server = opts }))
          return true
        end,
        yamlls = function()
          -- Neovim < 0.10 does not have dynamic registration for formatting
          if vim.fn.has "nvim-0.10" == 0 then
            require("lazyvim.util").lsp.on_attach(function(client, _)
              if client.name == "yamlls" then client.server_capabilities.documentFormattingProvider = true end
            end)
          end
        end,
      },
    },
    ---@param opts PluginLspOptions
    config = function(_, opts)
      local lspconfig = require "lspconfig"

      -- setup ufo before everything else
      Util.on_attach(function(client, bufnr)
        local ok, ufo = pcall(require, "ufo")
        if ok then ufo.attach(bufnr) end
      end)

      Util.on_attach(function(cl, bufnr) K.on_attach(cl, bufnr) end)
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
        Util.on_attach(function(client, bufnr)
          if client.supports_method "textDocument/inlayHint" then inlay_hint(bufnr, true) end
        end)
      end

      Util.on_attach(function(cl, bufnr)
        if cl.supports_method("textDocument/publishDiagnostics", { bufnr = bufnr }) then
          vim.lsp.handlers["textDocument/publishDiagnostics"] =
            vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
              signs = true,
              underline = false,
              virtual_text = false,
              update_in_insert = true,
            })
        end
        if cl.supports_method("textDocument/hover", { bufnr = bufnr }) then
          vim.lsp.handlers["textDocument/hover"] =
            vim.lsp.with(vim.lsp.handlers.hover, { border = "none", focusable = true })
        end
        if cl.supports_method("textDocument/signatureHelp", { bufnr = bufnr }) then
          vim.lsp.handlers["textDocument/signatureHelp"] =
            vim.lsp.with(vim.lsp.handlers.signatureHelp, { border = "none", focusable = true })
        end
      end)

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
        lspconfig[server].setup(server_opts)
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
