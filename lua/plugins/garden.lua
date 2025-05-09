local capstone_vault = vim.fn.expand "~" .. "/workspace/capstone/docs/content"
local garden_vault = vim.fn.expand "~" .. "/workspace/garden/content"

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
  if out.modified == nil or vim.b.changedtick ~= vim.b.last_changedtick then
    local raw_offset = os.date "%z" -- e.g. "+0530"
    local sign = raw_offset:sub(1, 1) -- "+" or "-"
    local hour_part = raw_offset:sub(2, 3) -- "05"
    local min_part = raw_offset:sub(4, 5) -- "30"
    local tz_colon = string.format("%s%s:%s", sign, hour_part, min_part)
    out.modified = string.format("%s GMT%s", os.date "%Y-%m-%d %H:%M:%S", tz_colon)
    vim.b.last_changedtick = vim.b.changedtick
  end
  -- modify to always keep up-to-date with the filename. i.e: /workspace/posts/corporate personhood.md -> id: corporate personhood
  parts = vim.split(note.path.filename, "/")
  out.id = parts[#parts]:gsub("%.md$", "")
  return out
end

return {
  {
    "epwalsh/obsidian.nvim",
    lazy = true,
    version = false,
    event = {
      "BufReadPre " .. garden_vault .. "/**.md",
      "BufNewFile " .. garden_vault .. "/**.md",
      "BufReadPre " .. capstone_vault .. "/**.md",
      "BufNewFile " .. capstone_vault .. "/**.md",
    },
    keys = {
      {
        "<Leader>o",
        "<cmd>ObsidianOpen<cr>",
        desc = "obsidian: open",
      },
      {
        "<Leader>on",
        ":ObsidianTemplate ",
        desc = "obsidian: new notes",
      },
      {
        "<Leader>os",
        "<cmd>ObsidianSearch<cr>",
        desc = "obsidian: search",
      },
      {
        "<Leader>ob",
        "<cmd>ObsidianBacklinks<cr>",
        desc = "obsidian: backlinks",
      },
    },
    dependencies = { "nvim-lua/plenary.nvim", "mini.nvim" },
    ---@type obsidian.config.ClientOpts
    opts = {
      workspaces = {
        {
          name = "garden",
          path = garden_vault,
          overrides = {
            notes_subdir = "thoughts",
            attachments = {
              img_folder = "thoughts/images",
            },
          },
        },
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
        return out_functor(
          note,
          function(n)
            return {
              id = n.id,
              aliases = n.aliases,
              tags = n.tags,
            }
          end
        )
      end,
      note_id_func = function(title) return title end,
      picker = { name = "mini.pick" },
    },
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
    "aarnphm/surf.nvim",
    dev = true,
    version = false,
    enabled = false,
    build = "nix run .#plugin",
    event = "VeryLazy",
    dependencies = {
      "plenary.nvim",
      "blink.cmp",
      "folke/snacks.nvim",
    },
    opts = {},
  },
  {
    "yetone/avante.nvim",
    dev = true,
    version = false,
    build = "nix run .#plugin",
    event = "VeryLazy",
    dependencies = "nui.nvim",
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<CR>", desc = "avante: open" },
      { "<leader>aC", "<cmd>AvanteChat<CR>", desc = "avante: chat" },
      { "<leader>al", "<cmd>AvanteAsk position=left<CR>", desc = "avante: open on right panel" },
    },
    ---@type avante.Config
    opts = {
      debug = false,
      provider = "claude", -- tbh we can switch to copilot
      cursor_applying_provider = "claude",
      memory_summary_provider = "claude",
      claude = {
        -- api_key_name = { "bw", "get", "notes", "anthropic-api-key" },
      },
      copilot = {
        model = "claude-3.7-sonnet",
      },
      openai = {
        -- api_key_name = "cmd:bw get notes oai-api-key",
        model = "gpt-4o-2024-08-06",
      },
      cohere = {
        model = "command-r-plus-08-2024",
        -- api_key_name = "cmd:bw get notes cohere-api-key",
      },
      gemini = {
        -- api_key_name = "cmd:bw get notes gemini-api-key",
      },
      rag_service = {
        enabled = vim.g.avante_rag,
        runner = "nix",
        llm_model = "o4-mini",
        embed_model = "text-embedding-3-small",
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        support_paste_from_clipboard = true,
        auto_suggestions_respect_ignore = true,
        enable_cursor_planning_mode = true,
        enable_claude_text_editor_tool_mode = true,
      },
      file_selector = { provider = "mini.pick" },
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
        position = "right",
        height = 4,
        sidebar_header = {
          align = "left", -- left, center, right for title
          rounded = false,
        },
        input = { prefix = "➜ " },
        edit = { border = vim.g.border, start_insert = false },
        ask = { start_insert = false, border = vim.g.border },
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
          parse_response = function(data_stream, event_state, opts)
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
          parse_response = function(data_stream, event_state, opts)
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
          parse_response = function(data_stream, event_state, opts)
            require("avante.providers").openai.parse_response(data_stream, event_state, opts)
          end,
        },
        ---@type AvanteProvider
        codestral = {
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
          parse_response = function(data_stream, event_state, opts)
            require("avante.providers").openai.parse_response(data_stream, event_state, opts)
          end,
        },
        ---@type AvanteProvider
        ollama = {
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
          parse_response = function(data_stream, event_state, opts)
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
          parse_response = function(data_stream, event_state, opts)
            require("avante.providers").openai.parse_response(data_stream, event_state, opts)
          end,
        },
      },
    },
  },
}
