_G.Util = require "utils"
_G.augroup = function(name) return vim.api.nvim_create_augroup(("simple_%s"):format(name), { clear = true }) end

_G.hi = function(name, opts)
  opts.default = opts.default or true
  opts.force = opts.force or true
  vim.api.nvim_set_hl(0, name, opts)
end

for _, provider in ipairs { "node", "perl", "python3", "ruby" } do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end

for _, plugin in ipairs {
  "gzip",
  "netrw",
  "netrwPlugin",
  "rplugin",
  "tarPlugin",
  "tutor",
  "zipPlugin",
} do
  vim.g["loaded_" .. plugin] = 1
end

local background = os.getenv "XDG_SYSTEM_THEME"
vim.go.background = background ~= nil and background or "dark"

if vim.uv.os_uname().sysname == "Darwin" then
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
    cache_enabled = 0,
  }
end

vim.g.mapleader = vim.keycode "<space>"
vim.g.maplocalleader = vim.keycode ","
vim.g.markdown_recommended_style = 0
vim.g.autoformat = true
vim.g.enable_highlighturl = true

hi("HighlightURL", { default = true, underline = true })
hi("CmpGhostText", { link = "Comment", default = true })
hi("LeapBackdrop", { link = "Comment" })
hi("LeapMatch", { fg = vim.go.background == "dark" and "white" or "black", bold = true, nocombine = true })

local specs = {
  { src = "https://github.com/nuvic/flexoki-nvim.git", name = "flexoki" },
  { src = "https://github.com/echasnovski/mini.nvim.git", name = "mini.nvim" },
  { src = "https://github.com/Saghen/blink.cmp.git", name = "blink.cmp", version = "v1.10.2" },
  { src = "https://github.com/rafamadriz/friendly-snippets.git", name = "friendly-snippets" },
  { src = "https://github.com/stevearc/conform.nvim.git", name = "conform.nvim" },
  { src = "https://codeberg.org/andyg/leap.nvim.git", name = "leap.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter.git", name = "nvim-treesitter", version = "main" },
  { src = "https://github.com/neovim/nvim-lspconfig.git", name = "nvim-lspconfig" },
  { src = "https://github.com/Bekaboo/dropbar.nvim.git", name = "dropbar.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim.git", name = "gitsigns.nvim" },
  { src = "https://github.com/MagicDuck/grug-far.nvim.git", name = "grug-far.nvim" },
}
if not vim.pack then error "This config expects Nvim with vim.pack support" end

vim.pack.add(specs, {
  confirm = false,
  load = function(plugin)
    if vim.tbl_contains({ "blink.cmp", "friendly-snippets", "grug-far.nvim" }, plugin.spec.name) then return end
    vim.cmd.packadd(plugin.spec.name)
  end,
})

-- colorscheme
local ok, palette = pcall(require, "flexoki.palette")
if not ok then
  vim.cmd.colorscheme "habamax"
else
  require("flexoki").setup {
    styles = { italic = true },
    highlight_groups = {
      ["@variable"] = { fg = palette.text, italic = false },
      ["@parameter"] = { fg = palette.purple_two, italic = false },
      ["@variable.parameter"] = { fg = palette.purple_two, italic = false },
      StatusLine = { fg = palette.orange_two, bg = palette.overlay },
      StatusLineNC = { bg = palette.overlay },
      QuickFixLine = { bg = palette.highlight_high },
      WinBar = { bg = palette.base },
      WinBarNC = { bg = palette.base },
      LspCodeLens = { fg = palette.purple_two, italic = true },
      LspCodeLensSeparator = { fg = palette.muted, italic = true },
      DropBarMenuCurrentContext = { bg = palette.base },
    },
  }
  vim.cmd.colorscheme "flexoki"
end

-- mini
local function silent_map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc }) end
local function pick_files(cwd) require("mini.pick").builtin.files(nil, { source = { cwd = cwd } }) end
local icons = require "mini.icons"
icons.setup()
icons.mock_nvim_web_devicons()

