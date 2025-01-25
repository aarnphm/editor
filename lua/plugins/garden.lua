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
    out.modified = os.date "%Y-%m-%d %H:%M:%S GMT-05:00" -- Toronto timezone
    vim.b.last_changedtick = vim.b.changedtick
  end
  -- modify to always keep up-to-date with the filename. i.e: /workspace/posts/corporate personhood.md -> id: corporate personhood
  parts = vim.split(note.path.filename, "/")
  out.id = parts[#parts]:gsub("%.md$", "")
  return out
end

return {
  {
    "benlubas/molten-nvim",
    version = false,
    build = ":UpdateRemotePlugins",
    ft = { "markdown" },
    dependencies = "image.nvim",
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

      vim.api.nvim_create_autocmd("User", {
        pattern = "MoltenInitPost",
        callback = function()
          require("quarto").activate()
          require("otter").activate()
        end,
      })

      -- automatically import output chunks from a jupyter notebook
      -- tries to find a kernel that matches the kernel in the jupyter notebook
      -- falls back to a kernel that matches the name of the active venv (if any)
      local imb = function(e) -- init molten buffer
        vim.schedule(function()
          local kernels = vim.fn.MoltenAvailableKernels()
          local try_kernel_name = function()
            local metadata = vim.json.decode(io.open(e.file, "r"):read "a")["metadata"]
            return metadata.kernelspec.name
          end
          local ok, kernel_name = pcall(try_kernel_name)
          if not ok or not vim.tbl_contains(kernels, kernel_name) then
            kernel_name = nil
            local venv = os.getenv "VIRTUAL_ENV" or os.getenv "CONDA_PREFIX"
            if venv ~= nil then kernel_name = string.match(venv, "/.+/(.+)") end
          end
          if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
            vim.cmd(("MoltenInit %s"):format(kernel_name))
          else
            vim.cmd "MoltenInit"
          end
          vim.cmd "MoltenImportOutput"
        end)
      end

      -- automatically import output chunks from a jupyter notebook
      vim.api.nvim_create_autocmd("BufAdd", {
        pattern = { "*.ipynb" },
        callback = imb,
      })

      -- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { "*.ipynb" },
        callback = function(e)
          if vim.api.nvim_get_vvar "vim_did_enter" ~= 1 then imb(e) end
        end,
      })
    end,
    keys = {
      -- kernels
      {
        "<LocalLeader>m",
        "",
        desc = "+Molten",
      },
      {
        "<LocalLeader>mi",
        ":MoltenInit<CR>",
        desc = "molten: init",
      },
      -- general
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
        "<leader>mp",
        ":MoltenPrev<CR>",
        desc = "molten: next",
        silent = true,
      },
      {
        "<leader>mn",
        ":MoltenNext<CR>",
        desc = "molten: next",
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
    "yetone/avante.nvim",
    dev = true,
    version = false,
    build = "make",
    event = "VeryLazy",
    dependencies = "nui.nvim",
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<CR>", desc = "avante: open" },
      { "<leader>ac", "<cmd>AvanteChat<CR>", desc = "avante: chat" },
      { "<leader>al", "<cmd>AvanteAsk position=left<CR>", desc = "avante: open on right panel" },
    },
    ---@type avante.Config
    opts = {
      debug = false,
      provider = "claude", -- tbh we can switch to copilot
      claude = {
        -- api_key_name = { "bw", "get", "notes", "anthropic-api-key" },
        max_tokens = 8192,
      },
      copilot = {
        model = "claude-3.5-sonnet",
        max_tokens = 8192,
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
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        support_paste_from_clipboard = true,
      },
      file_selector = {
        provider = "mini.pick",
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
        position = "smart",
        sidebar_header = {
          align = "left", -- left, center, right for title
          rounded = false,
        },
        input = { prefix = "➜ " },
        edit = { border = vim.g.border },
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
