return function()
  local icons = { ui = require("utils.icons").get("ui", true) }
  local lga_actions = require("telescope-live-grep-args.actions")
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
        "*/lazy-lock.json",
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
      live_grep_args = {
        auto_quoting = true, -- enable/disable auto-quoting
        -- define mappings, e.g.
        mappings = { -- extend mappings
          i = {
            ["<C-k>"] = lga_actions.quote_prompt(),
            ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
          },
        },
      },
      undo = {
        side_by_side = true,
        layout_config = {
          preview_height = 0.8,
        },
        mappings = { -- this whole table is the default
          i = {
            -- IMPORTANT: Note that telescope-undo must be available when telescope is configured if
            -- you want to use the following actions. This means installing as a dependency of
            -- telescope in it's `requirements` and loading this extension from there instead of
            -- having the separate plugin definition as outlined above. See issue #6.
            ["<cr>"] = require("telescope-undo.actions").yank_additions,
            ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
            ["<C-cr>"] = require("telescope-undo.actions").restore,
          },
        },
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

  require("telescope").load_extension("notify")
  require("telescope").load_extension("fzf")
  require("telescope").load_extension("zoxide")
  require("telescope").load_extension("frecency")
  require("telescope").load_extension("projects")
  require("telescope").load_extension("live_grep_args")
  require("telescope").load_extension("undo")
  require("telescope").load_extension("emoji")
end