require("mini.extra").setup()
require("mini.pick").setup {
  options = { use_cache = true },
  window = {
    prompt_prefix = "󰄾 ",
    config = function()
      local height = math.floor(0.618 * vim.o.lines)
      local width = math.floor(0.618 * vim.o.columns)
      return {
        anchor = "NW",
        height = height,
        width = width,
        row = 1 + math.floor(0.21 * (vim.o.lines + height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
      }
    end,
  },
}
require("mini.files").setup {
  windows = {
    preview = false,
    width_focus = 30,
    width_nofocus = 30,
    width_preview = math.floor(0.25 * vim.o.columns),
    max_number = 3,
  },
  mappings = { synchronize = "<leader>" },
}
require("mini.git").setup()
require("mini.align").setup { mappings = { start = "<leader>ga", start_with_preview = "<leader>gA" } }
require("mini.bracketed").setup { window = { suffix = "" }, treesitter = { suffix = "" } }
require("mini.move").setup()
require("mini.surround").setup {
  mappings = {
    add = "gsa",
    delete = "gsd",
    find = "gsf",
    find_left = "gsF",
    highlight = "gsh",
    replace = "gsr",
    update_n_lines = "gsn",
  },
}
require("mini.pairs").setup {
  modes = { insert = true, command = true, terminal = false },
  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  skip_ts = { "string" },
  skip_unbalanced = true,
  markdown = true,
}

local ai = require "mini.ai"
local extra = require "mini.extra"
require("mini.ai").setup {
  n_lines = 500,
  custom_textobjects = {
    o = ai.gen_spec.treesitter {
      a = { "@block.outer", "@conditional.outer", "@loop.outer" },
      i = { "@block.inner", "@conditional.inner", "@loop.inner" },
    },
    f = ai.gen_spec.treesitter { a = "@function.outer", i = "@function.inner" },
    c = ai.gen_spec.treesitter { a = "@class.outer", i = "@class.inner" },
    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
    d = { "%f[%d]%d+" },
    e = {
      { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
      "^().*()$",
    },
    i = extra.gen_ai_spec.indent(),
    g = extra.gen_ai_spec.buffer(),
    u = ai.gen_spec.function_call(),
    U = ai.gen_spec.function_call { name_pattern = "[%w_]" },
  },
}

require("mini.diff").setup {
  view = {
    style = "sign",
    signs = { add = "▎", change = "▎", delete = "" },
  },
  mappings = {
    apply = "",
    reset = "",
    textobject = "",
    goto_first = "",
    goto_prev = "",
    goto_next = "",
    goto_last = "",
  },
}

if vim.fn.executable "git-lfs" == 1 then
  local diff = require "mini.diff"
  local original_set_ref_text = diff.set_ref_text
  local lfs_pointer_prefix = "version https://git-lfs.github.com/spec/"
  diff.set_ref_text = function(buf, text)
    local raw = type(text) == "table" and table.concat(text, "\n") or text
    if type(raw) == "string" and raw:sub(1, #lfs_pointer_prefix) == lfs_pointer_prefix then
      local path = vim.api.nvim_buf_get_name(buf)
      if path ~= "" then
        local result = vim
          .system({ "git", "lfs", "smudge", "--", vim.fn.fnamemodify(path, ":t") }, {
            cwd = vim.fn.fnamemodify(path, ":h"),
            stdin = raw,
            text = true,
          })
          :wait()
        if result.code == 0 and result.stdout and result.stdout ~= "" then
          return original_set_ref_text(buf, result.stdout)
        end
      end
    end
    return original_set_ref_text(buf, text)
  end
end

local hipatterns = require "mini.hipatterns"
hipatterns.setup {
  highlighters = {
    hex_color = hipatterns.gen_highlighter.hex_color { priority = 2000 },
    shorthand = {
      pattern = "()#%x%x%x()%f[^%x%w]",
      group = function(_, _, data)
        local match = data.full_match
        local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
        return MiniHipatterns.compute_hex_color_group("#" .. r .. r .. g .. g .. b .. b, "bg")
      end,
      extmark_opts = { priority = 2000 },
    },
  },
}

-- blink.cmp
local blink_loaded = false
local function setup_blink()
  if blink_loaded then return end
  vim.cmd.packadd "friendly-snippets"
  vim.cmd.packadd "blink.cmp"

  require("blink.cmp").setup {
    fuzzy = { implementation = "prefer_rust" },
    snippets = { preset = "default" },
    signature = { enabled = false },
    completion = {
      menu = {
        auto_show = true,
        draw = {
          treesitter = { "lsp" },
          columns = { { "kind_icon" }, { "label", "label_description", gap = 2 } },
          components = {
            label_description = { width = { max = 0 }, text = function(ctx) return ctx.label_description or "" end },
            kind_icon = {
              text = function(ctx)
                local kind_icon = require("mini.icons").get("lsp", ctx.kind)
                return kind_icon
              end,
              highlight = function(ctx)
                local _, hl = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
            kind = {
              highlight = function(ctx)
                local _, hl = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
          },
          padding = 0,
          gap = 1,
        },
      },
      accept = { auto_brackets = { enabled = false } },
      documentation = { auto_show = false, auto_show_delay_ms = 200 },
      trigger = { show_in_snippet = true },
      list = {
        selection = {
          preselect = function() return not require("blink.cmp").snippet_active { direction = 1 } end,
          auto_insert = false,
        },
      },
    },
    cmdline = { enabled = false },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        snippets = {
          opts = {
            ignored_filetypes = { "git", "gitcommit" },
            extended_filetypes = { markdown = { "latex" } },
          },
        },
      },
    },
    keymap = {
      preset = "enter",
      ["<C-y>"] = { "select_and_accept" },
      ["<Up>"] = false,
      ["<Down>"] = false,
    },
  }

  blink_loaded = true
end

vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup "blink",
  once = true,
  callback = setup_blink,
})

local show_dotfiles = true
local show_preview = false

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local buf = args.data.buf_id
    vim.keymap.set("n", "g.", function()
      show_dotfiles = not show_dotfiles
      require("mini.files").refresh {
        content = {
          filter = show_dotfiles and function() return true end
            or function(entry) return not vim.startswith(entry.name, ".") end,
        },
      }
    end, { buffer = buf, desc = "files: toggle dotfiles" })

    vim.keymap.set("n", "gp", function()
      show_preview = not show_preview
      require("mini.files").refresh { windows = { preview = show_preview } }
    end, { buffer = buf, desc = "files: toggle preview" })
  end,
})

