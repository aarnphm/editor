local lang = {}
local config = require("modules.lang.config")

lang["fatih/vim-go"] = {
  opt = true,
  ft = "go",
  run = ":GoInstallBinaries",
  config = config.lang_go,
}
lang["simrat39/rust-tools.nvim"] = {
  opt = true,
  ft = "rust",
  config = config.rust_tools,
  requires = "nvim-lua/plenary.nvim",
}
lang["mzlogin/vim-markdown-toc"] = {
  opt = true,
  ft = "md",
  cmd = "GenTocGFM",
}
lang["iamcco/markdown-preview.nvim"] = {
  opt = true,
  ft = "markdown",
  run = "cd app && yarn install",
}
lang["lervag/vimtex"] = { opt = true, ft = "tex", config = config.vimtex }
return lang
