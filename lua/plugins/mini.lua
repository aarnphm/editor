---@class MiniFilesBufferCreateData
---@field buf_id integer

---@class MiniFilesBufferCreate: vim.api.create_autocmd.callback.args
---@field data MiniFilesBufferCreateData

---@class MiniPickOpts: lazyvim.util.pick.Opts
---@field tool? string
---@field source? table<['cwd'] | string, any>

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
  ---@param opts? MiniPickOpts
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
    event = "LazyFile",
    --joined opts for all mini plugins
    ---@class MiniPluginOpts
    ---@field enabled? boolean
    ---@class MiniOpts: table<string, MiniPluginOpts>
    opts = {
      extra = {},
      align = { mappings = { start = "<leader>ga", start_with_preview = "<leader>gA" } },
      pick = {
        options = { use_cache = true },
        window = {
          prompt_prefix = "󰄾 ",
          config = function()
            local height = math.floor(0.618 * vim.o.lines)
            local width = math.floor(0.618 * vim.o.columns)
            return {
              anchor = "NW",
              height = height,
              width = width,
              row = 1 + math.floor(0.21 * (vim.o.lines + height)),
              col = math.floor(0.5 * (vim.o.columns - width)),
            }
          end,
        },
      },
      bracketed = { window = { suffix = "" }, treesitter = { suffix = "" } },
      files = {
        windows = {
          preview = false,
          width_focus = 30,
          width_nofocus = 30,
          width_preview = math.floor(0.25 * vim.o.columns),
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
        mappings = {
          apply = "",
          reset = "",
          textobject = "",
          goto_first = "",
          goto_prev = "",
          goto_next = "",
          goto_last = "",
        },
      },
      statusline = {
        enabled = false,
        set_vim_settings = false,
        content = {
          active = function()
            local statusline = Util.statusline.generate()

            local m = statusline.mode { trunc_width = 75 }
            local diagnostics = statusline.diagnostic { trunc_width = 75 }
            local lint = statusline.lint { trunc_width = 50 }
            local git = statusline.git { trunc_width = 50 }
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
              { hl = "MiniStatuslineDevinfo", strings = { git, lsp, lint } },
              "%<", -- Mark general truncate point
              { hl = "MiniStatuslineFilename", strings = { filename } },
              "%=", -- End left alignment
              { hl = "MiniStatuslineDevinfo", strings = { diagnostics, fileinfo } },
              { hl = m.hl, strings = { search, location } },
            }
          end,
        },
      },
      indentscope = { enabled = false, symbol = "│", options = { try_as_border = true } },
      icons = {
        file = {
          [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
          [".gitignore"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
          ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
          [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
          [".oxlintrc.json"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
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
          copilot = { glyph = "", hl = "MiniIconsOrange" },
          namespace = { glyph = "󰅪", hl = "MiniIconsRed" },
          null = { glyph = "NULL", hl = "MiniIconGrey" },
          snippet = { glyph = "", hl = "MiniIconsYellow" },
          struct = { glyph = "", hl = "MiniIconsRed" },
          event = { glyph = "", hl = "MiniIconsYellow" },
          operator = { glyph = "", hl = "MiniIconsGrey" },
          typeparameter = { glyph = "", hl = "MiniIconsBlue" },
        },
      },
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
        "<Leader>f",
        Util.pick("files", { tool = "git" }),
        desc = "mini.pick: open (git root)",
      },
      {
        "<LocalLeader>f",
        Util.pick "oldfiles",
        desc = "mini.pick: oldfiles",
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
      -- mini.diff
      {
        "<leader>g",
        function() require("mini.diff").toggle_overlay(0) end,
        desc = "git: toggle diff overlay",
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "Trouble",
          "alpha",
          "dashboard",
          "fzf",
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "notify",
          "snacks_dashboard",
          "snacks_notif",
          "snacks_terminal",
          "snacks_win",
          "toggleterm",
          "trouble",
        },
        callback = function() vim.b.miniindentscope_disable = true end,
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "SnacksDashboardOpened",
        callback = function(data) vim.b[data.buf].miniindentscope_disable = true end,
      })
    end,
    ---@param opts MiniOpts
    config = function(_, opts)
      vim.iter(opts):each(function(module, _opts)
        local config = type(_opts) == "function" and _opts() or _opts --[[@as MiniPluginOpts]]
        if config.enabled == false then return end
        config.enabled = nil
        if Util.mini[module] ~= nil then
          Util.mini[module](config)
        else
          require("mini." .. module).setup(config)
        end
      end)
    end,
  },
}
