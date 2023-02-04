local config = {}

config.bigfile = function()
  local cmp = {
    name = "nvim-cmp",
    opts = { defer = false },
    disable = function()
      require("cmp").setup.buffer({ enabled = false })
    end,
  }

  require("bigfile").config({
    filesize = 1, -- size of the file in MiB
    pattern = { "*" }, -- autocmd pattern
    features = { -- features to disable
      "indent_blankline",
      "lsp",
      "illuminate",
      "treesitter",
      "syntax",
      "vimopts",
      cmp,
    },
  })
end

config.nvim_treesitter = function()
  vim.api.nvim_set_option_value("foldmethod", "expr", {})
  vim.api.nvim_set_option_value("foldexpr", "nvim_treesitter#foldexpr()", {})

  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "lua",
      "python",
      "c",
      "go",
      "bash",
      "markdown",
      "typescript",
      "cpp",
      "terraform",
      "make",
      "rust",
    },
    ignore_install = { "phpdoc" },
    highlight = {
      enable = true,
      disable = function(ft, bufnr)
        if vim.tbl_contains({ "vim", "help" }, ft) then
          return true
        end

        local ok, is_large_file = pcall(vim.api.nvim_buf_get_var, bufnr, "bigfile_disable_treesitter")
        return ok and is_large_file
      end,
      additional_vim_regex_highlighting = false,
    },
    context_commentstring = { enable = true, enable_autocmd = false },
    matchup = { enable = true },
    lsp_interop = {
      enable = true,
      border = "none",
      peek_definition_code = {
        ["<leader>sd"] = "@function.outer",
        ["<leader>sD"] = "@class.outer",
      },
    },
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]["] = "@function.outer",
          ["]m"] = "@class.outer",
        },
        goto_next_end = {
          ["]]"] = "@function.outer",
          ["]M"] = "@class.outer",
        },
        goto_previous_start = {
          ["[["] = "@function.outer",
          ["[m"] = "@class.outer",
        },
        goto_previous_end = {
          ["[]"] = "@function.outer",
          ["[M"] = "@class.outer",
        },
      },
    },
    rainbow = {
      enable = true,
      extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
      max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
    },
  })

  require("nvim-treesitter.install").prefer_git = true
  local parsers = require("nvim-treesitter.parsers")
  local parsers_config = parsers.get_parser_configs()
  for _, p in pairs(parsers_config) do
    p.install_info.url = p.install_info.url:gsub("https://github.com/", "git@github.com:")
  end

  -- use with octo.nvim
  parsers.filetype_to_parsername.octo = "markdown"
end

config.illuminate = function()
  require("illuminate").configure({
    providers = {
      "lsp",
      "treesitter",
      "regex",
    },
    delay = 100,
    filetypes_denylist = {
      "alpha",
      "dashboard",
      "DoomInfo",
      "fugitive",
      "help",
      "norg",
      "NvimTree",
      "Outline",
      "toggleterm",
    },
    under_cursor = false,
  })
end

config.auto_session = function()
  local sessions_dir = vim.fn.stdpath("data") .. "/sessions/"
  local opts = {
    log_level = "info",
    auto_session_enable_last_session = true,
    auto_session_root_dir = sessions_dir,
    auto_session_enabled = true,
    auto_save_enabled = true,
    auto_restore_enabled = true,
    auto_session_suppress_dirs = nil,
  }

  require("auto-session").setup(opts)
end

config.autotag = function()
  require("nvim-ts-autotag").setup({
    filetypes = {
      "html",
      "xml",
      "javascript",
      "typescriptreact",
      "javascriptreact",
      "vue",
    },
  })
end

