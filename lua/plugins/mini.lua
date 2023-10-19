local simplified_status_ft = {
  "neo-tree",
  "qf",
  "PlenaryTestPopup",
  "help",
  "lspinfo",
  "man",
  "notify",
  "qf",
  "query",
  "man",
  "nowrite", -- fugitive
  "fugitive",
  "prompt",
  "spectre_panel",
  "startuptime",
  "tsplayground",
  "neorepl",
  "alpha",
  "toggleterm",
  "health",
  "nofile",
  "scratch",
  "starter",
  "",
}

return {
  "echasnovski/mini.colors",
  "echasnovski/mini.doc",
  { "echasnovski/mini.align", event = "VeryLazy", opts = {} },
  { "echasnovski/mini.trailspace", event = { "BufRead", "BufNewFile" }, opts = {} },
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<C-x>",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- no
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "buf: delete",
      },
      { "<C-q>", function() require("mini.bufremove").delete(0, true) end, desc = "buf: force delete" },
    },
  },
  {
    "echasnovski/mini.statusline",
    opts = function()
      return {
        content = {
          set_vim_settings = false,
          active = function()
            local mode_info = statusline.modes[vim.fn.mode()]
            local mode_hl = mode_info.hl

            local mode = statusline.mode { trunc_width = 75 }
            local git = statusline.git { trunc_width = 120 }
            local diagnostic = statusline.diagnostic { trunc_width = 90 }
            local filetype = statusline.filetype { trunc_width = 75 }
            local location = statusline.location { trunc_width = 90 }
            local filename = statusline.filename { trunc_width = 75 }

            if vim.tbl_contains(simplified_status_ft, vim.bo.filetype) then
              return MiniStatusline.combine_groups {
                { hl = "MiniStatuslineInactive", strings = { "%F" } },
                "%=",
              }
            end

            return MiniStatusline.combine_groups {
              { hl = mode_hl, strings = { mode } },
              { hl = "MiniStatuslineDevinfo", strings = { git } },
              "%<",
              { hl = "MiniStatuslineFilename", strings = { filename } },
              "%=",
              { hl = "MiniStatuslineDevinfo", strings = { diagnostic } },
              { hl = "MiniStatuslineFileinfo", strings = { filetype } },
              { hl = mode_hl, strings = { location } },
            }
          end,
        },
      }
    end,
    config = function(_, opts) require("mini.statusline").setup(opts) end,
  },
  {
    "echasnovski/mini.files",
    opts = {
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 30,
      },
      options = {
        -- Whether to use for editing directories
        -- Disabled by default in LazyVim because neo-tree is used for that
        use_as_default_explorer = false,
      },
    },
    keys = {
      {
        "<LocalLeader>f",
        function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end,
        desc = "Open mini.files (directory of current file)",
      },
      {
        "<LocalLeader>F",
        function() require("mini.files").open(vim.loop.cwd(), true) end,
        desc = "Open mini.files (cwd)",
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

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          -- Tweak left-hand side of mapping to your liking
          vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(ev) Util.on_rename(ev.data.from, ev.data.to) end,
      })
    end,
  },
  { "echasnovski/mini.pairs", event = "VeryLazy", opts = {} },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = function()
      local ai = require "mini.ai"
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)

      Util.on_load("which-key.nvim", function()
        ---@type table<string, string|table>
        local i = {
          [" "] = "Whitespace",
          ['"'] = 'Balanced "',
          ["'"] = "Balanced '",
          ["`"] = "Balanced `",
          ["("] = "Balanced (",
          [")"] = "Balanced ) including white-space",
          [">"] = "Balanced > including white-space",
          ["<lt>"] = "Balanced <",
          ["]"] = "Balanced ] including white-space",
          ["["] = "Balanced [",
          ["}"] = "Balanced } including white-space",
          ["{"] = "Balanced {",
          ["?"] = "User Prompt",
          _ = "Underscore",
          a = "Argument",
          b = "Balanced ), ], }",
          c = "Class",
          f = "Function",
          o = "Block, conditional, loop",
          q = "Quote `, \", '",
          t = "Tag",
        }
        local a = vim.deepcopy(i)
        for k, v in pairs(a) do
          a[k] = v:gsub(" including.*", "")
        end
        local ic = vim.deepcopy(i)
        local ac = vim.deepcopy(a)
        for key, name in pairs { n = "Next", l = "Last" } do
          i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
          a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
        end
        require("which-key").register {
          mode = { "o", "x" },
          i = i,
          a = a,
        }
      end)
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
      }
      mappings = vim.tbl_filter(function(m) return m[1] and #m[1] > 0 end, mappings)
      return vim.list_extend(mappings, keys)
    end,
  },
  {
    "echasnovski/mini.starter",
    event = "BufEnter",
    opts = function()
      return {
        items = {
          function()
            return {
              { action = Util.telescope("files", {}), name = "Files (.git dependent)", section = "Telescope" },
              { action = Util.telescope("help_tags", {}), name = "Help tags", section = "Telescope" },
              { action = Util.telescope("live_grep", {}), name = "Live grep", section = "Telescope" },
              {
                action = Util.telescope("oldfiles", {}),
                name = "Recent files",
                section = "Telescope",
              },
              {
                action = Util.telescope("command_history", {}),
                name = "Command history",
                section = "Telescope",
              },
              {
                action = Util.telescope("colorscheme", {}),
                name = "Colorscheme",
                section = "Telescope",
              },
              {
                action = function() require("telescope").extensions.frecency.frecency {} end,
                name = "Frequency",
                section = "Telescope",
              },
            }
          end,
          {
            { name = "Edit new buffer", action = "enew", section = "Shortcut" },
            {
              name = "Neovim config",
              action = Util.telescope("files", { cwd = vim.fn.stdpath "config" }),
              section = "Shortcut",
            },
            {
              name = "Garden",
              action = Util.telescope("files", { cwd = vim.fn.expand "~" .. "/workspace/garden" }),
              section = "Shortcut",
            },
            { name = "Quit Neovim", action = "qall", section = "Shortcut" },
          },
        },
      }
    end,
    config = function(_, opts)
      local starter = require "mini.starter"

      opts.content_hook = {
        starter.gen_hook.adding_bullet(),
        starter.gen_hook.aligning("center", "center"),
      }

      starter.setup(opts)
    end,
  },
  {
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      symbol = "│", -- "▏"
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
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
