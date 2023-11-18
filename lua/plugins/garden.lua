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
    "NStefan002/speedtyper.nvim",
    lazy = true,
    cmd = "Speedtyper",
    opts = {},
  },
  { "pwntester/octo.nvim", opts = {}, cmd = "Octo" },
}
