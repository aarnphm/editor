_G.Util = require "utils"
_G.augroup = function(name) return vim.api.nvim_create_augroup(("simple_%s"):format(name), { clear = true }) end
_G.P = function(...)
  print(vim.inspect(...))
  return ...
end
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

local function limit_render_markdown_latex()
  local ok, latex = pcall(require, "render-markdown.handler.latex")
  if not ok or not (debug and debug.getupvalue) then return false end

  -- render-markdown fans out one converter process per unique formula. Keep
  -- the upstream cache, but run the converter path one formula at a time.
  local handler
  for index = 1, 20 do
    local name, value = debug.getupvalue(latex.parse, index)
    if not name then break end
    if name == "Handler" and type(value) == "table" then
      handler = value
      break
    end
  end
  if not handler then return false end
  if handler._simple_serial_convert then return true end

  handler._simple_serial_convert = handler.convert
  handler.convert = function(cmd, inputs)
    local failed = {}
    for _, input in ipairs(inputs) do
      local ok_convert, remaining = pcall(handler._simple_serial_convert, cmd, { input })
      if not ok_convert or #remaining > 0 then failed[#failed + 1] = input end
    end
    return failed
  end
  return true
end

local render_markdown_config = {
  enabled = false,
  preset = "obsidian",
  file_types = { "markdown", "markdown.mdx" },
  render_modes = { "n", "c", "t" },
  completions = { lsp = { enabled = true } },
  latex = {
    enabled = vim.fn.executable "latex2text" == 1 or vim.fn.executable "utftex" == 1,
  },
  sign = { enabled = false },
}

vim.g.render_markdown_config = render_markdown_config

Util.pack.setup {
  "folke/lazydev.nvim",
  "echasnovski/mini.nvim",
  "mason-org/mason.nvim",
  "lewis6991/gitsigns.nvim",
  "nvim-treesitter/nvim-treesitter",
  "https://codeberg.org/andyg/leap.nvim.git",
  { "nuvic/flexoki-nvim", name = "flexoki" },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter", "mini.nvim" },
    opts = render_markdown_config,
    config = function(_, opts)
      if opts.latex and opts.latex.enabled and not limit_render_markdown_latex() then
        opts = vim.deepcopy(opts)
        opts.latex.enabled = false
      end
      local ok_icons, icons = pcall(require, "mini.icons")
      if ok_icons then
        if not _G.MiniIcons then icons.setup() end
        icons.mock_nvim_web_devicons()
      end
      require("render-markdown").setup(opts)
    end,
  },
  { "stevearc/conform.nvim", version = "master" },
  { "mfussenegger/nvim-lint", version = "master" },
  { "neovim/nvim-lspconfig", version = "master" },
  { "Bekaboo/dropbar.nvim", version = "master" },
  {
    "Saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = { "Saghen/blink.lib", "rafamadriz/friendly-snippets" },
    build = function()
      vim.cmd.packadd "blink.lib"
      vim.cmd.packadd "blink.cmp"
      require("blink.cmp").build():wait(60000)
    end,
  },
  {
    "aarnphm/luasnip-latex-snippets.nvim",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "master",
        build = (not jit.os:find "Windows")
            and "echo -e 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
          or nil,
        opts = function()
          return {
            history = true,
            region_check_events = "InsertEnter",
            delete_check_events = "TextChanged",
            ft_func = function() return vim.split(vim.bo.filetype, ".", { plain = true }) end,
            load_ft_func = require("luasnip.extras.filetype_functions").extend_load_ft {
              markdown = { "lua", "json", "tex" },
            },
          }
        end,
        config = function(_, opts) require("luasnip").config.setup(opts) end,
      },
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {
      headerMaxWidth = 50,
      windowCreationCommand = "botright vsplit",
    },
    config = function(_, opts) require("grug-far").setup(opts) end,
  },
}
