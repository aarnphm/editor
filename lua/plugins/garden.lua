local vault = vim.fn.expand "~" .. "/workspace/garden/content"

return {
  {
    "epwalsh/obsidian.nvim",
    lazy = true,
    version = false,
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
    dependencies = { "nvim-lua/plenary.nvim", "nvim-cmp" },
    ---@type obsidian.config.ClientOpts
    opts = {
      workspaces = { { name = "garden", path = vault, overrides = { notes_subdir = "dump" } } },
      open_app_foreground = true,
      completion = { prepend_note_path = true, prepend_note_id = false },
      new_notes_location = "notes_subdir",
      yaml_parser = "yq",
      disable_frontmatter = false,
      ---@type fun(note: obsidian.Note): table<string, string>
      note_frontmatter_func = function(note)
        local out = { id = note.id, tags = note.tags }
        -- `note.metadata` contains any manually added fields in the frontmatter.
        -- So here we just make sure those fields are kept in the frontmatter.
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          out = vim.tbl_deep_extend("force", out, note.metadata)
        end
        if out.title == nil then out.title = note.id end
        if out.date == nil then out.date = os.date "%Y-%m-%d" end
        return out
      end,
      note_id_func = function(title) return title end,
    },
    config = function(_, opts) require("obsidian").setup(opts) end,
  },
}
