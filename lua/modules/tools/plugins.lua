local tools = {}
local conf = require("modules.tools.config")
local utils = require("core.utils")

tools["RishabhRD/popfix"] = { opt = false }
tools["nvim-lua/plenary.nvim"] = { opt = false }
tools["nvim-telescope/telescope.nvim"] = {
  opt = false,
  module = "telescope",
  cmd = "Telescope",
  config = conf.telescope,
  requires = {
    { "nvim-lua/plenary.nvim", opt = false },
    { "nvim-lua/popup.nvim", opt = false },
  },
}
tools["nvim-telescope/telescope-ui-select.nvim"] = { opt = false }
tools["nvim-telescope/telescope-fzf-native.nvim"] = {
  opt = false,
  run = "make",
  after = "telescope.nvim",
}
tools["nvim-telescope/telescope-project.nvim"] = {
  opt = false,
  after = "telescope.nvim",
}
tools["nvim-telescope/telescope-file-browser.nvim"] = {
  opt = false,
  after = "telescope.nvim",
}
tools["nvim-telescope/telescope-frecency.nvim"] = {
  opt = false,
  after = "telescope.nvim",
  requires = { { "tami5/sqlite.lua", opt = false } },
}
tools["jvgrootveld/telescope-zoxide"] = { opt = false, after = "telescope-frecency.nvim" }
tools["thinca/vim-quickrun"] = { opt = true, cmd = { "QuickRun", "Q" } }
tools["folke/which-key.nvim"] = {
  opt = true,
  keys = ",",
  config = function()
    require("which-key").setup({})
  end,
}
tools["dstein64/vim-startuptime"] = { opt = true, cmd = "StartupTime" }
tools["gelguy/wilder.nvim"] = {
  event = "CmdlineEnter",
  config = conf.wilder,
  requires = { { "romgrk/fzy-lua-native", after = "wilder.nvim" } },
}
tools["folke/trouble.nvim"] = {
  opt = true,
  cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
  config = conf.trouble,
}
return tools
