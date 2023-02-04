return function()
  require("mason-tool-installer").setup({

    -- a list of all tools you want to ensure are installed upon
    -- start; they should be the names Mason uses for each tool
    ensure_installed = {
      -- you can turn off/on auto_update per tool
      "rust-analyzer",
      "clangd",
      "typescript-language-server",
      "eslint-lsp",
      "efm",
      "dockerfile-language-server",
      "gopls",
      "rnix-lsp",
      "pyright",
      "jdtls",
      "bash-language-server",
      "grammarly-languageserver",
      "lua-language-server",
      "stylua",
      "selene",
      "black",
      "isort",
      "yamllint",
      "clang-format",
      "buf",
      "pylint",
      "prettier",
      "shellcheck",
      "shfmt",
      "vint",
      "buildifier",
      "taplo",
      "vim-language-server",
      "tflint",
      "jq",
      "yamlfmt",
    },
    auto_update = false,
    run_on_start = true,
  })
end
