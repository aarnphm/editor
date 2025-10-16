---@class lazyvim.util.mini
local M = {}

---@param opts? table
function M.files(opts)
  opts = opts or {}

  require("utils.pick").set_force_include_globs(opts.include_ignored_globs)
  opts.include_ignored_globs = nil

  local show_dotfiles = true
  local filter_show = function(_) return true end
  local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end

  local toggle_dotfiles = function()
    show_dotfiles = not show_dotfiles
    local new_filter = show_dotfiles and filter_show or filter_hide
    require("mini.files").refresh { content = { filter = new_filter } }
  end

  local show_preview = false
  local toggle_preview = function()
    show_preview = not show_preview
    require("mini.files").refresh { windows = { preview = show_preview } }
  end

  local go_in_plus = function()
    for _ = 1, vim.v.count1 - 1 do
      MiniFiles.go_in { close_on_file = false }
    end
    local fs_entry = MiniFiles.get_fs_entry()
    local is_at_file = fs_entry ~= nil and fs_entry.fs_type == "file"
    MiniFiles.go_in { close_on_file = false }
    if is_at_file then MiniFiles.close() end
  end

  local map_split = function(buf_id, lhs, direction)
    local rhs = function()
      -- Make new window and set it as target
      ---@type integer
      local new_target_window
      local target_win = MiniFiles.get_explorer_state().target_window
      if target_win then
        vim.api.nvim_win_call(target_win, function()
          vim.cmd(direction .. " split")
          new_target_window = vim.api.nvim_get_current_win()
        end)
      end

      MiniFiles.set_target_window(new_target_window)
      go_in_plus()
    end

    -- Adding `desc` will result into `show_help` entries
    vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = "files: split " .. direction })
  end

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    ---@param args MiniFilesBufferCreate
    callback = function(args)
      local buf_id = args.data.buf_id
      -- Tweak left-hand side of mapping to your liking
      vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "files: toggle dotfiles" })
      vim.keymap.set("n", "gp", toggle_preview, { buffer = buf_id, desc = "files: toggle preview" })
      map_split(buf_id, "gs", "belowright horizontal")
      map_split(buf_id, "gv", "belowright vertical")
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesActionRename",
    callback = function(ev) Snacks.rename.on_rename_file(ev.data.from, ev.data.to) end,
  })

  require("mini.files").setup(opts)
end

---@param opts {skip_next: string, skip_ts: string[], skip_unbalanced: boolean, markdown: boolean, filetypes: string[], mappings?: table<string, any>}
function M.pairs(opts)
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup "disable_ft_minipairs",
    pattern = opts.filetypes,
    callback = function(ev) vim.b[ev.buf].minipairs_disable = true end,
  })
  Snacks.toggle({
    name = "mini pairs",
    get = function() return not vim.g.minipairs_disable end,
    set = function(state) vim.g.minipairs_disable = not state end,
  }):map "<leader>up"

  local P = require "mini.pairs"
  P.setup(opts)

  local open = P.open
  ---@param pair __pairs_pair
  ---@param neigh_pattern __pairs_neigh_pattern
  ---@diagnostic disable-next-line: duplicate-set-field
  P.open = function(pair, neigh_pattern)
    if vim.fn.getcmdline() ~= "" then return open(pair, neigh_pattern) end
    local o, c = pair:sub(1, 1), pair:sub(2, 2)
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local next = line:sub(cursor[2] + 1, cursor[2] + 1)
    local before = line:sub(1, cursor[2])
    if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match "^%s*``" then
      return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
    end
    if opts.skip_next and next ~= "" and next:match(opts.skip_next) then return o end
    if opts.skip_ts and #opts.skip_ts > 0 then
      local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
      for _, capture in ipairs(ok and captures or {}) do
        if vim.tbl_contains(opts.skip_ts, capture.capture) then return o end
      end
    end
    if opts.skip_unbalanced and next == c and c ~= o then
      local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
      local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
      if count_close > count_open then return o end
    end
    return open(pair, neigh_pattern)
  end

  Util.on_load("which-key.nvim", function()
    local objects = {
      { " ", desc = "whitespace" },
      { '"', desc = '" string' },
      { "'", desc = "' string" },
      { "(", desc = "() block" },
      { ")", desc = "() block with ws" },
      { "<", desc = "<> block" },
      { ">", desc = "<> block with ws" },
      { "?", desc = "user prompt" },
      { "U", desc = "use/call without dot" },
      { "[", desc = "[] block" },
      { "]", desc = "[] block with ws" },
      { "_", desc = "underscore" },
      { "`", desc = "` string" },
      { "a", desc = "argument" },
      { "b", desc = ")]} block" },
      { "c", desc = "class" },
      { "d", desc = "digit(s)" },
      { "e", desc = "CamelCase / snake_case" },
      { "f", desc = "function" },
      { "g", desc = "entire file" },
      { "i", desc = "indent" },
      { "o", desc = "block, conditional, loop" },
      { "q", desc = "quote `\"'" },
      { "t", desc = "tag" },
      { "u", desc = "use/call" },
      { "{", desc = "{} block" },
      { "}", desc = "{} with ws" },
    }

    local ret = { mode = { "o", "x" } }
    ---@type table<string, string>
    local mappings = vim.tbl_extend("force", {}, {
      around = "a",
      inside = "i",
      around_next = "an",
      inside_next = "in",
      around_last = "al",
      inside_last = "il",
    }, opts.mappings or {})
    mappings.goto_left = nil
    mappings.goto_right = nil

    for name, prefix in pairs(mappings) do
      name = name:gsub("^around_", ""):gsub("^inside_", "")
      ret[#ret + 1] = { prefix, group = name }
      for _, obj in ipairs(objects) do
        local desc = obj.desc
        if prefix:sub(1, 1) == "i" then desc = desc:gsub(" with ws", "") end
        ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
      end
    end
    require("which-key").add(ret, { notify = false })
  end)
end

return M
