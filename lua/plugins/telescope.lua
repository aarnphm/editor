if
  not Util.pick.register {
    name = "telescope",
    commands = {
      files = "find_files",
    },
    -- this will return a function that calls telescope.
    -- cwd will default to lazyvim.util.get_root
    -- for `files`, git_files or find_files will be chosen depending on .git
    ---@param builtin string
    ---@param opts? simple.util.pick.Opts
    open = function(builtin, opts)
      opts = opts or {}
      opts.follow = opts.follow ~= false
      if opts.cwd and opts.cwd ~= vim.uv.cwd() then
        ---@diagnostic disable-next-line: inject-field
        opts.attach_mappings = function(_, map)
          -- opts.desc is overridden by telescope, until it's changed there is this fix
          map("i", "<a-c>", function()
            local action_state = require "telescope.actions.state"
            local line = action_state.get_current_line()
            Util.pick.open(
              builtin,
              vim.tbl_deep_extend("force", {}, opts or {}, {
                root = false,
                default_text = line,
              })
            )
          end, { desc = "telescope: open cwd" })
          return true
        end
      end

      require("telescope.builtin")[builtin](opts)
    end,
  }
then
  return {}
end

local has_make = function() return vim.fn.executable "make" == 1 end
local has_cmake = function() return vim.fn.executable "cmake" == 1 end

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    enabled = Util.pick.want() == "telescope",
    version = false,
    dependencies = {
      {
        "jvgrootveld/telescope-zoxide",
        enabled = vim.fn.executable "zoxide" == 1,
        keys = {
          {
            "<Leader>z",
            function() require("telescope").extensions.zoxide.list() end,
            desc = "telescope: zoxide",
          },
        },
        config = function()
          Util.on_load("telescope.nvim", function()
            local ok, err = pcall(require("telescope").load_extension, "zoxide")
            if not ok then Util.error("Failed to load `telescope-zoxide`:\n" .. err) end
          end)
        end,
      },
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        keys = {
          {
            "<Leader>w",
            function() require("telescope").extensions.live_grep_args.live_grep_args() end,
            desc = "telescope: grep word",
          },
          {
            "<LocalLeader>w",
            function() require("telescope-live-grep-args.shortcuts").grep_word_under_cursor() end,
            desc = "telescope: grep word",
          },
        },
        config = function()
          Util.on_load("telescope.nvim", function(name)
            local ok, err = pcall(require("telescope").load_extension, "live_grep_args")
            if not ok then Util.error("Failed to load `telescope-live-grep-args.nvim`:\n" .. err) end
          end)
        end,
      },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = has_make() and "make"
          or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        enabled = has_make() or has_cmake(),
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
        "<C-\\>",
        Util.pick("keymaps", {
          initial_mode = "normal",
          lhs_filter = function(lhs) return not string.find(lhs, "Þ") end,
          layout_strategy = "vertical",
          previewer = false,
          layout_config = {
            width = 0.6,
            height = 0.6,
            prompt_position = "top",
          },
        }),
        desc = "telescope: keymaps",
        noremap = true,
        silent = true,
      },
      {
        "<LocalLeader>b",
        Util.pick("buffers", {
          initial_mode = "normal",
          layout_config = { width = 0.6, height = 0.6, prompt_position = "top" },
          show_all_buffers = true,
          previewer = false,
          cwd = require("plenary.job"):new({ command = "git", args = { "rev-parse", "--show-toplevel" } }):sync()[1],
        }),
        desc = "telescope: Manage buffers",
      },
      { "<leader>f", Util.pick("files", { root = false }), desc = "telescope: find files" },
      { "<LocalLeader>f", Util.pick "oldfiles", desc = "telescope: recent files" },
      { "<Leader>/", Util.pick("grep_string", { word_match = "-w" }), desc = "telescope: grep string (cursor)" },
    },
    opts = function()
      local actions = require "telescope.actions"
      local actions_layout = require "telescope.actions.layout"

      local open_with_trouble = function(...) return require("trouble.sources.telescope").open(...) end
      local find_files_no_ignore = function()
        local action_state = require "telescope.actions.state"
        local line = action_state.get_current_line()
        Util.pick("find_files", { no_ignore = true, default_text = line })()
      end
      local find_files_with_hidden = function()
        local action_state = require "telescope.actions.state"
        local action_set = require "telescope.actions.set"
        local line = action_state.get_current_line()
        Util.pick("find_files", { hidden = true, default_text = line })()
      end

      local find_command = function()
        if 1 == vim.fn.executable "rg" then
          return { "rg", "--files", "--color", "never", "-g", "!.git" }
        elseif 1 == vim.fn.executable "fd" then
          return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
        elseif 1 == vim.fn.executable "fdfind" then
          return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
        elseif 1 == vim.fn.executable "find" and vim.fn.has "win32" == 0 then
          return { "find", ".", "-type", "f" }
        elseif 1 == vim.fn.executable "where" then
          return { "where", "/r", ".", "*" }
        end
      end

      return {
        defaults = {
          prompt_prefix = "󰄾 ",
          selection_caret = " ",
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
          vimgrep_arguments = {
            "rg",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
          },
          layout_config = {
            horizontal = {
              size = {
                width = "90%",
                height = "60%",
              },
            },
            vertical = {
              size = {
                width = "90%",
                height = "90%",
              },
            },
          },
          mappings = {
            i = {
              ["<C-a>"] = { "<esc>0i", type = "command" },
              ["<Esc>"] = actions.close,
              ["<C-t>"] = open_with_trouble,
              ["<a-i>"] = find_files_no_ignore,
              ["<a-h>"] = find_files_with_hidden,
              ["<C-Down>"] = actions.cycle_history_next,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
              ["<C-p>"] = actions_layout.toggle_preview,
            },
            n = {
              ["q"] = actions.close,
              ["<C-p>"] = actions_layout.toggle_preview,
            },
          },
        },
        pickers = { find_files = { find_command = find_command, hidden = true } },
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
    end,
  },
}
