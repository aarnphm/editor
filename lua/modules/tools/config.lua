local config = {}

function config.telescope()
  if not packer_plugins["sqlite.lua"].loaded then
    vim.cmd([[packadd sqlite.lua]])
  end

  if not packer_plugins["telescope-fzf-native.nvim"].loaded then
    vim.cmd([[packadd telescope-fzf-native.nvim]])
  end

  if not packer_plugins["telescope-file-browser.nvim"].loaded then
    vim.cmd([[packadd telescope-file-browser.nvim]])
  end

  if not packer_plugins["telescope-project.nvim"].loaded then
    vim.cmd([[packadd telescope-project.nvim]])
  end

  if not packer_plugins["telescope-frecency.nvim"].loaded then
    vim.cmd([[packadd telescope-frecency.nvim]])
  end

  if not packer_plugins["telescope-zoxide"].loaded then
    vim.cmd([[packadd telescope-zoxide]])
  end

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
      fzf = {
        fuzzy = false, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      },
      file_browser = {
        theme = "ivy",
        mappings = {
          ["i"] = {
            -- your custom insert mode mappings
          },
          ["n"] = {
            -- your custom normal mode mappings
          },
        },
      },
      frecency = {
        show_scores = true,
        show_unindexed = true,
        ignore_patterns = { "*.git/*", "*/tmp/*" },
      },
    },
  })

  require("telescope").load_extension("file_browser")
  require("telescope").load_extension("fzf")
  require("telescope").load_extension("project")
  require("telescope").load_extension("zoxide")
  require("telescope").load_extension("frecency")
end

function config.wilder()
  vim.cmd([[
call wilder#setup({'modes': [':', '/', '?']})
call wilder#set_option('use_python_remote_plugin', 0)

call wilder#set_option('pipeline', [wilder#branch(wilder#cmdline_pipeline({'use_python': 0,'fuzzy': 1, 'fuzzy_filter': wilder#lua_fzy_filter()}),wilder#vim_search_pipeline(), [wilder#check({_, x -> empty(x)}), wilder#history(), wilder#result({'draw': [{_, x -> ' ' . x}]})])])

call wilder#set_option('renderer', wilder#renderer_mux({':': wilder#popupmenu_renderer({'highlighter': wilder#lua_fzy_highlighter(), 'left': [wilder#popupmenu_devicons()], 'right': [' ', wilder#popupmenu_scrollbar()]}), '/': wilder#wildmenu_renderer({'highlighter': wilder#lua_fzy_highlighter()})}))
]])
end

return config
