-- mini
Util.pack.load "mini.nvim"

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
