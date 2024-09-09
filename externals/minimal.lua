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
opt.listchars = {
  tab = "»·",
  lead = "·",
  leadmultispace = "»···",
  nbsp = "+",
  trail = "·",
  extends = "→",
  precedes = "←",
}
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

o.cmdheight = 1
o.showcmd = false
o.timeout = true
o.timeoutlen = 300
o.updatetime = 200

-- last but def not least, wildmenu
o.wildchar = 9
o.wildignorecase = true
o.wildmode = "longest:full,full"
opt.wildignore = { "__pycache__", "*.o", "*~", "*.pyc", "Cargo.lock", "lazy-lock.json" }

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
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<cmd>close<cr>", { silent = true })
  end,
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

        require("mini.extra").setup {}
        require("mini.hipatterns").setup {}
        require("mini.bufremove").setup {}
        require("mini.statusline").setup {}
        require("mini.trailspace").setup {}
        require("mini.bracketed").setup {}
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
      opts = {
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
      "hrsh7th/nvim-cmp",
      version = false,
      event = "InsertEnter",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "FelipeLema/cmp-async-path",
        "echasnovski/mini.icons",
        {
          "garymjr/nvim-snippets",
          opts = { friendly_snippets = true, ignored_filetypes = { "git", "gitcommit" } },
          dependencies = { "rafamadriz/friendly-snippets" },
        },
        {
          "supermaven-inc/supermaven-nvim",
          lazy = true,
          event = "VeryLazy",
          build = ":SupermavenUsePro",
          opts = {
            ignore_filetypes = {
              gitcommit = true,
              hgcommit = true,
              TelescopePrompt = true,
              ministarter = true,
              nofile = true,
              startup = true,
              Trouble = true,
            },
            log_level = "warn",
            disable_inline_completion = true,
            disable_keymaps = true,
          },
        },
        {
          "folke/lazydev.nvim",
          ft = "lua",
          cmd = "LazyDev",
          dependencies = {
            -- Manage libuv types with lazy. Plugin will never be loaded
            { "Bilal2453/luvit-meta", lazy = true },
          },
          opts = {
            library = {
              { path = "~/workspace/neovim-plugins/avante.nvim/lua", words = { "avante" } },
              { path = "luvit-meta/library", words = { "vim%.uv" } },
              { path = "lazy.nvim", words = { "Util" } },
            },
          },
        },
      },
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
    border = "none",
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

local cmp = require "cmp"
local TC = require "cmp.types.cmp"
local defaults = require "cmp.config.default"()

local M = {}
M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
M.create_undo = function()
  if vim.api.nvim_get_mode().mode == "i" then vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false) end
end

---@type cmp.SelectOption
local select_opts = { behavior = cmp.SelectBehavior.Select }

local opts = vim.tbl_deep_extend("force", defaults, {
  preselect = TC.PreselectMode.None,
  ---@type cmp.CompletionConfig
  completion = { completeopt = "menu,menuone,noinsert" },
  ---@type cmp.SnippetConfig
  snippet = { expand = function(item) return vim.snippet.expand(item.body) end },
  ---@type cmp.FormattingConfig
  formatting = {
    fields = { TC.ItemField.Menu, TC.ItemField.Abbr, TC.ItemField.Kind },
    expandable_indicator = true,
    format = function(entry, item)
      ---@type string
      local mini_icon = MiniIcons.get("lsp", item.kind or "")
      item.kind = mini_icon and mini_icon .. " " or item.kind
      item.menu = ({
        supermaven = "[MVN]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[LUA]",
        snippets = "[SNP]",
        buffer = "[BUF]",
        async_path = "[DIR]",
        latex_symbols = "[LTX]",
      })[entry.source.name]

      ---@type table<"abbr"|"menu", integer>
      local widths = { abbr = 30, menu = 30 }

      for key, width in pairs(widths) do
        if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
          item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
        end
      end
      return item
    end,
  },
  experimental = { ghost_text = false },
  enabled = function()
    local disabled = { gitcommit = true, TelescopePrompt = true, help = true, minifiles = true, Avante = true }
    return not disabled[vim.bo.filetype]
  end,
  mapping = cmp.mapping.preset.insert {
    ["<CR>"] = cmp.mapping(function(fallback)
      if cmp.core.view:visible() or vim.fn.pumvisible() == 1 then
        M.create_undo()
        if cmp.confirm {
          select = true,
          behavior = cmp.ConfirmBehavior.Insert,
        } then
          return
        end
      end
      return fallback()
    end, { "i", "s" }),
    ["<S-CR>"] = cmp.mapping(function(fallback)
      if cmp.core.view:visible() or vim.fn.pumvisible() == 1 then
        M.create_undo()
        if cmp.confirm {
          select = true,
          behavior = cmp.ConfirmBehavior.Replace,
        } then
          return
        end
      end
      return fallback()
    end, { "i", "s" }),
    ["<C-CR>"] = function(fallback)
      cmp.abort()
      fallback()
    end,
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ---@type cmp.MappingFunction
    ["<Tab>"] = cmp.mapping(function(fallback)
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
      end

      local supermaven = require "supermaven-nvim.completion_preview"

      if cmp.visible() then
        cmp.select_next_item(select_opts)
      elseif vim.snippet.active { direction = 1 } then
        vim.schedule(function() vim.snippet.jump(1) end)
      elseif vim.g.enable_agent_inlay and supermaven.has_suggestion() then
        supermaven.on_accept_suggestion()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ---@type cmp.MappingFunction
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item(select_opts)
      elseif vim.snippet.active { direction = -1 } then
        vim.schedule(function() vim.snippet.jump(-1) end)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = cmp.config.sources {
    {
      name = "nvim_lsp",
      option = {
        markdown_oxide = {
          keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
        },
      },
    },
    { name = "snippets", group_index = 1 },
    { name = "supermaven", group_index = 2 },
    { name = "async_path" },
    { name = "buffer" },
    { name = "lazydev", group_index = 0 },
  },
})

cmp.setup(opts)

local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities = vim.tbl_deep_extend(
  "force",
  {},
  vim.lsp.protocol.make_client_capabilities(),
  has_cmp and cmp_nvim_lsp.default_capabilities() or {},
  {
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
  }
)

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
