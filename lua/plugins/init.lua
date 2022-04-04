local fn = vim.fn
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
  use({ "wbthomason/packer.nvim", opt = true })

  use({ "kyazdani42/nvim-web-devicons" })
  use({ "stevearc/dressing.nvim", after = "nvim-web-devicons" })

  -- tpope
  use({ "tpope/vim-sleuth" })
  use({ "tpope/vim-surround" })
  use({ "tpope/vim-commentary" })
  use({
    "glepnir/dashboard-nvim",
    opt = true,
    cond = function()
      return #vim.api.nvim_list_uis() > 0
    end,
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
