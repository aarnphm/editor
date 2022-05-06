local tools = {}
local config = require("modules.tools.config")

tools["github/copilot.vim"] = {
  opt = true,
  cmd = "Copilot",
  setup = function()
    vim.cmd([[
packadd copilot.vim
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
    ]])
  end,
}
tools["renerocksai/telekasten.nvim"] = {
  opt = true,
  module = "telekasten",
  config = config.telekasten,
  requires = { "renerocksai/calendar-vim", opt = true, after = "telekasten", module = "telekasten" },
}
tools["windwp/nvim-spectre"] = {
  module = "spectre",
  config = config.spectre,
}
tools["tpope/vim-dispatch"] = { cmd = "Dispatch" }
tools["wakatime/vim-wakatime"] = { opt = true }
tools["nvim-telescope/telescope.nvim"] = {
  opt = true,
  module = "telescope",
  cmd = "Telescope",
  requires = {
    { "nvim-lua/plenary.nvim", opt = false },
    { "nvim-lua/popup.nvim", opt = true },
  },
  config = config.telescope,
}
tools["nvim-telescope/telescope-fzf-native.nvim"] = {
  opt = true,
  run = "make",
  after = "telescope.nvim",
}
tools["nvim-telescope/telescope-file-browser.nvim"] = {
  opt = true,
  after = "telescope-fzf-native.nvim",
}
tools["nvim-telescope/telescope-frecency.nvim"] = {
  opt = true,
  after = "telescope-file-browser.nvim",
  requires = { { "tami5/sqlite.lua", opt = true } },
}
tools["nvim-telescope/telescope-ui-select.nvim"] = {
  opt = true,
  after = "telescope.nvim",
}
tools["xiyaowong/telescope-emoji.nvim"] = {
  opt = true,
  after = "telescope.nvim",
}
tools["pwntester/octo.nvim"] = {
  opt = true,
  after = "telescope.nvim",
  config = config.octo,
  cmd = "Octo",
  module = "octo",
  requires = {
    "nvim-telescope/telescope.nvim",
  },
}
tools["sudormrfbin/cheatsheet.nvim"] = {
  opt = true,
  after = "telescope.nvim",
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
tools["dstein64/vim-startuptime"] = {
  opt = true,
  cmd = "StartupTime",
  disable = __editor_config.debug ~= true,
}
tools["folke/trouble.nvim"] = {
  opt = true,
  cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
  config = config.trouble,
}
return tools
