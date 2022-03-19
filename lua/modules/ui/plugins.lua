local ui = {}
local conf = require("modules.ui.config")

ui["folke/tokyonight.nvim"] = { opt = false, config = conf.tokyo }
ui["jacoborus/tender.vim"] = { opt = false }
ui["kyazdani42/nvim-web-devicons"] = { opt = false }
ui["rebelot/kanagawa.nvim"] = { opt = false, config = conf.kanagawa }
ui["NLKNguyen/papercolor-theme"] = { opt = false }
ui["sainnhe/edge"] = { opt = false, config = conf.edge }
ui["catppuccin/nvim"] = {
  opt = false,
  as = "catppuccin",
  config = conf.catppuccin,
}
ui["rmehri01/onenord.nvim"] = {
  opt = false,
  config = function()
    require("onenord").setup({
      theme = "dark",
    })
  end,
}
ui["SmiteshP/nvim-gps"] = {
  opt = true,
  after = "nvim-treesitter",
  config = conf.nvim_gps,
}
ui["hoob3rt/lualine.nvim"] = {
  opt = true,
  after = "lualine-lsp-progress",
  config = conf.lualine,
}
ui["arkav/lualine-lsp-progress"] = { opt = true, after = "nvim-gps" }
ui["glepnir/dashboard-nvim"] = { opt = true, event = "BufWinEnter" }
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
