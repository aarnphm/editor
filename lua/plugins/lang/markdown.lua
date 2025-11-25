-- markdown render backend
---@type "markview" | "render-markdown"
local markdown_render_backend = "render-markdown"
local enable_renderer = true

return {
  { "mason-org/mason.nvim", opts = { ensure_installed = { "markdownlint", "typos" } } },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = { markdown = { "markdownlint" } },
      linters = {
        markdownlint = {
          condition = function(ctx)
            return vim.fs.find(
              { ".markdownlint.jsonc", ".markdownlint.yaml", ".markdownlint.yml" },
              { path = ctx.filename, upward = true }
            )[1]
          end,
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        markdown_oxide = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = { dynamicRegistration = true },
            },
          },
        },
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      require("lazy").load { plugins = { "markdown-preview.nvim" } }
      vim.fn["mkdp#util#install"]()
    end,
    init = function() vim.g.mkdp_filetypes = { "markdown" } end,
    keys = {
      {
        "<leader>cp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "markdown: preview",
      },
    },
    config = function() vim.cmd [[do FileType]] end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = function() return markdown_render_backend == "render-markdown" and enable_renderer end,
    opts = function()
      ---@type render.md.UserConfig
      return {
        enabled = false,
        completions = { blink = { enabled = false } },
        render_modes = { "n", "c" },
        anti_conceal = { enabled = true },
        max_file_size = Snacks.config.bigfile.size,
        code = {
          sign = false,
          width = "full",
          right_pad = 1,
        },
        pipe_table = { preset = "double" },
        latex = { enabled = false },
        win_options = {
          conceallevel = { rendered = 2 },
        },
        callout = {
          --stylua: ignore start
          note      = { raw = '[!note]',      rendered = '󰋽 Note',      highlight = 'RenderMarkdownInfo',    category = 'github'   },
          tip       = { raw = '[!tip]',       rendered = '󰌶 Tip',       highlight = 'RenderMarkdownSuccess', category = 'github'   },
          important = { raw = '[!important]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint',    category = 'github'   },
          warning   = { raw = '[!warning]',   rendered = '󰀪 Warning',   highlight = 'RenderMarkdownWarn',    category = 'github'   },
          caution   = { raw = '[!caution]',   rendered = '󰳦 Caution',   highlight = 'RenderMarkdownError',   category = 'github'   },
          abstract  = { raw = '[!abstract]',  rendered = '󰨸 Abstract',  highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
          summary   = { raw = '[!summary]',   rendered = '󰨸 Summary',   highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
          tldr      = { raw = '[!tldr]',      rendered = '󰨸 Tldr',      highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
          info      = { raw = '[!info]',      rendered = '󰋽 Info',      highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
          todo      = { raw = '[!todo]',      rendered = '󰗡 Todo',      highlight = 'RenderMarkdownInfo',    category = 'obsidian' },
          hint      = { raw = '[!hint]',      rendered = '󰌶 Hint',      highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
          success   = { raw = '[!success]',   rendered = '󰄬 Success',   highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
          check     = { raw = '[!check]',     rendered = '󰄬 Check',     highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
          done      = { raw = '[!done]',      rendered = '󰄬 Done',      highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
          question  = { raw = '[!question]',  rendered = '󰘥 Question',  highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
          help      = { raw = '[!help]',      rendered = '󰘥 Help',      highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
          faq       = { raw = '[!faq]',       rendered = '󰘥 Faq',       highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
          attention = { raw = '[!attention]', rendered = '󰀪 Attention', highlight = 'RenderMarkdownWarn',    category = 'obsidian' },
          failure   = { raw = '[!failure]',   rendered = '󰅖 Failure',   highlight = 'RenderMarkdownError',   category = 'obsidian' },
          fail      = { raw = '[!fail]',      rendered = '󰅖 Fail',      highlight = 'RenderMarkdownError',   category = 'obsidian' },
          missing   = { raw = '[!missing]',   rendered = '󰅖 Missing',   highlight = 'RenderMarkdownError',   category = 'obsidian' },
          danger    = { raw = '[!danger]',    rendered = '󱐌 Danger',    highlight = 'RenderMarkdownError',   category = 'obsidian' },
          error     = { raw = '[!error]',     rendered = '󱐌 Error',     highlight = 'RenderMarkdownError',   category = 'obsidian' },
          bug       = { raw = '[!bug]',       rendered = '󰨰 Bug',       highlight = 'RenderMarkdownError',   category = 'obsidian' },
          example   = { raw = '[!example]',   rendered = '󰉹 Example',   highlight = 'RenderMarkdownHint' ,   category = 'obsidian' },
          quote     = { raw = '[!quote]',     rendered = '󱆨 Quote',     highlight = 'RenderMarkdownQuote',   category = 'obsidian' },
          cite      = { raw = '[!cite]',      rendered = '󱆨 Cite',      highlight = 'RenderMarkdownQuote',   category = 'obsidian' },
          --stylua: ignore end
        },
      }
    end,
    ft = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
    cmd = "RenderMarkdown",
    config = function(_, opts)
      require("render-markdown").setup(opts)
      Snacks.toggle({
        name = "Render Markdown",
        get = function() return require("render-markdown.state").enabled end,
        set = function(enabled)
          local m = require "render-markdown"
          if enabled then
            m.enable()
          else
            m.disable()
          end
        end,
      }):map "<leader>um"
    end,
  },
  {
    "OXY2DEV/markview.nvim",
    enabled = function() return markdown_render_backend == "markview" and enable_renderer end,
    ft = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
    opts = {
      filetypes = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
      buf_ignore = {},
    },
  },
  {
    "aarnphm/luasnip-latex-snippets.nvim",
    version = false,
    enabled = true,
    dev = true,
    ft = { "markdown", "norg", "rmd", "org" },
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = false,
        branch = "master",
        build = (not jit.os:find "Windows")
            and "echo -e 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
          or nil,
        opts = function()
          return {
            history = true,
            -- Event on which to check for exiting a snippet's region
            region_check_events = "InsertEnter",
            delete_check_events = "TextChanged",
            ft_func = function() return vim.split(vim.bo.filetype, ".", { plain = true }) end,
            load_ft_func = require("luasnip.extras.filetype_functions").extend_load_ft {
              markdown = { "lua", "json", "tex" },
            },
          }
        end,
      },
    },
    config = function()
      require("luasnip-latex-snippets").setup { use_treesitter = true }
      require("luasnip").config.setup { enable_autosnippets = true }
    end,
  },
}
