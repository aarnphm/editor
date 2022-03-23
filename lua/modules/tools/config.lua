local config = {}

function config.telescope()
  vim.cmd([[packadd sqlite.lua]])
  vim.cmd([[packadd telescope-fzf-native.nvim]])
  vim.cmd([[packadd telescope-file-browser.nvim]])
  vim.cmd([[packadd telescope-project.nvim]])
  vim.cmd([[packadd telescope-frecency.nvim]])
  vim.cmd([[packadd telescope-zoxide]])
  vim.cmd([[packadd telescope-ui-select.nvim]])
  vim.cmd([[packadd nvim-notify]])

  require("telescope").setup({
    defaults = {
      prompt_prefix = "🔭 ",
      selection_caret = " ",
      layout_config = {
        horizontal = { prompt_position = "bottom", results_width = 0.6 },
        vertical = { mirror = false },
      },
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      file_sorter = require("telescope.sorters").get_fuzzy_file,
      file_ignore_patterns = {},
      generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
      path_display = { "absolute" },
      winblend = 0,
      border = {},
      borderchars = {
        "─",
        "│",
        "─",
        "│",
        "╭",
        "╮",
        "╯",
        "╰",
      },
      color_devicons = true,
      use_less = true,
      set_env = { ["COLORTERM"] = "truecolor" },
    },
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_ivy({}),
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
  })

  require("telescope").load_extension("fzf")
  require("telescope").load_extension("zoxide")
  require("telescope").load_extension("frecency")
  require("telescope").load_extension("ui-select")
  require("telescope").load_extension("file_browser")
  require("telescope").load_extension("project")
  require("telescope").load_extension("notify")
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
      \ 'border': 'rounded',
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

return config
