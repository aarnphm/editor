--# selene: allow(global_usage)
_G.P = function(v)
  print(vim.inspect(v))
  return v
end

-- NOTE: Keymaps that are useful, use it and never come back.
local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

local api, wo, o, g, autocmd = vim.api, vim.wo, vim.o, vim.g, vim.api.nvim_create_autocmd
-- NOTE: augroup la autocmd setup
local augroup_name = function(name) return "simple_" .. name end
local augroup = function(name) return api.nvim_create_augroup(augroup_name(name), { clear = true }) end

local icons = require "icons"
local utils = require "utils"
local TAB_WIDTH = 2

o.wrap = false
o.autowrite = true
o.undodir = "/tmp/.vim-undo-dir"
o.undofile = true                                                    -- enable undofile
wo.breakindent = true                                                -- use breakindent
o.clipboard = "unnamedplus"                                          -- sync system clipboard
o.expandtab = true                                                   -- space to tabs
o.number = true                                                      -- number is good for nav
o.relativenumber = true                                              -- relativenumber is useful, grow up
o.mouse = "a"                                                        -- because sometimes mouse is needed for ssh
o.diffopt = "filler,iwhite,internal,linematch:60,algorithm:patience" -- better diff
o.copyindent = true
o.splitright = true
vim.opt.smartcase = true
vim.opt.completeopt = { "menuone", "noselect" }
o.grepprg = "rg --vimgrep"
o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"
o.tabstop = TAB_WIDTH
o.shiftwidth = TAB_WIDTH
o.softtabstop = TAB_WIDTH
o.expandtab = true
o.signcolumn = "yes"
o.timeoutlen = 200
o.updatetime = 200
o.statusline = utils.statusline.build()

g.mapleader = " "
g.maplocalleader = ","

vim.keymap.set({ "n", "x" }, " ", "", { noremap = true })

-- NOTE: normal mode
map("n", "<S-Tab>", "<cmd>normal za<cr>", { desc = "edit: Toggle code fold" })
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
map("c", "W!!", "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!", { desc = "edit: Save file using sudo" })
map("n", "<C-h>", "<C-w>h", { desc = "window: Focus left" })
map("n", "<C-l>", "<C-w>l", { desc = "window: Focus right" })
map("n", "<C-j>", "<C-w>j", { desc = "window: Focus down" })
map("n", "<C-k>", "<C-w>k", { desc = "window: Focus up" })
map("n", "<LocalLeader>|", "<C-w>|", { desc = "window: Maxout width" })
map("n", "<LocalLeader>-", "<C-w>_", { desc = "window: Maxout width" })
map("n", "<LocalLeader>=", "<C-w>=", { desc = "window: Equal size" })
map("n", "<Leader>qq", "<cmd>wqa<cr>", { desc = "editor: write quit all" })
map("n", "<Leader>.", "<cmd>bnext<cr>", { desc = "buffer: next" })
map("n", "<Leader>,", "<cmd>bprevious<cr>", { desc = "buffer: previous" })
map("n", "<Leader>q", "<cmd>copen<cr>", { desc = "quickfix: Open quickfix" })
map("n", "<Leader>l", "<cmd>lopen<cr>", { desc = "quickfix: Open location list" })
map("n", "<Leader>n", "<cmd>enew<cr>", { desc = "buffer: new" })
map("n", "<LocalLeader>sw", "<C-w>r", { desc = "window: swap position" })
map("n", "<LocalLeader>vs", "<C-w>v", { desc = "edit: split window vertically" })
map("n", "<LocalLeader>hs", "<C-w>s", { desc = "edit: split window horizontally" })
map("n", "<LocalLeader>cd", ":lcd %:p:h<cr>", { desc = "misc: change directory to current file buffer" })
map("n", "<LocalLeader>l", "<cmd>set list! list?<cr>", { silent = false, desc = "misc: toggle invisible characters" })
map("n", "<LocalLeader>]", string.format("<cmd>vertical resize -%s<cr>", 10),
  { noremap = false, desc = "windows: resize right 10px" })
map("n", "<LocalLeader>[", string.format("<cmd>vertical resize +%s<cr>", 10),
  { noremap = false, desc = "windows: resize left 10px" })
