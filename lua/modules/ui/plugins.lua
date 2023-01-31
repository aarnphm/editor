local ui = {}
local config = require("modules.ui.config")

ui["nathom/filetype.nvim"] = { lazy = false }
ui["catppuccin/nvim"] = {
  as = "catppuccin",
  lazy = false,
  name = "catppuccin",
  config = config.catppuccin,
}

ui["j-hui/fidget.nvim"] = {
  lazy = true,
  event = "BufRead",
  config = function()
    require("fidget").setup({
      text = {
        spinner = "dots",
      },
      window = { blend = 0 },
    })
  end,
}
ui["goolord/alpha-nvim"] = {
  lazy = true,
  event = "BufWinEnter",
  config = config.alpha,
  cond = function()
    return #vim.api.nvim_list_uis() > 0
  end,
}
ui["nvim-lualine/lualine.nvim"] = {
  lazy = true,
  event = "VeryLazy",
  config = config.lualine,
}
ui["kyazdani42/nvim-tree.lua"] = {
  cmd = {
    "NvimTreeToggle",
    "NvimTreeOpen",
    "NvimTreeFindFile",
    "NvimTreeFindFileToggle",
    "NvimTreeRefresh",
  },
  config = config.nvim_tree,
}
ui["lukas-reineke/indent-blankline.nvim"] = {
  lazy = true,
  event = "BufRead",
  config = config.indent_blankline,
}
ui["lewis6991/gitsigns.nvim"] = {
  lazy = true,
  event = { "BufRead", "BufNewFile" },
  config = config.gitsigns,
}
ui["akinsho/nvim-bufferline.lua"] = {
  lazy = true,
  event = { "BufReadPost", "BufAdd", "BufNewFile" },
  config = config.nvim_bufferline,
}

return ui
