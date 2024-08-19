if Util.pick.want() == "telescope" then
  Util.pick.register {
    name = "telescope",
    commands = {
      files = "find_files",
    },
    -- this will return a function that calls telescope.
    -- cwd will default to lazyvim.util.get_root
    -- for `files`, git_files or find_files will be chosen depending on .git
    ---@param builtin string
    ---@param opts? lazyvim.util.pick.Opts
    open = function(builtin, opts)
      opts = opts or {}
      ---@diagnostic disable-next-line: inject-field
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
elseif Util.pick.want() == "mini.pick" then
  Util.pick.register {
    name = "mini.pick",
    commands = {
      files = "files",
      live_grep = "grep_live",
      oldfiles = "files",
    },
    -- this will return a function that calls telescope.
    -- cwd will default to lazyvim.util.get_root
    -- for `files`, git_files or find_files will be chosen depending on .git
    ---@param builtin string
    ---@param opts? lazyvim.util.pick.Opts
    open = function(builtin, opts)
      opts = opts or {}
      if opts.tool ~= nil then
        opts.source = vim.tbl_deep_extend("force", opts.source or {}, { cwd = opts.cwd })
        opts.cwd = nil
      end
      require("mini.pick").builtin[builtin](opts)
    end,
  }
end

local has_make = function() return vim.fn.executable "make" == 1 end
local has_cmake = function() return vim.fn.executable "cmake" == 1 end

return {
  {
    "echasnovski/mini.pick",
    cmd = "Pick",
    version = false,
    enabled = function() return Util.pick.want() == "mini.pick" end,
    opts = {},
    keys = {
      {
        "<LocalLeader>f",
        Util.pick("files", { tool = "git" }),
        desc = "mini.pick: open (git root)",
      },
      {
        "<LocalLeader>.",
        Util.pick("files", { source = { items = vim.fn.readdir "." } }),
        desc = "mini.pick: open (current)",
      },
      {
        "<LocalLeader>w",
        Util.pick "grep_live",
        desc = "mini.pick: grep word",
      },
      {
        "<leader>b",
        Util.pick "buffers",
        desc = "mini.pick: grep word",
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    enabled = function() return Util.pick.want() == "telescope" end,
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
            "<LocalLeader>w",
            function() require("telescope").extensions.live_grep_args.live_grep_args() end,
            desc = "telescope: grep word",
          },
          {
            "<Leader>/",
            function() require("telescope-live-grep-args.shortcuts").grep_word_under_cursor() end,
            desc = "telescope: grep word (cursor)",
          },
        },
        config = function()
          Util.on_load("telescope.nvim", function()
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
      { "<LocalLeader>f", Util.pick("files", { root = false }), desc = "telescope: find files" },
      { "<leader>sf", Util.pick "oldfiles", desc = "telescope: recent files" },
    },
    opts = function()
      local actions = require "telescope.actions"
      local actions_layout = require "telescope.actions.layout"

      local open_with_trouble = function(...) return require("trouble.sources.telescope").open(...) end
      local find_files_no_ignore = function()
        local line = require("telescope.actions.state").get_current_line()
        Util.pick("find_files", { no_ignore = true, default_text = line })()
      end
      local find_files_with_hidden = function()
        local line = require("telescope.actions.state").get_current_line()
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
          borderchars = BORDER.single["simple"],
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
