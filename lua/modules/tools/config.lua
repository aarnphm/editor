local config = {}

function config.spectre()
  require("spectre").setup({

    color_devicons = true,
    open_cmd = "vnew",
    live_update = false, -- auto excute search again when you write any file in vim
    line_sep_start = "┌-----------------------------------------",
    result_padding = "¦  ",
    line_sep = "└-----------------------------------------",
    highlight = {
      ui = "String",
      search = "DiffChange",
      replace = "DiffDelete",
    },
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

function config.telescope()
  vim.cmd([[packadd sqlite.lua]])
  vim.cmd([[packadd telescope-fzf-native.nvim]])
  vim.cmd([[packadd telescope-file-browser.nvim]])
  vim.cmd([[packadd telescope-frecency.nvim]])
  vim.cmd([[packadd telescope-emoji.nvim]])
  vim.cmd([[packadd telescope-ui-select.nvim]])

  local telescope_config = {
    defaults = {
      prompt_prefix = "🔭 ",
      selection_caret = "» ",
      layout_config = {
        horizontal = { prompt_position = "bottom", results_width = 0.6 },
        vertical = { mirror = false },
      },
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      file_sorter = require("telescope.sorters").get_fuzzy_file,
      file_ignore_patterns = { "__compiled.lua" },
      generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
      path_display = { "absolute" },
      winblend = 0,
      border = {},
      color_devicons = true,
      use_less = true,
      set_env = { ["COLORTERM"] = "truecolor" },
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown({}),
      },
      fzf = {
        fuzzy = false, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      },
      frecency = {
        show_scores = true,
        show_unindexed = true,
        ignore_patterns = { "*.git/*", "*/tmp/*" },
      },
    },
  }

  require("telescope").setup(telescope_config)
  require("telescope").load_extension("fzf")
  require("telescope").load_extension("frecency")
  require("telescope").load_extension("ui-select")
  require("telescope").load_extension("file_browser")
  require("telescope").load_extension("notify")
  require("telescope").load_extension("emoji")
end

function config.octo()
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

function config.trouble()
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
    auto_close = false, -- automatically close the list when you have no diagnostics
    auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
    auto_fold = false, -- automatically fold a file trouble list at creation
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

function config.cheatsheet()
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

function config.wilder()
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
