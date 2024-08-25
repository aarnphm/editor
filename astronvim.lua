local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  spec = {
    {
      "AstroNvim/AstroNvim",
      version = "^4",
      import = "astronvim.plugins",
      opts = { -- AstroNvim options must be set here with the `import` key
        mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
        maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
        icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
        pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
        update_notifications = true, -- Enable/disable notification about running `:Lazy update` twice to update pinned plugins
      },
    },
    {
      "yetone/avante.nvim",
      event = "VeryLazy",
      build = "make",
      opts = {
        mappings = {
          ask = "<leader>ua",
          refresh = "<leader>ur",
          submit = {
            normal = "<CR>",
            insert = "<C-CR>",
          },
          toggle = {
            debug = "<LocalLeader>ud",
            hint = "<LocalLeader>uh",
          },
        },
        windows = {
          width = 30,
          sidebar_header = {
            align = "left", -- left, center, right for title
            rounded = false,
          },
        },
      },
      dependencies = {
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
      },
    },
  },
  change_detection = { notify = false },
  checker = { enabled = true, frequency = 3600 * 24, notify = false },
  ui = { border = "single", backdrop = 100, wrap = false },
  dev = {
    path = "~/workspace/neovim-plugins/",
  },
}
