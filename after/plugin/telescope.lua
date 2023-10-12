local utils = require('utils')
local telescope = require('telescope')
local builtin = require("telescope.builtin")

local opts = {
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
    fuzzy = false,                  -- false will only do exact matching
    override_generic_sorter = true, -- override the generic sorter
    override_file_sorter = true,    -- override the file sorter
    case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
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
}
opts.defaults.mappings = {
  i = {
    ["<C-a>"] = { "<esc>0i", type = "command" },
    ["<Esc>"] = function(...) return require("telescope.actions").close(...) end,
    ["<c-t>"] = function(...) return require("trouble.providers.telescope").open_with_trouble(...) end,
    ["<a-t>"] = function(...) return require("trouble.providers.telescope").open_selected_with_trouble(...) end,
    ["<a-i>"] = function()
      local action_state = require "telescope.actions.state"
      local line = action_state.get_current_line()
      utils.telescope("find_files", { no_ignore = true, default_text = line })()
    end,
    ["<a-h>"] = function()
      local action_state = require "telescope.actions.state"
      local line = action_state.get_current_line()
      utils.telescope("find_files", { hidden = true, default_text = line })()
    end,
    ["<C-Down>"] = function(...) return require("telescope.actions").cycle_history_next(...) end,
    ["<C-Up>"] = function(...) return require("telescope.actions").cycle_history_prev(...) end,
    ["<C-f>"] = function(...) return require("telescope.actions").preview_scrolling_down(...) end,
    ["<C-b>"] = function(...) return require("telescope.actions").preview_scrolling_up(...) end,
  },
  n = { ["q"] = function(...) return require("telescope.actions").close(...) end },
}
opts.extensions = {
  live_grep_args = {
    auto_quoting = false,
    mappings = {
      i = {
        ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
        ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt { postfix = " --iglob " },
        ["<C-j>"] = require("telescope-live-grep-args.actions").quote_prompt { postfix = " -t " }
      },
    },
  },
}

telescope.setup(opts)
telescope.load_extension "live_grep_args"

vim.keymap.set('n', 'gI', function(...)
  builtin.lsp_implementation { reuse_win = true }
end, { desc = 'lsp: Goto implementation' })
vim.keymap.set('n', 'gY', function(...)
  builtin.lsp_type_definitions { reuse_win = true }
end, { desc = 'lsp: Goto type definitions' })
vim.keymap.set('n', '<C-p>', function(...)
  builtin.keymaps {
    lhs_filter = function(lhs) return not string.find(lhs, "Þ") end,
    layout_config = {
      width = 0.6,
      height = 0.6,
      prompt_position = "top",
    },
  }
end, { desc = "telescope: Keymaps", noremap = true, silent = true })
vim.keymap.set('n', '<leader>b', function(...)
  builtin.buffers {
    layout_config = { width = 0.6, height = 0.6, prompt_position = "top" },
    show_all_buffers = true,
    previewer = false,
  }
end, { desc = "telescope: Manage buffers" })
vim.keymap.set('n', "<leader>f", builtin.find_files, { desc = "telescope: Find files" })
vim.keymap.set('n', "<LocalLeader>f", builtin.git_files, { desc = "telescope: Find files (git)" })
vim.keymap.set("n", "<leader>/", function()
  builtin.grep_string { word_match = '-w' }
end, { desc = "telescope: Grep string" })
vim.keymap.set("v", "<leader>/", builtin.grep_string, { desc = "telescope: Grep string" })
vim.keymap.set("n", "<leader>w",
  function() require("telescope").extensions.live_grep_args.live_grep_args() end,
  { desc = "telescope: Help tags" })
