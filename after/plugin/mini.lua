local did = {}

local function silent_map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc }) end

local function once(name, fn)
  if did[name] then return end
  did[name] = true
  Util.pack.load "mini.nvim"
  fn()
end

local function setup_icons()
  once("icons", function()
    local icons = require "mini.icons"
    icons.setup()
    icons.mock_nvim_web_devicons()
  end)
end

local function setup_extra()
  once("extra", function() require("mini.extra").setup() end)
end

local function setup_pick()
  setup_icons()
  setup_extra()
  once("pick", function()
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
  end)
end

local function setup_files()
  once(
    "files",
    function()
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
    end
  )
end

local function setup_git()
  once("git", function() require("mini.git").setup() end)
end

local function setup_align()
  once(
    "align",
    function() require("mini.align").setup { mappings = { start = "<leader>ga", start_with_preview = "<leader>gA" } } end
  )
end

local function setup_bracketed()
  once(
    "bracketed",
    function() require("mini.bracketed").setup { window = { suffix = "" }, treesitter = { suffix = "" } } end
  )
end

local function setup_move()
  once("move", function() require("mini.move").setup() end)
end

local function setup_surround()
  once(
    "surround",
    function()
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
    end
  )
end

local function setup_pairs()
  once(
    "pairs",
    function()
      require("mini.pairs").setup {
        modes = { insert = true, command = true, terminal = false },
        skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
        skip_ts = { "string" },
        skip_unbalanced = true,
        markdown = true,
      }
    end
  )
end

local function setup_ai()
  once("ai", function()
    setup_extra()
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
  end)
end

local function setup_diff()
  once("diff", function()
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
  end)
end

local function setup_hipatterns()
  once("hipatterns", function()
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
  end)
end

local function setup_text_editing()
  setup_align()
  setup_bracketed()
  setup_move()
  setup_surround()
  setup_ai()
end

local function setup_file_features()
  setup_git()
  setup_diff()
  setup_hipatterns()
end

local function file_buffer_exists()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      return true
    end
  end
  return false
end

local function empty_startup_buffer()
  if #vim.api.nvim_list_uis() == 0 then return false end
  if vim.fn.argc(-1) > 0 then return false end

  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].modified then return false end
  if vim.api.nvim_buf_line_count(buf) ~= 1 then return false end

  local line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
  return line == nil or line == ""
end

local function git_root()
  if vim.fn.executable "git" ~= 1 then return nil end

  local cwd = vim.uv.cwd()
  if not cwd then return nil end

  local result = vim.system({ "git", "-C", cwd, "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if result.code ~= 0 or not result.stdout or result.stdout == "" then return nil end

  return Util.norm(vim.trim(result.stdout))
end

local function startup_git_files_window()
  local width = math.min(96, math.max(40, math.floor(0.62 * vim.o.columns)))
  local height = math.min(28, math.max(12, math.floor(0.54 * vim.o.lines)))

  width = math.min(width, math.max(1, vim.o.columns - 4))
  height = math.min(height, math.max(1, vim.o.lines - 4))

  return {
    anchor = "NW",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2)),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
  }
end

local function open_startup_git_files()
  if not empty_startup_buffer() then return end

  local root = git_root()
  if not root then return end

  setup_pick()
  require("mini.pick").builtin.files({ tool = "git" }, {
    source = { cwd = root, name = "Git files" },
    window = { config = startup_git_files_window },
  })
end

vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup "mini_pairs",
  once = true,
  callback = setup_pairs,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
  group = augroup "mini_pairs_cmdline",
  once = true,
  callback = setup_pairs,
})

vim.api.nvim_create_autocmd("User", {
  group = augroup "mini_files",
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local buf = args.data.buf_id
    local show_dotfiles = true
    local show_preview = false

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

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = augroup "mini_file_features",
  once = true,
  callback = function()
    if vim.v.vim_did_enter == 1 then vim.defer_fn(setup_file_features, 20) end
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup "mini_defer",
  once = true,
  callback = function()
    vim.schedule(open_startup_git_files)
    vim.defer_fn(setup_text_editing, 10)
    if file_buffer_exists() then vim.defer_fn(setup_file_features, 20) end
  end,
})

local function pick_files(cwd)
  setup_pick()
  require("mini.pick").builtin.files(nil, { source = { cwd = cwd } })
end

silent_map("n", "<leader>f", function() pick_files(Util.root.git()) end, "files: find in root")
silent_map("n", "<localleader>f", function()
  setup_pick()
  require("mini.extra").pickers.oldfiles()
end, "files: recent")
silent_map("n", "<localleader>/", function()
  setup_files()
  require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
end, "files: current")
silent_map("n", "<localleader>.", function()
  setup_files()
  require("mini.files").open(Util.root.git(), true)
end, "files: root")
silent_map("n", "-", function()
  setup_files()
  require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
end, "files: current")
silent_map("n", "<leader>g", function()
  setup_diff()
  require("mini.diff").toggle_overlay(0)
end, "git: toggle diff overlay")
silent_map("n", "<leader>gg", function()
  setup_git()
  vim.cmd "Git status"
end, "git: status")
silent_map("n", "<leader>gl", function()
  setup_git()
  vim.cmd "Git log --oneline --decorate --graph -n 50"
end, "git: log")
silent_map({ "n", "x" }, "<leader>gs", function()
  setup_git()
  require("mini.git").show_at_cursor()
end, "git: show at cursor")
