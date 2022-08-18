local config = {}

config.nvim_treesitter = function()
  vim.api.nvim_set_option_value("foldmethod", "expr", {})
  vim.api.nvim_set_option_value("foldexpr", "nvim_treesitter#foldexpr()", {})

  require("nvim-treesitter.configs").setup({
    -- 'all', 'maintained', or list of string
    ensure_installed = {
      "bash",
      "c",
      "cpp",
      "lua",
      "go",
      "gomod",
      "rust",
      "dockerfile",
      "json",
      "yaml",
      "latex",
      "nix",
      "make",
      "python",
      "html",
      "javascript",
      "typescript",
      "vue",
      "css",
    },
    sync_install = true,
    highlight = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
    context_commentstring = { enable = true, enable_autocmd = false },
    matchup = { enable = true },
    textobjects = {
      select = {
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@conditional.outer",
          ["ic"] = "@conditional.inner",
          ["ai"] = "@call.outer",
          ["ii"] = "@call.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
          ["is"] = "@statement.inner",
          ["as"] = "@statement.outer",
          ["aC"] = "@class.outer",
          ["iC"] = "@class.inner",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>a"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner",
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
      lsp_interop = {
        enable = true,
        border = "none",
        peek_definition_code = {
          ["<leader>sd"] = "@function.outer",
          ["<leader>sD"] = "@class.outer",
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
  local parsers = require("nvim-treesitter.parsers").get_parser_configs()
  for _, p in pairs(parsers) do
    p.install_info.url = p.install_info.url:gsub("https://github.com/", "git@github.com:")
  end

  parsers.markdown.filetype_to_parsername = "octo"
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

config.matchup = function()
  vim.cmd([[let g:matchup_matchparen_offscreen = {'method': 'popup'}]])
end

config.toggleterm = function()
  require("toggleterm").setup({
    -- size can be a number or function which is passed the current terminal
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.40
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

config.accelerated_jk = function()
  require("accelerated-jk").setup({
    mode = "time_driven",
    enable_deceleration = false,
    acceleration_motions = {},
    acceleration_limit = 150,
    acceleration_table = { 7, 12, 17, 21, 24, 26, 28, 30 },
    -- when 'enable_deceleration = true', 'deceleration_table = { {200, 3}, {300, 7}, {450, 11}, {600, 15}, {750, 21}, {900, 9999} }'
    deceleration_table = { { 150, 9999 } },
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
  vim.cmd([[packadd sqlite.lua]])
  vim.cmd([[packadd telescope-fzf-native.nvim]])
  vim.cmd([[packadd telescope-file-browser.nvim]])
  vim.cmd([[packadd telescope-frecency.nvim]])
  vim.cmd([[packadd telescope-emoji.nvim]])
  vim.cmd([[packadd telescope-ui-select.nvim]])
  vim.cmd([[packadd telescope-live-grep-args.nvim]])

  local telescope_actions = require("telescope.actions.set")
  local theme = __editor_config.theme

  local fixfolds = {
    hidden = true,
    attach_mappings = function(_)
      telescope_actions.select:enhance({
        post = function()
          vim.cmd(":normal! zx")
        end,
      })
      return true
    end,
  }

  local fb_actions = require("telescope").extensions.file_browser.actions

  local telescope_config = {
    defaults = {
      initial_model = "insert",
      scroll_strategy = "limit",
      prompt_prefix = "🔭 ",
      selection_caret = "» ",
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
      },
      mappings = {
        i = {
          ["<C-a>"] = { "<esc>0i", type = "command" },
          ["<Esc>"] = require("telescope.actions").close,
        },
      },
      results_title = false,
      selection_strategy = "reset",
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.55,
          results_width = 0.8,
        },
        vertical = {
          mirror = false,
        },
        width = 0.87,
        height = 0.80,
        preview_cutoff = 120,
      },
      file_ignore_patterns = { "packer_compiled.lua", "static_content/", "node_modules/", ".git/" },
      -- file_sorter = require("telescope.sorters").get_fuzzy_file,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
      buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
      path_display = { "smart" },
      winblend = 0,
      border = {},
      color_devicons = true,
      use_less = true,
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown({}),
      },
      file_browser = {
        theme = theme,
        mappings = {
          ["i"] = {
            -- your custom insert mode mappings
            ["<C-h>"] = fb_actions.goto_parent_dir,
            ["<C-e>"] = fb_actions.rename,
            ["<C-c>"] = fb_actions.create,
          },
          ["n"] = {
            -- your custom normal mode mappings
          },
        },
      },
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
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
        theme = theme,
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
      lsp_document_symbols = {
        theme = theme,
      },
      diagnostics = {
        theme = theme,
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
  }

  _G.telescope_config = telescope_config

  require("telescope").setup(telescope_config)
  require("telescope").load_extension("fzf")
  require("telescope").load_extension("frecency")
  require("telescope").load_extension("ui-select")
  require("telescope").load_extension("file_browser")
  require("telescope").load_extension("emoji")
  require("telescope").load_extension("live_grep_args")
end

config.octo = function()
  require("octo").setup({
    default_remote = { "upstream", "origin" }, -- order to try remotes
    reaction_viewer_hint_icon = "", -- marker for user reactions
    user_icon = " ", -- user icon
    timeline_marker = "", -- timeline marker
    timeline_indent = "2", -- timeline indentation
    right_bubble_delimiter = "", -- Bubble delimiter
    left_bubble_delimiter = "", -- Bubble delimiter
    github_hostname = "", -- GitHub Enterprise host
    snippet_context_lines = 4, -- number or lines around commented lines
    file_panel = {
      size = 10, -- changed files panel rows
      use_icons = true, -- use web-devicons in file panel
    },
    mappings = {
      issue = {
        close_issue = "<space>ic", -- close issue
        reopen_issue = "<space>io", -- reopen issue
        list_issues = "<space>il", -- list open issues on same repo
        reload = "<C-r>", -- reload issue
        open_in_browser = "<C-b>", -- open issue in browser
        copy_url = "<C-y>", -- copy url to system clipboard
        add_assignee = "<space>aa", -- add assignee
        remove_assignee = "<space>ad", -- remove assignee
        create_label = "<space>lc", -- create label
        add_label = "<space>la", -- add label
        remove_label = "<space>ld", -- remove label
        goto_issue = "<space>gi", -- navigate to a local repo issue
        add_comment = "<space>ca", -- add comment
        delete_comment = "<space>cd", -- delete comment
        next_comment = "]c", -- go to next comment
        prev_comment = "[c", -- go to previous comment
        react_hooray = "<space>rp", -- add/remove 🎉 reaction
        react_heart = "<space>rh", -- add/remove ❤️ reaction
        react_eyes = "<space>re", -- add/remove 👀 reaction
        react_thumbs_up = "<space>r+", -- add/remove 👍 reaction
        react_thumbs_down = "<space>r-", -- add/remove 👎 reaction
        react_rocket = "<space>rr", -- add/remove 🚀 reaction
        react_laugh = "<space>rl", -- add/remove 😄 reaction
        react_confused = "<space>rc", -- add/remove 😕 reaction
      },
      pull_request = {
        checkout_pr = "<space>po", -- checkout PR
        merge_pr = "<space>pm", -- merge PR
        list_commits = "<space>pc", -- list PR commits
        list_changed_files = "<space>pf", -- list PR changed files
        show_pr_diff = "<space>pd", -- show PR diff
        add_reviewer = "<space>va", -- add reviewer
        remove_reviewer = "<space>vd", -- remove reviewer request
        close_issue = "<space>ic", -- close PR
        reopen_issue = "<space>io", -- reopen PR
        list_issues = "<space>il", -- list open issues on same repo
        reload = "<C-r>", -- reload PR
        open_in_browser = "<C-b>", -- open PR in browser
        copy_url = "<C-y>", -- copy url to system clipboard
        add_assignee = "<space>aa", -- add assignee
        remove_assignee = "<space>ad", -- remove assignee
        create_label = "<space>lc", -- create label
        add_label = "<space>la", -- add label
        remove_label = "<space>ld", -- remove label
        goto_issue = "<space>gi", -- navigate to a local repo issue
        add_comment = "<space>ca", -- add comment
        delete_comment = "<space>cd", -- delete comment
        next_comment = "]c", -- go to next comment
        prev_comment = "[c", -- go to previous comment
        react_hooray = "<space>rp", -- add/remove 🎉 reaction
        react_heart = "<space>rh", -- add/remove ❤️ reaction
        react_eyes = "<space>re", -- add/remove 👀 reaction
        react_thumbs_up = "<space>r+", -- add/remove 👍 reaction
        react_thumbs_down = "<space>r-", -- add/remove 👎 reaction
        react_rocket = "<space>rr", -- add/remove 🚀 reaction
        react_laugh = "<space>rl", -- add/remove 😄 reaction
        react_confused = "<space>rc", -- add/remove 😕 reaction
      },
      review_thread = {
        goto_issue = "<space>gi", -- navigate to a local repo issue
        add_comment = "<space>ca", -- add comment
        add_suggestion = "<space>sa", -- add suggestion
        delete_comment = "<space>cd", -- delete comment
        next_comment = "]c", -- go to next comment
        prev_comment = "[c", -- go to previous comment
        select_next_entry = "]q", -- move to previous changed file
        select_prev_entry = "[q", -- move to next changed file
        close_review_tab = "<C-c>", -- close review tab
        react_hooray = "<space>rp", -- add/remove 🎉 reaction
        react_heart = "<space>rh", -- add/remove ❤️ reaction
        react_eyes = "<space>re", -- add/remove 👀 reaction
        react_thumbs_up = "<space>r+", -- add/remove 👍 reaction
        react_thumbs_down = "<space>r-", -- add/remove 👎 reaction
        react_rocket = "<space>rr", -- add/remove 🚀 reaction
        react_laugh = "<space>rl", -- add/remove 😄 reaction
        react_confused = "<space>rc", -- add/remove 😕 reaction
      },
      submit_win = {
        approve_review = "<C-a>", -- approve review
        comment_review = "<C-m>", -- comment review
        request_changes = "<C-r>", -- request changes review
        close_review_tab = "<C-c>", -- close review tab
      },
      review_diff = {
        add_review_comment = "<space>ca", -- add a new review comment
        add_review_suggestion = "<space>sa", -- add a new review suggestion
        focus_files = "<leader>e", -- move focus to changed file panel
        toggle_files = "<leader>b", -- hide/show changed files panel
        next_thread = "]t", -- move to next thread
        prev_thread = "[t", -- move to previous thread
        select_next_entry = "]q", -- move to previous changed file
        select_prev_entry = "[q", -- move to next changed file
        close_review_tab = "<C-c>", -- close review tab
        toggle_viewed = "<leader><space>", -- toggle viewer viewed state
      },
      file_panel = {
        next_entry = "j", -- move to next changed file
        prev_entry = "k", -- move to previous changed file
        select_entry = "<cr>", -- show selected changed file diffs
        refresh_files = "R", -- refresh changed files panel
        focus_files = "<leader>e", -- move focus to changed file panel
        toggle_files = "<leader>b", -- hide/show changed files panel
        select_next_entry = "]q", -- move to previous changed file
        select_prev_entry = "[q", -- move to next changed file
        close_review_tab = "<C-c>", -- close review tab
        toggle_viewed = "<leader><space>", -- toggle viewer viewed state
      },
    },
  })
end

config.trouble = function()
  require("trouble").setup({
    mode = "document_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
    fold_open = "", -- icon used for open folds
    fold_closed = "", -- icon used for closed folds
    indent_lines = false, -- add an indent guide below the fold icons
    auto_close = true, -- automatically close the list when you have no diagnostics
    auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
    auto_fold = false, -- automatically fold a file trouble list at creation
    auto_jump = { "lsp_definitions" },
    signs = {
      -- icons / text used for a diagnostic
      error = "",
      warning = "",
      hint = "",
      information = "",
      other = "﫠",
    },
    use_lsp_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
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
  wilder.setup({ modes = { "/", "?" } })
  wilder.set_option("pipeline", {
    wilder.branch(
      wilder.python_file_finder_pipeline({
        file_command = function(_, arg)
          if string.find(arg, ".") ~= nil then
            return { "fdfind", "-tf", "-H" }
          else
            return { "fdfind", "-tf" }
          end
        end,
        dir_command = { "fd", "-td" },
      }),
      wilder.substitute_pipeline({
        pipeline = wilder.python_search_pipeline({
          skip_cmdtype_check = 1,
          pattern = wilder.python_fuzzy_pattern({
            start_at_boundary = 0,
          }),
        }),
      }),
      { wilder.check(function(_, x)
        return x == ""
      end), wilder.history() },
      wilder.python_search_pipeline({
        pattern = wilder.python_fuzzy_pattern({ start_at_boundary = 0 }),
      })
    ),
  })

  local highlighters = { wilder.pcre2_highlighter(), wilder.lua_fzy_highlighter() }
  local popupmenu_renderer = wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
    border = "rounded",
    empty_message = wilder.popupmenu_empty_message_with_spinner(),
    highligher = highlighters,
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
    highlighter = highlighters,
    separator = " · ",
    left = { " ", wilder.wildmenu_spinner(), " " },
    right = { " ", wilder.wildmenu_index() },
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

return config
