local lang = {}
local conf = require("modules.lang.config")

lang["fatih/vim-go"] = {
  opt = true,
  ft = "go",
  run = ":GoInstallBinaries",
  config = conf.lang_go,
}
lang["rust-lang/rust.vim"] = { opt = true, ft = "rust" }
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
lang["lervag/vimtex"] = { opt = true, config = conf.vimtex }
lang["jakewvincent/texmagic.nvim"] = {
  opt = true,
  config = function()
    require("texmagic").setup({
      -- Config goes here; leave blank for defaults
    })
  end,
  after = "nvim-lspconfig",
}
lang["xeluxee/competitest.nvim"] = {
  opt = true,
  requires = "MunifTanjim/nui.nvim",
  config = function()
    require("competitest").setup()
  end,
}
lang["p00f/cphelper.nvim"] = {
  opt = true,
  requires = "nvim-lua/plenary.nvim",
}

return lang
