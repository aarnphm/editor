local config = {}

function config.edge()
  vim.cmd([[set background=light]])
  vim.g.edge_style = "neon"
  vim.g.edge_enable_italic = 1
  vim.g.edge_disable_italic_comment = 1
  vim.g.edge_show_eob = 0
  vim.g.edge_better_performance = 1
  vim.g.edge_transparent_background = 0
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
      nvimtree = { enabled = true, show_root = true },
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
end

function config.lualine()
  local gps = require("nvim-gps")

  local function gps_content()
    if gps.is_available() then
      return gps.get_location()
    else
      return ""
    end
  end
  local mini_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "location" },
  }
  local minimap = {
    sections = mini_sections,
    filetypes = { "minimap" },
  }
  local symbols_outline = {
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "filetype" },
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { "location" },
    },
    filetypes = { "Outline" },
  }

  require("lualine").setup({
    options = {
      icons_enabled = true,
      theme = "auto",
      disabled_filetypes = {},
      component_separators = "|",
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { { "branch" }, { "diff" } },
      lualine_c = {
        { "lsp_progress" },
        { gps_content, cond = gps.is_available },
      },
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = { error = " ", warn = " ", info = " " },
        },
      },
      lualine_y = { "filetype", "encoding", "fileformat" },
      lualine_z = { "progress", "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    extensions = {
      "quickfix",
      "nvim-tree",
      "toggleterm",
      "fugitive",
      minimap,
      symbols_outline,
    },
  })
end

function config.nvim_gps()
  require("nvim-gps").setup({
    icons = {
      ["class-name"] = " ", -- Classes and class-like objects
      ["function-name"] = " ", -- Functions
      ["method-name"] = " ", -- Methods (functions inside class-like objects)
    },
    languages = {
      -- You can disable any language individually here
      ["c"] = true,
      ["cpp"] = true,
      ["go"] = true,
      ["java"] = true,
      ["javascript"] = true,
      ["lua"] = true,
      ["python"] = true,
      ["rust"] = true,
    },
    separator = " > ",
  })
end

function config.nvim_tree()
  require("nvim-tree").setup({
    disable_netrw = true,
    hijack_netrw = true,
    open_on_setup = true,
    ignore_ft_on_setup = {},
    auto_close = true,
    auto_reload_on_write = true,
    open_on_tab = false,
    hijack_cursor = true,
    update_cwd = false,
    update_to_buf_dir = { enable = true, auto_open = true },
    diagnostics = {
      enable = false,
      icons = { hint = "", info = "", warning = "", error = "" },
    },
    update_focused_file = {
      enable = true,
      update_cwd = true,
      ignore_list = {},
    },
    system_open = { cmd = nil, args = {} },
    filters = { dotfiles = true, custom = {} },
    git = { enable = true, ignore = true, timeout = 500 },
    view = {
      width = 30,
      height = 30,
      hide_root_folder = false,
      side = "left",
      auto_resize = false,
      mappings = { custom_only = false, list = {} },
      number = false,
      relativenumber = false,
      signcolumn = "yes",
    },
    trash = { cmd = "trash", require_confirm = true },
  })
end

function config.gitsigns()
  require("gitsigns").setup({
    signs = {
      add = {
        hl = "GitSignsAdd",
        text = "│",
        numhl = "GitSignsAddNr",
        linehl = "GitSignsAddLn",
      },
      change = {
        hl = "GitSignsChange",
        text = "│",
        numhl = "GitSignsChangeNr",
        linehl = "GitSignsChangeLn",
      },
      delete = {
        hl = "GitSignsDelete",
        text = "_",
        numhl = "GitSignsDeleteNr",
        linehl = "GitSignsDeleteLn",
      },
      topdelete = {
        hl = "GitSignsDelete",
        text = "‾",
        numhl = "GitSignsDeleteNr",
        linehl = "GitSignsDeleteLn",
      },
      changedelete = {
        hl = "GitSignsChange",
        text = "~",
        numhl = "GitSignsChangeNr",
        linehl = "GitSignsChangeLn",
      },
    },
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,
      ["n <leader>]g"] = {
        expr = true,
        "&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'",
      },
      ["n <leader>[g"] = {
        expr = true,
        "&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'",
      },
      ["n <leader>hs"] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
      ["v <leader>hs"] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
      ["n <leader>hu"] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
      ["n <leader>hr"] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
      ["v <leader>hr"] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
      ["n <leader>hR"] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
      ["n <leader>hp"] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
      ["n <leader>hb"] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',
      -- Text objects
      ["o ih"] = ':<C-U>lua require"gitsigns".text_object()<CR>',
      ["x ih"] = ':<C-U>lua require"gitsigns".text_object()<CR>',
    },
    watch_gitdir = { interval = 1000, follow_files = true },
    current_line_blame = true,
    current_line_blame_opts = { delay = 1000, virtual_text_pos = "eol" },
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    word_diff = false,
    diff_opts = { internal = true },
  })
end

function config.nvim_bufferline()
  require("bufferline").setup({
    options = {
      number = "none",
      modified_icon = "✥",
      buffer_close_icon = "",
      left_trunc_marker = "",
      right_trunc_marker = "",
      max_name_length = 14,
      max_prefix_length = 13,
      tab_size = 20,
      show_buffer_close_icons = true,
      show_buffer_icons = true,
      show_tab_indicators = true,
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
      separator_style = "thin",
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          text_align = "center",
          padding = 1,
        },
      },
    },
  })
end

function config.indent_blankline()
  vim.opt.termguicolors = true
  vim.opt.list = true
  require("indent_blankline").setup({
    char = "│",
    show_first_indent_level = true,
    filetype_exclude = {
      "startify",
      "dashboard",
      "dotooagenda",
      "log",
      "fugitive",
      "gitcommit",
      "packer",
      "vimwiki",
      "markdown",
      "json",
      "txt",
      "vista",
      "help",
      "todoist",
      "NvimTree",
      "peekaboo",
      "git",
      "TelescopePrompt",
      "undotree",
      "flutterToolsOutline",
      "", -- for all buffers without a file type
    },
    buftype_exclude = { "terminal", "nofile" },
    show_trailing_blankline_indent = false,
    show_current_context = true,
    context_patterns = {
      "class",
      "function",
      "method",
      "block",
      "list_literal",
      "selector",
      "^if",
      "^table",
      "if_statement",
      "while",
      "for",
      "type",
      "var",
      "import",
    },
    space_char_blankline = " ",
  })
  -- because lazy load indent-blankline so need readd this autocmd
  -- vim.cmd("autocmd CursorMoved * IndentBlanklineRefresh")
end

return config
