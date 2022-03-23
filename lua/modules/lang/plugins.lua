local lang = {}
local conf = require("modules.lang.config")

lang["ray-x/go.nvim"] = {
  opt = true,
  ft = "go",
  config = function()
    require("go").setup({})
  end,
  after = "nvim-lspconfig",
}
lang["rust-lang/rust.vim"] = { opt = true, ft = "rust" }
lang["simrat39/rust-tools.nvim"] = {
  opt = true,
  ft = "rust",
  config = conf.rust_tools,
  requires = { { "nvim-lua/plenary.nvim", opt = false } },
}
lang["iamcco/markdown-preview.nvim"] = {
  opt = true,
  ft = "markdown",
  run = "cd app && yarn install",
}
lang["chrisbra/csv.vim"] = { opt = true, ft = "csv" }
return lang
