---@class MiniFilesBufferCreateData
---@field buf_id integer
---
---@class MiniFilesBufferCreate: vim.api.create_autocmd.callback.args
---@field data MiniFilesBufferCreateData

Util.pick.register {
  name = "mini.pick",
  commands = {
    files = "files",
    live_grep = "grep_live",
  },
  -- this will return a function that calls telescope.
  -- cwd will default to lazyvim.util.get_root
  -- for `files`, git_files or find_files will be chosen depending on .git
  ---@param builtin string
  ---@param opts? lazyvim.util.pick.Opts
  open = function(builtin, opts)
    local extras = require "mini.extra"
    opts = opts or {}
    if opts.tool ~= nil then
      opts.source = vim.tbl_deep_extend("force", opts.source or {}, { cwd = opts.cwd })
      opts.cwd = nil
    end
    if extras.pickers[builtin] then
      extras.pickers[builtin](opts)
    else
      require("mini.pick").builtin[builtin](opts)
    end
  end,
}

return {
  {
    "echasnovski/mini.nvim",
    version = false,
    event = "VeryLazy",
    dependencies = {
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        version = false,
        lazy = true,
        opts = { enable_autocmd = false },
      },
      {
        "j-hui/fidget.nvim",
        enabled = function() return not vim.g.enable_ui end,
        version = false,
        opts = { progress = { display = { render_limit = 3 } } },
      },
      {
        "s1n7ax/nvim-window-picker",
        name = "window-picker",
        lazy = true,
        opts = {
          hint = "floating-big-letter",
          show_prompt = false,
          filter_rules = {
            autoselect_one = true,
            include_current = false,
            bo = {
              filetype = { "notify", "noice" },
              buftype = { "terminal", "quickfix", "Scratch", "aerial", "noice" },
            },
          },
        },
      },
    },
    -- joined opts for all mini plugins
    ---@class MiniOpts
    opts = {
      extra = {},
      trailspace = {},
      doc = {},
      align = { mappings = { start = "<leader>ga", start_with_preview = "<leader>gA" } },
      pick = { options = { use_cache = true }, window = { prompt_prefix = "󰄾 " } },
      bracketed = { window = { suffix = "" }, treesitter = { suffix = "" } },
      -- indentscope = { symbol = "│", options = { try_as_border = true } },
      comment = {
        options = {
          custom_commentstring = function()
            return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
          end,
        },
      },
      files = {
        windows = {
          preview = false,
          width_focus = 30,
          width_nofocus = 30,
          width_preview = math.floor(0.45 * vim.o.columns),
          max_number = 3,
        },
        mappings = { synchronize = "<leader>" },
      },
      ---@class MiniSurroundOpts
      surround = {
        mappings = {
          add = "gsa", -- Add surrounding in Normal and Visual modes
          delete = "gsd", -- Delete surrounding
          find = "gsf", -- Find surrounding (to the right)
          find_left = "gsF", -- Find surrounding (to the left)
          highlight = "gsh", -- Highlight surrounding
          replace = "gsr", -- Replace surrounding
          update_n_lines = "gsn", -- Update `n_lines`
        },
      },
      pairs = {
        modes = { insert = true, command = true, terminal = false },
        -- skip autopair when next character is one of these
        skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
        -- skip autopair when the cursor is inside these treesitter nodes
        skip_ts = { "string" },
        -- skip autopair when next character is closing pair
        -- and there are more closing pairs than opening pairs
        skip_unbalanced = true,
        -- better deal with markdown code blocks
        markdown = true,
        -- manually disable based on filetype
        filetypes = { "lua", "python" },
      },
      diff = {
        view = {
          style = "sign",
          signs = {
            add = "▎",
            change = "▎",
            delete = "",
          },
        },
      },
      icons = {
        file = {
          [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
          [".gitignore"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
          ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
          [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
          [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
          [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
          [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
          ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
          ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
          ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
          ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
          ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
          [".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
          [".rgignore"] = { glyph = "", hl = "MiniIconsYellow" },
          ["*.py"] = { glyph = "󰌠", hl = "MiniIconsYellow" },
        },
        filetype = {
          dotenv = { glyph = "", hl = "MiniIconsYellow" },
          gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
        },
        lsp = {
          supermaven = { glyph = "", hl = "MiniIconsOrange" },
          namespace = { glyph = "󰅪", hl = "MiniIconsRed" },
          null = { glyph = "NULL", hl = "MiniIconGrey" },
          snippet = { glyph = "", hl = "MiniIconsYellow" },
          struct = { glyph = "", hl = "MiniIconsRed" },
          event = { glyph = "", hl = "MiniIconsYellow" },
          operator = { glyph = "", hl = "MiniIconsGrey" },
          typeparameter = { glyph = "", hl = "MiniIconsBlue" },
        },
      },
      statusline = {
        set_vim_settings = false,
        content = {
          active = function()
            local statusline = make_statusline()

            local m = statusline.mode { trunc_width = 75 }
            local diagnostics = statusline.diagnostic { trunc_width = 75 }
            local lint = statusline.lint { trunc_width = 50 }
            local filename = MiniStatusline.section_filename { trunc_width = 140 }
            local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
            local fileinfo = statusline.fileinfo { trunc_width = 90 }
            local location = statusline.location { trunc_width = 90 }
            local search = MiniStatusline.section_searchcount { trunc_width = 75 }

            -- Usage of `MiniStatusline.combine_groups()` ensures highlighting and
            -- correct padding with spaces between groups (accounts for 'missing'
            -- sections, etc.)
            return MiniStatusline.combine_groups {
              { hl = m.hl, strings = { m.md } },
              { hl = "MiniStatuslineDevinfo", strings = { lsp, lint } },
              "%<", -- Mark general truncate point
              { hl = "MiniStatuslineFilename", strings = { filename } },
              "%=", -- End left alignment
              { hl = "MiniStatuslineDevinfo", strings = { diagnostics, fileinfo } },
              { hl = m.hl, strings = { search, location } },
            }
          end,
        },
      },
      hipatterns = function()
        local hi = require "mini.hipatterns"
        return {
          -- custom LazyVim option to enable the tailwind integration
          tailwind = {
            enabled = true,
            ft = {
              "astro",
              "css",
              "heex",
              "html",
              "html-eex",
              "javascript",
              "javascriptreact",
              "rust",
              "svelte",
              "typescript",
              "typescriptreact",
              "vue",
            },
            -- full: the whole css class will be highlighted
            -- compact: only the color will be highlighted
            style = "full",
          },
          highlighters = {
            hex_color = hi.gen_highlighter.hex_color { priority = 2000 },
            shorthand = {
              pattern = "()#%x%x%x()%f[^%x%w]",
              group = function(_, _, data)
                ---@type string
                local match = data.full_match
                local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
                local hex_color = "#" .. r .. r .. g .. g .. b .. b

                return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
              end,
              extmark_opts = { priority = 2000 },
            },
          },
        }
      end,
      ai = function()
        ---@module "mini.ai"
        local ai = require "mini.ai"
        local extra = require "mini.extra"
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
            i = extra.gen_ai_spec.indent(), -- indent
            g = extra.gen_ai_spec.buffer(), -- buffer
            u = ai.gen_spec.function_call(), -- u for "Usage"
            U = ai.gen_spec.function_call { name_pattern = "[%w_]" }, -- without dot in function name
          },
        }
      end,
    },
    specs = { { "nvim-tree/nvim-web-devicons", enabled = false, optional = true } },
    keys = {
      -- mini.pick
      {
        "<LocalLeader>f",
        Util.pick("files", { tool = "git" }),
        desc = "mini.pick: open (git root)",
      },
      {
        "<Leader>f",
        Util.pick "oldfiles",
        desc = "mini.pick: oldfiles",
      },
      {
        "<LocalLeader>w",
        Util.pick "live_grep",
        desc = "mini.pick: grep word",
      },
      {
        "<LocalLeader>x",
        Util.pick "diagnostic",
        desc = "mini.pick: diagnostics",
      },
      {
        "<Leader>/",
        '<CMD>:Pick grep pattern="<cword>"<CR>',
        desc = "mini.pick: grep word",
      },
      -- mini.files
      {
        "<LocalLeader>/",
        function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end,
        desc = "mini.files: open (directory of current file)",
      },
      {
        "<LocalLeader>.",
        function() require("mini.files").open(Util.root.git(), true) end,
        desc = "mini.files: open (working root)",
      },
      -- mini.comment
      { "<Leader>v", "gcc", remap = true, silent = true, mode = "n", desc = "comment: visual line" },
      { "<Leader>v", "gc", remap = true, silent = true, mode = "x", desc = "comment: visual line" },
      -- mini.diff
      {
        "<leader>go",
        function() require("mini.diff").toggle_overlay(0) end,
        desc = "git: toggle diff overlay",
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
    ---@param opts MiniOpts
    config = function(_, opts)
      vim.iter(opts):each(function(module, _opts)
        if Util.mini[module] ~= nil then
          Util.mini[module](_opts)
        else
          require("mini." .. module).setup(_opts)
        end
      end)
    end,
  },
  {
    "echasnovski/mini.starter",
    version = false,
    event = "VimEnter",
    opts = function()
      local logo = table.concat({
        [[                                  __]],
        [[     ___     ___    ___   __  __ /\_\    ___ ___]],
        [[    / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\]],
        [[   /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \]],
        [[   \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
        [[    \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
      }, "\n")
      local pad = string.rep(" ", 15)

      ---@param name string shortcuts to show on starter
      ---@param action string | fun(...): any any callable or commands
      ---@param section string given name under which section
      local new_section = function(name, action, section)
        return { name = name, action = action, section = pad .. section }
      end

      local starter = require "mini.starter"
      local config = {
        evaluate_single = true,
        header = logo,
        items = {
          new_section("Files", Util.pick "files", "Picker"),
          new_section("Recents", Util.pick "oldfiles", "Picker"),
          new_section("Text", Util.pick "live_grep", "Picker"),
          new_section("Config", Util.pick.config_files(), "Config"),
          new_section("Lazy", "Lazy", "Config"),
          new_section("New", "ene | startinsert", "Builtin"),
          new_section("Quit", "qa", "Builtin"),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(pad .. "░ ", false),
          starter.gen_hook.aligning("center", "center"),
        },
      }
      return config
    end,
    config = function(_, config)
      -- close Lazy and re-open when starter is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "MiniStarterOpened",
          callback = function() require("lazy").show() end,
        })
      end

      local starter = require "mini.starter"
      starter.setup(config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function(ev)
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          local pad_footer = string.rep(" ", 8)
          starter.config.footer = pad_footer .. "⚡ loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          -- INFO: based on @echasnovski's recommendation (thanks a lot!!!)
          if vim.bo[ev.buf].filetype == "ministarter" then pcall(starter.refresh) end
        end,
      })
    end,
  },
}
