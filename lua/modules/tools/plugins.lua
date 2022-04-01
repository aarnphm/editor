local tools = {}
local config = require("modules.tools.config")

tools["renerocksai/telekasten.nvim"] = {
  opt = true,
  module = "telekasten",
  config = config.telekasten,
  requires = { "renerocksai/calendar-vim", opt = true, after = "telekasten", module = "telekasten" },
}
tools["windwp/nvim-spectre"] = {
  requires = { "nvim-lua/plenary.nvim" },
  module = "spectre",
  config = config.spectre,
}
tools["tpope/vim-dispatch"] = { cmd = "Dispatch" }
tools["RishabhRD/popfix"] = { opt = false }
tools["nvim-lua/plenary.nvim"] = { opt = false }
tools["wakatime/vim-wakatime"] = { opt = true }
tools["nvim-telescope/telescope.nvim"] = {
  opt = true,
  module = "telescope",
  cmd = "Telescope",
  config = config.telescope,
  requires = {
    { "nvim-lua/plenary.nvim", opt = false },
    { "nvim-lua/popup.nvim", opt = false },
  },
}
tools["nvim-telescope/telescope-fzf-native.nvim"] = {
  opt = true,
  run = "make",
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
tools["nvim-telescope/telescope-ui-select.nvim"] = { opt = true, after = "telescope.nvim" }
tools["xiyaowong/telescope-emoji.nvim"] = {
  opt = true,
  after = "telescope.nvim",
}
tools["pwntester/octo.nvim"] = {
  opt = true,
  after = "telescope.nvim",
  config = config.octo,
  cmd = "Octo",
  requires = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "kyazdani42/nvim-web-devicons",
  },
}
tools["sudormrfbin/cheatsheet.nvim"] = {
  opt = true,
  after = "telescope.nvim",
  requires = {
    { "nvim-telescope/telescope.nvim" },
    { "nvim-lua/popup.nvim" },
    { "nvim-lua/plenary.nvim" },
  },
  config = config.cheatsheet,
}
tools["gelguy/wilder.nvim"] = {
  event = "CmdlineEnter",
  config = config.wilder,
  run = ":UpdateRemotePlugins",
  requires = {
    { "romgrk/fzy-lua-native", opt = true, after = "wilder.nvim" },
  },
}
tools["dstein64/vim-startuptime"] = { opt = true, cmd = "StartupTime", disable = __editor_config.debug ~= true }
tools["folke/trouble.nvim"] = {
  opt = true,
  cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
  config = config.trouble,
}
return tools
