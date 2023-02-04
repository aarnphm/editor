local language = {}

language["chrisbra/csv.vim"] = { lazy = true, ft = "csv" }
language["lervag/vimtex"] = { lazy = true, ft = "tex", config = require("language.vimtex") }
language["bazelbuild/vim-bazel"] = { lazy = true, dependencies = { "google/vim-maktaba" }, ft = "bzl" }
language["simrat39/rust-tools.nvim"] = { lazy = true, ft = "rust", config = require("language.rust-tools") }
language["fatih/vim-go"] = { lazy = true, ft = "go", run = ":GoInstallBinaries", config = require("language.vim-go") }
language["iamcco/markdown-preview.nvim"] = {
  lazy = true,
  ft = "markdown",
  run = "cd app && yarn install",
  build = "cd app && yarn install",
}

return language
