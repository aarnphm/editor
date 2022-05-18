local ui = {}
local config = require("modules.ui.config")

ui["folke/which-key.nvim"] = {
  opt = true,
  event = "BufEnter",
  config = function()
    require("which-key").setup()
  end,
}
ui["nvim-lualine/lualine.nvim"] = {
  opt = true,
  config = config.lualine,
  after = "fidget.nvim",
  cond = function()
    return __editor_config.plugins.statusline == "lualine"
  end,
}
ui["j-hui/fidget.nvim"] = {
  opt = true,
  after = "nvim-treesitter",
  config = function()
    require("fidget").setup({
      text = {
        spinner = "dots",
      },
    })
  end,
}
ui["goolord/alpha-nvim"] = {
  opt = true,
  event = "BufWinEnter",
  config = config.alpha,
  cond = function()
    return #vim.api.nvim_list_uis() > 0
  end,
}
ui["kyazdani42/nvim-tree.lua"] = {
  opt = true,
  cmd = { "NvimTreeToggle" },
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
}
ui["akinsho/nvim-bufferline.lua"] = {
  opt = true,
  event = "BufRead",
  config = config.nvim_bufferline,
}
ui["mbbill/undotree"] = {
  opt = true,
  cmd = "UndotreeToggle",
}

return ui
