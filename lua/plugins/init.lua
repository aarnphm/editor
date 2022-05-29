local present, packer = pcall(require, "plugins.packerInit")
if not present then
  return false
end

local get_plugins_list = function()
  local list = {}
  local tmp = vim.split(vim.fn.globpath(__editor_global.modules_dir, "*/plugins.lua"), "\n")
  for _, f in ipairs(tmp) do
    list[#list + 1] = f:sub(#__editor_global.modules_dir - 6, -1)
  end
  return list
end

local get_plugins_mapping = function()
  local plugins = {}
  local plugins_ = get_plugins_list()

  for _, m in ipairs(plugins_) do
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

  -- colorscheme
  use({
    "rose-pine/neovim",
    as = "rose-pine",
    tag = "v1.*",
    config = function()
      vim.cmd("colorscheme rose-pine")
    end,
  })

  use({ "stevearc/dressing.nvim", after = "nvim-web-devicons" })

  -- tpope
  use({ "tpope/vim-sleuth" })
  use({ "tpope/vim-surround" })
  use({ "tpope/vim-commentary" })
end

return packer.startup(function(use)
  required_plugins(use)
  for _, repo in ipairs(get_plugins_mapping()) do
    use(repo)
  end
end)
