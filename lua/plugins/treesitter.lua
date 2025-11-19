return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    enabled = false,
    event = "LazyFile",
    opts = { mode = "cursor", enable = true, max_lines = 5 },
    keys = {
      {
        "[c",
        function() require("treesitter-context").go_to_context(vim.v.count1) end,
        silent = true,
        desc = "treesitter: go to next context",
      },
      {
        "]c",
        function() require("treesitter-context").go_to_context(-vim.v.count1) end,
        silent = true,
        desc = "treesitter: go to previous context",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = function()
      local TS = require "nvim-treesitter"
      -- make sure we're using the latest treesitter util
      package.loaded["utils.treesitter"] = nil
      Util.treesitter.build(function() TS.update(nil, { summary = true }) end)
    end,
    event = { "LazyFile", "VeryLazy" },
    branch = "main",
    keys = {
      { "<c-space>", desc = "Increment Selection" },
      { "<bs>", desc = "Decrement Selection", mode = "x" },
    },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
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
        "rust",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      indent = { enable = true },
      highlight = { enable = true },
      injections = {
        enable = true,
        languages = { manim = "python" },
      },
      textobjects = {
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
            ["]b"] = { query = "@code_cell.inner", desc = "next code block" },
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
            ["[b"] = { query = "@code_cell.inner", desc = "previous code block" },
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
          },
        },
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["ib"] = { query = "@code_cell.inner", desc = "in block" },
            ["ab"] = { query = "@code_cell.outer", desc = "around block" },
            ["af"] = { query = "@function.outer", desc = "outer function" },
            ["if"] = { query = "@function.inner", desc = "inner function" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>sbl"] = "@code_cell.outer",
          },
          swap_previous = {
            ["<leader>sbh"] = "@code_cell.outer",
          },
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
    config = function(_, opts)
      local TS = require "nvim-treesitter"

      TS.setup(opts)
      Util.treesitter.get_installed(true) -- initialize the installed langs

      -- install missing parsers
      local install = vim.tbl_filter(
        function(lang) return not Util.treesitter.have(lang) end,
        opts.ensure_installed or {}
      )
      if #install > 0 then
        Util.treesitter.build(function()
          TS.install(install, { summary = true }):await(function()
            Util.treesitter.get_installed(true) -- refresh the installed langs
          end)
        end)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
        callback = function(ev)
          local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
          if not Util.treesitter.have(ft) then return end

          ---@param feat string
          ---@param query string
          local function enabled(feat, query)
            local f = opts[feat] or {} ---@type lazyvim.TSFeat
            return f.enable ~= false
              and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
              and Util.treesitter.have(ft, query)
          end

          -- highlighting
          if enabled("highlight", "highlights") then pcall(vim.treesitter.start, ev.buf) end

          -- indents
          if enabled("indent", "indents") then Util.set_default("indentexpr", "v:lua.Util.treesitter.indentexpr()") end

          -- folds
          if enabled("folds", "folds") then
            if Util.set_default("foldmethod", "expr") then
              Util.set_default("foldexpr", "v:lua.Util.treesitter.foldexpr()")
            end
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        -- Util extention to create buffer-local keymaps
        keys = {
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      local TS = require "nvim-treesitter-textobjects"
      TS.setup(opts)

      local function attach(buf)
        local ft = vim.bo[buf].filetype
        if not (vim.tbl_get(opts, "move", "enable") and Util.treesitter.have(ft, "textobjects")) then return end
        ---@type table<string, table<string, string>>
        local moves = vim.tbl_get(opts, "move", "keys") or {}

        for method, keymaps in pairs(moves) do
          for key, query in pairs(keymaps) do
            local queries = type(query) == "table" and query or { query }
            local parts = {}
            for _, q in ipairs(queries) do
              local part = q:gsub("@", ""):gsub("%..*", "")
              part = part:sub(1, 1):upper() .. part:sub(2)
              table.insert(parts, part)
            end
            local desc = table.concat(parts, " or ")
            desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
            desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
            if not (vim.wo.diff and key:find "[cC]") then
              vim.keymap.set(
                { "n", "x", "o" },
                key,
                function() require("nvim-treesitter-textobjects.move")[method](query, "textobjects") end,
                {
                  buffer = buf,
                  desc = desc,
                  silent = true,
                }
              )
            end
          end
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_treesitter_textobjects", { clear = true }),
        callback = function(ev) attach(ev.buf) end,
      })
      vim.tbl_map(attach, vim.api.nvim_list_bufs())
    end,
  },
}