map("n", "<LocalLeader>-", string.format("<cmd>resize -%s<cr>", 10),
  { noremap = false, desc = "windows: resize down 10px" })
map("n", "<LocalLeader>+", string.format("<cmd>resize +%s<cr>", 10),
  { noremap = false, desc = "windows: resize up 10px" })
map("n", "<LocalLeader>p", "<cmd>Lazy<cr>", { desc = "package: show manager" })

-- NOTE: compatible block with vscode
if vim.g.vscode then return end

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup "filetype",
  pattern = {
    "qf",
    "help",
    "man",
    "nowrite", -- fugitive
    "prompt",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neorepl",
    "alpha",
    "toggleterm",
    "health",
    "PlenaryTestPopup",
    "nofile",
    "scratch",
    "",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<cmd>close<cr>", { silent = true })
  end,
})
-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup "checktime",
  pattern = "*",
  command = "checktime",
})
autocmd("VimResized", { group = augroup "resized", command = "tabdo wincmd =" })

-- Set noundofile for temporary files
autocmd("BufWritePre",
  { group = augroup "tempfile", pattern = { "/tmp/*", "*.tmp", "*.bak" }, command = "setlocal noundofile" })
-- set filetype for header files
autocmd({ "BufNewFile", "BufRead" },
  { group = augroup "cpp_headers", pattern = { "*.h", "*.hpp", "*.hxx", "*.hh" }, command = "setlocal filetype=c" })
-- set filetype for dockerfile
autocmd({ "BufNewFile", "BufRead", "FileType" },
  {
    group = augroup "dockerfile",
    pattern = { "*.dockerfile", "Dockerfile-*", "Dockerfile.*", "Dockerfile.template" },
    command = "setlocal filetype=dockerfile"
  })
-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup "highlight_yank",
  pattern = "*",
  callback = function(_) vim.highlight.on_yank { higroup = "IncSearch", timeout = 100 } end,
})

-- NOTE: vim options
if vim.loop.os_uname().sysname == "Darwin" then
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
    cache_enabled = 0,
  }
end

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

local colorscheme = vim.NIL ~= vim.env.SIMPLE_COLORSCHEME and vim.env.SIMPLE_COLORSCHEME or "rose-pine"
local background = vim.NIL ~= vim.env.SIMPLE_BACKGROUND and vim.env.SIMPLE_BACKGROUND or "dark"

