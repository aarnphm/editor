--# selene: allow(global_usage)

-- NOTE: compatible block with vscode
if vim.g.vscode then return end

require "globals"

local icons = _G.icons
local utils = require "utils"
local user = require "options"

-- bootstrap logics
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  }
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
  -- NOTE: utilities
  "lewis6991/impatient.nvim",
  "nvim-lua/plenary.nvim",
  "nvim-tree/nvim-web-devicons",
  {
    "stevearc/dressing.nvim",
    opts = {
      input = {
        enabled = true,
        override = function(config)
          return vim.tbl_deep_extend("force", config, { col = -1, row = 0 })
        end,
      },
      select = { enabled = true, backend = "telescope", trim_prompt = true },
    },
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.input(...)
      end
    end,
    config = true,
  },
  -- NOTE: cozy colorscheme
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    opts = {
      disable_italics = true,
      dark_variant = "main",
      highlight_groups = {
        Comment = { fg = "muted", italic = true },
        StatusLine = { fg = "rose", bg = "iris", blend = 10 },
        StatusLineNC = { fg = "subtle", bg = "surface" },
        TelescopeBorder = { fg = "highlight_high" },
        TelescopeNormal = { fg = "subtle" },
        TelescopePromptNormal = { fg = "text" },
        TelescopeSelection = { fg = "text" },
        TelescopeSelectionCaret = { fg = "iris" },
      },
    },
  },
  -- NOTE: nice git integration and UI
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    opts = {
      numhl = true,
      watch_gitdir = { interval = 1000, follow_files = true },
      current_line_blame = true,
      current_line_blame_opts = { delay = 1000, virtual_text_pos = "eol" },
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      word_diff = false,
      diff_opts = { internal = true },
      on_attach = function(bufnr)
        local actions = require "gitsigns.actions"
        local kmap = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        -- stylua: ignore start
        kmap("n", "]h", actions.next_hunk, "git: next hunk")
        kmap("n", "[h", actions.prev_hunk, "git: prev hunk")
        kmap("n", "<leader>hu", actions.undo_stage_hunk, "git: undo stage hunk")
        kmap("n", "<leader>hR", actions.reset_buffer, "git: reset buffer")
        kmap("n", "<leader>hS", actions.stage_buffer, "git: stage buffer")
        kmap("n", "<leader>hp", actions.preview_hunk, "git: preview hunk")
        kmap("n", "<leader>hd", actions.diffthis, "git: diff this")
        kmap("n", "<leader>hD", function() actions.diffthis("~") end, "git: diff this ~")
        kmap("n", "<leader>hb", function() actions.blame_line({ full = true }) end, "git: blame Line")
        kmap({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "git: stage hunk")
        kmap({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "git: reset hunk")
        kmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        -- stylua: ignore end
      end,
    },
  },
  -- NOTE: Gigachad Git
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = {
      {
        "<Leader>p",
        function() vim.cmd [[ Git pull --rebase ]] end,
        desc = "git: pull rebase",
      },
      { "<Leader>P", function() vim.cmd [[ Git push ]] end, desc = "git: push" },
    },
  },
  -- NOTE: exit fast af
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = { timeout = 200, clear_empty_lines = true, keys = "<Esc>" },
  },
  -- NOTE: treesitter-based dependencies
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      if #vim.api.nvim_list_uis() ~= 0 then vim.api.nvim_command "TSUpdate" end
    end,
    event = "BufReadPost",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        init = function()
          -- PERF: no need to load the plugin, if we only need its queries for mini.ai
          local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
          local opts = require("lazy.core.plugin").values(plugin, "opts", false)
          local enabled = false
          if opts.textobjects then
            for _, mod in ipairs { "move", "select", "swap", "lsp_interop" } do
              if opts.textobjects[mod] and opts.textobjects[mod].enable then
                enabled = true
                break
              end
            end
          end
          if not enabled then
            require("lazy.core.loader").disable_rtp_plugin "nvim-treesitter-textobjects"
          end
        end,
      },
    },
    keys = { { "<bs>", desc = "Decrement selection", mode = "x" } },
    opts = {
      ensure_installed = {
        "python",
        "rust",
        "lua",
        "c",
        "cpp",
        "toml",
        "bash",
        "css",
        "vim",
        "regex",
        "markdown",
        "markdown_inline",
        "yaml",
        "go",
      },
      ignore_install = { "phpdoc", "gitcommit" },
      indent = { enable = true },
      highlight = { enable = true },
      context_commentstring = { enable = true, enable_autocmd = false },
      autotag = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-a>",
          node_incremental = "<C-a>",
          scope_incremental = "<nop>",
          node_decremental = "<bs>",
        },
      },
    },
    config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
  },
  -- NOTE: comments, you say what?
  {
    "numToStr/Comment.nvim",
    lazy = true,
    event = "BufReadPost",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = true,
  },
  -- NOTE: mini libraries of deps because it is light and easy to use.
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<C-x>",
        function() require("mini.bufremove").delete(0, false) end,
        desc = "buf: delete",
      },
      {
        "<C-q>",
        function() require("mini.bufremove").delete(0, true) end,
        desc = "buf: force delete",
      },
    },
  },
  { 'echasnovski/mini.colors', version = false },
  {
    -- better text-objects
    "echasnovski/mini.ai",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter-textobjects" },
    opts = function()
      local ai = require "mini.ai"
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter(
            { a = "@function.outer", i = "@function.inner" },
            {}
          ),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      utils.on_load("which-key.nvim", function()
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
          i[key] =
              vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
          a[key] =
              vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
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
    "echasnovski/mini.align",
    event = "InsertEnter",
    config = function(_, opts) require("mini.align").setup(opts) end,
  },
  {
    "echasnovski/mini.surround",
    event = "InsertEnter",
    config = function(_, opts) require("mini.surround").setup(opts) end,
  },
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    config = function(_, opts) require("mini.pairs").setup(opts) end,
  },
  -- NOTE: cuz sometimes `set list` is not enough and you need some indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = 'ibl',
    opts = {
      debounce = 200,
      indent = {
        char = "│",
        tab_char = "│",
        smart_indent_cap = true,
        priority = 2,
      },
      whitespace = { remove_blankline_trail = true },
      -- Note: The `scope` field requires treesitter to be set up
      scope = {
        enabled = true,
        char = "┃",
        show_start = false,
        show_end = false,
        injected_languages = true,
        priority = 1000,
        include = {
          node_type = {
            ["*"] = {
              "argument_list",
              "arguments",
              "assignment_statement",
              "Block",
              "chunk",
              "class",
              "ContainerDecl",
              "dictionary",
              "do_block",
              "do_statement",
              "element",
              "except",
              "FnCallArguments",
              "for",
              "for_statement",
              "function",
              "function_declaration",
              "function_definition",
              "if_statement",
              "IfExpr",
              "IfStatement",
              "import",
              "InitList",
              "list_literal",
              "method",
              "object",
              "ParamDeclList",
              "repeat_statement",
              "selector",
              "SwitchExpr",
              "table",
              "table_constructor",
              "try",
              "tuple",
              "type",
              "var",
              "while",
              "while_statement",
              "with",
            },
          },
        },
      },
      exclude = {
        filetypes = {
          "", -- for all buffers without a file type
          "alpha",
          "big_file_disabled_ft",
          "dashboard",
          "dotooagenda",
          "flutterToolsOutline",
          "fugitive",
          "git",
          "gitcommit",
          "help",
          "json",
          "log",
          "markdown",
          "NvimTree",
          "Outline",
          "peekaboo",
          "startify",
          "TelescopePrompt",
          "todoist",
          "txt",
          "undotree",
          "vimwiki",
          "vista",
        },
        buftypes = { "terminal", "nofile", "quickfix", "prompt" },
      },
    },
  },
  -- NOTE: folke is neovim's tpope
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
    opts = { use_diagnostic_signs = true },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      {
        "[q",
        function()
          if #vim.fn.getqflist() > 0 then
            if require("trouble").is_open() then
              require("trouble").previous { skip_groups = true, jump = true }
            else
              vim.cmd.cprev()
            end
          else
            vim.notify("trouble: No items in quickfix", vim.log.levels.INFO)
          end
        end,
        desc = "qf: Previous item",
      },
      {
        "]q",
        function()
          if #vim.fn.getqflist() > 0 then
            if require("trouble").is_open() then
              require("trouble").next { skip_groups = true, jump = true }
            else
              vim.cmd.cnext()
            end
          else
            vim.notify("trouble: No items in quickfix", vim.log.levels.INFO)
          end
        end,
        desc = "qf: Next item",
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "BufReadPost",
    opts = { plugins = { presets = { operators = false } } },
    config = function(_, opts) require("which-key").setup(opts) end,
  },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    keys = {
      {
        "]t",
        function() require("todo-comments").jump_next() end,
        desc = "todo: Next comment",
      },
      {
        "[t",
        function() require("todo-comments").jump_prev() end,
        desc = "todo: Previous comment",
      },
    },
  },
  -- NOTE: fuzzy finder ftw
  {
    "nvim-telescope/telescope.nvim",
    event = "BufReadPost",
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
      "jvgrootveld/telescope-zoxide",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make -C ~/.local/share/nvim/lazy/telescope-fzf-native.nvim",
      },
    },
    keys = {
      {
        "<Leader>f",
        function()
          require("telescope.builtin").find_files {
            find_command = {
              "fd",
              "-H",
              "-tf",
              "-E",
              "lazy-lock.json",
              "--strip-cwd-prefix",
            },
            theme = "dropdown",
            previewer = false,
          }
        end,
        desc = "telescope: Find files in current directory",
        noremap = true,
        silent = true,
      },
      {
        "<Leader>r",
        function()
          require("telescope.builtin").git_files {
            find_command = {
              "fd",
              "-H",
              "-tf",
              "-E",
              "lazy-lock.json",
              "--strip-cwd-prefix",
            },
            theme = "dropdown",
            previewer = false,
          }
        end,
        desc = "telescope: Find files in git repository",
        noremap = true,
        silent = true,
      },
      {
        "<Leader>'",
        function() require("telescope.builtin").live_grep {} end,
        desc = "telescope: Live grep",
        noremap = true,
        silent = true,
      },
      {
        "<Leader>w",
        function() require("telescope").extensions.live_grep_args.live_grep_args() end,
        desc = "telescope: Live grep args",
        noremap = true,
        silent = true,
      },
      {
        "<Leader>/",
        "<cmd>Telescope grep_string<cr>",
        desc = "telescope: Grep string under cursor",
        noremap = true,
        silent = true,
      },
      {
        "<Leader>b",
        "<cmd>Telescope buffers show_all_buffers=true previewer=false<cr>",
        desc = "telescope: Manage buffers",
        noremap = true,
        silent = true,
      },
      {
        "<C-p>",
        function()
          require("telescope.builtin").keymaps {
            lhs_filter = function(lhs) return not string.find(lhs, "Þ") end,
            layout_config = {
              width = 0.6,
              height = 0.6,
              prompt_position = "top",
            },
          }
        end,
        desc = "telescope: Keymaps",
        noremap = true,
        silent = true,
      },
    },
    config = function()
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
          prompt_prefix = " " .. icons.ui_space.Telescope .. " ",
          selection_caret = icons.ui_space.DoubleSeparator,
          file_ignore_patterns = {
            ".git/",
            "node_modules/",
            "static_content/",
            "lazy-lock.json",
            "pdm.lock",
          },
          mappings = {
            i = {
              ["<C-a>"] = { "<esc>0i", type = "command" },
              ["<Esc>"] = require("telescope.actions").close,
            },
            n = { ["q"] = require("telescope.actions").close },
          },
          layout_config = { width = 0.8, height = 0.8, prompt_position = "top" },
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          color_devicons = true,
          file_previewer = require("telescope.previewers").vim_buffer_cat.new,
          grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
          qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
          file_sorter = require("telescope.sorters").get_fuzzy_file,
          generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
          buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
        },
        extensions = {
          live_grep_args = {
            auto_quoting = false,
            mappings = {
              i = {
                ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
                ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt {
                  postfix = " --iglob ",
                },
                ["<C-j>"] = require("telescope-live-grep-args.actions").quote_prompt {
                  postfix = " -t ",
                },
              },
            },
          },
        },
        fzf = {
          fuzzy = false,             -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case",  -- or "ignore_case" or "respect_case"
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

      require("telescope").setup(opts)
      require("telescope").load_extension "live_grep_args"
      require("telescope").load_extension "fzf"
      require("telescope").load_extension "zoxide"
    end,
  },
  -- NOTE: better nvim-tree.lua
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    branch = "v3.x",
    deactivate = function() vim.cmd([[Neotree close]]) end,
    init = function()
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    dependencies = {
      { "MunifTanjim/nui.nvim", lazy = true },
      "nvim-lua/plenary.nvim",
      {
        "s1n7ax/nvim-window-picker",
        lazy = true,
        opts = {
          autoselect_one = true,
          include_current = false,
          filter_rules = {
            -- filter using buffer options
            bo = {
              -- if the file type is one of following, the window will be ignored
              filetype = { "neo-tree", "neo-tree-popup", "notify" },
              -- if the buffer type is one of following, the window will be ignored
              buftype = { "terminal", "quickfix", "Scratch" },
            },
          },
        },
        config = function(_, opts) require("window-picker").setup(opts) end,
      },
    },
    keys = {
      {
        "<C-n>",
        function() require("neo-tree.command").execute { toggle = true, dir = vim.loop.cwd() } end,
        desc = "explorer: root dir",
      },
    },
    opts = {
      close_if_last_window = true,
      enable_diagnostics = false, -- default is set to true here.
      filesystem = {
        bind_to_cwd = false,
        use_libuv_file_watcher = true, -- use system level watcher for file change
        follow_current_file = { enabled = true },
        filtered_items = {
          visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            "node_modules",
            "pdm.lock",
          },
          hide_by_pattern = { -- uses glob style patterns
            "*.meta",
            "*/src/*/tsconfig.json",
            "*/.ruff_cache/*",
            "*/__pycache__/*",
          },
        },
      },
      event_handlers = {
        {
          event = "neo_tree_window_after_open",
          handler = function(args)
            if args.position == "left" or args.position == "right" then vim.cmd "wincmd =" end
          end,
        },
        {
          event = "neo_tree_window_after_close",
          handler = function(args)
            if args.position == "left" or args.position == "right" then vim.cmd "wincmd =" end
          end,
        },
        -- disable last status on neo-tree
        -- If I use laststatus, then uncomment this
        {
          event = "neo_tree_buffer_enter",
          handler = function() vim.opt_local.laststatus = 0 end,
        },
        {
          event = "neo_tree_buffer_leave",
          handler = function() vim.opt_local.laststatus = 2 end,
        },
      },
      always_show = { ".github" },
      window = {
        mappings = {
          ["<space>"] = "none", -- disable space since it is leader
          ["s"] = "split_with_window_picker",
          ["v"] = "vsplit_with_window_picker",
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
      },
    },
    config = function(_, opts)
      local function on_move(data)
        utils.on_rename(data.source, data.destination)
      end

      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED,   handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })
      require("neo-tree").setup(opts)
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*lazygit",
        callback = function()
          if package.loaded["neo-tree.sources.git_status"] then
            require("neo-tree.sources.git_status").refresh()
          end
        end,
      })
    end,
  },
  -- NOTE: spectre for magic search and replace
  {
    "nvim-pack/nvim-spectre",
    event = "BufReadPost",
    keys = {
      {
        "<Leader>so",
        function() require("spectre").open() end,
        desc = "replace: Open panel",
      },
      {
        "<Leader>so",
        function() require("spectre").open_visual() end,
        desc = "replace: Open panel",
        mode = "v",
      },
      {
        "<Leader>sw",
        function() require("spectre").open_visual { select_word = true } end,
        desc = "replace: Replace word under cursor",
      },
      {
        "<Leader>sp",
        function() require("spectre").open_file_search() end,
        desc = "replace: Replace word under file search",
      },
    },
    opts = {
      live_update = true,
      mapping = {
        ["change_replace_sed"] = {
          map = "<LocalLeader>trs",
          cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
          desc = "replace: Using sed",
        },
        ["change_replace_oxi"] = {
          map = "<LocalLeader>tro",
          cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
          desc = "replace: Using oxi",
        },
        ["toggle_live_update"] = {
          map = "<LocalLeader>tu",
          cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
          desc = "replace: update live changes",
        },
        -- only work if the find_engine following have that option
        ["toggle_ignore_case"] = {
          map = "<LocalLeader>ti",
          cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
          desc = "replace: toggle ignore case",
        },
        ["toggle_ignore_hidden"] = {
          map = "<LocalLeader>th",
          cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
          desc = "replace: toggle search hidden",
        },
      },
    },
  },
  -- NOTE: nice winbar
  {
    "Bekaboo/dropbar.nvim",
    config = true,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      icons = {
        enable = true,
        ui = {
          bar = { separator = "  ", extends = "…" },
          menu = { separator = " ", indicator = "  " },
        },
      },
    },
  },
  { "smjonas/inc-rename.nvim", cmd = "IncRename", config = true },
  -- NOTE: lspconfig
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "mason.nvim",
      {
        "dnlhc/glance.nvim",
        cmd = "Glance",
        lazy = true,
        config = true,
        opts = { border = { enable = false } },
      },
      "hrsh7th/cmp-nvim-lsp",
    },
    ---@class LspOptions
    opts = {
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = false,
      },
      -- add any global capabilities here
      capabilities = {},
      -- Automatically format on save
      autoformat = false,
      -- Enable this to show formatters used in a notification
      -- Useful for debugging formatter issues
      format_notify = false,
      -- options for vim.lsp.buf.format
      -- `bufnr` and `filter` is handled by the formatter,
      -- but can be also overridden when specified
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      ---@type lspconfig.options
      servers = {
        pyright = {
          flags = { debounce_text_changes = 500 },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "WORKSPACE",
              ".git",
              "Pipfile",
              "pyrightconfig.json",
              "hatch.toml",
              "setup.py",
              "setup.cfg",
              "pyproject.toml",
              "requirements.txt"
            )(fname) or require("lspconfig.util").path.dirname(fname)
          end,
          settings = {
            python = {
              autoImportCompletions = true,
              autoSearchPaths = true,
              diagnosticMode = "workspace", -- workspace
              useLibraryCodeForTypes = true,
            },
          },
        },
        -- pylyzer = {
        -- 	settings = {
        -- 		python = {
        -- 			checkOnType = false,
        -- 			diagnostics = false,
        -- 			inlayHints = false,
        -- 			smartCompletion = true,
        -- 		},
        -- 	},
        -- },
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              hint = { enable = true, setType = true },
              runtime = {
                version = "LuaJIT",
                special = { reload = "require" },
              },
              diagnostics = {
                globals = { "vim" },
                disable = { "different-requires" },
              },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              semantic = { enable = false },
            },
          },
        },
      },
      taplo = {},
      ---@type table<string, fun(lspconfig:any, options:_.lspconfig.options):boolean?>
      setup = {},
    },
    ---@param opts LspOptions
