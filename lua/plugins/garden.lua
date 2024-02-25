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
      workspaces = { { name = "garden", path = vault, overrides = { notes_subdir = "thoughts" } } },
      open_app_foreground = true,
      wiki_link_func = function(opts)
        path = opts.path
        if opts.label ~= path then
          -- check if opts.path is a markdown file, if so, remove the extension
          -- this is to make sure that the link is not broken when the file is renamed
          if opts.path:match "%.md$" then path = path:sub(1, -4) end
          -- if opts.path start with [, then remove it so that once we format the wikilink it is correct
          if opts.path:match "^%[" then path = path:sub(2) end
          return string.format("[[%s|%s]]", path, opts.label)
        else
          return string.format("[[%s]]", path)
        end
      end,
      new_notes_location = "notes_subdir",
      yaml_parser = "yq",
      preferred_link_style = "wiki",
      disable_frontmatter = false,
      ---@type fun(note: obsidian.Note): table<string, string>
      note_frontmatter_func = function(note)
        if note.path.filename:match "tags" then return note.metadata end
        local out = { id = note.id, aliases = note.aliases, tags = note.tags }
        -- `note.metadata` contains any manually added fields in the frontmatter.
        -- So here we just make sure those fields are kept in the frontmatter.
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          out = vim.tbl_deep_extend("force", out, note.metadata)
        end
        if out.title == nil then out.title = note.id end
        if out.date == nil then out.date = os.date "%Y-%m-%d" end
        -- check if the length of out.aliases is 0, if so, remove it from the frontmatter
        if #out.aliases == 0 then out.aliases = nil end
        return out
      end,
      note_id_func = function(title) return title end,
    },
    config = function(_, opts) require("obsidian").setup(opts) end,
  },
}
