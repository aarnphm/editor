local ui = {}

ui["nathom/filetype.nvim"] = { lazy = false }
ui["catppuccin/nvim"] = { as = "catppuccin", lazy = false, name = "catppuccin", config = require("ui.catppuccin") }
ui["lewis6991/gitsigns.nvim"] = { lazy = true, event = { "BufRead", "BufNewFile" }, config = require("ui.gitsigns") }
ui["lukas-reineke/indent-blankline.nvim"] = { lazy = true, event = "BufRead", config = require("ui.indent-blankline") }
ui["akinsho/nvim-bufferline.lua"] =
  { lazy = true, event = { "BufReadPost", "BufAdd", "BufNewFile" }, config = require("ui.nvim-bufferline") }

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
  config = require("ui.alpha-nvim"),
  cond = function()
    return #vim.api.nvim_list_uis() > 0
  end,
}

ui["nvim-lualine/lualine.nvim"] = {
  lazy = true,
  event = "VeryLazy",
  config = require("ui.lualine"),
}

ui["kyazdani42/nvim-tree.lua"] = {
  cmd = {
    "NvimTreeToggle",
    "NvimTreeOpen",
    "NvimTreeFindFile",
    "NvimTreeFindFileToggle",
    "NvimTreeRefresh",
  },
  config = require("ui.nvim-tree"),
}

return ui
