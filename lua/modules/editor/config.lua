local config = {}

config.symbols_outline = function()
  require("symbols-outline").setup({
    highlight_hovered_item = true,
    width = 30,
    show_guides = true,
    auto_preview = true,
    position = "right",
    show_numbers = true,
    show_relative_numbers = true,
    show_symbol_details = true,
    preview_bg_highlight = "Pmenu",
    keymaps = {
      close = "<Esc>",
      goto_location = "<Cr>",
      focus_location = "o",
      hover_symbol = "<C-space>",
      rename_symbol = "r",
      code_actions = "a",
    },
    lsp_blacklist = {},
    symbols = {
      File = { icon = "", hl = "TSURI" },
      Module = { icon = "", hl = "TSNamespace" },
      Namespace = { icon = "", hl = "TSNamespace" },
      Package = { icon = "", hl = "TSNamespace" },
      Class = { icon = "𝓒", hl = "TSType" },
      Method = { icon = "ƒ", hl = "TSMethod" },
      Property = { icon = "", hl = "TSMethod" },
      Field = { icon = "", hl = "TSField" },
      Constructor = { icon = "", hl = "TSConstructor" },
      Enum = { icon = "ℰ", hl = "TSType" },
      Interface = { icon = "ﰮ", hl = "TSType" },
      Function = { icon = "", hl = "TSFunction" },
      Variable = { icon = "", hl = "TSConstant" },
      Constant = { icon = "", hl = "TSConstant" },
      String = { icon = "𝓐", hl = "TSString" },
      Number = { icon = "#", hl = "TSNumber" },
      Boolean = { icon = "⊨", hl = "TSBoolean" },
      Array = { icon = "", hl = "TSConstant" },
      Object = { icon = "⦿", hl = "TSType" },
      Key = { icon = "🔐", hl = "TSType" },
      Null = { icon = "NULL", hl = "TSType" },
      EnumMember = { icon = "", hl = "TSField" },
      Struct = { icon = "𝓢", hl = "TSType" },
      Event = { icon = "🗲", hl = "TSType" },
      Operator = { icon = "+", hl = "TSOperator" },
      TypeParameter = { icon = "𝙏", hl = "TSParameter" },
    },
  })
end

