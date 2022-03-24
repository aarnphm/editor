local ui = {}
local conf = require("modules.ui.config")

ui["SmiteshP/nvim-gps"] = {
  opt = true,
  after = "nvim-treesitter",
  config = conf.nvim_gps,
}
ui["nvim-lualine/lualine.nvim"] = {
  opt = false,
  after = "nvim-gps",
  config = conf.lualine,
}
ui["j-hui/fidget.nvim"] = {
  requires = {
    "nvim-lualine/lualine.nvim",
  },
  config = function()
    require("fidget").setup({})
  end,
  after = "nvim-gps",
}
ui["glepnir/dashboard-nvim"] = { event = { "BufWinEnter", "BufNewFile" } }
ui["kyazdani42/nvim-tree.lua"] = {
  opt = true,
  cmd = { "NvimTreeToggle", "NvimTreeOpen" },
  config = conf.nvim_tree,
}
ui["lukas-reineke/indent-blankline.nvim"] = {
  opt = true,
  event = "BufRead",
  config = conf.indent_blankline,
}
ui["lewis6991/gitsigns.nvim"] = {
  opt = true,
  event = { "BufRead", "BufNewFile" },
  config = conf.gitsigns,
  requires = { "nvim-lua/plenary.nvim", opt = true },
}
ui["wfxr/minimap.vim"] = {
  opt = true,
  event = "BufRead",
}
ui["lukas-reineke/indent-blankline.nvim"] = {
  opt = true,
  event = "BufRead",
  config = conf.indent_blankline,
}
ui["akinsho/nvim-bufferline.lua"] = {
  opt = true,
  event = "BufRead",
  config = conf.nvim_bufferline,
}

return ui
