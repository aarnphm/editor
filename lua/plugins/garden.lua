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
    dependencies = { "plenary.nvim", "mini.nvim" },
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
        return out_functor(note, function(n) return { id = n.id, aliases = n.aliases, tags = n.tags } end)
      end,
      note_id_func = function(title) return title end,
      picker = { name = "mini.pick" },
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
}
