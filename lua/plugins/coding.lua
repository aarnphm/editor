-- This is the same as in lspconfig.server_configurations.jdtls, but avoids
-- needing to require that when this module loads.
local java_filetypes = { "java" }

return {
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
    "lervag/vimtex",
    lazy = false, -- lazy-loading will disable inverse search
    config = function()
      vim.api.nvim_create_autocmd({ "FileType" }, {
        group = augroup "vimtex_conceal",
        pattern = { "bib", "tex", "md" },
        callback = function() vim.wo.conceallevel = 2 end,
      })

      vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
      vim.g.vimtex_quickfix_method = vim.fn.executable "pplatex" == 1 and "pplatex" or "latexlog"
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
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "hpp", "h" },
    lazy = true,
    opts = function()
      ---@param binaries string[]
      local get_binary_path_list = function(binaries)
        ---@param binary string
        ---@return string|nil
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
          )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
            fname
          ) or require("lspconfig.util").find_git_ancestor(fname)
        end,
        server = {
          single_file_support = true,
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
          capabilities = { offsetEncoding = { "utf-16" } },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
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
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--header-insertion-decorators",
            "--header-insertion=iwyu",
            "--limit-references=3000",
            "--limit-results=350",
          },
        },
        inlay_hints = { inline = false },
        ast = {
          --These require codicons (https://github.com/microsoft/vscode-codicons)
          role_icons = {
            type = "",
            declaration = "",
            expression = "",
            specifier = "",
            statement = "",
            ["template argument"] = "",
          },
          kind_icons = {
            Compound = "",
            Recovery = "",
            TranslationUnit = "",
            PackExpansion = "",
            TemplateTypeParm = "",
            TemplateTemplateParm = "",
            TemplateParamObject = "",
          },
        },
      }
    end,
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
}
