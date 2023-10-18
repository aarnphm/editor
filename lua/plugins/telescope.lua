local Util = require "utils"

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
      },
    },
    keys = {
      {
        "gI",
        function() require("telescope.builtin").lsp_implementations { reuse_win = true } end,
        desc = "lsp: Goto implementation",
      },
      {
        "gY",
        function() require("telescope.builtin").lsp_type_definitions { reuse_win = true } end,
        desc = "lsp: Goto type definitions",
      },
      {
        "<C-p>",
        function()
          require("telescope.builtin").keymaps {
            lhs_filter = function(lhs) return not string.find(lhs, "Þ") end,
            layout_config = {
              width = 0.6,
              height = 0.6,
              prompt_position = "top",
            },
          }
        end,
        desc = "telescope: Keymaps",
        noremap = true,
        silent = true,
      },
      {
        "<leader>b",
        function()
          require("telescope.builtin").buffers {
            layout_config = { width = 0.6, height = 0.6, prompt_position = "top" },
            show_all_buffers = true,
            previewer = false,
          }
        end,
        desc = "telescope: Manage buffers",
      },
      {
        "<leader>f",
        function() require("telescope.builtin").find_files() end,
        desc = "telescope: Find files",
      },
      {
        "<LocalLeader>f",
        function() require("telescope.builtin").git_files() end,
        desc = "telescope: Find files (git)",
      },
      {
        "<leader>/",
        function() require("telescope.builtin").grep_string { word_match = "-w" } end,
        desc = "telescope: Grep string",
      },
      {
        "<leader>w",
        function() require("telescope").extensions.live_grep_args.live_grep_args() end,
        desc = "telescope: Grep word",
      },
    },
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },
        prompt_prefix = "  ",
        selection_caret = "󰄾 ",
        -- open files in the first window that is an actual file.
        -- use the current window if no other window is available.
        get_selection_window = function()
          local wins = vim.api.nvim_list_wins()
          table.insert(wins, 1, vim.api.nvim_get_current_win())
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].buftype == "" then return win end
          end
          return 0
        end,
        file_ignore_patterns = {
          ".git/",
          "node_modules/",
          "static_content/",
          "lazy-lock.json",
          "pdm.lock",
          "__pycache__",
        },
        layout_config = { width = 0.8, height = 0.8, prompt_position = "top" },
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        color_devicons = true,
      },
      fzf = {
        fuzzy = false, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      },
      pickers = {
        find_files = { hidden = true },
        live_grep = {
          on_input_filter_cb = function(prompt)
            -- AND operator for live_grep like how fzf handles spaces with wildcards in rg
            return { prompt = prompt:gsub("%s", ".*") }
          end,
          attach_mappings = function(_)
            require("telescope.actions.set").select:enhance {
              post = function() vim.cmd ":normal! zx" end,
            }
            return true
          end,
        },
      },
    },
    config = function(_, opts)
      local actions = require "telescope.actions"
      opts.defaults.mappings = {
        i = {
          ["<C-a>"] = { "<esc>0i", type = "command" },
          ["<Esc>"] = function(...) return actions.close(...) end,
          ["<c-t>"] = function(...) return require("trouble.providers.telescope").open_with_trouble(...) end,
          ["<a-t>"] = function(...) return require("trouble.providers.telescope").open_selected_with_trouble(...) end,
          ["<a-i>"] = function()
            local action_state = require "telescope.actions.state"
            local line = action_state.get_current_line()
            Util.telescope("find_files", { no_ignore = true, default_text = line })()
          end,
          ["<a-h>"] = function()
            local action_state = require "telescope.actions.state"
            local line = action_state.get_current_line()
            Util.telescope("find_files", { hidden = true, default_text = line })()
          end,
          ["<C-Down>"] = function(...) return actions.cycle_history_next(...) end,
          ["<C-Up>"] = function(...) return actions.cycle_history_prev(...) end,
          ["<C-f>"] = function(...) return actions.preview_scrolling_down(...) end,
          ["<C-b>"] = function(...) return actions.preview_scrolling_up(...) end,
        },
        n = { ["q"] = function(...) return actions.close(...) end },
      }
      opts.extensions = {
        live_grep_args = {
          auto_quoting = false,
          mappings = {
            i = {
              ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
              ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt { postfix = " --iglob " },
              ["<C-j>"] = require("telescope-live-grep-args.actions").quote_prompt { postfix = " -t " },
            },
          },
        },
      }
      require("telescope").setup(opts)
      require("telescope").load_extension "live_grep_args"
    end,
  },
}