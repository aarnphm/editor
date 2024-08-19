local o, opt, g, wo = vim.o, vim.opt, vim.g, vim.wo

local hi = function(name, opts)
  opts.default = opts.default or true
  opts.force = opts.force or true
  vim.api.nvim_set_hl(0, name, opts)
end

local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Window blending configuration
o.winblend = 0
o.pumblend = 0 -- make completion window transparent
opt.shortmess:append { W = true, c = true, C = true }
o.formatoptions = "1jqlnt" -- NOTE: "tqjcro"
o.diffopt = "filler,iwhite,internal,linematch:60,algorithm:patience" -- better diff
-- searching and grep stuff
o.infercase = true
o.hlsearch = true
o.grepformat = "%f:%l:%c:%m"
o.grepprg = "rg --vimgrep" -- also its 2023 use rg
o.jumpoptions = "stack"
o.list = true
o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
o.inccommand = "split"
o.foldenable = true
o.conceallevel = 2
o.relativenumber = true
o.laststatus = 3
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
  vert = "│",
  horiz = "─",
  horizdown = "┬",
  horizup = "┴",
  verthoriz = "┼",
  vertleft = "┤",
  vertright = "├",
}
o.smoothscroll = true
o.foldlevel = 99
o.foldlevelstart = 99
o.foldopen = "block,mark,percent,quickfix,search,tag,undo"
-- Spaces and tabs config
o.tabstop = TABWIDTH
o.softtabstop = TABWIDTH
o.shiftwidth = TABWIDTH
o.shiftround = true
wo.scrolloff = 8
wo.sidescrolloff = 8
wo.wrap = false
wo.cursorcolumn = false

o.cmdheight = 0
o.showcmd = false
o.timeout = true
o.timeoutlen = 300
o.updatetime = 200

-- last but def not least, wildmenu
o.wildchar = 9
o.wildignorecase = true
o.wildmode = "longest:full,full"
opt.wildignore = { "__pycache__", "*.o", "*~", "*.pyc", "*pycache*", "Cargo.lock", "lazy-lock.json" }

-- map leader to <Space> and localeader to +
g.mapleader = " "
g.maplocalleader = ","

vim.keymap.set({ "n", "x" }, " ", "", { noremap = true })

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

-- bootstrap logics
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

