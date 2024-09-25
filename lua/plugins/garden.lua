local capstone_vault = vim.fn.expand "~" .. "/workspace/capstone/docs/content"

---@param note obsidian.Note
---@param tbl function(note: obsidian.Note): table<string, any>
local out_functor = function(note, tbl)
  if note.path.filename:match "tags" then return note.metadata end

  local out = tbl(note)

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
end

return {
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
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "quarto", "markdown" },
    opts = {
      debug = false,
      closePreviewOnExit = true,
      lspFeatures = {
        enabled = true,
        chunks = "curly",
        languages = { "r", "python", "rust", "bash", "html" },
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
      codeRunner = { enabled = true, default_method = "molten", never_run = { "yaml" } },
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
    "benlubas/molten-nvim",
    version = false,
    build = ":UpdateRemotePlugins",
    ft = { "markdown" },
    dependencies = { "quarto-nvim" },
    cmd = { "MoltenInfo", "MoltenInit" },
    init = function()
      -- I find auto open annoying, keep in mind setting this option will require setting
      -- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
      vim.g.molten_auto_open_output = false

      -- this guide will be using image.nvim
      -- Don't forget to setup and install the plugin if you want to view image outputs
      vim.g.molten_image_provider = "image.nvim"

      -- optional, I like wrapping. works for virt text and the output window
      vim.g.molten_wrap_output = true

      -- Output as virtual text. Allows outputs to always be shown, works with images, but can
      -- be buggy with longer images
      vim.g.molten_virt_text_output = true

      -- this will make it so the output shows up below the \`\`\` cell delimiter
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    keys = {
      {
        "<leader>m",
        "",
        desc = "+Molten",
      },
      {
        "<leader>me",
        ":MoltenEvaluateOperator<CR>",
        desc = "molten: evaluate operator",
        silent = true,
      },
      {
        "<leader>mr",
        ":MoltenReevaluateCell<CR>",
        desc = "molten: re-eval cell",
        silent = true,
      },
      {
        "<leader>md",
        ":MoltenDelete<CR>",
        desc = "molten: delete cell",
        silent = true,
      },
      {
        "<leader>mx",
        ":MoltenOpenInBrowser<CR>",
        desc = "molten: open in browser",
        silent = true,
      },
      {
        "<leader>mh",
        ":MoltenHideOutput<CR>",
        desc = "molten: hide output windows",
        silent = true,
      },
      {
        "<leader>mr",
        mode = { "v" },
        "<C-u>MoltenEvaluateVisual<CR>gv",
        desc = "molten: execute visual selection",
        silent = true,
      },
      {
        "<leader>mo",
        ":noautocmd MoltenEnterOutput<CR>",
        desc = "molten: open output window",
        silent = true,
      },
    },
  },
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
    enabled = function() return vim.g.markdown_render_backend == "render-markdown" end,
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
    "OXY2DEV/markview.nvim",
    enabled = function() return vim.g.markdown_render_backend == "markview" end,
    lazy = false,
    ft = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
    opts = {
      filetypes = { "markdown", "norg", "rmd", "org", "vimwiki", "Avante" },
      buf_ignore = {},
    },
  },
  {
    "epwalsh/obsidian.nvim",
    lazy = true,
    version = false,
    event = {
      "BufReadPre " .. vim.g.vault .. "/**.md",
      "BufNewFile " .. vim.g.vault .. "/**.md",
      "BufReadPre " .. capstone_vault .. "/**.md",
      "BufNewFile " .. capstone_vault .. "/**.md",
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
      workspaces = {
        { name = "garden", path = vim.g.vault, overrides = { notes_subdir = "thoughts" } },
        {
          name = "capstone",
          path = capstone_vault,
          overrides = {
            note_frontmatter_func = function(note)
              return out_functor(
                note,
                function(note) return { id = note.id, aliases = note.aliases, tags = note.tags, author = "" } end
              )
            end,
          },
        },
      },
      open_app_foreground = true,
      log_level = vim.log.levels.INFO,
      open_notes_in = "vsplit",
      completion = { nvim_cmp = false },
      follow_url_func = function(url) vim.ui.open(url) end,
      new_notes_location = "notes_subdir",
      yaml_parser = "yq",
      preferred_link_style = "wiki",
      disable_frontmatter = false,
      templates = { subdir = "templates" },
      ui = { enable = false, external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" } },
      note_frontmatter_func = function(note)
        return out_functor(note, function(note) return { id = note.id, aliases = note.aliases, tags = note.tags } end)
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
  -- support for image pasting
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>ip",
        function()
          return vim.bo.filetype == "AvanteInput" and require("avante.clipboard").paste_image()
            or require("img-clip").paste_image()
        end,
        desc = "clip: paste image",
      },
    },
    opts = {
      default = {
        embed_image_as_base64 = false,
        prompt_for_file_name = false,
        drag_and_drop = {
          insert_mode = true,
        },
      },
    },
  },
  {
    "yetone/avante.nvim",
    dev = true,
    version = false,
    build = ":AvanteBuild",
    event = "VeryLazy",
    dependencies = { "nui.nvim" },
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<CR>", desc = "avante: open" },
      { "<leader>ac", "<cmd>AvanteChat<CR>", desc = "avante: chat" },
      { "<leader>al", "<cmd>AvanteAsk position=left<CR>", desc = "avante: open on right panel" },
    },
    ---@type avante.Config
    opts = {
      debug = false,
      provider = "claude",
      claude = {
        api_key_name = { "bw", "get", "notes", "anthropic-api-key" },
        max_tokens = 8192,
      },
      openai = {
        api_key_name = "cmd:bw get notes oai-api-key",
        model = "gpt-4o-2024-08-06",
      },
      cohere = {
        model = "command-r-plus-08-2024",
        api_key_name = "cmd:bw get notes cohere-api-key",
      },
      gemini = {
        api_key_name = "cmd:bw get notes gemini-api-key",
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        support_paste_from_clipboard = true,
      },
      mappings = {
        submit = { normal = "<CR>", insert = "<C-CR>" },
        suggestion = {
          accept = "<M-j>",
          next = "<M-l>",
          prev = "<M-h>",
          dismiss = "<M-k>",
        },
      },
      windows = {
        sidebar_header = {
          align = "left", -- left, center, right for title
          rounded = false,
        },
        input = { prefix = "➜ " },
        edit = { border = vim.g.border },
      },
      vendors = {
        ---@type AvanteProvider
        perplexity = {
          endpoint = "https://api.perplexity.ai/chat/completions",
          model = "llama-3.1-sonar-large-128k-online",
          api_key_name = "cmd:bw get notes perplexity-api-key",
          parse_curl_args = function(opts, code_opts)
            return {
              url = opts.endpoint,
              headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. os.getenv(opts.api_key_name),
              },
              body = {
                model = opts.model,
                messages = { -- you can make your own message, but this is very advanced
                  { role = "system", content = code_opts.system_prompt },
                  { role = "user", content = require("avante.providers.openai").get_user_message(code_opts) },
                },
                temperature = 0,
                max_tokens = 8192,
                stream = true, -- this will be set by default.
              },
            }
          end,
          -- The below function is used if the vendors has specific SSE spec that is not claude or openai.
          parse_response_data = function(data_stream, event_state, opts)
            require("avante.providers").openai.parse_response(data_stream, event_state, opts)
          end,
        },
        ---@type AvanteProvider
        groq = {
          endpoint = "https://api.groq.com/openai/v1/chat/completions",
          model = "llama-3.1-70b-versatile",
          api_key_name = "GROQ_API_KEY",
          parse_curl_args = function(opts, code_opts)
            return {
              url = opts.endpoint,
              headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. os.getenv(opts.api_key_name),
              },
              body = {
                model = opts.model,
                messages = { -- you can make your own message, but this is very advanced
                  { role = "system", content = code_opts.system_prompt },
                  { role = "user", content = require("avante.providers.openai").get_user_message(code_opts) },
                },
                temperature = 0,
                max_tokens = 4096,
                stream = true, -- this will be set by default.
              },
            }
          end,
          parse_response_data = function(data_stream, event_state, opts)
            require("avante.providers").openai.parse_response(data_stream, event_state, opts)
          end,
        },
        ---@type AvanteProvider
        deepseek = {
          endpoint = "https://api.deepseek.com/chat/completions",
          model = "deepseek-coder",
          api_key_name = "DEEPSEEK_API_KEY",
          parse_curl_args = function(opts, code_opts)
            return {
              url = opts.endpoint,
              headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. os.getenv(opts.api_key_name),
              },
              body = {
                model = opts.model,
                messages = { -- you can make your own message, but this is very advanced
                  { role = "system", content = code_opts.system_prompt },
                  { role = "user", content = require("avante.providers.openai").get_user_message(code_opts) },
                },
                temperature = 0,
                max_tokens = 4096,
                stream = true, -- this will be set by default.
              },
            }
          end,
          parse_response_data = function(data_stream, event_state, opts)
            require("avante.providers").openai.parse_response(data_stream, event_state, opts)
          end,
        },
        ---@type AvanteProvider
        codestral = {
          ["local"] = true,
          endpoint = "",
          model = "mistralai/Codestral-22B-v0.1",
          api_key_name = "BENTOCLOUD_API_KEY",
          parse_curl_args = function(opts, code_opts)
            return {
              url = opts.endpoint .. "/v1/chat/completions",
              headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
              },
              body = {
                model = opts.model,
                messages = { -- you can make your own message, but this is very advanced
                  { role = "system", content = code_opts.system_prompt },
                  { role = "user", content = require("avante.providers.openai").get_user_message(code_opts) },
                },
                max_tokens = 1024,
                stream = true,
              },
            }
          end,
          -- The below function is used if the vendors has specific SSE spec that is not claude or openai.
          parse_response_data = function(data_stream, event_state, opts)
            require("avante.providers").openai.parse_response(data_stream, event_state, opts)
          end,
        },
        ---@type AvanteProvider
        ollama = {
          ["local"] = true,
          endpoint = "127.0.0.1:11434/v1",
          model = "codegemma",
          parse_curl_args = function(opts, code_opts)
            return {
              url = opts.endpoint .. "/chat/completions",
              headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
              },
              body = {
                model = opts.model,
                messages = { -- you can make your own message, but this is very advanced
                  { role = "system", content = code_opts.system_prompt },
                  { role = "user", content = require("avante.providers.openai").get_user_message(code_opts) },
                },
                max_tokens = 2048,
                stream = true,
              },
            }
          end,
          parse_response_data = function(data_stream, event_state, opts)
            require("avante.providers").openai.parse_response(data_stream, event_state, opts)
          end,
        },
        ---@type AvanteProvider
        mistral = {
          endpoint = "https://api.mistral.ai/v1/chat/completions",
          model = "mistral-7b-v0.1",
          api_key_name = "MISTRAL_API_KEY",
          parse_curl_args = function(opts, code_opts)
            return {
              url = opts.endpoint,
              headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. os.getenv(opts.api_key_name),
              },
              body = {
                model = opts.model,
                messages = {
                  { role = "system", content = code_opts.system_prompt },
                  { role = "user", content = table.concat(code_opts.user_prompts, "\n\n") },
                },
                temperature = 0,
                max_tokens = 4096,
                stream = true,
              },
            }
          end,
          parse_response_data = function(data_stream, event_state, opts)
            require("avante.providers").openai.parse_response(data_stream, event_state, opts)
          end,
        },
      },
    },
  },
}
