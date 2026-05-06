return {
  {
    "stevearc/conform.nvim",
    lazy = true,
    cmd = "ConformInfo",
    enabled = true,
    dependencies = { "mason.nvim" },
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
    opts_extend = { "formatters" },
    ---@type conform.setupOpts
    opts = {
      default_format_opts = { timeout_ms = 3000 },
      formatters_by_ft = {
        lua = { "stylua" },
        toml = { "taplo" },
        proto = { "buf", "protolint" },
        zsh = { "beautysh", fallback = true },
        sh = { "shfmt" },
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
        taplo = { append_args = { "-c", "align_entries=false" } },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    version = false,
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = { "stylua", "shfmt", "beautysh", "selene", "hadolint", "ast-grep", "typos", "cbfmt" },
      ui = { backdrop = 100 },
      max_concurrent_installers = 15,
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
    dependencies = { "mason-org/mason.nvim", { "mason-org/mason-lspconfig.nvim", config = function() end } },
    opts_extend = { "servers.*.keys" },
    ---@class PluginLspOptions
    ---@field setup table<string, fun(server: string, opts: table<string, any>): boolean>
    opts = function()
      return {
        -- options for vim.diagnostic.config()
        ---@type vim.diagnostic.config.Opts
        diagnostics = {
          severity_sort = true,
          underline = false,
          update_in_insert = false,
          -- enable virtual text with { spacing = 2, min = "Error" }
          virtual_text = false,
          float = {
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            focusable = false,
            focus = false,
            format = function(diagnostic) return string.format("%s (%s)", diagnostic.message, diagnostic.source) end,
            source = "if_many",
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
          exclude = { "vue", "typescriptreact", "typescript", "javascript", "lua", "python" },
        },
        -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
        -- Be aware that you also will need to properly configure your LSP server to
        -- provide the code lenses.
        codelens = { enabled = true },
        -- Enable lsp cursor word highlighting
        document_highlight = { enabled = true },
        -- LSP Server Settings
        -- Sets the default configuration for an LSP client (or all clients if the special name "*" is used).
        ---@alias lazyvim.lsp.Config vim.lsp.Config|{mason?:boolean, enabled?:boolean, keys?:LazyKeysLspSpec[]}
        ---@type table<string, lazyvim.lsp.Config|boolean>
        servers = {
          ["*"] = {
            capabilities = {
              workspace = {
                didChangeWatchedFiles = { dynamicRegistration = false },
                fileOperations = { didRename = true, willRename = true },
              },
            },
            keys = {
              { "<leader>cl", Snacks.picker.lsp_config, desc = "lsp: info" },
              { "K", vim.lsp.buf.hover, desc = "lsp: Hover" },
              {
                "<C-k>",
                vim.lsp.buf.signature_help,
                mode = "i",
                desc = "lsp: signature help",
                has = "signatureHelp",
              },
              { "gr", vim.lsp.buf.rename, desc = "lsp: rename", has = "rename" },
              { "gy", vim.lsp.buf.type_definition, desc = "lsp: t[y]pe definition" },
              { "gD", vim.lsp.buf.declaration, desc = "lsp: peek declaration", has = "declaration" },
              { "gR", Util.lsp.buf.references, desc = "lsp: show references", has = "definition", nowait = true },
              { "gd", Util.lsp.buf.definitions, desc = "lsp: peek definition", has = "definition" },
              { "gI", Util.lsp.buf.implementations, desc = "lsp: implementation" },
              {
                "<leader>ca",
                vim.lsp.buf.code_action,
                desc = "lsp: code action",
                mode = { "n", "v" },
                has = "codeAction",
              },
              {
                "<leader>cc",
                vim.lsp.codelens.run,
                desc = "lsp: run codelens",
                mode = { "n", "v" },
                has = "codeLens",
              },
              {
                "<leader><leader>f",
                function() Util.format { force = true } end,
                mode = { "n", "v" },
                desc = "style: format buffer",
              },
              {
                "<leader>cR",
                function() Snacks.rename.rename_file() end,
                desc = "lsp: rename file",
                mode = { "n" },
                has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
              },
              { "<leader>cA", Util.lsp.action.source, desc = "lsp: source action", has = "codeAction" },
              {
                "]]",
                function() Snacks.words.jump(vim.v.count1) end,
                has = "documentHighlight",
                desc = "lsp: next reference",
                enabled = function() return Snacks.words.is_enabled() end,
              },
              {
                "[[",
                function() Snacks.words.jump(-vim.v.count1) end,
                has = "documentHighlight",
                desc = "lsp: prev reference",
                enabled = function() return Snacks.words.is_enabled() end,
              },
              {
                "<C-n>",
                function() Snacks.words.jump(vim.v.count1, true) end,
                has = "documentHighlight",
                desc = "lsp: next reference",
                enabled = function() return Snacks.words.is_enabled() end,
              },
              {
                "<C-p>",
                function() Snacks.words.jump(-vim.v.count1, true) end,
                has = "documentHighlight",
                desc = "lsp: prev reference",
                enabled = function() return Snacks.words.is_enabled() end,
              },
            },
          },
          bashls = {},
          mojo = {},
          lua_ls = {
            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT",
                  special = { reload = "require" },
                },
                library = { vim.env.VIMRUNTIME },
                telemetry = { enable = false },
                semantic = { enable = true },
                completion = { workspaceWord = true, callSnippet = "Replace" },
                hover = { expandAlias = false },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = false,
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
        },
      }
    end,
    ---@param opts PluginLspOptions
    config = vim.schedule_wrap(function(_, opts)
      Util.format.register(Util.lsp.formatter())

      local function clear_vim_nil(value)
        if type(value) ~= "table" then return end
        for key, child in pairs(value) do
          if child == vim.NIL then
            value[key] = nil
          else
            clear_vim_nil(child)
          end
        end
      end

      local function normalize_file_operation_filters(client)
        local workspace = client.server_capabilities and client.server_capabilities.workspace
        local file_operations = workspace and workspace.fileOperations
        if type(file_operations) ~= "table" then return end

        clear_vim_nil(file_operations)
      end

      local file_operation_group = vim.api.nvim_create_augroup("lsp_file_operation_filters", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = file_operation_group,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then normalize_file_operation_filters(client) end
        end,
      })
      for _, client in ipairs(vim.lsp.get_clients()) do
        normalize_file_operation_filters(client)
      end

      -- setup keymaps
      for server, server_opts in pairs(opts.servers) do
        if type(server_opts) == "table" and server_opts.keys then
          require("plugins.lsp.keymaps").set({ name = server ~= "*" and server or nil }, server_opts.keys)
        end
      end

      -- inlay hints
      if opts.inlay_hints.enabled then
        Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buffer)
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
        local codelens_group = vim.api.nvim_create_augroup("lsp_codelens_refresh", { clear = true })
        local function refresh_codelens(buffer) vim.lsp.codelens.enable(true, { bufnr = buffer }) end

        Snacks.util.lsp.on({ method = "textDocument/codeLens" }, function(buffer)
          refresh_codelens(buffer)
          vim.api.nvim_clear_autocmds { group = codelens_group, buffer = buffer }
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
            group = codelens_group,
            buffer = buffer,
            callback = function() refresh_codelens(buffer) end,
          })
        end)
      end

      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      if opts.servers["*"] then vim.lsp.config("*", opts.servers["*"]) end

      -- get all the servers that are available through mason-lspconfig
      local have_mason = Util.has "mason-lspconfig.nvim"
      local mason_all = have_mason
          and vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package)
        or {} --[[ @as string[] ]]
      local mason_exclude = {} ---@type string[]

      ---@return boolean? exclude automatic setup
      local function configure(server)
        if server == "*" then return false end
        local sopts = opts.servers[server]
        sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts --[[@as lazyvim.lsp.Config]]

        if sopts.enabled == false then
          mason_exclude[#mason_exclude + 1] = server
          return
        end

        local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)
        local setup = opts.setup[server] or opts.setup["*"]
        if setup and setup(server, sopts) then
          mason_exclude[#mason_exclude + 1] = server
        else
          vim.lsp.config(server, sopts) -- configure the server
          if not use_mason then vim.lsp.enable(server) end
        end
        return use_mason
      end

      local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
      if have_mason then
        require("mason-lspconfig").setup {
          ensure_installed = vim.list_extend(install, Util.opts("mason-lspconfig.nvim").ensure_installed or {}),
          automatic_enable = { exclude = mason_exclude },
        }
      end
    end),
  },
}