silent_map("n", "<leader>f", function() pick_files(Util.root.git()) end, "files: find in root")
silent_map("n", "<localleader>f", function() require("mini.extra").pickers.oldfiles() end, "files: recent")
silent_map(
  "n",
  "<localleader>/",
  function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end,
  "files: current"
)
silent_map("n", "<localleader>.", function() require("mini.files").open(Util.root.git(), true) end, "files: root")
silent_map("n", "-", function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end, "files: current")
silent_map("n", "<leader>g", function() require("mini.diff").toggle_overlay(0) end, "git: toggle diff overlay")
silent_map("n", "<leader>gg", "<cmd>Git status<cr>", "git: status")
silent_map("n", "<leader>gl", "<cmd>Git log --oneline --decorate --graph -n 50<cr>", "git: log")
silent_map({ "n", "x" }, "<leader>gs", function() require("mini.git").show_at_cursor() end, "git: show at cursor")

-- leap.nvim
local leap = require "leap"
leap.opts["max_highlighted_traversal_targets"] = 15

local function leap_ft_safe_labels()
  local mode = vim.fn.mode(1)
  if mode == "n" or mode == "v" or mode == "V" or mode == "\22" then return nil end
  return ""
end

local function leap_ft(args)
  leap.leap(vim.tbl_deep_extend("keep", args, {
    inputlen = 1,
    inclusive = true,
    opts = {
      labels = "",
      safe_labels = leap_ft_safe_labels(),
      vim_opts = { ["go.ignorecase"] = false },
    },
  }))
end

