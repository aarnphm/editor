return function()
  local formatting = require("completion.formatting")

  local nvim_lsp = require("lspconfig")
  local mason = require("mason")
  local mason_lspconfig = require("mason-lspconfig")

  require("lspconfig.ui.windows").default_options.border = "single"

  local icons = {
    ui = require("utils.icons").get("ui", true),
    misc = require("utils.icons").get("misc", true),
  }

  mason.setup({
    ui = {
      border = "rounded",
      icons = {
        package_pending = icons.ui.Modified_alt,
        package_installed = icons.ui.Check,
        package_uninstalled = icons.misc.Ghost,
      },
      keymaps = {
        toggle_server_expand = "<CR>",
        install_server = "i",
        update_server = "u",
        check_server_version = "c",
        update_all_servers = "U",
        check_outdated_servers = "C",
        uninstall_server = "X",
        cancel_installation = "<C-c>",
      },
    },
  })
  mason_lspconfig.setup({
    ensure_installed = {
      "bashls",
      "clangd",
      "efm",
      "gopls",
      "pyright",
      "sumneko_lua",
      "taplo",
      "rust_analyzer",
    },
    automatic_installation = true,
  })

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

  local options = {
    on_attach = function()
      require("lsp_signature").on_attach({
        bind = true,
        use_lspsaga = false,
        floating_window = true,
        fix_pos = true,
        hint_enable = true,
        hi_parameter = "Search",
        handler_opts = { border = "rounded" },
      })
    end,
    capabilities = capabilities,
  }

  mason_lspconfig.setup_handlers({
    function(server)
      require("lspconfig")[server].setup({
        capabilities = options.capabilities,
        on_attach = options.on_attach,
      })
    end,

    bashls = function()
      nvim_lsp.bashls.setup(vim.tbl_deep_extend("keep", require("completion.servers.bashls"), options))
    end,

    clangd = function()
      nvim_lsp.clangd.setup(vim.tbl_deep_extend("keep", require("completion.servers.clangd"), {
        on_attach = options.on_attach,
        capabilities = vim.tbl_deep_extend("keep", { offsetEncoding = { "utf-16", "utf-8" } }, capabilities),
      }))
    end,

    efm = function()
      -- Do not setup efm
    end,

    gopls = function()
      nvim_lsp.gopls.setup(vim.tbl_deep_extend("keep", require("completion.servers.gopls"), options))
    end,

    jsonls = function()
      nvim_lsp.jsonls.setup(vim.tbl_deep_extend("keep", require("completion.servers.jsonls"), options))
    end,

    jdtls = function()
      nvim_lsp.jdtls.setup(vim.tbl_deep_extend("keep", require("completion.servers.jdtls"), options))
    end,

    sumneko_lua = function()
      nvim_lsp.sumneko_lua.setup(vim.tbl_deep_extend("keep", require("completion.servers.sumneko_lua"), options))
    end,

    yamlls = function()
      nvim_lsp.yamlls.setup(vim.tbl_deep_extend("keep", require("completion.servers.yamlls"), options))
    end,

    tsserver = function()
      nvim_lsp.tsserver.setup(vim.tbl_deep_extend("keep", require("completion.servers.tsserver"), options))
    end,

    pyright = function()
      nvim_lsp.pyright.setup(vim.tbl_deep_extend("keep", require("completion.servers.pyright"), options))
    end,
  })

  if vim.fn.executable("html-languageserver") then
    nvim_lsp.html.setup(vim.tbl_deep_extend("keep", require("completion.servers.html"), options))
  end

  local efmls = require("efmls-configs")

  -- Init `efm-langserver` here.
  efmls.init({
    on_attach = options.on_attach,
    capabilities = capabilities,
    init_options = { documentFormatting = true, codeAction = true },
  })

  -- Require `efmls-configs-nvim`'s config here
  local eslint = require("efmls-configs.linters.eslint")
  local prettier = require("efmls-configs.formatters.prettier")

  -- Setup formatter and linter for efmls here

  efmls.setup({
    vue = { formatter = prettier },
    yaml = { formatter = prettier },
    html = { formatter = prettier },
    css = { formatter = prettier },
    scss = { formatter = prettier },
    markdown = { formatter = prettier },
    typescript = { formatter = prettier, linter = eslint },
    javascript = { formatter = prettier, linter = eslint },
    typescriptreact = { formatter = prettier, linter = eslint },
    javascriptreact = { formatter = prettier, linter = eslint },
    vim = { formatter = require("efmls-configs.linters.vint") },
    lua = { formatter = require("efmls-configs.formatters.stylua") },
    c = { formatter = require("completion.efm.formatters.clangfmt") },
    cpp = { formatter = require("completion.efm.formatters.clangfmt") },
    rust = { formatter = require("completion.efm.formatters.rustfmt") },
    python = { formatter = require("efmls-configs.formatters.black"), linter = require("efmls-configs.linters.pylint") },
    sh = { formatter = require("efmls-configs.formatters.shfmt"), linter = require("efmls-configs.linters.shellcheck") },
  })

  formatting.configure_format_on_save()
end
