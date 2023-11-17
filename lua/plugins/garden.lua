local vault = vim.fn.expand "~" .. "/workspace/garden/content"

return {
  {
    "epwalsh/obsidian.nvim",
    lazy = true,
    event = {
      "BufReadPre " .. vault .. "/**.md",
      "BufNewFile " .. vault .. "/**.md",
    },
    keys = {
      {
        "<LocalLeader>n",
        ":ObsidianNew ",
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
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      dir = vault,
      notes_subdir = "dump",
      open_app_foreground = true,
      new_notes_location = "notes_subdir",
      note_id_func = function(title) return title end,
      ---@param note obsidian.Note
      note_frontmatter_func = function(note)
        local out = { id = note.id, tags = note.tags }
        -- `note.metadata` contains any manually added fields in the frontmatter.
        -- So here we just make sure those fields are kept in the frontmatter.
        if note.metadata ~= nil and require("obsidian").util.table_length(note.metadata) > 0 then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,
      mappings = {
        ["gf"] = {
          action = function() return require("obsidian").util.gf_passthrough() end,
          opts = { noremap = false, expr = true, buffer = true },
        },
      },
    },
    config = function(_, opts) require("obsidian").setup(opts) end,
  },
  {
    "glacambre/firenvim",
    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    -- run this without cond: nvim --headless "+call firenvim#install(0) | q"
    lazy = false,
    build = function() vim.fn["firenvim#install"](0) end,
    init = function()
      vim.g.firenvim_config = {
        globalSettings = {
          alt = "all",
        },
        localSettings = {
          [".*"] = {
            takeover = "never",
          },
        },
      }
      if vim.g.started_by_firenvim == true then
        vim.o.guifont = "JetBrainsMonoNL Nerd Font:h18"
        vim.o.laststatus = 0
      end
    end,
  },
  {
    "NStefan002/speedtyper.nvim",
    lazy = true,
    cmd = "Speedtyper",
    opts = {},
  },
  { "pwntester/octo.nvim", opts = {}, cmd = "Octo" },
}
