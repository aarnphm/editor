local tools = {}
local conf = require("modules.tools.config")

tools["RishabhRD/popfix"] = { opt = false }
tools["nvim-lua/plenary.nvim"] = { opt = false }
tools["wakatime/vim-wakatime"] = { opt = true, run = ":WakaTimeApiKey" }
tools["nvim-telescope/telescope.nvim"] = {
  opt = true,
  module = "telescope",
  cmd = "Telescope",
  config = conf.telescope,
  requires = {
    { "nvim-lua/plenary.nvim", opt = false },
    { "nvim-lua/popup.nvim", opt = false },
  },
}
tools["pwntester/octo.nvim"] = {
  opt = true,
  after = "telescope.nvim",
  config = conf.octo,
  cmd = "Octo",
  requires = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "kyazdani42/nvim-web-devicons",
  },
}
tools["nvim-telescope/telescope-fzf-native.nvim"] = {
  opt = true,
  run = "make",
  after = "telescope.nvim",
}
tools["nvim-telescope/telescope-project.nvim"] = {
  opt = true,
  after = "telescope.nvim",
}
tools["nvim-telescope/telescope-file-browser.nvim"] = {
  opt = true,
  after = "telescope.nvim",
}
tools["nvim-telescope/telescope-frecency.nvim"] = {
  opt = true,
  after = "telescope.nvim",
  requires = { { "tami5/sqlite.lua", opt = false } },
}
tools["jvgrootveld/telescope-zoxide"] = { opt = true, after = "telescope-frecency.nvim" }
tools["nvim-telescope/telescope-ui-select.nvim"] = { opt = true, after = "telescope.nvim" }
tools["xiyaowong/telescope-emoji.nvim"] = {
  opt = true,
  after = "telescope.nvim",
}
tools["sudormrfbin/cheatsheet.nvim"] = {
  opt = true,
  after = "telescope.nvim",
  requires = {
    { "nvim-telescope/telescope.nvim" },
    { "nvim-lua/popup.nvim" },
    { "nvim-lua/plenary.nvim" },
  },
  config = conf.cheatsheet,
}

tools["thinca/vim-quickrun"] = { opt = true, cmd = { "QuickRun", "Q" } }
tools["dstein64/vim-startuptime"] = { opt = true, cmd = "StartupTime" }
tools["gelguy/wilder.nvim"] = {
  event = "CmdlineEnter",
  config = conf.wilder,
  requires = {
    { "romgrk/fzy-lua-native", opt = true, after = "wilder.nvim" },
  },
}
tools["folke/trouble.nvim"] = {
  opt = true,
  cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
  config = conf.trouble,
}
return tools
