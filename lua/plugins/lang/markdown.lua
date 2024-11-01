return {
  { "nvim-treesitter", opts = { ensure_installed = { "markdown", "markdown_inline" } } },
  { "jmbuhr/otter.nvim", dependencies = { "nvim-treesitter" }, ft = { "markdown", "quarto", "norg" } },
  -- LSP stuff
  { "mason.nvim", opts = { ensure_installed = { "markdownlint" } } },
  {
    "nvim-lspconfig",
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
  -- Jupyter notebook stuff
  {
    "GCBallesteros/jupytext.nvim",
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },
  {
    "quarto-dev/quarto-nvim",
    lazy = true,
    dependencies = {
      "nvim-cmp",
      "nvim-lspconfig",
      "otter.nvim",
      "nvim-treesitter",
    },
    ft = { "quarto", "markdown", "norg" },
    opts = {
      debug = false,
      closePreviewOnExit = true,
      lspFeatures = {
        enabled = true,
        chunks = "curly",
        languages = { "lua", "python", "rust", "bash" },
        diagnostics = { enabled = true, triggers = { "BufWritePost" } },
        completion = { enabled = true },
      },
      keymap = {
        hover = "H",
        definition = "gd",
        rename = "<LocalLeader>rn",
        references = "gr",
        format = "<Leader><Leader>f",
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
        never_run = { "yaml" },
        ft_runners = { bash = "slime" },
      },
    },
    keys = {
      { "<Leader>r", "", desc = "+Quarto" },
      { "<Leader>rc", function() require("quarto.runner").run_cell() end, desc = "quarto: run cell", silent = true },
      {
        "<Leader>ra",
        function() require("quarto.runner").run_above() end,
        desc = "quarto: run cell and above",
        silent = true,
      },
      {
        "<Leader>rA",
        function() require("quarto.runner").run_all() end,
        desc = "quarto: run all cells",
        silent = true,
      },
      { "<Leader>rl", function() require("quarto.runner").run_line() end, desc = "quarto: run line", silent = true },
      {
        "<Leader>r",
        mode = "v",
        function() require("quarto.runner").run_range() end,
        desc = "quarto: run visual range",
        silent = true,
      },
      {
        "<localleader>RA",
        function() require("quarto.runner").run_all(true) end,
        desc = "quarto: run all cells of all languages",
        silent = true,
      },
    },
  },
  {
    "3rd/image.nvim",
    ft = { "markdown", "norg" },
    config = function()
      local image = require "image"

      ---@diagnostic disable-next-line: missing-fields
      image.setup {
        backend = "kitty", -- ueberzug
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = false,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "quarto" }, -- markdown extensions (ie. quarto) can go here
          },
          neorg = { enabled = false },
        },
        max_width = 100,
        max_height = 8,
        max_height_window_percentage = math.huge,
        max_width_window_percentage = math.huge,
        window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
        editor_only_render_when_focused = true, -- auto show/hide images when the editor gains/looses focus
        tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "fidget", "" },
      }
    end,
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
    opts = {
      enabled = vim.g.enable_render,
      render_modes = { "n", "c" },
      max_file_size = vim.g.bigfile_size,
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
    },
    ft = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
    cmd = "RenderMarkdown",
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
