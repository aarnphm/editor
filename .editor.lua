return {
  background = "dark",
  colorscheme = "kanagawa",
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
