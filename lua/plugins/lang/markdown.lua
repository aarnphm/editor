return {
  { "mason.nvim", opts = { ensure_installed = { "markdownlint", "typos" } } },
  {
    "nvim-lint",
    opts = {
      linters_by_ft = { markdown = { "markdownlint", "typos" } },
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
    "nvim-lspconfig",
    opts = {
      servers = {
        typos_lsp = {},
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
    enabled = function() return vim.g.markdown_render_backend == "render-markdown" end,
    opts = function()
      return {
        enabled = vim.g.enable_render,
        render_modes = { "n", "c" },
        max_file_size = Snacks.config.bigfile.size,
        heading = { sign = false },
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
    enabled = function() return vim.g.markdown_render_backend == "markview" end,
    ft = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
    opts = {
      filetypes = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
      buf_ignore = {},
    },
  },
  {
    "aarnphm/luasnip-latex-snippets.nvim",
    version = false,
    lazy = true,
    ft = { "markdown", "norg", "rmd", "org" },
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
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
