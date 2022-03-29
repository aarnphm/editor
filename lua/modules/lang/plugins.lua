local lang = {}
local conf = require("modules.lang.config")

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
lang["xuhdev/vim-latex-live-preview"] = {
  opt = true,
  after = "vimtex",
  config = function()
    vim.g.livepreview_previewer = "/Applications/Preview.app"
  end,
}
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
