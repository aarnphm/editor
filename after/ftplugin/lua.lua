if Util.pack.in_maintenance() then return end

Util.pack.load "lazydev.nvim"

require("lazydev").setup {
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    { path = "conform.nvim", words = { "conform" } },
  },
}

Util.lsp.enable("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT", special = { reload = "require" } },
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
      diagnostics = {
        disable = { "incomplete-signature-doc", "trailing-space" },
        unusedLocalExclude = { "_*" },
      },
    },
  },
})

Util.lsp.ensure_mason_packages({ "lua-language-server" }, { ["lua-language-server"] = "lua_ls" })

Util.lsp.formatters("lua", { "stylua" })
Util.lint.linters("lua", { "selene" })
Util.lint.linter("selene", {
  condition = function(ctx) return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1] end,
})
