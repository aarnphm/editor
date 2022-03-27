local ui = {}
local config = require("modules.ui.config")

ui["folke/which-key.nvim"] = {
  opt = true,
  event = "BufEnter",
  config = function()
    require("which-key").setup()
  end,
}
ui["SmiteshP/nvim-gps"] = {
  opt = true,
  after = "nvim-treesitter",
  config = config.nvim_gps,
}
ui["nvim-lualine/lualine.nvim"] = {
  opt = true,
  after = "nvim-gps",
  config = config.lualine,
}
ui["j-hui/fidget.nvim"] = {
  opt = true,
  config = function()
    require("fidget").setup({
      text = {
        spinner = "dots",
      },
    })
  end,
  after = "nvim-gps",
}
ui["kyazdani42/nvim-tree.lua"] = {
  opt = true,
  cmd = { "NvimTreeToggle", "NvimTreeOpen" },
  config = config.nvim_tree,
}
ui["lukas-reineke/indent-blankline.nvim"] = {
  opt = true,
  event = "BufRead",
  config = config.indent_blankline,
}
ui["lewis6991/gitsigns.nvim"] = {
  opt = true,
  event = { "BufRead", "BufNewFile" },
  config = config.gitsigns,
  requires = { "nvim-lua/plenary.nvim", opt = true },
}
ui["lukas-reineke/indent-blankline.nvim"] = {
  opt = true,
  event = "BufRead",
  config = config.indent_blankline,
}
ui["akinsho/nvim-bufferline.lua"] = {
  opt = true,
  event = "BufRead",
  config = config.nvim_bufferline,
}

return ui
