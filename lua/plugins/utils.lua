return {
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "<leader>R", "", desc = "+Rest" },
      { "<leader>Rs", function() require("kulala").run() end, desc = "curl: send request" },
      { "<leader>Rt", function() require("kulala").toggle_view() end, desc = "curl: toggle headers/body" },
      { "<leader>Rp", function() require("kulala").jump_prev() end, desc = "curl: jump to previous requests" },
      { "<leader>Rn", function() require("kulala").jump_next() end, desc = "curl: jump to next requests" },
    },
    opts = {},
  },
  {
    "andweeb/presence.nvim",
    event = "LazyFile",
    opts = { enable_line_number = true },
  },
  {
    "yetone/avante.nvim",
    dev = true,
    version = false,
    cmd = "AvanteAsk",
    build = "make",
    keys = {
      { "<leader>ua", "<cmd>:AvanteAsk<CR>", desc = "avante: ask", mode = { "n", "v" } },
      { "<leader>ur", "<cmd>:AvanteRefresh<CR>", desc = "avante: refresh" },
    },
    specs = { { "zbirenbaum/copilot.lua", enabled = false, optional = true } },
    dependencies = { { "grapp-dev/nui-components.nvim" } },
    ---@type avante.Config
    opts = {
      debug = false,
      provider = "copilot", -- "groq"
      mappings = {
        ask = "<leader>ua",
        refresh = "<leader>ur",
      },
      vendors = {
        ---@type AvanteProvider
        perplexity = {
          endpoint = "https://api.perplexity.ai/chat/completions",
          model = "llama-3.1-sonar-large-128k-online",
          api_key_name = "PPLX_API_KEY",
          --- this function below will be used to parse in cURL arguments.
          parse_curl_args = function(opts, code_opts)
            local Llm = require "avante.llm"
            return {
              url = opts.endpoint,
              headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. os.getenv(opts.api_key_name),
              },
              body = {
                model = opts.model,
                messages = Llm.make_openai_message(code_opts), -- you can make your own message, but this is very advanced
                temperature = 0,
                max_tokens = 8192,
                stream = true, -- this will be set by default.
              },
            }
          end,
          -- The below function is used if the vendors has specific SSE spec that is not claude or openai.
          parse_response_data = function(data_stream, event_state, opts)
            local Llm = require "avante.llm"
            Llm.parse_openai_response(data_stream, event_state, opts)
          end,
        },
        ---@type AvanteProvider
        ["codestral"] = {
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
                messages = require("avante.llm").make_openai_message(code_opts), -- you can make your own message, but this is very advanced
                max_tokens = 1024,
                stream = true,
              },
            }
          end,
          -- The below function is used if the vendors has specific SSE spec that is not claude or openai.
          parse_response_data = function(data_stream, event_state, opts)
            require("avante.llm").parse_openai_response(data_stream, event_state, opts)
          end,
        },
      },
    },
  },
}
