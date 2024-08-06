return {
  { "echasnovski/mini.align", event = "VeryLazy", opts = {} },
  { "echasnovski/mini.trailspace", event = { "BufRead", "BufNewFile" }, opts = {} },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require "mini.ai"
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter { -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          },
          f = ai.gen_spec.treesitter { a = "@function.outer", i = "@function.inner" }, -- function
          c = ai.gen_spec.treesitter { a = "@class.outer", i = "@class.inner" }, -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          i = Util.mini.ai_indent, -- indent
          g = Util.mini.ai_buffer, -- buffer
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call { name_pattern = "[%w_]" }, -- without dot in function name
        },
      }
    end,
    config = function(_, opts) require("mini.ai").setup(opts) end,
  },
  {
    "echasnovski/mini.files",
    dependencies = {
      {
        "s1n7ax/nvim-window-picker",
        name = "window-picker",
        lazy = true,
        opts = {
          autoselect_one = true,
          include_current = false,
          filter_rules = {
            bo = {
              filetype = { "neo-tree", "neo-tree-popup", "notify" },
              buftype = { "terminal", "quickfix", "Scratch", "aerial" },
            },
          },
        },
      },
    },
    opts = {
      windows = { preview = true, width_focus = 50, width_nofocus = 15, width_preview = 50 },
      mappings = { synchronize = "<leader>" },
    },
    keys = {
      {
        "<LocalLeader>/",
        function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end,
        desc = "Open mini.files (directory of current file)",
      },
      {
        "<LocalLeader>.",
        function() require("mini.files").open(Util.root.git(), true) end,
        desc = "Open mini.files (working root)",
      },
    },
    config = function(_, opts)
      require("mini.files").setup(opts)

      local show_dotfiles = true
      local filter_show = function(fs_entry) return true end
      local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        require("mini.files").refresh { content = { filter = new_filter } }
      end

      local go_in_plus = function()
        for _ = 1, vim.v.count1 - 1 do
          MiniFiles.go_in()
        end
        local fs_entry = MiniFiles.get_fs_entry()
        local is_at_file = fs_entry ~= nil and fs_entry.fs_type == "file"
        MiniFiles.go_in()
        if is_at_file then MiniFiles.close() end
      end

      local map_goto_windows = function(buf_id, lhs)
        local rhs = function()
          local id = require("window-picker").pick_window()
          vim.api.nvim_win_call(MiniFiles.get_target_window(), function() MiniFiles.set_target_window(id) end)
          go_in_plus()
        end
        vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = "files: Pick a given window" })
      end

      local map_split = function(buf_id, lhs, direction)
        local rhs = function()
          -- Make new window and set it as target
          local new_target_window
          vim.api.nvim_win_call(MiniFiles.get_target_window(), function()
            vim.cmd(direction .. " split")
            new_target_window = vim.api.nvim_get_current_win()
          end)

          MiniFiles.set_target_window(new_target_window)
          go_in_plus()
        end

        -- Adding `desc` will result into `show_help` entries
        vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = "files: split " .. direction })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          -- Tweak left-hand side of mapping to your liking
          vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "files: toggle dotfiles" })
          map_goto_windows(buf_id, "gw")
          map_split(buf_id, "gs", "belowright horizontal")
          map_split(buf_id, "gv", "belowright vertical")
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(ev) Util.lsp.on_rename(ev.data.from, ev.data.to) end,
      })
    end,
  },
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "sa", -- Add surrounding in Normal and Visual modes
        delete = "sd", -- Delete surrounding
        find = "sf", -- Find surrounding (to the right)
        find_left = "sF", -- Find surrounding (to the left)
        highlight = "sh", -- Highlight surrounding
        replace = "sr", -- Replace surrounding
        update_n_lines = "sn", -- Update `n_lines`
      },
    },
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete surrounding" },
        { opts.mappings.find, desc = "Find right surrounding" },
        { opts.mappings.find_left, desc = "Find left surrounding" },
        { opts.mappings.highlight, desc = "Highlight surrounding" },
        { opts.mappings.replace, desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
        {
          "<leader><leader>s",
          ":normal saiW`<Esc>",
          desc = "Surround inner word with backticks",
          noremap = true,
        },
      }
      mappings = vim.tbl_filter(function(m) return m[1] and #m[1] > 0 end, mappings)
      return vim.list_extend(mappings, keys)
    end,
  },
  {
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    enabled = true,
    event = "LazyFile",
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "", -- for all buffers without a file type
          "alpha",
          "fugitive",
          "git",
          "aerial",
          "dropbar",
          "gitcommit",
          "help",
          "json",
          "log",
          "markdown",
          "neo-tree",
          "Outline",
          "startify",
          "TelescopePrompt",
          "txt",
          "undotree",
          "vimwiki",
          "vista",
          "lazyterm",
        },
        callback = function() vim.b.miniindentscope_disable = true end,
      })
    end,
  },
  {
    "echasnovski/mini.comment",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    keys = {
      { "<Leader>v", "gcc", remap = true, silent = true, mode = "n", desc = "Comment visual line" },
      { "<Leader>v", "gc", remap = true, silent = true, mode = "x", desc = "Uncomment visual line" },
    },
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },
}
