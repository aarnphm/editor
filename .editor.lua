local vim = vim

return {
  background = "dark",
  colorscheme = "kanagawa",
  schemeopts = {
    ["rose-pine"] = {
      dark_variant = "moon",
    },
  },
  debug = true,
  options = {
    shadafile = "NONE",
  },
  global = {
    python3_host_org = vim.fn.expand("~/mambaforge/bin/python"),
  },
  plugins = {
    statusline = "lualine",
  },
  repos = "bentoml/bentoml",
  reset_cache = false,
}
