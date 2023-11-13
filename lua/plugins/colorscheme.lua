local transparent_background = true
local clear = {}

---@alias RosePineOptions Options

return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    lazy = not (vim.g.simple_colorscheme == "rose-pine"),
    opts = function()
      ---@type RosePineOptions
      local opts = {
        disable_italics = true,
        disable_background = transparent_background,
        dark_variant = "main",
        highlight_groups = {
          Comment = { fg = "muted", italic = true },
          StatusLine = { fg = "rose", bg = "iris", blend = 10 },
          StatusLineNC = { fg = "subtle", bg = "surface" },
          TelescopeBorder = { fg = "highlight_high", bg = transparent_background and "none" or "base" },
          TelescopeNormal = { fg = "subtle", bg = "none" },
          TelescopePromptNormal = { bg = "base" },
          TelescopeResultsNormal = { fg = "subtle", bg = "none" },
          TelescopeSelection = { fg = "text", bg = "none" },
          TelescopeSelectionCaret = { fg = "rose", bg = "none" },
          WindowPickerStatusLine = { fg = "rose", bg = "iris", blend = 10 },
          WindowPickerStatusLineNC = { fg = "subtle", bg = "surface" },
          GlanceWinBarTitle = { fg = "rose", bg = "iris", blend = 10 },
          GlanceWinBarFilepath = { fg = "subtle", bg = "surface" },
          GlanceWinBarFilename = { fg = "love", bg = "surface" },
          GlancePreviewNormal = { bg = "surface" },
          GlanceListNormal = { bg = "overlay" },
          GlancePreviewMatch = { fg = "love" },
          Headline1 = { bg = "love" },
          Headline2 = { bg = "gold" },
          Headline3 = { bg = "rose" },
          Headline4 = { bg = "pine" },
          Headline5 = { bg = "foam" },
          Headline6 = { bg = "iris" },
          UfoFoldedBg = { bg = "surface" },
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
    branch = "refactor/syntax-highlighting",
    name = "catppuccin",
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
        alpha = false,
        barbar = false,
        beacon = false,
        cmp = true,
        coc_nvim = false,
        dap = { enabled = false, enable_ui = true },
        dashboard = false,
        dropbar = { enabled = true, color_mode = true },
        fern = false,
        fidget = true,
        flash = false,
        gitgutter = false,
        gitsigns = true,
        harpoon = true,
        headlines = true,
        hop = false,
        illuminate = true,
        indent_blankline = { enabled = true, colored_indent_levels = false },
        leap = true,
        lightspeed = false,
        lsp_saga = false,
        lsp_trouble = true,
        markdown = true,
        mason = true,
        mini = true,
        navic = { enabled = false },
        neogit = false,
        neotest = false,
        neotree = { enabled = true, show_root = true, transparent_panel = false },
        noice = false,
        notify = false,
        nvimtree = false,
        overseer = false,
        pounce = false,
        rainbow_delimiters = true,
        sandwich = false,
        semantic_tokens = true,
        symbols_outline = false,
        telekasten = false,
        telescope = { enabled = true, style = "nvchad" },
        treesitter_context = true,
        ts_rainbow = false,
        vim_sneak = false,
        vimwiki = false,
        which_key = true,
      },
      color_overrides = {},
      highlight_overrides = {
        ---@param cp palette
        all = function(cp)
          return {
            -- For base configs
            NormalFloat = { fg = cp.text, bg = transparent_background and cp.none or cp.mantle },
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

            -- For fidget
            FidgetTask = { bg = cp.none, fg = cp.surface2 },
            FidgetTitle = { fg = cp.blue, style = { "bold" } },

            -- For nvim-tree
            NvimTreeRootFolder = { fg = cp.pink },
            NvimTreeIndentMarker = { fg = cp.surface2 },

            -- For trouble.nvim
            TroubleNormal = { bg = transparent_background and cp.none or cp.base },

            -- For nvim-ufo
            UfoFoldedBg = { bg = transparent_background and cp.none or cp.base },

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

            -- For nvim-treehopper
            TSNodeKey = {
              fg = cp.peach,
              bg = transparent_background and cp.none or cp.base,
              style = { "bold", "underline" },
            },

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