local function prepend_leap_key(key, keys)
  local ret = { key }
  if type(keys) == "table" then
    vim.list_extend(ret, keys)
  else
    ret[#ret + 1] = keys
  end
  return ret
end

local function leap_line_start(skip_range)
  local win = vim.api.nvim_get_current_win()
  local info = vim.fn.getwininfo(win)[1]
  local cur_line = vim.fn.line "."
  local cur_screen_row = vim.fn.screenpos(win, cur_line, 1).row
  local targets = {}
  skip_range = skip_range or 2

  local line = info.topline
  while line <= info.botline do
    local fold_end = vim.fn.foldclosedend(line)
    if fold_end ~= -1 then
      line = fold_end + 1
    else
      if line < cur_line - skip_range or line > cur_line + skip_range then
        targets[#targets + 1] = { pos = { line, 1 } }
      end
      line = line + 1
    end
  end

  table.sort(targets, function(left, right)
    local left_row = vim.fn.screenpos(win, left.pos[1], left.pos[2]).row
    local right_row = vim.fn.screenpos(win, right.pos[1], right.pos[2]).row
    return math.abs(cur_screen_row - left_row) < math.abs(cur_screen_row - right_row)
  end)

  leap.leap { target_windows = { win }, targets = targets }
end

local clever = require("leap.user").with_traversal_keys
local clever_f = clever("f", "F")
local clever_t = clever("t", "T")
vim.keymap.set(
  { "n", "x", "o" },
  "f",
  function() leap_ft { opts = clever_f } end,
  { desc = "motion: leap forward to char" }
)
vim.keymap.set(
  { "n", "x", "o" },
  "F",
  function() leap_ft { backward = true, opts = clever_f } end,
  { desc = "motion: leap backward to char" }
)
vim.keymap.set(
  { "n", "x", "o" },
  "t",
  function() leap_ft { offset = -1, opts = clever_t } end,
  { desc = "motion: leap forward till char" }
)
vim.keymap.set(
  { "n", "x", "o" },
  "T",
  function() leap_ft { backward = true, offset = 1, opts = clever_t } end,
  { desc = "motion: leap backward till char" }
)
vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", { desc = "motion: leap forward to" })
vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", { desc = "motion: leap backward to" })
vim.keymap.set("n", "gs", "<Plug>(leap-from-window)", { desc = "motion: leap from window" })
vim.keymap.set({ "n", "x", "o" }, "ga", function()
  local keys = vim.deepcopy(leap.opts.keys)
  keys.next_target = prepend_leap_key("a", keys.next_target)
  keys.prev_target = prepend_leap_key("A", keys.prev_target)
  require("leap.treesitter").select { opts = { keys = keys } }
end, { desc = "motion: leap treesitter" })
vim.keymap.set(
  { "n", "x", "o" },
  "gA",
  'V<cmd>lua require("leap.treesitter").select()<cr>',
  { desc = "motion: leap treesitter (linewise)" }
)
vim.keymap.set("o", "|", function()
  vim.cmd "normal! V"
  leap_line_start()
end, { desc = "motion: leap line start (linewise)" })
vim.keymap.set("x", "|", function()
  if vim.fn.mode(1) ~= "V" then vim.cmd "normal! V" end
  leap_line_start()
end, { desc = "motion: leap line start" })

-- grug-far.nvim
local grug_loaded = false
local function grug()
  if not grug_loaded then
    pcall(vim.api.nvim_del_user_command, "GrugFar")
    vim.cmd.packadd "grug-far.nvim"
    require("grug-far").setup {
      headerMaxWidth = 50,
      windowCreationCommand = "botright vsplit",
    }
    grug_loaded = true
  end
  return require "grug-far"
end

local function grug_ext_filter()
  local ext = vim.bo.buftype == "" and vim.fn.expand "%:e"
  return ext and ext ~= "" and "*." .. ext or nil
end

local function open_grug(opts)
  opts = vim.tbl_extend("force", { transient = true }, opts or {})
  grug().open(opts)
end

vim.api.nvim_create_user_command("GrugFar", function(opts)
  grug()
  local command = "GrugFar"
  if opts.bang then command = command .. "!" end
  if opts.args ~= "" then command = command .. " " .. opts.args end
  vim.cmd(command)
end, { nargs = "*", bang = true, desc = "grug-far: open" })

vim.keymap.set(
  { "n", "v" },
  "<LocalLeader>w",
  function() open_grug { windowCreationCommand = "60vsplit" } end,
  { desc = "search: open and replace" }
)
vim.keymap.set(
  { "n", "v" },
  "<LocalLeader>hw",
  function() open_grug { windowCreationCommand = "topleft 60vsplit" } end,
  { desc = "search: open and replace (left)" }
)
vim.keymap.set(
  { "n", "v" },
  "<LocalLeader>jw",
  function() open_grug { instanceName = "far-below", windowCreationCommand = "botright 15split" } end,
  { desc = "search: open and replace (below)" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>w",
  function()
    open_grug {
      windowCreationCommand = "60vsplit",
      prefills = { filesFilter = grug_ext_filter() },
    }
  end,
  { desc = "search: open and replace (current filetype)" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>hw",
  function()
    open_grug {
      windowCreationCommand = "topleft 60vsplit",
      prefills = { filesFilter = grug_ext_filter() },
    }
  end,
  { desc = "search: open and replace (current filetype, left)" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>jw",
  function()
    open_grug {
      instanceName = "far-below",
      windowCreationCommand = "botright 15split",
      prefills = { filesFilter = grug_ext_filter() },
    }
  end,
  { desc = "search: open and replace (current filetype, below)" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>/",
  function()
    open_grug {
      windowCreationCommand = "60vsplit",
      prefills = { search = vim.fn.expand "<cword>" },
    }
  end,
  { desc = "search: open and replace (cursor word)" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>h/",
  function()
    open_grug {
      windowCreationCommand = "topleft 60vsplit",
      prefills = { search = vim.fn.expand "<cword>" },
    }
  end,
  { desc = "search: open and replace (cursor word, left)" }
)
vim.keymap.set(
  { "n", "v" },
  "<Leader>j/",
  function()
    open_grug {
      windowCreationCommand = "botright 15split",
      prefills = { search = vim.fn.expand "<cword>" },
    }
  end,
  { desc = "search: open and replace (cursor word, below)" }
)

-- gitsigns.nvim
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

-- treesitter
local function register_mojo_parser()
  local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok_parsers then return end
  parsers.mojo = {
    install_info = {
      url = "https://github.com/lsh/tree-sitter-mojo",
      revision = "03966fb3f209bea86844aab3bd0f2158a5a8bb8d",
      queries = "queries",
    },
  }
end

local ts = require "nvim-treesitter"
ts.setup()
register_mojo_parser()
Util.treesitter.get_installed(true)

vim.api.nvim_create_user_command("TSInstallDefault", function()
  local missing = vim.tbl_filter(function(lang) return not Util.treesitter.have(lang) end, {
    "bash",
    "c",
    "cpp",
    "diff",
    "go",
    "gomod",
    "gosum",
    "gowork",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "lua",
    "markdown",
    "markdown_inline",
    "mojo",
    "nix",
    "ocaml",
    "python",
    "query",
    "regex",
    "ron",
    "rust",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
  })
  if #missing == 0 then
    Util.info "treesitter: all configured parsers are installed"
    return
  end
  ts.install(missing, { summary = true })
end, { desc = "treesitter: install configured missing parsers" })

vim.api.nvim_create_autocmd("FileType", {
  group = augroup "treesitter",
  callback = function(ev)
    local ft = ev.match
    if not Util.treesitter.have(ft) then return end

    if Util.treesitter.have(ft, "highlights") then pcall(vim.treesitter.start, ev.buf) end
    if Util.treesitter.have(ft, "indents") then
      Util.set_default("indentexpr", "v:lua.Util.treesitter.indentexpr()")
    end
    if Util.treesitter.have(ft, "folds") and Util.set_default("foldmethod", "expr") then
      Util.set_default("foldexpr", "v:lua.Util.treesitter.foldexpr()")
    end
  end,
})

-- lsp
local function lsp_map(buf, mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
end

local ruff_format_excluded_roots = { "$WORKSPACE/monpy" }

local function expand_env_path(path)
  local unresolved = false
  local expanded = path:gsub("%${([%w_]+)}", function(name)
    local value = vim.env[name]
    if value == nil or value == "" then
      unresolved = true
      return ""
    end
    return value
  end)
  expanded = expanded:gsub("%$([%w_]+)", function(name)
    local value = vim.env[name]
    if value == nil or value == "" then
      unresolved = true
      return ""
    end
    return value
  end)
  if unresolved then return nil end
  return vim.fs.normalize(vim.fn.expand(expanded))
end

local function path_is_under(path, root)
  path = vim.uv.fs_realpath(path) or vim.fs.normalize(path)
  root = vim.uv.fs_realpath(root) or vim.fs.normalize(root)
  return path == root or vim.startswith(path, root .. "/")
end

local function skip_ruff_format(path)
  if path == nil or path == "" then return false end
  local roots = vim.list_extend({}, ruff_format_excluded_roots)
  if type(vim.g.python_ruff_format_excluded_roots) == "string" then
    roots[#roots + 1] = vim.g.python_ruff_format_excluded_roots
  elseif type(vim.g.python_ruff_format_excluded_roots) == "table" then
    vim.list_extend(roots, vim.g.python_ruff_format_excluded_roots)
  end

  for _, root in ipairs(roots) do
    local expanded = expand_env_path(root)
    if expanded and path_is_under(path, expanded) then return true end
  end
  return false
end

-- conform.nvim
local prettier_filetypes = {
  "css",
  "graphql",
  "handlebars",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "less",
  "markdown",
  "markdown.mdx",
  "scss",
  "sass",
  "typescript",
  "typescriptreact",
  "vue",
  "yaml",
}

local function format_enabled(buf)
  if buf == nil or buf == 0 then buf = vim.api.nvim_get_current_buf() end
  if vim.g.disable_autoformat or vim.b[buf].disable_autoformat then return false end
  if vim.b[buf].autoformat ~= nil then return vim.b[buf].autoformat end
  return vim.g.autoformat ~= false
end

local function set_autoformat(enabled, buf_only)
  if buf_only then
    vim.b.autoformat = enabled
  else
    vim.g.autoformat = enabled
    vim.g.markdown_frontmatter = enabled
    vim.b.autoformat = nil
  end
end

local function use_ruff_formatters(buf)
  if skip_ruff_format(vim.api.nvim_buf_get_name(buf)) then return {} end
  return { "ruff_fix", "ruff_organize_imports" }
end

local function ruff_format_enabled(_, ctx) return not skip_ruff_format(ctx.filename) end

local prettier_has_config = Util.memoize(function(filename)
  if vim.fn.executable "prettier" == 0 then return false end
  vim.fn.system { "prettier", "--find-config-path", filename }
  return vim.v.shell_error == 0
end)

local prettier_has_parser = Util.memoize(function(ft, filename)
  if vim.fn.executable "prettier" == 0 then return false end
  if vim.tbl_contains(prettier_filetypes, ft) then return true end
  local ret = vim.fn.system { "prettier", "--file-info", filename }
  local parsed_ok, info = pcall(vim.json.decode, ret)
  return parsed_ok and info and info.inferredParser ~= nil and info.inferredParser ~= vim.NIL
end)

local function prettier_enabled(_, ctx)
  return prettier_has_parser(vim.bo[ctx.buf].filetype, ctx.filename) and prettier_has_config(ctx.filename)
end

local function format_info()
  local buf = vim.api.nvim_get_current_buf()
  local buffer_setting = vim.b[buf].autoformat
  local lines = {
    "# Format",
    ("- global: %s"):format(vim.g.autoformat ~= false and "enabled" or "disabled"),
    ("- buffer: %s"):format(buffer_setting == nil and "inherit" or buffer_setting and "enabled" or "disabled"),
    ("- effective: %s"):format(format_enabled(buf) and "enabled" or "disabled"),
  }

  local conform_ok, conform = pcall(require, "conform")
  if conform_ok then
    local formatters = conform.list_formatters(buf)
    lines[#lines + 1] = ""
    lines[#lines + 1] = #formatters > 0 and "# Formatters" or "# Formatters\n- none"
    for _, formatter in ipairs(formatters) do
      local marker = formatter.available and "x" or " "
      lines[#lines + 1] = ("- [%s] %s"):format(marker, formatter.name)
    end
  end

  Util[format_enabled(buf) and "info" or "warn"](lines)
end

require("conform").setup {
  default_format_opts = { timeout_ms = 3000, lsp_format = "fallback" },
  format_on_save = function(buf)
    if not format_enabled(buf) then return end
    return { timeout_ms = 3000, lsp_format = "fallback" }
  end,
  formatters_by_ft = {
    c = { "clang_format" },
    cpp = { "clang_format" },
    cuda = { "clang_format" },
    go = { "goimports", "gofumpt" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    lua = { "stylua" },
    markdown = { "prettier", "cbfmt" },
    ["markdown.mdx"] = { "prettier", "cbfmt" },
    mojo = { "mojo_format" },
    nix = { "alejandra" },
    objc = { "clang_format" },
    objcpp = { "clang_format" },
    ocaml = { "ocamlformat" },
    proto = { "buf", "protolint" },
    python = use_ruff_formatters,
    rust = { "rustfmt" },
    sh = { "shfmt" },
    sql = { "sqlfluff" },
    toml = { "taplo" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    yaml = { "prettier" },
    zsh = { "beautysh", fallback = true },
  },
  formatters = {
    injected = { options = { ignore_errors = true } },
    prettier = { condition = prettier_enabled },
    ruff_fix = { condition = ruff_format_enabled },
    ruff_organize_imports = { condition = ruff_format_enabled },
  },
}

vim.api.nvim_create_user_command("Format", function(opts)
  local range = nil
  if opts.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, opts.line2 - 1, opts.line2, true)[1] or ""
    range = {
      start = { opts.line1, 0 },
      ["end"] = { opts.line2, end_line:len() },
    }
  end
  require("conform").format { async = true, lsp_format = "fallback", range = range }
end, { desc = "format: selection or buffer", range = true })
vim.api.nvim_create_user_command("FormatInfo", format_info, { desc = "format: info" })
vim.api.nvim_create_user_command("FormatDisable", function(opts)
  set_autoformat(false, opts.bang)
  format_info()
end, { bang = true, desc = "format: disable autoformat" })
vim.api.nvim_create_user_command("FormatEnable", function(opts)
  set_autoformat(true, opts.bang)
  format_info()
end, { bang = true, desc = "format: enable autoformat" })
vim.api.nvim_create_user_command("FormatToggle", function(opts)
  set_autoformat(not format_enabled(0), opts.bang)
  format_info()
end, { bang = true, desc = "format: toggle autoformat" })

silent_map(
  { "n", "v" },
  "<leader><leader>f",
  function() require("conform").format { async = true, lsp_format = "fallback" } end,
  "format: buffer"
)
silent_map(
  { "n", "v" },
  "<leader>cF",
  function() require("conform").format { formatters = { "injected" }, timeout_ms = 3000 } end,
  "format: injected langs"
)
silent_map("n", "<leader>uf", "<cmd>FormatToggle<cr>", "format: toggle autoformat")
silent_map("n", "<leader>uF", "<cmd>FormatToggle!<cr>", "format: toggle buffer autoformat")

local servers = {
  bashls = {},
  clangd = {
    capabilities = { offsetEncoding = { "utf-16" } },
    root_markers = {
      ".git",
      "Makefile",
      "configure.ac",
      "configure.in",
      "config.h.in",
      "meson.build",
      "meson_options.txt",
      "build.ninja",
      "compile_commands.json",
      "compile_flags.txt",
    },
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
      "--fallback-style=llvm",
    },
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true,
    },
  },
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        codelenses = {
          gc_details = false,
          generate = true,
          regenerate_cgo = true,
          run_govulncheck = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        analyses = {
          nilness = true,
          unusedparams = true,
          unusedwrite = true,
          useany = true,
        },
        usePlaceholders = true,
        completeUnimported = true,
        staticcheck = true,
        directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
        semanticTokens = true,
      },
    },
  },
  jsonls = {
    settings = {
      json = {
        format = { enable = true },
        validate = { enable = true },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT", special = { reload = "require" } },
        library = { vim.env.VIMRUNTIME },
        telemetry = { enable = false },
        semantic = { enable = true },
        completion = { workspaceWord = true, callSnippet = "Replace" },
        hover = { expandAlias = false },
        hint = {
          enable = true,
          setType = false,
          paramType = true,
          paramName = false,
          semicolon = "Disable",
          arrayIndex = "Disable",
        },
        diagnostics = {
          disable = { "incomplete-signature-doc", "trailing-space" },
          unusedLocalExclude = { "_*" },
        },
      },
    },
  },
  markdown_oxide = {
    capabilities = {
      workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
    },
  },
  mojo = {},
  nil_ls = {
    settings = {
      ["nil"] = {
        formatting = { command = { "alejandra" } },
        nix = { flake = { autoArchive = true } },
      },
    },
  },
  ocamllsp = {
    filetypes = {
      "ocaml",
      "ocaml.menhir",
      "ocaml.interface",
      "ocaml.ocamllex",
      "reason",
      "dune",
    },
    root_markers = {
      function(name) return name:match ".*%.opam$" end,
      "esy.json",
      "package.json",
      ".git",
      "dune-project",
      "dune-workspace",
      function(name) return name:match ".*%.ml$" end,
    },
  },
  ruff = {
    cmd_env = { RUFF_TRACE = "messages" },
    init_options = { settings = { logLevel = "error" } },
  },
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          buildScripts = { enable = true },
        },
        checkOnSave = true,
        procMacro = {
          enable = true,
          ignored = {
            ["async-trait"] = { "async_trait" },
            ["napi-derive"] = { "napi" },
            ["async-recursion"] = { "async_recursion" },
          },
        },
        files = {
          exclude = {
            ".direnv",
            ".git",
            ".jj",
            ".github",
            ".gitlab",
            "bin",
            "node_modules",
            "target",
            "venv",
            ".venv",
          },
          watcher = "client",
        },
      },
    },
  },
  taplo = {},
  tailwindcss = {
    filetypes = {
      "astro",
      "css",
      "heex",
      "html",
      "html-eex",
      "javascript",
      "javascriptreact",
      "svelte",
      "typescript",
      "typescriptreact",
      "vue",
    },
    settings = {
      tailwindCSS = {
        includeLanguages = {
          elixir = "html-eex",
          eelixir = "html-eex",
          heex = "html-eex",
        },
      },
    },
  },
  ty = {},
  vtsls = {
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    settings = {
      complete_function_calls = true,
      vtsls = {
        enableMoveToFileCodeAction = true,
        autoUseWorkspaceTsdk = true,
        experimental = {
          maxInlayHintLength = 30,
          completion = { enableServerSideFuzzyMatch = true },
        },
      },
      typescript = {
        updateImportsOnFileMove = { enabled = "always" },
        suggest = { completeFunctionCalls = true },
        inlayHints = {
          enumMemberValues = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          parameterNames = { enabled = "literals" },
          parameterTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          variableTypes = { enabled = false },
        },
      },
    },
  },
  yamlls = {
    capabilities = {
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true,
        },
      },
    },
    settings = {
      redhat = { telemetry = { enabled = false } },
      yaml = {
        keyOrdering = false,
        format = { enable = true, singleQuote = true, bracketSpacing = false, printWidth = 120 },
        validate = true,
        schemaStore = { enable = true },
      },
    },
  },
  zls = {},
}
servers.vtsls.settings.javascript = vim.tbl_deep_extend("force", {}, servers.vtsls.settings.typescript)

local server_executables = {
  bashls = "bash-language-server",
  clangd = "clangd",
  gopls = "gopls",
  jsonls = "vscode-json-language-server",
  lua_ls = "lua-language-server",
  markdown_oxide = "markdown-oxide",
  mojo = "mojo-lsp-server",
  nil_ls = "nil",
  ocamllsp = "ocamllsp",
  ruff = "ruff",
  rust_analyzer = "rust-analyzer",
  taplo = "taplo",
  tailwindcss = "tailwindcss-language-server",
  ty = "ty",
  vtsls = "vtsls",
  yamlls = "yaml-language-server",
  zls = "zls",
}

local function server_is_available(name, config)
  local cmd = type(config) == "table" and config.cmd or nil
  local executable = type(cmd) == "table" and cmd[1] or server_executables[name]
  return executable ~= nil and vim.fn.executable(executable) == 1
end

vim.diagnostic.config {
  severity_sort = true,
  underline = false,
  update_in_insert = false,
  virtual_text = false,
  float = {
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    focusable = false,
    focus = false,
    source = "if_many",
    format = function(diagnostic) return string.format("%s (%s)", diagnostic.message, diagnostic.source) end,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✖",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.HINT] = "⚑",
      [vim.diagnostic.severity.INFO] = "●",
    },
  },
}

vim.lsp.config("*", {
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
          commitCharactersSupport = false,
          deprecatedSupport = true,
          documentationFormat = { "markdown", "plaintext" },
          insertReplaceSupport = true,
          insertTextModeSupport = { valueSet = { 1 } },
          labelDetailsSupport = true,
          preselectSupport = false,
          resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits", "command", "data" } },
          tagSupport = { valueSet = { 1 } },
        },
        completionList = {
          itemDefaults = { "commitCharacters", "editRange", "insertTextFormat", "insertTextMode", "data" },
        },
        contextSupport = true,
        insertTextMode = 1,
      },
    },
    workspace = {
      didChangeWatchedFiles = { dynamicRegistration = false },
      fileOperations = { didRename = true, willRename = true },
    },
  },
})

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  if server_is_available(name, config) then vim.lsp.enable(name) end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup "lsp_attach",
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    if client.name == "ruff" and skip_ruff_format(vim.api.nvim_buf_get_name(ev.buf)) then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
      client.server_capabilities.documentOnTypeFormattingProvider = nil
    end

    if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
      local semantic = client.config.capabilities
        and client.config.capabilities.textDocument
        and client.config.capabilities.textDocument.semanticTokens
      if semantic then
        client.server_capabilities.semanticTokensProvider = {
          full = true,
          legend = {
            tokenTypes = semantic.tokenTypes,
            tokenModifiers = semantic.tokenModifiers,
          },
          range = true,
        }
      end
    end

    lsp_map(ev.buf, "n", "K", vim.lsp.buf.hover, "lsp: hover")
    lsp_map(ev.buf, "i", "<C-k>", vim.lsp.buf.signature_help, "lsp: signature help")
    lsp_map(ev.buf, "n", "gr", vim.lsp.buf.rename, "lsp: rename")
    lsp_map(ev.buf, "n", "gy", vim.lsp.buf.type_definition, "lsp: type definition")
    lsp_map(ev.buf, "n", "gD", vim.lsp.buf.declaration, "lsp: declaration")
    lsp_map(ev.buf, "n", "gd", vim.lsp.buf.definition, "lsp: definition")
    lsp_map(ev.buf, "n", "gI", vim.lsp.buf.implementation, "lsp: implementation")
    lsp_map(ev.buf, "n", "gR", vim.lsp.buf.references, "lsp: references")
    lsp_map(ev.buf, { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "lsp: code action")
    lsp_map(
      ev.buf,
      { "n", "v" },
      "<leader><leader>f",
      function() vim.lsp.buf.format { async = true } end,
      "lsp: format"
    )
  end,
})

