return {
  {
    -- support for image pasting
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
    event = "VeryLazy",
    dependencies = { "nui.nvim" },
    ---@type avante.Config
    opts = {
      debug = false,
      provider = "claude",
      claude = {
        api_key_name = "cmd:bw get notes anthropic-api-key",
        max_tokens = 8192,
      },
      openai = {
        api_key_name = "cmd:bw get notes oai-api-key",
      },
      behaviour = {
        auto_set_highlight_group = false,
        support_paste_from_clipboard = true,
      },
      mappings = {
        submit = { normal = "<CR>", insert = "<C-CR>" },
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
      },
    },
  },
}
