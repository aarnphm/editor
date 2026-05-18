Util.lsp.enable("tailwindcss", {
  filetypes = {
    "astro",
    "css",
    "heex",
    "html",
    "html-eex",
    "javascript",
    "javascriptreact",
    "less",
    "scss",
    "svelte",
    "typescript",
    "typescriptreact",
    "vue",
  },
  settings = {
    tailwindCSS = {
      includeLanguages = {
        elixir = "html-eex",
        eelixir = "html-eex",
        heex = "html-eex",
      },
    },
  },
})
