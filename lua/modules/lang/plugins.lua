local lang = {}
local conf = require("modules.lang.config")

lang["mzlogin/vim-markdown-toc"] = {
  opt = true,
  ft = "md",
  cmd = "GenTocGFM",
}
lang["fatih/vim-go"] = {
  opt = true,
  ft = "go",
  run = ":GoInstallBinaries",
  config = conf.lang_go,
}
lang["simrat39/rust-tools.nvim"] = {
  opt = true,
  ft = "rust",
  config = conf.rust_tools,
  requires = "nvim-lua/plenary.nvim",
}
lang["iamcco/markdown-preview.nvim"] = {
  opt = true,
  ft = "markdown",
  run = "cd app && yarn install",
}
lang["lervag/vimtex"] = { opt = true, ft = "tex", config = conf.vimtex }
return lang
