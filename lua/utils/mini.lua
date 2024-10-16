---@class lazyvim.util.mini
local M = {}

-- Tailwind support
---@type table<string,true>
M.hl = {}

M.colors = {
  slate = {
    [50] = "f8fafc",
    [100] = "f1f5f9",
    [200] = "e2e8f0",
    [300] = "cbd5e1",
    [400] = "94a3b8",
    [500] = "64748b",
    [600] = "475569",
    [700] = "334155",
    [800] = "1e293b",
    [900] = "0f172a",
    [950] = "020617",
  },

  gray = {
    [50] = "f9fafb",
    [100] = "f3f4f6",
    [200] = "e5e7eb",
    [300] = "d1d5db",
    [400] = "9ca3af",
    [500] = "6b7280",
    [600] = "4b5563",
    [700] = "374151",
    [800] = "1f2937",
    [900] = "111827",
    [950] = "030712",
  },

  zinc = {
    [50] = "fafafa",
    [100] = "f4f4f5",
    [200] = "e4e4e7",
    [300] = "d4d4d8",
    [400] = "a1a1aa",
    [500] = "71717a",
    [600] = "52525b",
    [700] = "3f3f46",
    [800] = "27272a",
    [900] = "18181b",
    [950] = "09090B",
  },

  neutral = {
    [50] = "fafafa",
    [100] = "f5f5f5",
    [200] = "e5e5e5",
    [300] = "d4d4d4",
    [400] = "a3a3a3",
    [500] = "737373",
    [600] = "525252",
    [700] = "404040",
    [800] = "262626",
    [900] = "171717",
    [950] = "0a0a0a",
  },

  stone = {
    [50] = "fafaf9",
    [100] = "f5f5f4",
    [200] = "e7e5e4",
    [300] = "d6d3d1",
    [400] = "a8a29e",
    [500] = "78716c",
    [600] = "57534e",
    [700] = "44403c",
    [800] = "292524",
    [900] = "1c1917",
    [950] = "0a0a0a",
  },

  red = {
    [50] = "fef2f2",
    [100] = "fee2e2",
    [200] = "fecaca",
    [300] = "fca5a5",
    [400] = "f87171",
    [500] = "ef4444",
    [600] = "dc2626",
    [700] = "b91c1c",
    [800] = "991b1b",
    [900] = "7f1d1d",
    [950] = "450a0a",
  },

  orange = {
    [50] = "fff7ed",
    [100] = "ffedd5",
    [200] = "fed7aa",
    [300] = "fdba74",
    [400] = "fb923c",
    [500] = "f97316",
    [600] = "ea580c",
    [700] = "c2410c",
    [800] = "9a3412",
    [900] = "7c2d12",
    [950] = "431407",
  },

  amber = {
    [50] = "fffbeb",
    [100] = "fef3c7",
    [200] = "fde68a",
    [300] = "fcd34d",
    [400] = "fbbf24",
    [500] = "f59e0b",
    [600] = "d97706",
    [700] = "b45309",
    [800] = "92400e",
    [900] = "78350f",
    [950] = "451a03",
  },

  yellow = {
    [50] = "fefce8",
    [100] = "fef9c3",
    [200] = "fef08a",
    [300] = "fde047",
    [400] = "facc15",
    [500] = "eab308",
    [600] = "ca8a04",
    [700] = "a16207",
    [800] = "854d0e",
    [900] = "713f12",
    [950] = "422006",
  },

  lime = {
    [50] = "f7fee7",
    [100] = "ecfccb",
    [200] = "d9f99d",
    [300] = "bef264",
    [400] = "a3e635",
    [500] = "84cc16",
    [600] = "65a30d",
    [700] = "4d7c0f",
    [800] = "3f6212",
    [900] = "365314",
    [950] = "1a2e05",
  },

  green = {
    [50] = "f0fdf4",
    [100] = "dcfce7",
    [200] = "bbf7d0",
    [300] = "86efac",
    [400] = "4ade80",
    [500] = "22c55e",
    [600] = "16a34a",
    [700] = "15803d",
    [800] = "166534",
    [900] = "14532d",
    [950] = "052e16",
  },

  emerald = {
    [50] = "ecfdf5",
    [100] = "d1fae5",
    [200] = "a7f3d0",
    [300] = "6ee7b7",
    [400] = "34d399",
    [500] = "10b981",
    [600] = "059669",
    [700] = "047857",
    [800] = "065f46",
    [900] = "064e3b",
    [950] = "022c22",
  },

  teal = {
    [50] = "f0fdfa",
    [100] = "ccfbf1",
    [200] = "99f6e4",
    [300] = "5eead4",
    [400] = "2dd4bf",
    [500] = "14b8a6",
    [600] = "0d9488",
    [700] = "0f766e",
    [800] = "115e59",
    [900] = "134e4a",
    [950] = "042f2e",
  },

  cyan = {
    [50] = "ecfeff",
    [100] = "cffafe",
    [200] = "a5f3fc",
    [300] = "67e8f9",
    [400] = "22d3ee",
    [500] = "06b6d4",
    [600] = "0891b2",
    [700] = "0e7490",
    [800] = "155e75",
    [900] = "164e63",
    [950] = "083344",
  },

  sky = {
    [50] = "f0f9ff",
    [100] = "e0f2fe",
    [200] = "bae6fd",
    [300] = "7dd3fc",
    [400] = "38bdf8",
    [500] = "0ea5e9",
    [600] = "0284c7",
    [700] = "0369a1",
    [800] = "075985",
    [900] = "0c4a6e",
    [950] = "082f49",
  },

  blue = {
    [50] = "eff6ff",
    [100] = "dbeafe",
    [200] = "bfdbfe",
    [300] = "93c5fd",
    [400] = "60a5fa",
    [500] = "3b82f6",
    [600] = "2563eb",
    [700] = "1d4ed8",
    [800] = "1e40af",
    [900] = "1e3a8a",
    [950] = "172554",
  },

  indigo = {
    [50] = "eef2ff",
    [100] = "e0e7ff",
    [200] = "c7d2fe",
    [300] = "a5b4fc",
    [400] = "818cf8",
    [500] = "6366f1",
    [600] = "4f46e5",
    [700] = "4338ca",
    [800] = "3730a3",
    [900] = "312e81",
    [950] = "1e1b4b",
  },

  violet = {
    [50] = "f5f3ff",
    [100] = "ede9fe",
    [200] = "ddd6fe",
    [300] = "c4b5fd",
    [400] = "a78bfa",
    [500] = "8b5cf6",
    [600] = "7c3aed",
    [700] = "6d28d9",
    [800] = "5b21b6",
    [900] = "4c1d95",
    [950] = "2e1065",
  },

  purple = {
    [50] = "faf5ff",
    [100] = "f3e8ff",
    [200] = "e9d5ff",
    [300] = "d8b4fe",
    [400] = "c084fc",
    [500] = "a855f7",
    [600] = "9333ea",
    [700] = "7e22ce",
    [800] = "6b21a8",
    [900] = "581c87",
    [950] = "3b0764",
  },

  fuchsia = {
    [50] = "fdf4ff",
    [100] = "fae8ff",
    [200] = "f5d0fe",
    [300] = "f0abfc",
    [400] = "e879f9",
    [500] = "d946ef",
    [600] = "c026d3",
    [700] = "a21caf",
    [800] = "86198f",
    [900] = "701a75",
    [950] = "4a044e",
  },

  pink = {
    [50] = "fdf2f8",
    [100] = "fce7f3",
    [200] = "fbcfe8",
    [300] = "f9a8d4",
    [400] = "f472b6",
    [500] = "ec4899",
    [600] = "db2777",
    [700] = "be185d",
    [800] = "9d174d",
    [900] = "831843",
    [950] = "500724",
  },

  rose = {
    [50] = "fff1f2",
    [100] = "ffe4e6",
    [200] = "fecdd3",
    [300] = "fda4af",
    [400] = "fb7185",
    [500] = "f43f5e",
    [600] = "e11d48",
    [700] = "be123c",
    [800] = "9f1239",
    [900] = "881337",
    [950] = "4c0519",
  },
}

