local fn = vim.fn
local uv = vim.loop
local present, packer = pcall(require, "plugins.packerInit")
if not present then
  return false
end

local get_plugins_list = function()
  local list = {}
  local tmp = vim.split(fn.globpath(__editor_global.modules_dir, "*/plugins.lua"), "\n")
  for _, f in ipairs(tmp) do
    list[#list + 1] = f:sub(#__editor_global.modules_dir - 6, -1)
  end
  return list
end

local get_plugins_mapping = function()
  local plugins = {}

  for _, m in ipairs(get_plugins_list()) do
    local repos = require(m:sub(0, #m - 4))
    for repo, conf in pairs(repos) do
      plugins[#plugins + 1] = vim.tbl_extend("force", { repo }, conf)
    end
  end
  return plugins
end

local required_plugins = function(use)
  use({ "RishabhRD/popfix" })
  use({ "nvim-lua/plenary.nvim" })
  use({ "lewis6991/impatient.nvim" })
  use({
    "nathom/filetype.nvim",
    config = function()
      require("filetype").setup({})
    end,
  })
  use({
    "wbthomason/packer.nvim",
    event = "VimEnter",
  })

  use({ "kyazdani42/nvim-web-devicons" })
  use({ "stevearc/dressing.nvim", after = "nvim-web-devicons" })

  -- tpope
  use({ "tpope/vim-sleuth" })
  use({ "tpope/vim-surround" })
  use({ "tpope/vim-commentary" })

  -- notify
  use({
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      local notify_config = {
        -- Animation style (see below for details)
        stages = "static",
        -- Default timeout for notifications
        timeout = 3000,
        -- Minimum width for notification windows
        minimum_width = 50,

        -- Icons for the different levels
        icons = {
          ERROR = " ",
          WARN = " ",
          INFO = " ",
          DEBUG = " ",
          TRACE = "✎ ",
        },
      }
      notify.setup(notify_config)
      vim.notify = notify
    end,
  })
  use({
    "glepnir/dashboard-nvim",
    event = { "BufWinEnter", "BufNewFile" },
  })

  -- colorscheme
  require("themes").setup(use)
end

return packer.startup(function(use)
  required_plugins(use)
  for _, repo in ipairs(get_plugins_mapping()) do
    use(repo)
  end
end)
