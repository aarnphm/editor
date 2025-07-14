return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = false,
        debounce = 75,
        keymap = {
          accept = "<M-CR>",
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      filetypes = {
        markdown = true,
        sh = function()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then return false end
          return true
        end,
      },
      server_opts_overrides = {
        settings = {
          advanced = {
            inlineSuggestCount = 3,
          },
        },
      },
    },
  },
  {
    "aarnphm/surf.nvim",
    dev = true,
    version = false,
    enabled = false,
    build = "nix run .#plugin",
    event = "VeryLazy",
    dependencies = { "plenary.nvim", "blink.cmp", "snacks.nvim" },
    opts = {},
  },
  {
    "yetone/avante.nvim",
    dev = true,
    version = false,
    enabled = false,
    build = "make",
    event = "LazyFile",
    dependencies = {
      "MunifTanjim/nui.nvim",
      -- support for image pasting
      {
        "HakonHarnes/img-clip.nvim",
        event = "LazyFile",
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
    },
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<CR>", desc = "avante: open" },
      {
        "<leader>aq",
        function()
          local _A = Util.opts "avante.nvim"
          if not _A then return end
          require("avante.diff").conflicts_to_qf_items(function(items)
            if #items > 0 then
              vim.fn.setqflist(items, "r")
              vim.cmd "copen"
            end
          end)
        end,
        desc = "avante: convert diff to quickfix",
      },
      { "<leader>aC", "<cmd>AvanteChat<CR>", desc = "avante: chat" },
      { "<leader>al", "<cmd>AvanteAsk position=left<CR>", desc = "avante: open on right panel" },
    },
    ---@type avante.Config
    opts = {
      debug = false,
      provider = "openai", -- tbh we can switch to copilot
      cursor_applying_provider = "claude-haiku",
      memory_summary_provider = "claude",
      rag_service = {
        enabled = false,
        runner = "nix",
        llm_model = "o4-mini",
        embed_model = "text-embedding-3-small",
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        support_paste_from_clipboard = false,
        auto_suggestions_respect_ignore = true,
        auto_focus_on_diff_view = true,
      },
      selector = { provider = "mini_pick" },
      mappings = {
        submit = { normal = "<CR>", insert = "<C-CR>" },
        sidebar = { close_from_input = { normal = "<Esc>", insert = "<C-d>" } },
      },
      windows = {
        position = "right",
        height = 4,
        sidebar_header = { align = "left", rounded = false },
        input = { prefix = "➜ ", height = 3 },
      },
      providers = {
        claude = {
          -- api_key_name = { "bw", "get", "notes", "anthropic-api-key" },
        },
        copilot = {
          model = "claude-3.7-sonnet",
        },
        openai = {
          -- api_key_name = "cmd:bw get notes oai-api-key",
          model = "o3-mini",
        },
        cohere = {
          model = "command-r-plus-08-2024",
          -- api_key_name = "cmd:bw get notes cohere-api-key",
        },
        gemini = {
          -- api_key_name = "cmd:bw get notes gemini-api-key",
        },
        ---@type AvanteProvider
        groq = {
          __inherited_from = "openai",
          api_key_name = "GROQ_API_KEY",
          endpoint = "https://api.groq.com/openai/v1/",
          model = "llama-3.3-70b-versatile",
          disable_tools = true,
        },
        ---@type AvanteProvider
        deepseek = {
          __inherited_from = "openai",
          endpoint = "https://api.deepseek.com/",
          model = "deepseek-coder",
          api_key_name = "DEEPSEEK_API_KEY",
        },
        ---@type AvanteProvider
        codestral = {
          __inherited_from = "openai",
          endpoint = "",
          model = "mistralai/Codestral-22B-v0.1",
          api_key_name = "BENTOCLOUD_API_KEY",
        },
        ---@type AvanteProvider
        ollama = {
          endpoint = "127.0.0.1:11434/v1",
          model = "codegemma",
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    version = false,
    build = "cargo build --release",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "moyiz/blink-emoji.nvim",
    },
    event = "InsertEnter",
    opts_extend = { "sources.default" },
    ---@type blink.cmp.Config
    opts = {
      fuzzy = { implementation = "rust" },
      appearance = { kind_icons = { Copilot = "" } },
      snippets = { expand = function(snippet) return Util.cmp.expand(snippet) end },
      signature = { enabled = false },
      completion = {
        menu = {
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } },
            components = {
              label_description = { width = { max = 40 }, text = function(ctx) return ctx.label_description or "" end },
            },
            padding = 0,
            gap = 1,
          },
        },
        accept = { auto_brackets = { enabled = false } },
        documentation = { auto_show = false, auto_show_delay_ms = 200 },
        trigger = { show_in_snippet = false },
        list = {
          selection = {
            preselect = function() return not require("blink.cmp").snippet_active { direction = 1 } end,
          },
        },
      },
      cmdline = { enabled = false },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "emoji" },
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          snippets = {
            opts = {
              ignored_filetypes = { "git", "gitcommit" },
              extended_filetypes = { markdown = { "latex" } },
            },
          },
          emoji = {
            module = "blink-emoji",
            name = "Emoji",
            score_offset = 15,
            opts = { insert = true },
            should_show_items = function() return vim.tbl_contains({ "gitcommit", "markdown" }, vim.o.filetype) end,
          },
        },
      },
      keymap = {
        preset = "super-tab",
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          Util.cmp.map { "snippet_forward" },
          "fallback",
        },
      },
    },
  },
}
