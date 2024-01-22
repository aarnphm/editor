local transparent_background = true
local clear = {}

return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    lazy = not (vim.g.simple_colorscheme == "rose-pine"),
    opts = function()
      local opts = {
        dark_variant = "main",
        dim_inactive_windows = true,
        styles = { transparency = not transparent_background },
        highlight_groups = {
          Comment = { fg = "muted", italic = true },
          StatusLine = { fg = "rose", bg = "overlay", blend = 10 },
          StatusLineNC = { fg = "subtle", bg = "overlay" },
          WinBar = { fg = "rose", bg = "overlay", blend = 10 },
          WinBarNC = { fg = "subtle", bg = "overlay" },
          --- nvim-window-picker.nvim
          WindowPickerStatusLine = { fg = "rose", bg = "iris", blend = 10 },
          WindowPickerStatusLineNC = { fg = "subtle", bg = "surface" },
          --- glance.nvim
          GlanceWinBarTitle = { fg = "rose", bg = "iris", blend = 10 },
          GlanceWinBarFilepath = { fg = "subtle", bg = "surface" },
          GlanceWinBarFilename = { fg = "love", bg = "surface" },
          GlancePreviewNormal = { bg = "surface" },
          GlanceListNormal = { bg = "overlay" },
          GlancePreviewMatch = { fg = "love" },
          --- headlines.nvim
          Headline1 = { bg = "surface" },
          Headline2 = { bg = "gold" },
          Headline3 = { bg = "rose" },
          Headline4 = { bg = "pine" },
          Headline5 = { bg = "foam" },
          Headline6 = { bg = "iris" },
        },
      }
      if vim.g.simple_background == "light" then
        opts.highlight_groups = vim.tbl_extend("force", opts.highlight_groups, { IblScope = { fg = "rose" } })
      end
      return opts
    end,
  },
  {
    "Jint-lzxy/nvim",
    priority = 1000,
    name = "catppuccin",
    version = false,
    branch = "refactor/syntax-highlighting",
    lazy = not (vim.g.simple_colorscheme == "catppuccin"),
    opts = {
      flavour = vim.g.simple_background == "light" and "latte" or "mocha", -- Can be one of: latte, frappe, macchiato, mocha
      background = { light = "latte", dark = "mocha" },
      dim_inactive = {
        enabled = false,
        -- Dim inactive splits/windows/buffers.
        -- NOT recommended if you use old palette (a.k.a., mocha).
        shade = "dark",
        percentage = 0.5,
      },
      transparent_background = transparent_background,
      show_end_of_buffer = false, -- show the '~' characters after the end of buffers
      term_colors = true,
      compile_path = vim.fn.stdpath "cache" .. "/catppuccin",
      styles = {
        comments = { "italic" },
        properties = { "italic" },
        functions = { "bold" },
        keywords = { "italic" },
        operators = { "bold" },
        conditionals = { "bold" },
        loops = { "bold" },
        booleans = { "bold", "italic" },
        numbers = {},
        types = {},
        strings = {},
        variables = {},
      },
      integrations = {
        treesitter = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
        aerial = true,
        cmp = true,
        dropbar = { enabled = true, color_mode = true },
        fidget = true,
        gitsigns = true,
        harpoon = true,
        headlines = true,
        ufo = true,
        illuminate = true,
        indent_blankline = { enabled = true, colored_indent_levels = true },
        leap = true,
        markdown = true,
        mason = true,
        mini = true,
        semantic_tokens = true,
        telescope = { enabled = true, style = "nvchad" },
        treesitter_context = true,
        which_key = true,
      },
      color_overrides = {},
      highlight_overrides = {
        ---@param cp palette
        all = function(cp)
          return {
            -- For base configs
            -- NormalFloat = { fg = cp.text, bg = transparent_background and cp.none or cp.mantle },
            NormalFloat = { fg = cp.text, bg = cp.none },
            FloatBorder = {
              fg = transparent_background and cp.blue or cp.mantle,
              bg = transparent_background and cp.none or cp.mantle,
            },
            CursorLineNr = { fg = cp.green },

            -- For native lsp configs
            DiagnosticVirtualTextError = { bg = cp.none },
            DiagnosticVirtualTextWarn = { bg = cp.none },
            DiagnosticVirtualTextInfo = { bg = cp.none },
            DiagnosticVirtualTextHint = { bg = cp.none },
            LspInfoBorder = { link = "FloatBorder" },

            -- For mason.nvim
            MasonNormal = { link = "NormalFloat" },

            -- For indent-blankline
            IblIndent = { fg = cp.surface0 },
            IblScope = { fg = cp.surface2, style = { "bold" } },

            -- For nvim-window-picker
            WindowPickerStatusLine = { fg = cp.surface0, blend = 10 },
            WindowPickerStatusLineNC = { fg = cp.surface2 },

            -- For telescope.nvim
            TelescopeMatching = { fg = cp.lavender },
            TelescopeResultsDiffAdd = { fg = cp.green },
            TelescopeResultsDiffChange = { fg = cp.yellow },
            TelescopeResultsDiffDelete = { fg = cp.red },

            -- For glance.nvim
            GlanceWinBarFilename = { fg = cp.subtext1, style = { "bold" } },
            GlanceWinBarFilepath = { fg = cp.subtext0, style = { "italic" } },
            GlanceWinBarTitle = { fg = cp.teal, style = { "bold" } },
            GlanceListCount = { fg = cp.lavender },
            GlanceListFilepath = { link = "Comment" },
            GlanceListFilename = { fg = cp.blue },
            GlanceListMatch = { fg = cp.lavender, style = { "bold" } },
            GlanceFoldIcon = { fg = cp.green },

            -- For treesitter
            ["@keyword.return"] = { fg = cp.pink, style = clear },
            ["@error.c"] = { fg = cp.none, style = clear },
            ["@error.cpp"] = { fg = cp.none, style = clear },
          }
        end,
      },
    },
  },
}
