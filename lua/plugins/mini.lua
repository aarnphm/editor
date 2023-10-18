return {
  { "echasnovski/mini.colors", version = false },
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
  { "echasnovski/mini.align", event = "VeryLazy" },
  {
    "echasnovski/mini.statusline",
    opts = function()
      return {
        content = {
          set_vim_settings = false,
          active = function()
            local get_filetype_icon = function()
              -- Have this `require()` here to not depend on plugin initialization order
              local has_devicons, devicons = pcall(require, "nvim-web-devicons")
              if not has_devicons then return "" end

              local file_name, file_ext = vim.fn.expand "%:t", vim.fn.expand "%:e"
              return devicons.get_icon(file_name, file_ext, { default = true })
            end

            -- For more information see ":h buftype"
            local isnt_normal_buffer = function() return vim.bo.buftype ~= "" end

            local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }

            local construct_filetype = function()
              local filetype = vim.bo.filetype
              -- Don't show anything if can't detect file type or not inside a "normal buffer"
              if (filetype == "") or isnt_normal_buffer() then return "" end

              -- Add filetype icon
              local icon = get_filetype_icon()
              if icon ~= "" then filetype = string.format("%s  %s", icon, filetype) end
              return filetype
            end

            return MiniStatusline.combine_groups {
              { hl = mode_hl, strings = { mode } },
              { hl = "MiniStatuslineDevinfo", strings = { statusline.git() } },
              "%<",
              { hl = "MiniStatuslineFilename", strings = { MiniStatusline.section_filename { trunc_width = 140 } } },
              "%=",
              "%=",
              { hl = "MiniStatuslineDevinfo", strings = { statusline.diagnostic() } },
              { hl = "MiniStatuslineFileinfo", strings = { construct_filetype() } },
              { hl = mode_hl, strings = { "%l:%c" } },
              { hl = mode_hl, strings = { "♥" } },
            }
          end,
        },
      }
    end,
    config = function(_, opts) require("mini.statusline").setup(opts) end,
  },
  { "echasnovski/mini.trailspace", event = "VeryLazy" },
  { "echasnovski/mini.pairs", event = "VeryLazy", opts = {} },
  {
    "echasnovski/mini.ai",
    event = "InsertEnter",
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
    "echasnovski/mini.comment",
    event = "VeryLazy",
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },
}
