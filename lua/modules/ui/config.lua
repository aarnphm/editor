local config = {}

function config.lualine()
  local symbols_outline = {
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = { "filetype", "location" },
      lualine_z = { "mode" },
    },
    filetypes = { "Outline" },
  }

  require("lualine").setup({
    options = {
      icons_enabled = true,
      theme = "auto",
      disabled_filetypes = {},
      component_separators = "|",
      section_separators = { left = " ", right = " " },
    },
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = { error = "  ", warn = "  ", info = " " },
        },
      },
      lualine_y = { "filetype", "branch", "diff", "location", { "fileformat", padding = 1 } },
      lualine_z = { "mode" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    extensions = {
      "quickfix",
      "toggleterm",
      "fugitive",
      symbols_outline,
    },
  })
end

function config.nvim_tree()
  require("nvim-tree").setup({
    hide_root_folder = true,
    disable_netrw = true,
    hijack_netrw = true,
    open_on_setup = false,
    ignore_ft_on_setup = {},
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
    filters = { dotfiles = false, custom = {} },
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
    trash = { cmd = "rip", require_confirm = true },
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
      ["n <LocalLeader>]g"] = {
        expr = true,
        "&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'",
      },
      ["n <LocalLeader>[g"] = {
        expr = true,
        "&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'",
      },
      ["n <LocalLeader>hs"] = '<cmd>lua require("gitsigns").stage_hunk()<CR>',
      ["v <LocalLeader>hs"] = '<cmd>lua require("gitsigns").stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
      ["n <LocalLeader>hu"] = '<cmd>lua require("gitsigns").undo_stage_hunk()<CR>',
      ["n <LocalLeader>hr"] = '<cmd>lua require("gitsigns").reset_hunk()<CR>',
      ["v <LocalLeader>hr"] = '<cmd>lua require("gitsigns").reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
      ["n <LocalLeader>hR"] = '<cmd>lua require("gitsigns").reset_buffer()<CR>',
      ["n <LocalLeader>hp"] = '<cmd>lua require("gitsigns").preview_hunk()<CR>',
      ["n <LocalLeader>hb"] = '<cmd>lua require("gitsigns").blame_line(true)<CR>',
      -- Text objects
      ["o ih"] = ':<C-U>lua require("gitsigns").text_object()<CR>',
      ["x ih"] = ':<C-U>lua require("gitsigns").text_object()<CR>',
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
    show_trailing_blankline_indent = true,
    show_current_context_start = true,
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
  vim.cmd("autocmd CursorMoved * IndentBlanklineRefresh")
end

return config