---@param opts (fun(): table) | table
function M.hipatterns(opts)
  ---@type table
  local config = type(opts) == "function" and opts() or opts

  if type(config.tailwind) == "table" and config.tailwind.enabled then
    -- reset hl groups when colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", { callback = function() M.hl = {} end })
    config.highlighters.tailwind = {
      pattern = function()
        if not vim.tbl_contains(config.tailwind.ft, vim.bo.filetype) then return end
        if config.tailwind.style == "full" then
          return "%f[%w:-]()[%w:-]+%-[a-z%-]+%-%d+()%f[^%w:-]"
        elseif config.tailwind.style == "compact" then
          return "%f[%w:-][%w:-]+%-()[a-z%-]+%-%d+()%f[^%w:-]"
        end
      end,
      group = function(_, _, m)
        ---@type string
        local match = m.full_match
        ---@type string, number
        local color, shade = match:match "[%w-]+%-([a-z%-]+)%-(%d+)"
        shade = tonumber(shade) or 0
        local bg = vim.tbl_get(M.colors, color, shade)
        if bg then
          local hl = "MiniHipatternsTailwind" .. color .. shade
          if not M.hl[hl] then
            M.hl[hl] = true
            local bg_shade = shade == 500 and 950 or shade < 500 and 900 or 100
            local fg = vim.tbl_get(M.colors, color, bg_shade)
            vim.api.nvim_set_hl(0, hl, { bg = "#" .. bg, fg = "#" .. fg })
          end
          return hl
        end
      end,
      extmark_opts = { priority = 2000 },
    }
  end

  require("mini.hipatterns").setup(config)
