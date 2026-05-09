Util.lsp.formatters("rust", { "rustfmt" })
Util.lsp.enable("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        buildScripts = { enable = true },
      },
      checkOnSave = true,
      procMacro = {
        enable = true,
        ignored = {
          ["async-trait"] = { "async_trait" },
          ["napi-derive"] = { "napi" },
          ["async-recursion"] = { "async_recursion" },
        },
      },
      files = {
        exclude = {
          ".direnv",
          ".git",
          ".jj",
          ".github",
          ".gitlab",
          "bin",
          "node_modules",
          "target",
          "venv",
          ".venv",
        },
        watcher = "client",
      },
    },
  },
})

vim.bo.commentstring = "// %s"
vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true

vim.keymap.set("n", "<leader>cR", vim.lsp.buf.code_action, { buffer = true, desc = "rust: code action" })
vim.keymap.set("n", "<leader>dr", vim.lsp.codelens.run, { buffer = true, desc = "rust: run codelens" })
