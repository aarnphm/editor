local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  spec = {
    {
      "AstroNvim/AstroNvim",
      version = "^4",
      import = "astronvim.plugins",
      opts = { -- AstroNvim options must be set here with the `import` key
        mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
        maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
        icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
        pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
        update_notifications = true, -- Enable/disable notification about running `:Lazy update` twice to update pinned plugins
      },
    },
    {
      "yetone/avante.nvim",
      dev = true,
      version = false,
      cmd = { "AvanteAsk", "AvanteSwitchProvider", "AvanteRefresh" },
      build = "make",
      keys = {
        { "<leader>ua", "<cmd>:AvanteAsk<CR>", desc = "avante: ask", mode = { "n", "v" } },
        { "<leader>ur", "<cmd>:AvanteRefresh<CR>", desc = "avante: refresh" },
      },
      dependencies = { "nui.nvim" },
      ---@type avante.Config
      opts = {
        debug = false,
        provider = "claude",
        claude = {
          api_key_name = "cmd:bw get notes anthropic-api-key",
        },
        openai = {
          api_key_name = "cmd:bw get notes oai-api-key",
        },
        behaviour = {
          auto_set_highlight_group = false,
          support_paste_from_clipboard = true,
        },
        mappings = {
          ask = "<leader>ua",
          edit = "<leader>ue",
          refresh = "<leader>ur",
          submit = {
            normal = "<CR>",
            insert = "<C-CR>",
          },
          toggle = {
            debug = "<LocalLeader>ud",
            hint = "<LocalLeader>uh",
          },
        },
        windows = {
          width = 30,
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
                  messages = require("avante.providers").openai.parse_message(code_opts), -- you can make your own message, but this is very advanced
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
                  messages = require("avante.providers").openai.parse_message(code_opts), -- you can make your own message, but this is very advanced
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
                  messages = require("avante.providers").openai.parse_message(code_opts), -- you can make your own message, but this is very advanced
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
                  messages = require("avante.providers").openai.parse_message(code_opts), -- you can make your own message, but this is very advanced
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