require("lazy").setup({
  -- NOTE: utilities
  "lewis6991/impatient.nvim",
  "nvim-lua/plenary.nvim",
  "jghauser/mkdir.nvim",
  "nvim-tree/nvim-web-devicons",
  {
    "stevearc/dressing.nvim",
    opts = {
      input = {
        enabled = true,
        override = function(config) return vim.tbl_deep_extend("force", config, { col = -1, row = 0 }) end,
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
        local kmap = function(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc }) end
        kmap("n", "]h", actions.next_hunk, "git: next hunk")
        kmap("n", "[h", actions.prev_hunk, "git: prev hunk")
        kmap("n", "<leader>hu", actions.undo_stage_hunk, "git: undo stage hunk")
        kmap("n", "<leader>hR", actions.reset_buffer, "git: reset buffer")
        kmap("n", "<leader>hS", actions.stage_buffer, "git: stage buffer")
        kmap("n", "<leader>hp", actions.preview_hunk, "git: preview hunk")
        kmap("n", "<leader>hd", actions.diffthis, "git: diff this")
        kmap("n", "<leader>hD", function() actions.diffthis "~" end, "git: diff this ~")
        kmap("n", "<leader>hb", function() actions.blame_line { full = true } end, "git: blame Line")
        kmap({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", "git: stage hunk")
        kmap({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", "git: reset hunk")
        kmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  -- NOTE: exit fast af
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      timeout = 200,
      clear_empty_lines = true,
      keys = "<Esc>"
    }
  },
  -- NOTE: treesitter-based dependencies
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
          -- When in diff mode, we want to use the default
          -- vim text objects c & C instead of the treesitter ones.
          local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
          local configs = require("nvim-treesitter.configs")
          for name, fn in pairs(move) do
            if name:find("goto") == 1 then
              move[name] = function(q, ...)
                if vim.wo.diff then
                  local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
                  for key, query in pairs(config or {}) do
                    if q == query and key:find("[%]%[][cC]") then
                      vim.cmd("normal! " .. key)
                      return
                    end
                  end
                end
                return fn(q, ...)
              end
            end
          end
        end,
      },
      "windwp/nvim-ts-autotag",
    },
    cmd = { "TSUpdateSync" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>",      desc = "Decrement selection", mode = "x" },
    },
    opts = {
      ensure_installed = { "python", "rust", "lua", "c", "cpp", "toml", "bash", "css", "vim", "regex", "markdown",
        "markdown_inline", "yaml", "go", "typescript", "tsx", "zig", "query", "regex", "luap", "luadoc", "javascript",
        "proto" },
      ignore_install = { "phpdoc" },
      indent = { enable = true },
      highlight = { enable = true },
      context_commentstring = { enable = true, enable_autocmd = false },
      autotag = { enable = true },
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
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
    config = function(_, opts)
      if utils.has "SchemaStore.nvim" then vim.list_extend(opts.ensure_installed, { "json", "jsonc", "json5" }) end
      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then return false end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end
      require("nvim-treesitter.configs").setup(opts)
    end,
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
  { 'echasnovski/mini.colors', version = false },
  {
    "echasnovski/mini.bufremove",
    version = false,
    keys = {
      { "<C-x>", function() require("mini.bufremove").delete(0, false) end, desc = "buf: delete" },
      { "<C-q>", function() require("mini.bufremove").delete(0, true) end,  desc = "buf: force delete" },
    },
  },
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
          o = ai.gen_spec.treesitter(
            {
              a = { "@block.outer", "@conditional.outer", "@loop.outer" },
              i = { "@block.inner", "@conditional.inner", "@loop.inner" }
            }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
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
  { "echasnovski/mini.align",  event = "VeryLazy" },
  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        {
          opts.mappings.add,
          desc = "Add surrounding",
          mode = { "n", "v" },
        },
        { opts.mappings.delete,         desc = "Delete surrounding" },
        { opts.mappings.find,           desc = "Find right surrounding" },
        { opts.mappings.find_left,      desc = "Find left surrounding" },
        { opts.mappings.highlight,      desc = "Highlight surrounding" },
        { opts.mappings.replace,        desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m) return m[1] and #m[1] > 0 end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gsa",            -- Add surrounding in Normal and Visual modes
        delete = "gsd",         -- Delete surrounding
        find = "gsf",           -- Find surrounding (to the right)
        find_left = "gsF",      -- Find surrounding (to the left)
        highlight = "gsh",      -- Highlight surrounding
        replace = "gsr",        -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
  },
  { "echasnovski/mini.pairs", event = "VeryLazy",    opts = {} },
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
  -- NOTE: easily jump to any location and enhanced f/t motions for Leap
  {
    "ggandor/flit.nvim",
    opts = { labeled_modes = "nx" },
    ---@diagnostic disable-next-line: assign-type-mismatch
    keys = function()
      ---@type table<string, LazyKeys[]>
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
      -- { "s", mode = { "n", "x", "o" }, desc = "motion: Leap forward to" },
      -- { "S", mode = { "n", "x", "o" }, desc = "motion: Leap backward to" },
      { "gs", mode = { "n", "x", "o" }, desc = "motion: Leap from windows" },
    },
    config = function(_, opts)
      local leap = require "leap"
      for key, val in pairs(opts) do
        leap.opts[key] = val
      end
      leap.add_default_mappings(true)
      vim.keymap.del({ "x", "o" }, "x")
      vim.keymap.del({ "x", "o" }, "X")
    end,
  },
  -- NOTE: better UI components
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      { "junegunn/fzf", lazy = true, build = ":call fzf#install()" },
    },
    config = true,
  },
  -- NOTE: folke is neovim's tpope
  { "folke/paint.nvim",       event = "BufReadPost", config = true },
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
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },
        prompt_prefix = "  ",
        selection_caret = "󰄾 ",
        file_ignore_patterns = {
          ".git/",
          "node_modules/",
          "static_content/",
          "lazy-lock.json",
          "pdm.lock",
          "__pycache__",
        },
        layout_config = { width = 0.8, height = 0.8, prompt_position = "top" },
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        color_devicons = true,
      },
      fzf = {
        fuzzy = false,                  -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true,    -- override the file sorter
        case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
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
    },
    config = function(_, opts)
      opts.defaults.mappings = {
        i = {
          ["<C-a>"] = { "<esc>0i", type = "command" },
          ["<Esc>"] = function(...) return require("telescope.actions").close(...) end,
          ["<c-t>"] = function(...) return require("trouble.providers.telescope").open_with_trouble(...) end,
          ["<a-t>"] = function(...) return require("trouble.providers.telescope").open_selected_with_trouble(...) end,
          ["<a-i>"] = function()
            local action_state = require "telescope.actions.state"
            local line = action_state.get_current_line()
            utils.telescope("find_files", { no_ignore = true, default_text = line })()
          end,
          ["<a-h>"] = function()
            local action_state = require "telescope.actions.state"
            local line = action_state.get_current_line()
            utils.telescope("find_files", { hidden = true, default_text = line })()
          end,
          ["<C-Down>"] = function(...) return require("telescope.actions").cycle_history_next(...) end,
          ["<C-Up>"] = function(...) return require("telescope.actions").cycle_history_prev(...) end,
          ["<C-f>"] = function(...) return require("telescope.actions").preview_scrolling_down(...) end,
          ["<C-b>"] = function(...) return require("telescope.actions").preview_scrolling_up(...) end,
        },
        n = { ["q"] = function(...) return require("telescope.actions").close(...) end },
      }
      opts.extensions = {
        live_grep_args = {
          auto_quoting = false,
          mappings = {
            i = {
              ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
              ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt { postfix = " --iglob " },
              ["<C-j>"] = require("telescope-live-grep-args.actions").quote_prompt { postfix = " -t " }
            },
          },
        },
      }

      require("telescope").setup(opts)
      require("telescope").load_extension "live_grep_args"
    end,
  },
  -- Automatically highlights other instances of the word under your cursor. This works with LSP, Treesitter, and regexp matching to find the other instances.
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function imap(key, dir, buffer)
        vim.keymap.set("n", key, function() require("illuminate")["goto_" .. dir .. "_reference"](false) end,
          { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      imap("]]", "next")
      imap("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          imap("]]", "next", buffer)
          imap("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },
  -- NOTE: better nvim-tree.lua
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
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
        bind_to_cwd = true,
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
  },
  -- NOTE: Chad colorizer
  {
    "NvChad/nvim-colorizer.lua",
    event = "LspAttach",
    config = function()
      require("colorizer").setup {
        filetypes = { "*" },
        user_default_options = {
          names = false,   -- "Name" codes like Blue
          RRGGBBAA = true, -- #RRGGBBAA hex codes
          rgb_fn = true,   -- CSS rgb() and rgba() functions
          hsl_fn = true,   -- CSS hsl() and hsla() functions
          css = true,      -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css_fn = true,   -- Enable all CSS *functions*: rgb_fn, hsl_fn
          sass = { enable = true, parsers = { "css" } },
          mode = "background",
        },
      }
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
    enabled = vim.fn.has("nvim-0.10") == 1,
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
        opts = {
          border = { enable = true },
          height = 20,
          zindex = 50,
          preview_win_opts = {
            cursorline = true,
            number = true,
            wrap = true,
          },
          list = {
            position = "right",
            width = 0.33, -- 33% width relative to the active window, min 0.1, max 0.5
          },
        },
      },
      "hrsh7th/cmp-nvim-lsp",
      -- stylua: ignore start
      { "folke/neodev.nvim",  config = true,                    ft = "lua" },
      { "folke/neoconf.nvim", cmd = "Neoconf",                  config = true, dependencies = { "nvim-lspconfig" } },
      { "saecki/crates.nvim", event = { "BufRead Cargo.toml" }, config = true },
      -- stylua: ignore stop
      {
        "simrat39/rust-tools.nvim",
        ft = "rust",
        dependencies = { "nvim-lua/plenary.nvim" },
        lazy = true,
        opts = {
          tools = {
            -- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
            reload_workspace_from_cargo_toml = true,
            inlay_hints = {
              auto = true,
              other_hints_prefix = ":: ",
              only_current_line = true,
              show_parameter_hints = false,
            },
          },
          server = {
            standalone = true,
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  loadOutDirsFromCheck = true,
                  buildScripts = { enable = true },
                },
                diagnostics = {
                  disabled = { "unresolved-proc-macro" },
                  enableExperimental = true,
                },
                checkOnSave = { command = "clippy" },
                procMacro = { enable = true },
              },
            },
          },
        },
        config = function(_, opts)
          local get_rust_adapters = function()
            if vim.loop.os_uname().sysname == "Windows_NT" then
              return {
                type = "executable",
                command = "lldb-vscode",
                name = "rt_lldb",
              }
            end
            local codelldb_extension_path = vim.fn.stdpath "data" .. "/mason/packages/codelldb/extension"
            local codelldb_path = codelldb_extension_path .. "/adapter/codelldb"
            local extension = ".so"
            if vim.loop.os_uname().sysname == "Darwin" then extension = ".dylib" end
            local liblldb_path = codelldb_extension_path .. "/lldb/lib/liblldb" .. extension
            return require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
          end

          local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
          local capabilities = vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(),
            has_cmp and cmp_nvim_lsp.default_capabilities() or {}, opts.server.capabilities or {})
          opts.server.capabilities = capabilities
          opts.dap = { adapter = get_rust_adapters() }
          require("rust-tools").setup(opts)
        end,
      },
      {
        "p00f/clangd_extensions.nvim",
        ft = { "c", "cpp", "hpp", "h" },
        dependencies = { "neovim/nvim-lspconfig" },
        lazy = true,
        opts = {
          -- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/clangd.lua
          server = {
            single_file_support = true,
            filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
            capabilities = {
              offsetEncoding = { "utf-8" },
              textDocument = {
                completion = {
                  completionItem = {
                    commitCharactersSupport = true,
                    deprecatedSupport = true,
                    insertReplaceSupport = true,
                    labelDetailsSupport = true,
                    preselectSupport = true,
                    resolveSupport = {
                      properties = { "documentation", "detail", "additionalTextEdits" }
                    },
                    snippetSupport = false,
                    tagSupport = {
                      valueSet = { 1 }
                    }
                  }
                }
              }
            },
          },
        },
        config = function(_, opts)
          local lspconfig = require "lspconfig"
          local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
          local capabilities = vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(),
            has_cmp and cmp_nvim_lsp.default_capabilities() or {}, opts.server.capabilities or {})

          local switch_source_header_splitcmd = function(bufnr, splitcmd)
            bufnr = lspconfig.util.validate_bufnr(bufnr)
            local params = { uri = vim.uri_from_bufnr(bufnr) }

            local clangd_client = lspconfig.util.get_active_client_by_name(bufnr, "clangd")

            if clangd_client then
              clangd_client.request("textDocument/switchSourceHeader", params, function(err, result)
                if err then error(tostring(err)) end
                if not result then
                  error("Corresponding file can’t be determined", vim.log.levels.ERROR)
                  return
                end
                vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
              end)
            else
              error("Method textDocument/switchSourceHeader is not supported by any active server on this buffer",
                vim.log.levels.ERROR)
            end
          end

          opts.server.commands = {
            ClangdSwitchSourceHeader = {
              function() switch_source_header_splitcmd(0, "edit") end,
              description = "cpp: Open source/header in current buffer",
            },
            ClangdSwitchSourceHeaderVSplit = {
              function() switch_source_header_splitcmd(0, "vsplit") end,
              description = "cpp: Open source/header in a new vsplit",
            },
            ClangdSwitchSourceHeaderSplit = {
              function() switch_source_header_splitcmd(0, "split") end,
              description = "cpp: Open source/header in a new split",
            },
          }

          local get_binary_path_list = function(binaries)
            local get_binary_path = function(binary)
              local path = nil
              if vim.loop.os_uname().sysname == "Windows_NT" then
                path = vim.fn.trim(vim.fn.system("where " .. binary))
              else
                path = vim.fn.trim(vim.fn.system("which " .. binary))
              end
              if vim.v.shell_error ~= 0 then path = nil end
              return path
            end

            local path_list = {}
            for _, binary in ipairs(binaries) do
              local path = get_binary_path(binary)
              if path then table.insert(path_list, path) end
            end
            return table.concat(path_list, ",")
          end

          opts.server.cmd = {
            "clangd",
            "-j=12",
            "--enable-config",
            "--background-index",
            "--pch-storage=memory",
            -- You MUST set this arg ↓ to your c/cpp compiler location (if not included)!
            "--query-driver=" .. get_binary_path_list {
              "clang++",
              "clang",
              "gcc",
              "g++",
            },
            "--clang-tidy",
            "--all-scopes-completion",
            "--completion-style=detailed",
            "--header-insertion-decorators",
            "--header-insertion=iwyu",
            "--limit-references=3000",
            "--limit-results=350",
          }

          opts.server.capabilities = capabilities

          require("clangd_extensions").setup(opts)
        end,
      },
      { "b0o/SchemaStore.nvim", version = false, ft = { "json", "yaml", "yml" } },
    },
    ---@class PluginLspOptions
    opts = {
      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = { enabled = false },
      -- add any global capabilities here
      capabilities = {},
      -- Automatically format on save
      autoformat = false,
      -- Enable this to show formatters used in a notification
      -- Useful for debugging formatter issues
      notify = false,
      -- options for vim.lsp.buf.format
      -- `bufnr` and `filter` is handled by the formatter,
      -- but can be also overridden when specified
      format = { formatting_options = nil, timeout_ms = nil },
      ---@type lspconfig.options
      servers = {
        bufls = { cmd = { "bufls", "serve", "--debug" }, filetypes = { "proto" } },
        gopls = {
          flags = { debounce_text_changes = 500 },
          cmd = { "gopls", "-remote=auto" },
          settings = {
            gopls = {
              usePlaceholders = true,
              analyses = {
                nilness = true,
                shadow = true,
                unusedparams = true,
                unusewrites = true,
              },
            },
          },
        },
        html = {
          cmd = { "html-languageserver", "--stdio" },
          filetypes = { "html" },
          init_options = {
            configurationSection = { "html", "css", "javascript" },
            embeddedLanguages = { css = true, javascript = true },
          },
          settings = {},
          single_file_support = true,
          flags = { debounce_text_changes = 500 },
        },
        jdtls = {
          flags = { debounce_text_changes = 500 },
          settings = {
            root_dir = {
              -- Single-module projects
              {
                "build.xml",           -- Ant
                "pom.xml",             -- Maven
                "settings.gradle",     -- Gradle
                "settings.gradle.kts", -- Gradle
              },
              -- Multi-module projects
              { "build.gradle", "build.gradle.kts" },
            } or vim.fn.getcwd(),
          },
        },
        jsonls = {
          -- lazy-load schemastore when needed
          on_new_config = function(config)
            config.settings.json.schemas = config.settings.json.schemas or {}
            vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
          end,
          settings = {
            json = {
              format = { enable = true },
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          -- lazy-load schemastore when needed
          on_new_config = function(config)
            if utils.has "SchemaStore" then config.settings.yaml.schemas = require("schemastore").yaml.schemas() end
          end,
          settings = { yaml = { hover = true, validate = true, completion = true } },
        },
        lua_ls = {
          settings = {
            Lua = {
              format = {
                enable = true,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                }
              },
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
        bashls = {},
        dockerls = {},
        marksman = {},
        rnix = {},
        svelte = {},
        cssls = {},
        spectral = {},
        taplo = {},
        -- NOTE: Python
        ruff_lsp = {
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("WORKSPACE", ".git", "Pipfile", "pyrightconfig.json",
                  "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(fname) or
                require("lspconfig.util").path.dirname(fname)
          end,
          settings = {},
        },
        pyright = {
          flags = { debounce_text_changes = 500 },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("WORKSPACE", ".git", "Pipfile", "pyrightconfig.json",
                  "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(fname) or
                require("lspconfig.util").path.dirname(fname)
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
        -- NOTE: isolated servers will have their own plugins for setup
        clangd = { isolated = true },
        rust_analyzer = { isolated = true },
        tsserver = { isolated = true },
        -- NOTE: servers that mason is currently not supported but nvim-lspconfig is.
        starlark_rust = { mason = false },
      },
      ---@type table<string, fun(lspconfig:any, options:_.lspconfig.options):boolean?>
      setup = {
        starlark_rust = function(lspconfig, options)
          lspconfig.starlark_rust.setup {
            capabilities = options.capabilities,
            cmd = { "starlark", "--lsp" },
            filetypes = {
              "bzl",
              "WORKSPACE",
              "star",
              "BUILD.bazel",
              "bazel",
              "bzlmod",
            },
            root_dir = function(fname)
              return require("lspconfig").util.root_pattern(unpack {
                    "WORKSPACE",
                    "WORKSPACE.bzlmod",
                    "WORKSPACE.bazel",
                    "MODULE.bazel",
                    "MODULE",
                  })(fname) or require("lspconfig").util.find_git_ancestor(fname) or
                  require("lspconfig").util.path.dirname(fname)
            end,
          }
          return true
        end,
      },
    },
    ---@param opts PluginLspOptions
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
    keys = { { "<leader>m", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {
      ensure_installed = { "lua-language-server", "pyright", "mypy", "mdx-analyzer" },
      ui = { border = 'single' },
    },
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
      "hrsh7th/cmp-emoji",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        build = (not jit.os:find "Windows") and
            "echo -e 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp" or
            nil,
        config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
        opts = { history = true, delete_check_events = "TextChanged" },
      },
      {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        opts = {
          cmp = { enabled = true, method = "getCompletionsCycling" },
          panel = { enabled = false },
          suggestion = { enabled = true, auto_trigger = true },
          filetypes = {
            markdown = true,
            help = false,
            terraform = false,
            hgcommit = false,
            svn = false,
            cvs = false,
            ["dap-repl"] = false,
            octo = false,
            TelescopePrompt = false,
            big_file_disabled_ft = false,
            neogitCommitMessage = false,
          },
        },
        config = function(_, opts)
          vim.defer_fn(function() require("copilot").setup(opts) end, 100)
        end,
      },
    },
    config = function()
      local cmp = require "cmp"

      local cmp_format = function(opts)
        opts = opts or {}
        return function(entry, vim_item)
          if opts.before then vim_item = opts.before(entry, vim_item) end

          local item = icons.kind[vim_item.kind] or icons.type[vim_item.kind] or icons.cmp[vim_item.kind] or
              icons.kind.Undefined

          vim_item.kind = string.format("  %s  %s", item, vim_item.kind)

          if opts.maxwidth ~= nil then
            if opts.ellipsis_char == nil then
              vim_item.abbr = string.sub(vim_item.abbr, 1, opts.maxwidth)
            else
              local label = vim_item.abbr
              local truncated_label = vim.fn.strcharpart(label, 0, opts.maxwidth)
              if truncated_label ~= label then vim_item.abbr = truncated_label .. opts.ellipsis_char end
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
          diff = (entry2.completion_item.score * entry2.score) - (entry1.completion_item.score * entry1.score)
        else
          diff = entry2.score - entry1.score
        end
        return (diff < 0)
      end

      ---@param str string
      ---@return string
      local replace_termcodes = function(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end

      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
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
          format = function(entry, vim_item) return cmp_format { maxwidth = 80 } (entry, vim_item) end,
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
            hl_group = "CmpGhostText",
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
            if require("copilot.suggestion").is_visible() then
              require("copilot.suggestion").accept()
            elseif cmp.visible() then
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
          { name = "emoji" },
        },
      }

      -- special cases with crates.nvim
      vim.api.nvim_create_autocmd({ "BufRead" }, {
        group = augroup "cmp_source_cargo",
        pattern = "Cargo.toml",
        callback = function() cmp.setup.buffer { sources = { { name = "crates" } } } end,
      })
      cmp.setup(opts)
    end,
  },
}, {
  install = { colorscheme = { colorscheme } },
  defaults = { lazy = true },
  change_detection = { notify = false },
  concurrency = vim.loop.os_uname() == "Darwin" and 30 or nil,
  checker = { enable = true },
  ui = { border = "single" },
})

vim.o.background = background
vim.cmd.colorscheme(colorscheme)
-- NOTE: this should only be run on Terminal.app
-- require("mini.colors").get_colorscheme():add_cterm_attributes():apply()
-- vim.opt.termguicolors = false
