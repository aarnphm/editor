return function()
  require("legendary").setup({
    which_key = {
      auto_register = true,
      do_binding = false,
    },
    scratchpad = {
      view = "float",
      results_view = "float",
      keep_contents = true,
    },
    sort = {
      -- sort most recently used item to the top
      most_recent_first = true,
      -- sort user-defined items before built-in items
      user_items_first = true,
      frecency = {
        -- the directory to store the database in
        db_root = string.format("%s/legendary/", vim.fn.stdpath("data")),
        -- the maximum number of timestamps for a single item
        -- to store in the database
        max_timestamps = 10,
      },
    },
    -- Directory used for caches
    cache_path = string.format("%s/legendary/", vim.fn.stdpath("cache")),
    -- Log level, one of 'trace', 'debug', 'info', 'warn', 'error', 'fatal'
    log_level = "info",
  })
  require("utils").annotate_mapping()
end
