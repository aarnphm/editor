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

local M = {}

return {
  "echasnovski/mini.colors",
  { "echasnovski/mini.pairs", event = "VeryLazy", opts = {} },
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
    "echasnovski/mini.files",
    opts = {
      windows = { preview = true, width_focus = 30, width_nofocus = 30, widthopreview = 30 },
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

      Util.on_load(
        "which-key.nvim",
        function()
          require("which-key").register {
            mode = { "n", "v" },
            s = {
              name = "Surround",
              a = "Add surrounding",
              d = "Delete surrounding",
              f = "Find surrounding (to the right)",
              F = "Find surrounding (to the left)",
              h = "Highlight surrounding",
              r = "Replace surrounding",
              n = "Update `MiniSurround.config.n_lines`",
            },
          }
        end
      )
      return vim.list_extend(mappings, keys)
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