-- breadcrumbs
require("dropbar").setup {
  bar = {
    update_events = {
      buf = {
        "FileChangedShellPost",
        "TextChanged",
        "ModeChanged",
        "BufWritePost",
      },
    },
    enable = function(buf, win, _)
      if
        not vim.api.nvim_buf_is_valid(buf)
        or not vim.api.nvim_win_is_valid(win)
        or vim.fn.win_gettype(win) ~= ""
        or vim.wo[win].winbar ~= ""
        or vim.tbl_contains({ "help", "terminal" }, vim.bo[buf].ft)
      then
        return false
      end

      local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
      if stat and stat.size > 1.5 * 1024 * 1024 then return false end

      return vim.bo[buf].ft == "markdown"
        or pcall(vim.treesitter.get_parser, buf)
        or #vim.lsp.get_clients { bufnr = buf, method = "textDocument/documentSymbol" } > 0
    end,
    hover = false,
    sources = function(buf, _)
      local sources = require "dropbar.sources"
      local utils = require "dropbar.utils"
      if vim.bo[buf].ft == "markdown" then return { sources.markdown } end
      return { utils.source.fallback { sources.lsp, sources.treesitter } }
    end,
  },
}
vim.keymap.set("n", "<leader>;", function() require("dropbar.api").pick() end, { desc = "breadcrumbs: pick" })