config.toggleterm = function()
  require("toggleterm").setup({
    -- size can be a number or function which is passed the current terminal
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.41
      end
    end,
    open_mapping = [[<C-t>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = false,
    shading_factor = "1", -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    persist_size = true,
    direction = "vertical",
    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
  })
end

config.spectre = function()
  require("spectre").setup({

    color_devicons = true,
    open_cmd = "vnew",
    live_update = true, -- auto excute search again when you write any file in vim
    mapping = {
      ["toggle_line"] = {
        map = "dd",
        cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
        desc = "toggle current item",
      },
      ["enter_file"] = {
        map = "<cr>",
        cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
        desc = "goto current file",
      },
      ["send_to_qf"] = {
        map = "<leader>q",
        cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
        desc = "send all item to quickfix",
      },
      ["replace_cmd"] = {
        map = "<leader>c",
        cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
        desc = "input replace vim command",
      },
      ["show_option_menu"] = {
        map = "<leader>o",
        cmd = "<cmd>lua require('spectre').show_options()<CR>",
        desc = "show option",
      },
      ["run_replace"] = {
        map = "<leader>R",
        cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
        desc = "replace all",
      },
      ["change_view_mode"] = {
        map = "<leader>v",
        cmd = "<cmd>lua require('spectre').change_view()<CR>",
        desc = "change result view mode",
      },
      ["toggle_live_update"] = {
        map = "tu",
        cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
        desc = "update change when vim write file.",
      },
      ["toggle_ignore_case"] = {
        map = "ti",
        cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
        desc = "toggle ignore case",
      },
      ["toggle_ignore_hidden"] = {
        map = "th",
        cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
        desc = "toggle search hidden",
      },
      -- you can put your mapping here it only use normal mode
    },
    find_engine = {
      -- rg is map with finder_cmd
      ["rg"] = {
        cmd = "rg",
        -- default args
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        options = {
          ["ignore-case"] = {
            value = "--ignore-case",
            icon = "[I]",
            desc = "ignore case",
          },
          ["hidden"] = {
            value = "--hidden",
            desc = "hidden file",
            icon = "[H]",
          },
          -- you can put any rg search option you want here it can toggle with
          -- show_option function
        },
      },
      ["ag"] = {
        cmd = "ag",
        args = {
          "--vimgrep",
          "-s",
        },
        options = {
          ["ignore-case"] = {
            value = "-i",
            icon = "[I]",
            desc = "ignore case",
          },
          ["hidden"] = {
            value = "--hidden",
            desc = "hidden file",
            icon = "[H]",
          },
        },
      },
    },
    replace_engine = {
      ["sed"] = {
        cmd = "sed",
        args = nil,
      },
      options = {
        ["ignore-case"] = {
          value = "--ignore-case",
          icon = "[I]",
          desc = "ignore case",
        },
      },
    },
    default = {
      find = {
        --pick one of item in find_engine
        cmd = "rg",
        options = { "ignore-case" },
      },
      replace = {
        --pick one of item in replace_engine
        cmd = "sed",
      },
    },
    replace_vim_cmd = "cdo",
    is_open_target_win = true, --open file on opener window
    is_insert_mode = false, -- start open panel on is_insert_mode
  })
end

config.telescope = function()
  local icons = { ui = require("utils.icons").get("ui", true) }
  local telescope_actions = require("telescope.actions.set")
  local fixfolds = {
    hidden = true,
    attach_mappings = function(_)
      telescope_actions.select:enhance({
        post = function()
          vim.api.nvim_command([[:normal! zx"]])
        end,
      })
      return true
    end,
  }

  require("telescope").setup({
    defaults = {
      initial_mode = "insert",
      prompt_prefix = " " .. icons.ui.Telescope .. " ",
      selection_caret = icons.ui.ChevronRight,
      entry_prefix = " ",
      borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      scroll_strategy = "limit",
      layout_strategy = "horizontal",
      path_display = { "absolute" },
      results_title = false,
      mappings = {
        i = {
          ["<C-a>"] = { "<esc>0i", type = "command" },
          ["<Esc>"] = require("telescope.actions").close,
        },
        n = { ["q"] = require("telescope.actions").close },
      },
      layout_config = {
        horizontal = {
          preview_width = 0.5,
        },
      },
      file_ignore_patterns = {
        "static_content",
        "node_modules",
        ".git/",
        ".cache",
        "%.class",
        "%.pdf",
        "%.mkv",
        "%.mp4",
        "%.zip",
      },
      file_sorter = require("telescope.sorters").get_fuzzy_file,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
      buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
    },
    extensions = {
      fzf = {
        fuzzy = false,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
      frecency = {
        show_scores = true,
        show_unindexed = true,
        ignore_patterns = { "*.git/*", "*/tmp/*" },
      },
    },
    pickers = {
      buffers = fixfolds,
      find_files = fixfolds,
      git_files = fixfolds,
      grep_string = fixfolds,
      live_grep = {
        on_input_filter_cb = function(prompt)
          -- AND operator for live_grep like how fzf handles spaces with wildcards in rg
          return { prompt = prompt:gsub("%s", ".*") }
        end,
        attach_mappings = function(_)
          telescope_actions.select:enhance({
            post = function()
              vim.cmd(":normal! zx")
            end,
          })
          return true
        end,
      },
      oldfiles = fixfolds,
      diagnostics = {
        initial_mode = "normal",
      },
      lsp_references = {
        theme = "cursor",
        initial_mode = "normal",
        layout_config = {
          width = 0.8,
          height = 0.4,
        },
      },
      lsp_code_actions = {
        theme = "cursor",
        initial_mode = "normal",
      },
    },
  })

  require("telescope").load_extension("fzf")
  require("telescope").load_extension("zoxide")
  require("telescope").load_extension("frecency")
  require("telescope").load_extension("emoji")
end

config.octo = function()
  require("octo").setup({ default_remote = { "upstream", "origin" } })
end

config.trouble = function()
  local icons = {
    ui = require("utils.icons").get("ui"),
    diagnostics = require("utils.icons").get("diagnostics"),
  }

  require("trouble").setup({
    position = "bottom", -- position of the list can be: bottom, top, left, right
    height = 10, -- height of the trouble list when position is top or bottom
    width = 50, -- width of the list when position is left or right
    icons = true, -- use devicons for filenames
    mode = "document_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
    fold_open = icons.ui.ArrowOpen, -- icon used for open folds
    fold_closed = icons.ui.ArrowClosed, -- icon used for closed folds
    group = true, -- group results by file
    padding = true, -- add an extra new line on top of the list
    action_keys = {
      -- key mappings for actions in the trouble list
      -- map to {} to remove a mapping, for example:
      -- close = {},
      close = "q", -- close the list
      cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
      refresh = "r", -- manually refresh
      jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
      open_split = { "<c-x>" }, -- open buffer in new split
      open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
      open_tab = { "<c-t>" }, -- open buffer in new tab
      jump_close = { "o" }, -- jump to the diagnostic and close the list
      toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
      toggle_preview = "P", -- toggle auto_preview
      hover = "K", -- opens a small popup with the full multiline message
      preview = "p", -- preview the diagnostic location
      close_folds = { "zM", "zm" }, -- close all folds
      open_folds = { "zR", "zr" }, -- open all folds
      toggle_fold = { "zA", "za" }, -- toggle fold of current file
      previous = "k", -- preview item
      next = "j", -- next item
    },
    indent_lines = true, -- add an indent guide below the fold icons
    auto_open = false, -- automatically open the list when you have diagnostics
    auto_close = false, -- automatically close the list when you have no diagnostics
    auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
    auto_fold = false, -- automatically fold a file trouble list at creation
    auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
    signs = {
      -- icons / text used for a diagnostic
      error = icons.diagnostics.Error_alt,
      warning = icons.diagnostics.Warning_alt,
      hint = icons.diagnostics.Hint_alt,
      information = icons.diagnostics.Information_alt,
      other = icons.diagnostics.Question_alt,
    },
    use_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
  })
end

config.cheatsheet = function()
  require("cheatsheet").setup({
    -- Whether to show bundled cheatsheets
    bundled_cheatsheets = true,
    bundled_plugin_cheatsheets = true,
    include_only_installed_plugins = true,

    -- Key mappings bound inside the telescope window
    telescope_mappings = {
      ["<CR>"] = require("cheatsheet.telescope.actions").select_or_fill_commandline,
      ["<A-CR>"] = require("cheatsheet.telescope.actions").select_or_execute,
      ["<C-Y>"] = require("cheatsheet.telescope.actions").copy_cheat_value,
      ["<C-E>"] = require("cheatsheet.telescope.actions").edit_user_cheatsheet,
    },
  })
end

config.wilder = function()
  local wilder = require("wilder")
  wilder.setup({ modes = { ":", "/", "?" } })
  wilder.set_option("use_python_remote_plugin", 0)
  wilder.set_option("pipeline", {
    wilder.branch(
      wilder.cmdline_pipeline({ use_python = 0, fuzzy = 1, fuzzy_filter = wilder.lua_fzy_filter() }),
      wilder.vim_search_pipeline(),
      {
        wilder.check(function(ctx, x)
          return x == ""
        end),
        wilder.history(),
        wilder.result({
          draw = {
            function(_, x)
              return " " .. x
            end,
          },
        }),
      }
    ),
  })

  local popupmenu_renderer = wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
    border = "rounded",
    empty_message = wilder.popupmenu_empty_message_with_spinner(),
    highlighter = wilder.lua_fzy_highlighter(),
    left = {
      " ",
      wilder.popupmenu_devicons(),
      wilder.popupmenu_buffer_flags({
        flags = " a + ",
        icons = { ["+"] = "", a = "", h = "" },
      }),
    },
    right = {
      " ",
      wilder.popupmenu_scrollbar(),
    },
  }))
  local wildmenu_renderer = wilder.wildmenu_renderer({
    highlighter = wilder.lua_fzy_highlighter(),
    apply_incsearch_fix = true,
  })
  wilder.set_option(
    "renderer",
    wilder.renderer_mux({
      [":"] = popupmenu_renderer,
      ["/"] = wildmenu_renderer,
      substitute = wildmenu_renderer,
    })
  )
end

config.which_key = function()
  local icons = {
    ui = require("utils.icons").get("ui"),
    misc = require("utils.icons").get("misc"),
  }

  require("which-key").setup({
    plugins = {
      presets = {
        operators = false,
        motions = false,
        text_objects = false,
        windows = false,
        nav = false,
        z = true,
        g = true,
      },
    },

    icons = {
      breadcrumb = icons.ui.Separator,
      separator = icons.misc.Vbar,
      group = icons.misc.Add,
    },

    window = {
      border = "none",
      position = "bottom",
      margin = { 1, 0, 1, 0 },
      padding = { 1, 1, 1, 1 },
      winblend = 0,
    },
  })
end

config.dressing = function()
  require("dressing").setup({
    input = {
      enabled = true,
    },
    select = {
      enabled = true,
      backend = "telescope",
      trim_prompt = true,
    },
  })
end

return config