config = function(client, opts)
      local lspconfig = require "lspconfig"
      utils.on_attach(function(client, bufnr) require('keymaps').on_attach(client, bufnr) end)
    local register_capability = vim.lsp.handlers["client/registerCapability"]

    vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
      local ret = register_capability(err, res, ctx)
      local client_id = ctx.client_id
      ---@type lsp.Client
      local client = vim.lsp.get_client_by_id(client_id)
      local buffer = vim.api.nvim_get_current_buf()
      require('keymaps').on_attach(client, buffer)
      return ret
    end

    local inlay_hint = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint

    if opts.inlay_hints.enabled and inlay_hint then utils.on_attach(function(client, bufnr)
      if client.supports_method "textDocument/inlayHint" then inlay_hint(bufnr, true) end
    end) end

    utils.on_attach(function(client, bufnr)
      -- if client.server_capabilities["documentSymbolProvider"] then require("nvim-navic").attach(client, bufnr) end
      if client.supports_method "textDocument/publishDiagnostics" then
        vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
          signs = true,
          underline = true,
          virtual_text = false,
          update_in_insert = true,
        })
      end
    end)

    -- diagnostic
    for _, type in pairs {
      { "Error", "✖" },
      { "Warn", "▲" },
      { "Hint", "⚑" },
      { "Info", "●" },
    } do
      local hl = string.format("DiagnosticSign%s", type[1])
      vim.fn.sign_define(hl, { text = type[2], texthl = hl, numhl = hl })
    end

    vim.diagnostic.config {
      severity_sort = true,
      underline = false,
      update_in_insert = false,
      virtual_text = false,
      float = {
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        focusable = false,
        focus = false,
        format = function(diagnostic) return string.format("%s (%s)", diagnostic.message, diagnostic.source) end,
        source = "if_many",
        border = "single",
      },
    }

    local servers = opts.servers
    local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    local capabilities = vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), has_cmp and cmp_nvim_lsp.default_capabilities() or {}, opts.capabilities or {})

    local mason_handler = function(server)
      local server_opts = vim.tbl_deep_extend("force", {
        capabilities = vim.deepcopy(capabilities),
        flags = { debounce_text_changes = 150 },
      }, servers[server] or {})

      if opts.setup[server] then
        if opts.setup[server](lspconfig, server_opts) then return end
      elseif opts.setup["*"] then
        if opts.setup["*"](lspconfig, server_opts) then return end
      else
        lspconfig[server].setup(server_opts)
      end
    end

    local have_mason, mason_lspconfig = pcall(require, "mason-lspconfig")
    local available = {}
    if have_mason then available = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package) end

    local ensure_installed = {} ---@type string[]
    for server, server_opts in pairs(servers) do
      if server_opts then
        server_opts = server_opts == true and {} or server_opts
        -- NOTE: servers that are isolated should be setup manually.
        if server_opts.isolated then
          ensure_installed[#ensure_installed + 1] = server
        else
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(available, server) then
            mason_handler(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end
    end

    if have_mason then mason_lspconfig.setup { ensure_installed = ensure_installed, handlers = { mason_handler } } end
    end,  
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = { ensure_installed = { "lua-language-server" } },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require "mason-registry"
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then p:install() end
      end
    end,
  },
  -- NOTE: Setup completions.
  {

    "hrsh7th/nvim-cmp",
    ---@diagnostic disable-next-line: assign-type-mismatch
    version = false,
    event = "InsertEnter",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
        opts = { history = true, delete_check_events = "TextChanged" },
      },
    },
    config = function()
      local cmp = require "cmp"

      local cmp_format = function(opts)
        opts = opts or {}
        return function(entry, vim_item)
          if opts.before then vim_item = opts.before(entry, vim_item) end

          local item = icons.kind[vim_item.kind]
              or icons.type[vim_item.kind]
              or icons.cmp[vim_item.kind]
              or icons.kind.Undefined

          vim_item.kind = string.format("  %s  %s", item, vim_item.kind)

          if opts.maxwidth ~= nil then
            if opts.ellipsis_char == nil then
              vim_item.abbr = string.sub(vim_item.abbr, 1, opts.maxwidth)
            else
              local label = vim_item.abbr
              local truncated_label = vim.fn.strcharpart(label, 0, opts.maxwidth)
              if truncated_label ~= label then
                vim_item.abbr = truncated_label .. opts.ellipsis_char
              end
            end
          end
          return vim_item
        end
      end

      local check_backspace = function()
        local col = vim.fn.col "." - 1
        ---@diagnostic disable-next-line: param-type-mismatch
        local current_line = vim.fn.getline "."
        ---@diagnostic disable-next-line: undefined-field
        return col == 0 or current_line:sub(col, col):match "%s"
      end

      local compare = require "cmp.config.compare"

      compare.lsp_scores = function(entry1, entry2)
        local diff
        if entry1.completion_item.score and entry2.completion_item.score then
          diff = (entry2.completion_item.score * entry2.score)
              - (entry1.completion_item.score * entry1.score)
        else
          diff = entry2.score - entry1.score
        end
        return (diff < 0)
      end

      ---@param str string
      ---@return string
      local replace_termcodes = function(str)
        return vim.api.nvim_replace_termcodes(str, true, true, true)
      end

      local opts = {
        preselect = cmp.PreselectMode.Item,
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
        },
        formatting = {
          fields = { "menu", "abbr", "kind" },
          format = function(entry, vim_item)
            return cmp_format { maxwidth = 80 } (entry, vim_item)
          end,
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            compare.offset, -- Items closer to cursor will have lower priority
            compare.exact,
            -- compare.scopes,
            compare.lsp_scores,
            compare.sort_text,
            compare.score,
            compare.recently_used,
            -- compare.locality, -- Items closer to cursor will have higher priority, conflicts with `offset`
            compare.kind,
            compare.length,
            compare.order,
          },
        },
        experimental = {
          ghost_text = {
            hl_group = "LspCodeLens",
          },
        },
        matching = {
          disallow_partial_fuzzy_matching = false,
        },
        performance = {
          async_budget = 1,
          max_view_entries = 120,
        },
        mapping = cmp.mapping.preset.insert {
          ["<CR>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif require("luasnip").expand_or_jumpable() then
              vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-expand-or-jump", "")
            elseif check_backspace() then
              vim.fn.feedkeys(replace_termcodes "<Tab>", "n")
            else
              fallback()
            end
          end,
          ["<S-Tab>"] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif require("luasnip").jumpable(-1) then
              vim.fn.feedkeys(replace_termcodes "<Plug>luasnip-jump-prev", "")
            else
              fallback()
            end
          end,
        },
        sources = {
          { name = "nvim_lsp", max_item_count = 350 },
          { name = "buffer" },
          { name = "luasnip" },
          { name = "path" },
        },
      }

      cmp.setup(opts)
    end,
  },
}, {
  install = { colorscheme = { user.colorscheme } },
  defaults = { lazy = true },
  change_detection = { notify = false },
  concurrency = vim.loop.os_uname() == "Darwin" and 30 or nil,
  checker = { enable = true },
  ui = {
    border = "none",
    icons = {
      cmd = icons.misc.Code,
      config = icons.ui.Gear,
      event = icons.kind.Event,
      ft = icons.documents.Files,
      init = icons.misc.ManUp,
      import = icons.documents.Import,
      keys = icons.ui.Keyboard,
      lazy = icons.misc.BentoBox,
      loaded = icons.ui.Check,
      not_loaded = icons.misc.Ghost,
      plugin = icons.ui.Package,
      runtime = icons.misc.Vim,
      source = icons.kind.StaticMethod,
      start = icons.ui.Play,
      list = {
        icons.ui_space.BigCircle,
        icons.ui_space.BigUnfilledCircle,
        icons.ui_space.Square,
        icons.ui_space.ChevronRight,
      },
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "rplugin",
        "zipPlugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
})

vim.o.background = user.background
vim.cmd.colorscheme(user.colorscheme)
-- NOTE: this should only be run on Terminal.app
-- require("mini.colors").get_colorscheme():add_cterm_attributes():apply()
-- vim.opt.termguicolors = false
