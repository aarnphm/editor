local setup_done = false

local function file_buffer_exists()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      return true
    end
  end
  return false
end

local function gitsigns_action(name, ...)
  local args = { ... }
  return function() require("gitsigns.actions")[name](unpack(args)) end
end

local function gitsigns_visual_action(name)
  return function() require("gitsigns.actions")[name] { vim.fn.line ".", vim.fn.line "v" } end
end

local function staged_hunks(buf)
  local cache_mod = package.loaded["gitsigns.cache"]
  local cache = cache_mod and cache_mod.cache and cache_mod.cache[buf]
  if not (cache and cache.hunks_staged and #cache.hunks_staged > 0) then return {} end

  local hunks = vim.deepcopy(cache.hunks_staged)
  table.sort(hunks, function(a, b) return a.added.start < b.added.start end)
  return hunks
end

local function echo_warning(message) vim.api.nvim_echo({ { message, "WarningMsg" } }, false, {}) end

local function cursor_indent_column(line)
  local _, col = vim.fn.getline(line):find "^%s*"
  return col or 0
end

local function foldopen_search() return vim.tbl_contains(vim.opt.foldopen:get(), "search") end

local function setup_gitsigns_keymaps(buf)
  local function hmap(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
  end

  local function nav_unstaged_hunk(direction)
    return function()
      if vim.wo.diff then
        local command = direction == "prev" and "[c" or "]c"
        vim.cmd.normal { command, bang = true }
      else
        require("gitsigns.actions").nav_hunk(direction, { target = "unstaged" })
      end
    end
  end

  local function nav_staged_hunk(direction)
    return function()
      if vim.wo.diff then
        local command = direction == "prev" and "[c" or "]c"
        vim.cmd.normal { command, bang = true }
        return
      end

      local hunks = staged_hunks(vim.api.nvim_get_current_buf())
      if #hunks == 0 then
        echo_warning "No staged hunks"
        return
      end

      local line = vim.api.nvim_win_get_cursor(0)[1]
      local buf_line_count = vim.api.nvim_buf_line_count(0)
      local index
      local forwards = direction == "next"

      for _ = 1, vim.v.count1 do
        index = require("gitsigns.hunks").find_nearest_hunk(line, hunks, direction, vim.o.wrapscan, buf_line_count)
        if not index then
          echo_warning "No more staged hunks"
          vim.api.nvim_win_set_cursor(0, { line, cursor_indent_column(line) })
          return
        end

        local hunk = hunks[index]
        line = forwards and hunk.added.start or hunk.vend
        line = math.max(math.min(line, buf_line_count), 1)
      end

      vim.cmd [[normal! m']]
      vim.api.nvim_win_set_cursor(0, { line, cursor_indent_column(line) })
      if foldopen_search() then vim.cmd "silent! foldopen!" end
      vim.api.nvim_echo({ { ("Staged hunk %d of %d"):format(index, #hunks), "None" } }, false, {})
    end
  end

  hmap({ "n", "v" }, "]h", nav_unstaged_hunk "next", "git: next current hunk")
  hmap({ "n", "v" }, "[h", nav_unstaged_hunk "prev", "git: prev current hunk")
  hmap({ "n", "v" }, "]hh", nav_staged_hunk "next", "git: next staged hunk")
  hmap({ "n", "v" }, "[hh", nav_staged_hunk "prev", "git: prev staged hunk")
  hmap("n", "<leader>hb", function() require("gitsigns.actions").blame_line { full = true } end, "git: blame line")
  hmap("n", "<leader>hp", gitsigns_action "preview_hunk_inline", "git: preview hunk inline")
  hmap("n", "<leader>hP", gitsigns_action "preview_hunk", "git: preview hunk")
  hmap("n", "<leader>hR", "<cmd>Gitsigns reset_buffer<cr>", "git: reset buffer")
  hmap("n", "<leader>hS", "<cmd>Gitsigns stage_buffer<cr>", "git: stage buffer")
  hmap("n", "<leader>hs", gitsigns_action "stage_hunk", "git: stage hunk")
  hmap("v", "<leader>hs", gitsigns_visual_action "stage_hunk", "git: stage hunk")
  hmap("n", "<leader>hr", gitsigns_action "reset_hunk", "git: reset hunk")
  hmap("v", "<leader>hr", gitsigns_visual_action "reset_hunk", "git: reset hunk")
  hmap({ "n", "v" }, "<leader>hh", "<cmd>Gitsigns setqflist<cr>", "git: set qflist")
  hmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>", "git: select hunk")
end

local function setup_attached_gitsigns_keymaps()
  local cache_mod = package.loaded["gitsigns.cache"]
  if not cache_mod then return end

  for buf in pairs(cache_mod.cache or {}) do
    if vim.api.nvim_buf_is_valid(buf) then setup_gitsigns_keymaps(buf) end
  end
end

local function setup_gitsigns()
  if setup_done then return end
  setup_done = true

  Util.pack.load "gitsigns.nvim"

  require("gitsigns").setup {
    numhl = true,
    attach_to_untracked = true,
    max_file_length = Util.bigfile.lines,
    _new_sign_calc = true,
    _refresh_staged_on_update = true,
    on_attach = setup_gitsigns_keymaps,
  }

  do
    local ok_git, git = pcall(require, "gitsigns.git")
    if ok_git and vim.fn.executable "git-lfs" == 1 and git.Obj and git.Obj.get_show_text then
      local original = git.Obj.get_show_text
      local pointer_prefix = "version https://git-lfs.github.com/spec/"

      function git.Obj:get_show_text(revision, relpath)
        local stdout, stderr = original(self, revision, relpath)
        if not (stdout and stdout[1] and vim.startswith(stdout[1], pointer_prefix)) then return stdout, stderr end

        local path = relpath or self.relpath
        if not path then return stdout, stderr end

        local smudged, _, code = self.repo:command(
          { "lfs", "smudge", "--", path },
          { stdin = table.concat(stdout, "\n") .. "\n", ignore_error = true }
        )
        if code == 0 and smudged then return smudged, stderr end
        return stdout, stderr
      end
    end
  end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = augroup "gitsigns_lazy",
  once = true,
  callback = function()
    if vim.v.vim_did_enter == 1 then vim.defer_fn(setup_gitsigns, 20) end
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup "gitsigns_startup_buffer",
  once = true,
  callback = function()
    if file_buffer_exists() then vim.defer_fn(setup_gitsigns, 20) end
  end,
})

setup_attached_gitsigns_keymaps()
