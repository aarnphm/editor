local config = {}

function config.rose_pine()
  require("rose-pine").setup({
    ---@usage 'main'|'moon'
    dark_variant = "main",
    bold_vert_split = false,
    dim_nc_background = false,
    disable_background = false,
    disable_float_background = false,
    disable_italics = false,
    ---@usage string hex value or named color from rosepinetheme.com/palette
    groups = {
      background = "base",
      panel = "surface",
      border = "highlight_med",
      comment = "muted",
      link = "iris",
      punctuation = "subtle",

      error = "love",
      hint = "iris",
      info = "foam",
      warn = "gold",

      headings = {
        h1 = "iris",
        h2 = "foam",
        h3 = "rose",
        h4 = "gold",
        h5 = "pine",
        h6 = "foam",
      },
      -- or set all headings at once
      -- headings = 'subtle'
    },
  })
  vim.cmd([[silent! colorscheme rose-pine]])
end

function config.tokyonight()
  require("tokyonight.colors").setup({
    tokyonight_style = "storm",
    tokyonight_italic_functions = true,
    tokyonight_sidebars = { "terminal", "packer" },
  })
  vim.cmd([[color tokyonight]])
end

function config.edge()
  vim.g.background = "light"
  vim.g.edge_style = "aura"
  vim.g.edge_enable_italic = 1
  vim.g.edge_disable_italic_comment = 1
  vim.g.edge_show_eob = 0
  vim.g.edge_better_performance = 1
  vim.g.edge_transparent_background = 0
  vim.cmd([[silent! colorscheme edge]])
end

function config.kanagawa()
  require("kanagawa").setup({
    undercurl = true, -- enable undercurls
    commentStyle = "italic",
    functionStyle = "bold,italic",
    keywordStyle = "italic",
    statementStyle = "bold",
    typeStyle = "NONE",
    variablebuiltinStyle = "italic",
    specialReturn = true, -- special highlight for the return keyword
    specialException = true, -- special highlight for exception handling keywords
    transparent = false, -- do not set background color
    dimInactive = true, -- dim inactive window `:h hl-NormalNC`
    colors = {},
    overrides = {},
  })

  vim.cmd([[silent! colorscheme kanagawa]])
end

function config.catppuccin()
  require("catppuccin").setup({
    transparent_background = false,
    term_colors = true,
    styles = {
      comments = "italic",
      functions = "italic,bold",
      keywords = "italic",
      strings = "NONE",
      variables = "NONE",
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
      lsp_saga = true,
      gitgutter = false,
      gitsigns = true,
      telescope = true,
      nvimtree = { enabled = false, show_root = false },
      which_key = true,
      indent_blankline = { enabled = true, colored_indent_levels = false },
      dashboard = true,
      neogit = false,
      vim_sneak = false,
      fern = false,
      bufferline = true,
      markdown = true,
      lightspeed = false,
      ts_rainbow = true,
    },
  })
  vim.cmd([[silent! colorscheme catppuccin]])
end

return config