end

---@param opts? table
function M.files(opts)
  opts = opts or {}

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

  local map_goto_windows = function(buf_id, lhs)
    local rhs = function()
      local id = Util.try(
        function() return require("window-picker").pick_window() end,
        { msg = "files: failed to pick windows" }
      )
      if not id then
        Util.error("failed to pick window", { title = "LazyVim" })
        return
      end
      local target_win = MiniFiles.get_explorer_state().target_window
      if target_win then vim.api.nvim_win_call(target_win, function() MiniFiles.set_target_window(id) end) end
      go_in_plus()
    end
    vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = "files: Pick a given window" })
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
      map_goto_windows(buf_id, "gw")
      map_split(buf_id, "gs", "belowright horizontal")
      map_split(buf_id, "gv", "belowright vertical")
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesActionRename",
    callback = function(ev) Util.lsp.on_rename(ev.data.from, ev.data.to) end,
  })

  require("mini.files").setup(opts)
end

---@param opts? table
function M.trailspace(opts)
  opts = opts or {}

  local show_trailspace = true
  Util.toggle.map("<leader>us", {
    name = "show trailspace",
    get = function() return show_trailspace end,
    set = function(state)
      show_trailspace = not state
      require("mini.trailspace").highlight()
    end,
  })

  require("mini.trailspace").setup(opts)
end

---@param opts (fun(): table) | table
function M.ai(opts)
  ---@type table
  local config = type(opts) == "function" and opts() or opts
  require("mini.ai").setup(config)
end

---@param opts {skip_next: string, skip_ts: string[], skip_unbalanced: boolean, markdown: boolean, filetypes: string[], mappings?: table<string, any>}
function M.pairs(opts)
  Util.toggle.map("<leader>up", {
    name = "mini pairs",
    get = function() return not vim.g.minipairs_disable end,
    set = function(state) vim.g.minipairs_disable = not state end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup "disable_ft_minipairs",
    pattern = opts.filetypes,
    callback = function(ev) vim.b[ev.buf].minipairs_disable = true end,
  })

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
