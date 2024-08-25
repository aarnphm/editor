return {
  -- Markdown preview
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
    enabled = true,
    opts = {
      file_types = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
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
    cmd = { "RenderMarkdown" },
    config = function(_, opts)
      require("render-markdown").setup(opts)

      Util.toggle.map("<leader>um", {
        name = "markdown render",
        get = function() return require("render-markdown.state").enabled end,
        set = function(enabled)
          local m = require "render-markdown"
          if enabled then
            m.enable()
          else
            m.disable()
          end
        end,
      })
    end,
  },
  {
    "epwalsh/obsidian.nvim",
    lazy = true,
    version = false,
    event = {
      "BufReadPre " .. vim.g.vault .. "/**.md",
      "BufNewFile " .. vim.g.vault .. "/**.md",
    },
    keys = {
      {
        "<LocalLeader>n",
        ":ObsidianTemplate ",
        desc = "obsidian: new notes",
      },
      {
        "<LocalLeader>o",
        "<cmd>ObsidianOpen<cr>",
        desc = "obsidian: open",
      },
      {
        "<Leader>ss",
        "<cmd>ObsidianSearch<cr>",
        desc = "obsidian: open",
      },
      {
        "<Leader>ll",
        "<cmd>ObsidianBacklinks<cr>",
        desc = "obsidian: open",
      },
    },
    dependencies = { "nvim-lua/plenary.nvim", "mini.nvim", "nvim-cmp" },
    ---@type obsidian.config.ClientOpts
    opts = {
      workspaces = { { name = "garden", path = vim.g.vault, overrides = { notes_subdir = "thoughts" } } },
      open_app_foreground = true,
      log_level = vim.log.levels.INFO,
      open_notes_in = "vsplit",
      follow_url_func = function(url) vim.ui.open(url) end,
      new_notes_location = "notes_subdir",
      yaml_parser = "yq",
      preferred_link_style = "wiki",
      disable_frontmatter = false,
      templates = { subdir = "templates" },
      ui = { enable = false, external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" } },
      note_frontmatter_func = function(note)
        if note.path.filename:match "tags" then return note.metadata end
        local out = { id = note.id, aliases = note.aliases, tags = note.tags }
        -- `note.metadata` contains any manually added fields in the frontmatter.
        -- So here we just make sure those fields are kept in the frontmatter.
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          out = vim.tbl_deep_extend("force", out, note.metadata)
        end
        if out.title == nil then out.title = note.id end
        if out.date == nil then out.date = os.date "%Y-%m-%d" end
        -- check if the length of out.aliases is 0, if so, remove it from the frontmatter
        if #out.aliases == 0 then out.aliases = nil end
        return out
      end,
      note_id_func = function(title) return title end,
      picker = { name = "mini.pick" },
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
