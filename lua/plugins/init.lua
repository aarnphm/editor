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

  use({
    "kyazdani42/nvim-web-devicons",
    config = function()
      local colors = require("core.colors").get().base_30
      require("nvim-web-devicons").setup({
        -- your personnal icons can go here (to override)
        -- you can specify color or cterm_color instead of specifying both of them
        -- DevIcon will be appended to `name`
        override = {
          zsh = {
            icon = "",
            color = "#428850",
            cterm_color = "65",
            name = "Zsh",
          },
          c = {
            icon = "",
            color = colors.blue,
            name = "c",
          },
          css = {
            icon = "",
            color = colors.blue,
            name = "css",
          },
          deb = {
            icon = "",
            color = colors.cyan,
            name = "deb",
          },
          Dockerfile = {
            icon = "",
            color = colors.cyan,
            name = "Dockerfile",
          },
          html = {
            icon = "",
            color = colors.baby_pink,
            name = "html",
          },
          jpeg = {
            icon = "",
            color = colors.dark_purple,
            name = "jpeg",
          },
          jpg = {
            icon = "",
            color = colors.dark_purple,
            name = "jpg",
          },
          js = {
            icon = "",
            color = colors.sun,
            name = "js",
          },
          kt = {
            icon = "󱈙",
            color = colors.orange,
            name = "kt",
          },
          lock = {
            icon = "",
            color = colors.red,
            name = "lock",
          },
          lua = {
            icon = "",
            color = colors.blue,
            name = "lua",
          },
          mp3 = {
            icon = "",
            color = colors.white,
            name = "mp3",
          },
          mp4 = {
            icon = "",
            color = colors.white,
            name = "mp4",
          },
          out = {
            icon = "",
            color = colors.white,
            name = "out",
          },
          png = {
            icon = "",
            color = colors.dark_purple,
            name = "png",
          },
          py = {
            icon = "",
            color = colors.cyan,
            name = "py",
          },
          ["robots.txt"] = {
            icon = "ﮧ",
            color = colors.red,
            name = "robots",
          },
          toml = {
            icon = "",
            color = colors.blue,
            name = "toml",
          },
          ts = {
            icon = "ﯤ",
            color = colors.teal,
            name = "ts",
          },
          ttf = {
            icon = "",
            color = colors.white,
            name = "TrueTypeFont",
          },
          rb = {
            icon = "",
            color = colors.pink,
            name = "rb",
          },
          rpm = {
            icon = "",
            color = colors.orange,
            name = "rpm",
          },
          vue = {
            icon = "﵂",
            color = colors.vibrant_green,
            name = "vue",
          },
          woff = {
            icon = "",
            color = colors.white,
            name = "WebOpenFontFormat",
          },
          woff2 = {
            icon = "",
            color = colors.white,
            name = "WebOpenFontFormat2",
          },
          xz = {
            icon = "",
            color = colors.sun,
            name = "xz",
          },
          zip = {
            icon = "",
            color = colors.sun,
            name = "zip",
          },
        },
        -- globally enable default icons (default to false)
        -- will get overriden by `get_icons` option
        default = true,
      })
    end,
  })

  -- colorscheme
  use({
    "rose-pine/neovim",
    as = "rose-pine",
    config = function()
      require("rose-pine").setup({})
    end,
  })
  use({
    "catppuccin/nvim",
    as = "catppuccin",
    config = function()
      require("catppuccin").setup({
        transparent_background = false,
        term_colors = true,
        styles = {
          comments = "italic",
          conditionals = "italic",
          loops = "italic",
          functions = "italic",
        },
        integrations = {
          treesitter = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = "italic",
              hints = "italic",
              warnings = "italic",
              information = "italic",
            },
            underlines = {
              errors = "underline",
              hints = "underline",
              warnings = "underline",
              information = "underline",
            },
          },
          lsp_trouble = true,
          cmp = true,
          lsp_saga = true,
          gitgutter = true,
          gitsigns = true,
          telescope = true,
          nvimtree = {
            enabled = true,
            show_root = true,
            transparent_panel = false,
          },
          which_key = true,
          indent_blankline = {
            enabled = true,
            colored_indent_levels = false,
          },
          dashboard = true,
          neogit = false,
          vim_sneak = false,
          fern = false,
          barbar = false,
          bufferline = true,
          markdown = true,
          lightspeed = false,
          ts_rainbow = true,
          hop = false,
          notify = true,
          telekasten = true,
          symbols_outline = true,
        },
      })
    end,
  })

  use({ "stevearc/dressing.nvim", after = "nvim-web-devicons" })

  -- tpope
  use({ "tpope/vim-repeat" })
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
