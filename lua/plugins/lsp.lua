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
      { "gI", Util.telescope("lsp_implementations", { reuse_win = true }), desc = "lsp: Goto implementation" },
      { "gY", Util.telescope("lsp_type_definitions", { reuse_win = true }), desc = "lsp: Goto type definitions" },
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

-- This is the same as in lspconfig.server_configurations.jdtls, but avoids
-- needing to require that when this module loads.
local java_filetypes = { "java" }

-- Utility function to extend or override a config table, similar to the way
-- that Plugin.opts works.
---@param config table
---@param custom function | table | nil
local function extend_or_override(config, custom, ...)
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
  {
    "smjonas/inc-rename.nvim",
    dependencies = { "stevearc/dressing.nvim" },
    opts = { input_buffer_type = "dressing" },
  },
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
    "mfussenegger/nvim-jdtls",
    dependencies = { "folke/which-key.nvim" },
    ft = java_filetypes,
    opts = function()
      return {
        -- How to find the root dir for a given filename. The default comes from
        -- lspconfig which provides a function specifically for java projects.
        root_dir = require("lspconfig.server_configurations.jdtls").default_config.root_dir,

        -- How to find the project name for a given root dir.
        project_name = function(root_dir) return root_dir and vim.fs.basename(root_dir) end,

        -- Where are the config and workspace dirs for a project?
        jdtls_config_dir = function(project_name)
          return vim.fn.stdpath "cache" .. "/jdtls/" .. project_name .. "/config"
        end,
        jdtls_workspace_dir = function(project_name)
          return vim.fn.stdpath "cache" .. "/jdtls/" .. project_name .. "/workspace"
        end,

        -- How to run jdtls. This can be overridden to a full java command-line
        -- if the Python wrapper script doesn't suffice.
        cmd = { "jdtls" },
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local cmd = vim.deepcopy(opts.cmd)
          if project_name then
            vim.list_extend(cmd, {
              "-configuration",
              opts.jdtls_config_dir(project_name),
              "-data",
              opts.jdtls_workspace_dir(project_name),
            })
          end
          return cmd
        end,

        -- These depend on nvim-dap, but can additionally be disabled by setting false here.
        dap = { hotcodereplace = "auto", config_overrides = {} },
        test = true,
      }
    end,
    config = function()
      local opts = Util.opts "nvim-jdtls" or {}

      -- Find the extra bundles that should be passed on the jdtls command-line
      -- if nvim-dap is enabled with java debug/test.
      local mason_registry = require "mason-registry"
      local bundles = {} ---@type string[]
      if opts.dap and Util.has "nvim-dap" and mason_registry.is_installed "java-debug-adapter" then
        local java_dbg_pkg = mason_registry.get_package "java-debug-adapter"
        local java_dbg_path = java_dbg_pkg:get_install_path()
        local jar_patterns = {
          java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
        }
        -- java-test also depends on java-debug-adapter.
        if opts.test and mason_registry.is_installed "java-test" then
          local java_test_pkg = mason_registry.get_package "java-test"
          local java_test_path = java_test_pkg:get_install_path()
          vim.list_extend(jar_patterns, {
            java_test_path .. "/extension/server/*.jar",
          })
        end
        for _, jar_pattern in ipairs(jar_patterns) do
          for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
            table.insert(bundles, bundle)
          end
        end
      end

      local function attach_jdtls()
        local fname = vim.api.nvim_buf_get_name(0)

        -- Configuration can be augmented and overridden by opts.jdtls
        local config = extend_or_override({
          cmd = opts.full_cmd(opts),
          root_dir = opts.root_dir(fname),
          init_options = {
            bundles = bundles,
          },
          -- enable CMP capabilities
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
        }, opts.jdtls)

        -- Existing server will be reused if the root_dir matches.
        require("jdtls").start_or_attach(config)
        -- not need to require("jdtls.setup").add_commands(), start automatically adds commands
      end

      -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
      -- depending on filetype, so this autocmd doesn't run for the first file.
      -- For that, we call directly below.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = java_filetypes,
        callback = attach_jdtls,
      })

      -- Setup keymap and dap after the lsp is fully attached.
      -- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
      -- https://neovim.io/doc/user/lsp.html#LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "jdtls" then
            local wk = require "which-key"
            wk.register({
              ["<leader>cx"] = { name = "+extract" },
              ["<leader>cxv"] = { require("jdtls").extract_variable_all, "Extract Variable" },
              ["<leader>cxc"] = { require("jdtls").extract_constant, "Extract Constant" },
              ["gs"] = { require("jdtls").super_implementation, "Goto Super" },
              ["gS"] = { require("jdtls.tests").goto_subjects, "Goto Subjects" },
              ["<leader>co"] = { require("jdtls").organize_imports, "Organize Imports" },
            }, { mode = "n", buffer = args.buf })
            wk.register({
              ["<leader>c"] = { name = "+code" },
              ["<leader>cx"] = { name = "+extract" },
              ["<leader>cxm"] = {
                [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
                "Extract Method",
              },
              ["<leader>cxv"] = {
                [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
                "Extract Variable",
              },
              ["<leader>cxc"] = {
                [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
                "Extract Constant",
              },
            }, { mode = "v", buffer = args.buf })

            if opts.dap and Util.has "nvim-dap" and mason_registry.is_installed "java-debug-adapter" then
              -- custom init for Java debugger
              require("jdtls").setup_dap(opts.dap)
              require("jdtls.dap").setup_dap_main_class_configs()

              -- Java Test require Java debugger to work
              if opts.test and mason_registry.is_installed "java-test" then
                -- custom keymaps for Java test runner (not yet compatible with neotest)
                wk.register({
                  ["<leader>t"] = { name = "+test" },
                  ["<leader>tt"] = { require("jdtls.dap").test_class, "Run All Test" },
                  ["<leader>tr"] = { require("jdtls.dap").test_nearest_method, "Run Nearest Test" },
                  ["<leader>tT"] = { require("jdtls.dap").pick_test, "Run Test" },
                }, { mode = "n", buffer = args.buf })
              end
            end

            -- User can set additional keymaps in opts.on_attach
            if opts.on_attach then opts.on_attach(args) end
          end
        end,
      })

      -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
      attach_jdtls()
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
        "p00f/clangd_extensions.nvim",
        ft = { "c", "cpp", "hpp", "h" },
        lazy = true,
        opts = function()
          local lspconfig = require "lspconfig"

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

          return {
            -- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/clangd.lua
            root_dir = function(fname)
              return require("lspconfig.util").root_pattern(
                "Makefile",
                "configure.ac",
                "configure.in",
                "config.h.in",
                "meson.build",
                "meson_options.txt",
                "WORKSPACE",
                "BUILD.bazel",
                "build.ninja"
              )(fname) or require("lspconfig.util").root_pattern(
                "compile_commands.json",
                "compile_flags.txt"
              )(fname) or require("lspconfig.util").find_git_ancestor(fname)
            end,
            server = {
              single_file_support = true,
              filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
              capabilities = { offsetEncoding = { "utf-16" } },
              command = {
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
              },
              cmd = {
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
              },
            },
          }
        end,
        config = function() end,
      },
      {
        "simrat39/rust-tools.nvim",
        ft = "rust",
        dependencies = { "nvim-lua/plenary.nvim" },
        lazy = true,
        opts = function()
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
          return {
            dap = { adapter = get_rust_adapters() },
            tools = {
              on_initialized = function()
                vim.cmd [[
                  augroup RustLSP
                    autocmd CursorHold                      *.rs silent! lua vim.lsp.buf.document_highlight()
                    autocmd CursorMoved,InsertEnter         *.rs silent! lua vim.lsp.buf.clear_references()
                    autocmd BufEnter,CursorHold,InsertLeave *.rs silent! lua vim.lsp.codelens.refresh()
                  augroup END
                ]]
              end,
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
          }
        end,
        config = function() end,
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
        jdtls = {},
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
          local rt_opts = Util.opts "rust-tools.nvim"
          require("rust-tools").setup(vim.tbl_deep_extend("force", rt_opts or {}, { server = opts }))
          return false
        end,
        jdtls = function() return true end, -- avoid duplicate servers
        yamlls = function()
          -- Neovim < 0.10 does not have dynamic registration for formatting
          if vim.fn.has "nvim-0.10" == 0 then
            Util.on_attach(function(client, _)
              if client.name == "yamlls" then client.server_capabilities.documentFormattingProvider = true end
            end)
          end
        end,
        clangd = function(_, opts)
          local clangd_opts = Util.opts "rust-tools.nvim"
          require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_opts or {}, { server = opts }))
          return false
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
