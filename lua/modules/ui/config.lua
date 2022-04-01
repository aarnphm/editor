local config = {}

function config.feline()
  -- refers to nvchad's feline config
  local present, feline = pcall(require, "feline")
  if not present then
    return
  end

  local default = {
    colors = require("themes").get(),
    lsp = require("feline.providers.lsp"),
    lsp_severity = vim.diagnostic.severity,
    config = {
      style = "default", -- default, round , slant , block , arrow
      shortline = true,
    },
  }

  default.icon_styles = {
    default = {
      left = "",
      right = " ",
      main_icon = "  ",
      vi_mode_icon = " ",
      position_icon = " ",
    },
    arrow = {
      left = "",
      right = "",
      main_icon = "  ",
      vi_mode_icon = " ",
      position_icon = " ",
    },

    block = {
      left = " ",
      right = " ",
      main_icon = "   ",
      vi_mode_icon = "  ",
      position_icon = "  ",
    },

    round = {
      left = "",
      right = "",
      main_icon = "  ",
      vi_mode_icon = " ",
      position_icon = " ",
    },

    slant = {
      left = " ",
      right = " ",
      main_icon = "  ",
      vi_mode_icon = " ",
      position_icon = " ",
    },
  }

  -- statusline style
  default.statusline_style = default.icon_styles[default.config.style]

  -- show short statusline on small screens
  default.shortline = default.config.shortline == false and true

  -- Initialize the components table
  default.components = {
    active = {},
  }

  default.main_icon = {
    provider = default.statusline_style.main_icon,

    hl = {
      fg = default.colors.statusline_bg,
      bg = default.colors.nord_blue,
    },

    right_sep = {
      str = default.statusline_style.right,
      hl = {
        fg = default.colors.nord_blue,
        bg = default.colors.lightbg,
      },
    },
  }

  default.file_name = {
    provider = function()
      local filename = vim.fn.expand("%:t")
      local extension = vim.fn.expand("%:e")
      local icon = require("nvim-web-devicons").get_icon(filename, extension)
      if icon == nil then
        icon = " "
        return icon
      end
      return " " .. icon .. " " .. filename .. " "
    end,
    enabled = default.shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 70
    end,
    hl = {
      fg = default.colors.white,
      bg = default.colors.lightbg,
    },

    right_sep = {
      str = default.statusline_style.right,
      hl = { fg = default.colors.lightbg, bg = default.colors.lightbg2 },
    },
  }

  default.dir_name = {
    provider = function()
      local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
      return "  " .. dir_name .. " "
    end,

    enabled = default.shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 80
    end,

    hl = {
      fg = default.colors.grey_fg2,
      bg = default.colors.lightbg2,
    },
    right_sep = {
      str = default.statusline_style.right,
      hi = {
        fg = default.colors.lightbg2,
        bg = default.colors.statusline_bg,
      },
    },
  }

  default.diff = {
    add = {
      provider = "git_diff_added",
      hl = {
        fg = default.colors.grey_fg2,
        bg = default.colors.statusline_bg,
      },
      icon = " ",
    },

    change = {
      provider = "git_diff_changed",
      hl = {
        fg = default.colors.grey_fg2,
        bg = default.colors.statusline_bg,
      },
      icon = "  ",
    },

    remove = {
      provider = "git_diff_removed",
      hl = {
        fg = default.colors.grey_fg2,
        bg = default.colors.statusline_bg,
      },
      icon = "  ",
    },
  }

  default.git_branch = {
    provider = "git_branch",
    enabled = default.shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 70
    end,
    hl = {
      fg = default.colors.grey_fg2,
      bg = default.colors.statusline_bg,
    },
    icon = "  ",
  }

  default.diagnostic = {
    error = {
      provider = "diagnostic_errors",
      enabled = function()
        return default.lsp.diagnostics_exist(default.lsp_severity.ERROR)
      end,

      hl = { fg = default.colors.red },
      icon = "  ",
    },

    warning = {
      provider = "diagnostic_warnings",
      enabled = function()
        return default.lsp.diagnostics_exist(default.lsp_severity.WARN)
      end,
      hl = { fg = default.colors.yellow },
      icon = "  ",
    },

    hint = {
      provider = "diagnostic_hints",
      enabled = function()
        return default.lsp.diagnostics_exist(default.lsp_severity.HINT)
      end,
      hl = { fg = default.colors.grey_fg2 },
      icon = "  ",
    },

    info = {
      provider = "diagnostic_info",
      enabled = function()
        return default.lsp.diagnostics_exist(default.lsp_severity.INFO)
      end,
      hl = { fg = default.colors.green },
      icon = "  ",
    },
  }

  default.lsp_progress = {
    provider = function()
      local Lsp = vim.lsp.util.get_progress_messages()[1]

      if Lsp then
        local msg = Lsp.message or ""
        local percentage = Lsp.percentage or 0
        local title = Lsp.title or ""
        local spinners = {
          "",
          "",
          "",
        }

        local success_icon = {
          "",
          "",
          "",
        }

        local ms = vim.loop.hrtime() / 1000000
        local frame = math.floor(ms / 120) % #spinners

        if percentage >= 70 then
          return string.format(" %%<%s %s %s (%s%%%%) ", success_icon[frame + 1], title, msg, percentage)
        end

        return string.format(" %%<%s %s %s (%s%%%%) ", spinners[frame + 1], title, msg, percentage)
      end

      return ""
    end,
    enabled = default.shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 80
    end,
    hl = { fg = default.colors.green },
  }

  default.lsp_icon = {
    provider = function()
      if next(vim.lsp.buf_get_clients()) ~= nil then
        return "  LSP"
      else
        return ""
      end
    end,
    enabled = default.shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 70
    end,
    hl = { fg = default.colors.grey_fg2, bg = default.colors.statusline_bg },
  }

  default.mode_colors = {
    ["n"] = { "NORMAL", default.colors.red },
    ["no"] = { "N-PENDING", default.colors.red },
    ["i"] = { "INSERT", default.colors.dark_purple },
    ["ic"] = { "INSERT", default.colors.dark_purple },
    ["t"] = { "TERMINAL", default.colors.green },
    ["v"] = { "VISUAL", default.colors.cyan },
    ["V"] = { "V-LINE", default.colors.cyan },
    [""] = { "V-BLOCK", default.colors.cyan },
    ["R"] = { "REPLACE", default.colors.orange },
    ["Rv"] = { "V-REPLACE", default.colors.orange },
    ["s"] = { "SELECT", default.colors.nord_blue },
    ["S"] = { "S-LINE", default.colors.nord_blue },
    [""] = { "S-BLOCK", default.colors.nord_blue },
    ["c"] = { "COMMAND", default.colors.pink },
    ["cv"] = { "COMMAND", default.colors.pink },
    ["ce"] = { "COMMAND", default.colors.pink },
    ["r"] = { "PROMPT", default.colors.teal },
    ["rm"] = { "MORE", default.colors.teal },
    ["r?"] = { "CONFIRM", default.colors.teal },
    ["!"] = { "SHELL", default.colors.green },
  }

  default.chad_mode_hl = function()
    return {
      fg = default.mode_colors[vim.fn.mode()][2],
      bg = default.colors.one_bg,
    }
  end

  default.empty_space = {
    provider = " " .. default.statusline_style.left,
    hl = {
      fg = default.colors.one_bg2,
      bg = default.colors.statusline_bg,
    },
  }

  -- this matches the vi mode color
  default.empty_spaceColored = {
    provider = default.statusline_style.left,
    hl = function()
      return {
        fg = default.mode_colors[vim.fn.mode()][2],
        bg = default.colors.one_bg2,
      }
    end,
  }

  default.mode_icon = {
    provider = default.statusline_style.vi_mode_icon,
    hl = function()
      return {
        fg = default.colors.statusline_bg,
        bg = default.mode_colors[vim.fn.mode()][2],
      }
    end,
  }

  default.empty_space2 = {
    provider = function()
      return " " .. default.mode_colors[vim.fn.mode()][1] .. " "
    end,
    hl = default.chad_mode_hl,
  }

  default.separator_right = {
    provider = default.statusline_style.left,
    enabled = default.shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 90
    end,
    hl = {
      fg = default.colors.grey,
      bg = default.colors.one_bg,
    },
  }

  default.separator_right2 = {
    provider = default.statusline_style.left,
    enabled = default.shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 90
    end,
    hl = {
      fg = default.colors.green,
      bg = default.colors.grey,
    },
  }

  default.position_icon = {
    provider = default.statusline_style.position_icon,
    enabled = default.shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 90
    end,
    hl = {
      fg = default.colors.black,
      bg = default.colors.green,
    },
  }

  default.current_line = {
    provider = function()
      local current_line = vim.fn.line(".")
      local total_line = vim.fn.line("$")

      if current_line == 1 then
        return " Top "
      elseif current_line == vim.fn.line("$") then
        return " Bot "
      end
      local result, _ = math.modf((current_line / total_line) * 100)
      return " " .. result .. "%% "
    end,

    enabled = default.shortline or function(winid)
      return vim.api.nvim_win_get_width(tonumber(winid) or 0) > 90
    end,

    hl = {
      fg = default.colors.green,
      bg = default.colors.one_bg,
    },
  }

  local function add_table(a, b)
    table.insert(a, b)
  end

  -- components are divided in 3 sections
  default.left = {}
  default.middle = {}
  default.right = {}

  -- left
  add_table(default.left, default.main_icon)
  add_table(default.left, default.file_name)
  add_table(default.left, default.dir_name)
  add_table(default.left, default.diff.add)
  add_table(default.left, default.diff.change)
  add_table(default.left, default.diff.remove)
  add_table(default.left, default.diagnostic.error)
  add_table(default.left, default.diagnostic.warning)
  add_table(default.left, default.diagnostic.hint)
  add_table(default.left, default.diagnostic.info)

  add_table(default.middle, default.lsp_progress)

  -- right
  add_table(default.right, default.lsp_icon)
  add_table(default.right, default.git_branch)
  add_table(default.right, default.empty_space)
  add_table(default.right, default.empty_spaceColored)
  add_table(default.right, default.mode_icon)
  add_table(default.right, default.empty_space2)
  add_table(default.right, default.separator_right)
  add_table(default.right, default.separator_right2)
  add_table(default.right, default.position_icon)
  add_table(default.right, default.current_line)

  default.components.active[1] = default.left
  default.components.active[2] = default.middle
  default.components.active[3] = default.right

  feline.setup({
    theme = {
      bg = default.colors.statusline_bg,
      fg = default.colors.fg,
    },
    components = default.components,
  })
end

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
  vim.g.nvim_tree_root_folder_modifier = table.concat({ ":t:gs?$?/..", string.rep(" ", 1000), "?:gs?^??" })
  require("nvim-tree").setup({
    hide_root_folder = true,
    disable_netrw = true,
    hijack_netrw = true,
    open_on_setup = false,
    open_on_tab = false,
    ignore_ft_on_setup = { "dashboard" },
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
      hide_root_folder = true,
      side = "left",
      auto_resize = false,
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
