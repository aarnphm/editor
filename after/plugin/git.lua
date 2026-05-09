-- gitsigns.nvim
Util.pack.load "gitsigns.nvim"

local function gitsigns_action(name, ...)
  local args = { ... }
  return function() require("gitsigns.actions")[name](unpack(args)) end
end

require("gitsigns").setup {
  numhl = true,
  attach_to_untracked = true,
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
        require("gitsigns.actions").nav_hunk "next"
      end
    end, "git: next hunk")
    hmap("n", "[h", function()
      if vim.wo.diff then
        vim.cmd.normal { "[c", bang = true }
      else
        require("gitsigns.actions").nav_hunk "prev"
      end
    end, "git: prev hunk")
    hmap("n", "[H", gitsigns_action("nav_hunk", "first"), "git: first hunk")
    hmap("n", "]H", gitsigns_action("nav_hunk", "last"), "git: last hunk")
    hmap("n", "<leader>hb", function() require("gitsigns.actions").blame_line { full = true } end, "git: blame line")
    hmap("n", "<leader>hp", gitsigns_action "preview_hunk_inline", "git: preview hunk inline")
    hmap("n", "<leader>hP", gitsigns_action "preview_hunk", "git: preview hunk")
    hmap("n", "<leader>hR", "<cmd>Gitsigns reset_buffer<cr>", "git: reset buffer")
    hmap("n", "<leader>hS", "<cmd>Gitsigns stage_buffer<cr>", "git: stage buffer")
    hmap({ "n", "v" }, "<leader>hs", "<cmd>Gitsigns stage_hunk<cr>", "git: stage hunk")
    hmap({ "n", "v" }, "<leader>hr", "<cmd>Gitsigns reset_hunk<cr>", "git: reset hunk")
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
