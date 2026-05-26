local setup_done = false

local function file_buffer_exists()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      return true
    end
  end
  return false
end

local function setup_gitsigns()
  if setup_done then return end
  setup_done = true

  Util.pack.load "gitsigns.nvim"

  local function gitsigns_action(name, ...)
    local args = { ... }
    return function() require("gitsigns.actions")[name](unpack(args)) end
  end

  local function gitsigns_visual_action(name)
    return function() require("gitsigns.actions")[name] { vim.fn.line ".", vim.fn.line "v" } end
  end

  require("gitsigns").setup {
    numhl = true,
    attach_to_untracked = true,
    max_file_length = Util.bigfile.lines,
    _new_sign_calc = true,
    _refresh_staged_on_update = true,
    on_attach = function(buf)
      local function hmap(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
      end

      hmap("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal { "]c", bang = true }
        else
          require("gitsigns.actions").nav_hunk("next", { target = "all" })
        end
      end, "git: next hunk")
      hmap("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal { "[c", bang = true }
        else
          require("gitsigns.actions").nav_hunk("prev", { target = "all" })
        end
      end, "git: prev hunk")
      hmap("n", "[H", gitsigns_action("nav_hunk", "first"), "git: first hunk")
      hmap("n", "]H", gitsigns_action("nav_hunk", "last"), "git: last hunk")
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
    end,
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