config.nvim_treesitter = function()
  vim.cmd([[set foldmethod=expr]])
  vim.cmd([[set foldexpr=nvim_treesitter#foldexpr()]])

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
    sync_install = false,
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
    highlight = { enable = true },
    context_commentstring = { enable = true, enable_autocmd = false },
    matchup = { enable = true },
    textobjects = {
      select = {
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
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
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
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
  })

  require("nvim-treesitter.install").prefer_git = true
  local parsers = require("nvim-treesitter.parsers").get_parser_configs()
  for _, p in pairs(parsers) do
    p.install_info.url = p.install_info.url:gsub("https://github.com/", "git@github.com:")
  end

  parsers.markdown.filetype_to_parsername = "octo"
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

config.telekasten = function()
  vim.cmd([[ packadd calendar-vim ]])

  local home = __editor_global.vim_path .. __editor_global.path_sep .. "zettelkasten"

  require("telekasten").setup({
    home = home,
    -- if trle, telekasten will be enabled when opening a note within the configured home
    take_over_my_home = true,

    -- auto-set telekasten filetype: if false, the telekasten filetype will not be used
    auto_set_filetype = true,

    -- dir names for special notes (absolute path or subdir name)
    dailies = home .. __editor_global.path_sep .. "daily",
    weeklies = home .. __editor_global.path_sep .. "weekly",
    templates = home .. __editor_global.path_sep .. "templates",

    -- image (sub)dir for pasting
    -- dir name (absolute path or subdir name)
    -- or nil if pasted images shouldn't go into a special subdir
    image_subdir = "images",

    -- markdown file extension
    extension = ".md",

    -- following a link to a non-existing note will create it
    follow_creates_nonexisting = true,
    dailies_create_nonexisting = true,
    weeklies_create_nonexisting = true,
    -- integrate with calendar-vim
    plug_into_calendar = true,
    calendar_opts = {
      -- calendar week display mode: 1 .. 'WK01', 2 .. 'WK 1', 3 .. 'KW01', 4 .. 'KW 1', 5 .. '1'
      weeknm = 4,
      -- use monday as first day of week: 1 .. true, 0 .. false
      calendar_monday = 1,
      -- calendar mark: where to put mark for marked days: 'left', 'right', 'left-fit'
      calendar_mark = "left-fit",
    },

    -- template for new notes (new_note, follow_link)
    -- set to `nil` or do not specify if you do not want a template
    template_new_note = home .. __editor_global.path_sep .. "templates" .. __editor_global.path_sep .. "new_note.md",

    -- template for newly created daily notes (goto_today)
    -- set to `nil` or do not specify if you do not want a template
    template_new_daily = home .. __editor_global.path_sep .. "templates" .. __editor_global.path_sep .. "daily.md",

    -- template for newly created weekly notes (goto_thisweek)
    -- set to `nil` or do not specify if you do not want a template
    template_new_weekly = home .. __editor_global.path_sep .. "templates" .. __editor_global.path_sep .. "weekly.md",

    -- image link style
    -- wiki:     ![[image name]]
    -- markdown: ![](image_subdir/xxxxx.png)
    image_link_style = "markdown",

    -- telescope actions behavior
    close_after_yanking = false,
    insert_after_inserting = true,

    -- tag notation: '#tag', ':tag:', 'yaml-bare'
    tag_notation = "#tag",

    -- command palette theme: dropdown (window) or ivy (bottom panel)
    command_palette_theme = "ivy",

    -- tag list theme:
    -- get_cursor: small tag list at cursor; ivy and dropdown like above
    show_tags_theme = "ivy",

    -- when linking to a note in subdir/, create a [[subdir/title]] link
    -- instead of a [[title only]] link
    subdirs_in_links = true,

    -- template_handling
    -- What to do when creating a new note via `new_note()` or `follow_link()`
    -- to a non-existing note
    -- - prefer_new_note: use `new_note` template
    -- - smart: if day or week is detected in title, use daily / weekly templates (default)
    -- - always_ask: always ask before creating a note
    template_handling = "smart",

    -- path handling:
    --   this applies to:
    --     - new_note()
    --     - new_templated_note()
    --     - follow_link() to non-existing note
    --
    --   it does NOT apply to:
    --     - goto_today()
    --     - goto_thisweek()
    --
    --   Valid options:
    --     - smart: put daily-looking notes in daily, weekly-looking ones in weekly,
    --              all other ones in home, except for notes/with/subdirs/in/title.
    --              (default)
    --
    --     - prefer_home: put all notes in home except for goto_today(), goto_thisweek()
    --                    except for notes with subdirs/in/title.
    --
    --     - same_as_current: put all new notes in the dir of the current note if
    --                        present or else in home
    --                        except for notes/with/subdirs/in/title.
    new_note_location = "smart",

    -- should all links be updated when a file is renamed
    rename_update_links = true,
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

  require("telescope").setup(telescope_config)
  require("telescope").load_extension("fzf")
  require("telescope").load_extension("frecency")
  require("telescope").load_extension("ui-select")
  require("telescope").load_extension("file_browser")
  require("telescope").load_extension("emoji")
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
    position = "bottom", -- position of the list can be: bottom, top, left, right
    height = 10, -- height of the trouble list when position is top or bottom
    width = 50, -- width of the list when position is left or right
    icons = true, -- use devicons for filenames
    mode = "document_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
    fold_open = "", -- icon used for open folds
    fold_closed = "", -- icon used for closed folds
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
  vim.cmd([[
call wilder#setup({'modes': [':', '/', '?']})
call wilder#set_option('pipeline', [
      \   wilder#branch(
      \     wilder#python_file_finder_pipeline({
      \       'file_command': {_, arg -> stridx(arg, '.') != -1 ? ['fd', '-tf', '-H'] : ['fd', '-tf']},
      \       'dir_command': ['fd', '-td'],
      \     }),
      \     wilder#substitute_pipeline({
      \       'pipeline': wilder#python_search_pipeline({
      \         'skip_cmdtype_check': 1,
      \         'pattern': wilder#python_fuzzy_pattern({
      \           'start_at_boundary': 0,
      \         }),
      \       }),
      \     }),
      \     wilder#cmdline_pipeline({
      \       'fuzzy': 1,
      \       'fuzzy_filter': has('nvim') ? wilder#lua_fzy_filter() : wilder#vim_fuzzy_filter(),
      \     }),
      \     [
      \       wilder#check({_, x -> empty(x)}),
      \       wilder#history(),
      \     ],
      \     wilder#python_search_pipeline({
      \       'pattern': wilder#python_fuzzy_pattern({
      \         'start_at_boundary': 0,
      \       }),
      \     }),
      \   ),
      \ ])
let s:highlighters = [
      \ wilder#pcre2_highlighter(),
      \ wilder#lua_fzy_highlighter(),
      \ ]
let s:popupmenu_renderer = wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
      \ 'empty_message': wilder#popupmenu_empty_message_with_spinner(),
      \ 'highlighter': s:highlighters,
      \ 'left': [
      \   ' ',
      \   wilder#popupmenu_devicons(),
      \   wilder#popupmenu_buffer_flags({
      \     'flags': ' a + ',
      \     'icons': {'+': '', 'a': '', 'h': ''},
      \   }),
      \ ],
      \ 'right': [
      \   ' ',
      \   wilder#popupmenu_scrollbar(),
      \ ],
      \ }))
let s:wildmenu_renderer = wilder#wildmenu_renderer({
      \ 'highlighter': s:highlighters,
      \ 'separator': ' · ',
      \ 'left': [' ', wilder#wildmenu_spinner(), ' '],
      \ 'right': [' ', wilder#wildmenu_index()],
      \ })
call wilder#set_option('renderer', wilder#renderer_mux({
      \ ':': s:popupmenu_renderer,
      \ '/': s:wildmenu_renderer,
      \ 'substitute': s:wildmenu_renderer,
      \ }))
]])
end

return config
