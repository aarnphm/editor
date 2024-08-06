return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
      "s1n7ax/nvim-window-picker",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = vim.fn.executable "make" == 1 and "make"
          or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        enabled = vim.fn.executable "cmake" == 1,
        config = function(plugin)
          Util.on_load("telescope.nvim", function()
            local ok, err = pcall(require("telescope").load_extension, "fzf")
            if not ok then
              local lib = plugin.dir .. "/build/libfzf." .. (Util.is_win() and "dll" or "so")
              if not vim.uv.fs_stat(lib) then
                Util.warn "`telescope-fzf-native.nvim` not built. Rebuilding..."
                require("lazy")
                  .build({ plugins = { plugin }, show = false })
                  :wait(
                    function() Util.info "Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim." end
                  )
              else
                Util.error("Failed to load `telescope-fzf-native.nvim`:\n" .. err)
              end
            end
          end)
        end,
      },
    },
    keys = {
      {
        "<C-S-p>",
        Util.telescope("keymaps", {
          lhs_filter = function(lhs) return not string.find(lhs, "Þ") end,
          layout_strategy = "vertical",
          previewer = false,
          layout_config = {
            width = 0.6,
            height = 0.6,
            prompt_position = "top",
          },
        }),
        desc = "telescope: Keymaps",
        noremap = true,
        silent = true,
      },
      {
        "<leader>b",
        Util.telescope("buffers", {
          layout_config = { width = 0.6, height = 0.6, prompt_position = "top" },
          show_all_buffers = true,
          previewer = false,
          cwd = require("plenary.job"):new({ command = "git", args = { "rev-parse", "--show-toplevel" } }):sync()[1],
        }),
        desc = "telescope: Manage buffers",
      },
      {
        "<leader>f",
        Util.telescope("find_files", {}),
        desc = "telescope: Find files",
      },
      {
        "<LocalLeader>f",
        Util.telescope("git_files", {}),
        desc = "telescope: Find files (git)",
      },
      {
        "<leader>/",
        Util.telescope("grep_string", { word_match = "-w" }),
        desc = "telescope: Grep string",
      },
      {
        "<leader>w",
        function() require("telescope").extensions.live_grep_args.live_grep_args() end,
        desc = "telescope: Grep word",
      },
    },
    opts = function()
      local TSActions = require "telescope.actions"
      local TSActionLayout = require "telescope.actions.layout"

      local Layout = require "nui.layout"
      local Popup = require "nui.popup"

      local telescope = require "telescope"
      local TSLayout = require "telescope.pickers.layout"

      local function make_popup(options)
        local popup = Popup(options)
        function popup.border:change_title(title) popup.border.set_text(popup.border, "top", title) end
        return TSLayout.Window(popup)
      end

      ---@class TelescopeOptions
      local opts = {
        defaults = {
          prompt_prefix = "  ",
          selection_caret = " 󰄾 ",
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
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
          mappings = {
            i = {
              ["<C-a>"] = { "<esc>0i", type = "command" },
              ["<Esc>"] = function(...) return TSActions.close(...) end,
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
              ["<C-Down>"] = TSActions.cycle_history_next,
              ["<C-Up>"] = TSActions.cycle_history_prev,
              ["<C-f>"] = TSActions.preview_scrolling_down,
              ["<C-b>"] = TSActions.preview_scrolling_up,
              ["<C-p>"] = TSActionLayout.toggle_preview,
            },
            n = {
              ["q"] = TSActions.close,
              ["<C-p>"] = TSActionLayout.toggle_preview,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = { "fd", "--type", "f", "--color", "never" },
            hidden = true,
          },
          live_grep = {
            additional_args = function() return { "--hidden" } end,
            glob_pattern = { "!.git" },

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
        extensions = {
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
        },
      }
      return opts
    end,
    ---@param opts TelescopeOptions
    config = function(_, opts)
      require("telescope").setup(opts)
      require("telescope").load_extension "live_grep_args"
    end,
  },
}