require("lazy").setup {
  spec = {
    "nvim-lua/plenary.nvim",
    { "romainl/vim-cool", event = { "CursorMoved", "InsertEnter" } },
    { "folke/lazy.nvim", version = false },
    ---colorscheme
    {
      "rose-pine/neovim",
      name = "rose-pine",
      priority = 1000,
      opts = {
        variant = "auto",
        dark_variant = "main",
        styles = { italic = false },
        highlight_groups = { StatusLine = { fg = "rose", bg = "overlay", blend = 0 } },
      },
    },
    {
      "ggandor/flit.nvim",
      opts = { labeled_modes = "nx" },
      keys = function()
        ---@type LazyKeysSpec[]
        local ret = {}
        for _, key in ipairs { "f", "F", "t", "T" } do
          ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
        end
        return ret
      end,
    },
    {
      "ggandor/leap.nvim",
      keys = {
        { "s", mode = { "n", "x", "o" }, desc = "motion: leap forward to" },
        { "S", mode = { "n", "x", "o" }, desc = "motion: leap backward to" },
        -- Linewise.
        {
          "gA",
          'V<cmd>lua require("leap.treesitter").select()<cr>',
          mode = { "n", "x", "o" },
          desc = "motion: leap treesiter (linewise)",
        },
        {
          "ga",
          function()
            local sk = vim.deepcopy(require("leap").opts.special_keys) ---@type LeapSpecialKeys
            -- The items in `special_keys` can be both strings or tables - the
            -- shortest workaround might be the below one:
            sk.next_target = vim.fn.flatten(vim.list_extend({ "a" }, { sk.next_target }))
            sk.prev_target = vim.fn.flatten(vim.list_extend({ "A" }, { sk.prev_target }))

            require("leap.treesitter").select { opts = { special_keys = sk } }
          end,
          mode = { "n", "x", "o" },
          desc = "motion: leap treesitter",
        },
      },
      opts = {
        max_highlighted_traversal_targets = 15,
      },
      ---@param opts LeapOpts
      config = function(_, opts)
        ---@type Leap
        local leap = require "leap"
        for key, val in pairs(opts) do
          leap.opts[key] = val
        end
        leap.add_default_mappings(true)

        vim.keymap.del({ "x", "o" }, "x")
        vim.keymap.del({ "x", "o" }, "X")
      end,
    },
    { "tpope/vim-repeat", lazy = false },
    {
      "stevearc/dressing.nvim",
      lazy = true,
      opts = {
        input = { border = "none" },
        builtin = { border = "none" },
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
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      event = "VeryLazy",
      opts = {
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = { enabled = false },
      },
    },
    {
      "echasnovski/mini.nvim",
      version = false,
      event = "VeryLazy",
      dependencies = {
        { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true, opts = { enable_autocmd = false } },
      },
      specs = {
        { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
      },
      keys = {
        {
          "C-q",
          function()
            local bd = require("mini.bufremove").delete
            if vim.bo.modified then
              local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
              if choice == 1 then -- Yes
                vim.cmd.write()
                bd(0)
              elseif choice == 2 then -- No
                bd(0, true)
              end
            else
              bd(0)
            end
          end,
          desc = "buffer: delete",
        },
        { "<C-x>", function() require("mini.bufremove").delete(0, true) end, desc = "buffer: force delete" },
        {
          "<LocalLeader>/",
          function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end,
          desc = "mini.files: open (directory of current file)",
        },
        {
          "<leader><leader>s",
          ":normal gsaiW`<Esc>",
          desc = "mini.surround: inner word with backticks",
          noremap = true,
        },
        { "<Leader>v", "gcc", remap = true, silent = true, mode = "n", desc = "comment: visual line" },
        { "<Leader>v", "gc", remap = true, silent = true, mode = "x", desc = "comment: visual line" },
        {
          "<leader>go",
          function() require("mini.diff").toggle_overlay(0) end,
          desc = "git: toggle diff overlay",
        },
        {
          "<LocalLeader>f",
          function() require("mini.pick").builtin.files { tool = "git" } end,
          desc = "mini.pick: open (git root)",
        },
        {
          "<LocalLeader>.",
          function() require("mini.pick").builtin.files({}, { source = { items = vim.fn.readdir "." } }) end,
          desc = "mini.pick: open (current)",
        },
        {
          "<LocalLeader>w",
          function() require("mini.pick").builtin.grep_live() end,
          desc = "mini.pick: grep word",
        },
        {
          "<leader>b",
          function() require("mini.pick").builtin.buffers() end,
          desc = "mini.pick: grep word",
        },
      },
      init = function()
        package.preload["nvim-web-devicons"] = function()
          require("mini.icons").mock_nvim_web_devicons()
          return package.loaded["nvim-web-devicons"]
        end
      end,
      config = function()
        require("mini.align").setup { mappings = { start = "<leader>ga", start_with_preview = "<leader>gA" } }
        require("mini.ai").setup {
          n_lines = 500,
          custom_textobjects = {
            o = require("mini.ai").gen_spec.treesitter { -- code block
              a = { "@block.outer", "@conditional.outer", "@loop.outer" },
              i = { "@block.inner", "@conditional.inner", "@loop.inner" },
            },
            f = require("mini.ai").gen_spec.treesitter { a = "@function.outer", i = "@function.inner" }, -- function
            c = require("mini.ai").gen_spec.treesitter { a = "@class.outer", i = "@class.inner" }, -- class
            t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
            d = { "%f[%d]%d+" }, -- digits
            e = { -- Word with case
              { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
              "^().*()$",
            },
            -- i = Util.mini.ai_indent, -- indent
            -- g = Util.mini.ai_buffer, -- buffer
            u = require("mini.ai").gen_spec.function_call(), -- u for "Usage"
            U = require("mini.ai").gen_spec.function_call { name_pattern = "[%w_]" }, -- without dot in function name
          },
        }
        require("mini.files").setup {
          windows = {
            preview = false,
            width_focus = 30,
            width_nofocus = 30,
            width_preview = math.floor(0.45 * vim.o.columns),
            max_number = 3,
          },
          mappings = { synchronize = "<leader>" },
        }
        require("mini.surround").setup {
          mappings = {
            add = "gsa", -- Add surrounding in Normal and Visual modes
            delete = "gsd", -- Delete surrounding
            find = "gsf", -- Find surrounding (to the right)
            find_left = "gsF", -- Find surrounding (to the left)
            highlight = "gsh", -- Highlight surrounding
            replace = "gsr", -- Replace surrounding
            update_n_lines = "gsn", -- Update `n_lines`
          },
        }
        require("mini.indentscope").setup {
          symbol = "│",
          options = { try_as_border = true },
        }
        require("mini.comment").setup {
          options = {
            custom_commentstring = function()
              return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
            end,
          },
        }
        require("mini.diff").setup {
          view = {
            style = "sign",
            signs = {
              add = "▎",
              change = "▎",
              delete = "",
            },
          },
        }
        require("mini.icons").setup {
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
        }
        require("mini.basics").setup { mappings = { option_toggle_prefix = "<leader>u", windows = true } }
        require("mini.pick").setup { window = { prompt_prefix = "󰄾 " } }

        require("mini.hipatterns").setup {}
        require("mini.bufremove").setup {}
        require("mini.statusline").setup {}
        require("mini.completion").setup {}
        require("mini.trailspace").setup {}
        require("mini.bracketed").setup {}
      end,
    },
    {
      "echasnovski/mini.starter",
      version = false,
      event = "VimEnter",
      opts = function()
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
          header = table.concat({
            [[                                  __]],
            [[     ___     ___    ___   __  __ /\_\    ___ ___]],
            [[    / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\]],
            [[   /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \]],
            [[   \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
            [[    \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
          }, "\n"),
          items = {
            new_section("Files", function() require("mini.pick").builtin.files() end, "Telescope"),
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
            if vim.bo[ev.buf].filetype == "ministarter" then
              vim.o.laststatus = 0
              vim.b[ev.buf].ministatusline_disable = true
              pcall(starter.refresh)
            end
          end,
        })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      version = false, -- last release is way too old and doesn't work on Windows
      build = ":TSUpdate",
      event = "VeryLazy",
      lazy = vim.fn.argc(-1) == 0,
      keys = {
        { "<c-space>", desc = "Increment Selection" },
        { "<bs>", desc = "Decrement Selection", mode = "x" },
      },
      init = function(plugin)
        -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
        -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
        -- no longer trigger the **nvim-treeitter** module to be loaded in time.
        -- Luckily, the only thins that those plugins need are the custom queries, which we make available
        -- during startup.
        require("lazy.core.loader").add_to_rtp(plugin)
        require "nvim-treesitter.query_predicates"
        -- vim.opt.runtimepath:prepend(rtp_path)
      end,
      opts = {
        ensure_installed = {
          "bash",
          "diff",
          "go",
          "gitcommit",
          "gitignore",
          "javascript",
          "jsdoc",
          "json",
          "jsonc",
          "lua",
          "luadoc",
          "luap",
          "markdown",
          "markdown_inline",
          "printf",
          "python",
          "query",
          "regex",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "xml",
          "yaml",
        },
        auto_install = false,
        indent = { enable = true },
        highlight = { enable = true },
        textobjects = {
          move = {
            enable = true,
            goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
            goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
          },
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-a>",
            node_incremental = "<C-a>",
            scope_incremental = "<C-i>",
            node_decremental = "<bs>",
          },
        },
      },
      config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
    },
    {
      "williamboman/mason.nvim",
      cmd = "Mason",
      build = ":MasonUpdate",
      opts = {
        ensure_installed = {
          "stylua",
          "shfmt",
          "mypy",
          "taplo",
          "beautysh",
          "selene",
          "hadolint",
          "oxlint",
          "markdownlint",
          "pyright",
          "ruff",
          "lua-language-server",
        },
        ui = { border = "none" },
        max_concurrent_installers = 15,
      },
      ---@param opts MasonSettings | {ensure_installed: string[]}
      config = function(_, opts)
        require("mason").setup(opts)
        local mr = require "mason-registry"
        mr:on("package:install:success", function()
          vim.defer_fn(function()
            -- trigger FileType event to possibly load this newly installed LSP server
            require("lazy.core.handler.event").trigger {
              event = "FileType",
              buf = vim.api.nvim_get_current_buf(),
            }
          end, 100)
        end)
        mr.refresh(function()
          for _, tool in ipairs(opts.ensure_installed) do
            local p = mr.get_package(tool)
            if not p:is_installed() then p:install() end
          end
        end)
      end,
    },
    {
      "neovim/nvim-lspconfig",
      event = "VeryLazy",
      dependencies = {
        "mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        { "b0o/SchemaStore.nvim", lazy = true, version = false, ft = { "json", "yaml" } },
      },
    },
    {
      "andweeb/presence.nvim",
      event = "VeryLazy",
      opts = { enable_line_number = true },
    },
  },
  change_detection = { notify = false },
  checker = { enabled = true, frequency = 3600 * 24, notify = false },
  ui = { border = "single", backdrop = 100, wrap = false },
  dev = {
    path = "~/workspace/neovim-plugins/",
  },
}

if package.loaded["rose-pine"] then
  vim.cmd.colorscheme "rose-pine"
else
  vim.opt.termguicolors = true
  vim.cmd.colorscheme "habamax"
end

map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "terminal: enter normal mode" })
map("t", "<C-w>h", "<cmd>wincmd h<cr>", { desc = "terminal: go to left window" })
map("t", "<C-w>j", "<cmd>wincmd j<cr>", { desc = "terminal: go to lower window" })
map("t", "<C-w>k", "<cmd>wincmd k<cr>", { desc = "terminal: go to upper window" })
map("t", "<C-w>l", "<cmd>wincmd l<cr>", { desc = "terminal: go to right window" })
map("i", "jj", "<Esc>", { desc = "normal: escape" })
map("i", "jk", "<Esc>", { desc = "normal: escape" })
map("n", "<leader><leader>a", "<CMD>normal za<CR>", { desc = "edit: Toggle code fold" })
map("n", "Y", "y$", { desc = "edit: Yank text to EOL" })
map("n", "D", "d$", { desc = "edit: Delete text to EOL" })
map("n", "J", "mzJ`z", { desc = "edit: Join next line" })
map("n", "\\", ":let @/=''<CR>:noh<CR>", { silent = true, desc = "window: Clean highlight" })
map("n", ";", ":", { silent = false, desc = "command: Enter command mode" })
map("n", ";;", ";", { silent = false, desc = "normal: Enter Ex mode" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "edit: Move this line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "edit: Move this line up" })
map("v", "<", "<gv", { desc = "edit: Decrease indent" })
map("v", ">", ">gv", { desc = "edit: Increase indent" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "lsp: show line diagnostics" })

hi("HighlightURL", { default = true, underline = true })
hi("VertSplit", { fg = "NONE", bg = "NONE", bold = false })
hi("CmpGhostText", { link = "Comment", default = true })
-- leap.nvim
hi("LeapBackdrop", { link = "Comment" }) -- or some grey
hi("LeapMatch", { fg = "white", bold = true, nocombine = true }) -- "black" for light theme

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
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✖",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.HINT] = "⚑",
      [vim.diagnostic.severity.INFO] = "●",
    },
  },
}

local capabilities = vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), {
  workspace = {
    didChangeWatchedFiles = { dynamicRegistration = false },
    fileOperations = { didRename = true, willRename = true },
  },
  textDocument = {
    completion = {
      snippetSupport = true,
      resolveSupport = {
        properties = { "documentation", "detail", "additionalTextEdits" },
      },
    },
  },
})

require("lspconfig").ruff.setup {
  capabilities = capabilities,
  flags = { debounce_text_changes = 300 },
}
require("lspconfig").pyright.setup {
  capabilities = capabilities,
  flags = { debounce_text_changes = 300 },
}

require("lspconfig").lua_ls.setup {
  capabilities = capabilities,
  flags = { debounce_text_changes = 300 },
}
