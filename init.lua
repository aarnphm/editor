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
  { src = "https://github.com/nuvic/flexoki-nvim.git",    name = "flexoki" },
  { src = "https://github.com/echasnovski/mini.nvim.git", name = "mini.nvim" },
  { src = "https://github.com/Saghen/blink.lib.git",      name = "blink.lib", lazy = true },
  {
    src = "https://github.com/Saghen/blink.cmp.git",
    name = "blink.cmp",
    version = "main",
    lazy = true,
    event = "InsertEnter",
    dependencies = { "blink.lib", "friendly-snippets" },
    build = function()
      vim.cmd.packadd "blink.lib"
      vim.cmd.packadd "blink.cmp"
      require("blink.cmp").build():wait(60000)
    end,
  },
  { src = "https://github.com/rafamadriz/friendly-snippets.git",    name = "friendly-snippets", lazy = true },
  { src = "https://github.com/mason-org/mason.nvim.git",            name = "mason.nvim" },
  { src = "https://github.com/stevearc/conform.nvim.git",           name = "conform.nvim" },
  { src = "https://codeberg.org/andyg/leap.nvim.git",               name = "leap.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter.git", name = "nvim-treesitter",   version = "main" },
  { src = "https://github.com/neovim/nvim-lspconfig.git",           name = "nvim-lspconfig" },
  { src = "https://github.com/folke/lazydev.nvim.git",              name = "lazydev.nvim",      lazy = true },
  { src = "https://github.com/Bekaboo/dropbar.nvim.git",            name = "dropbar.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim.git",         name = "gitsigns.nvim" },
  {
    src = "https://github.com/MagicDuck/grug-far.nvim.git",
    name = "grug-far.nvim",
    lazy = true,
    cmd = "GrugFar",
    opts = {
      headerMaxWidth = 50,
      windowCreationCommand = "botright vsplit",
    },
    config = function(_, opts) require("grug-far").setup(opts) end,
  },
}

if not vim.pack then error "This config expects Nvim with vim.pack support" end

local spec_by_name = {}
local pack_specs = {}
for _, spec in ipairs(specs) do
  spec_by_name[spec.name] = spec
  pack_specs[#pack_specs + 1] = {
    src = spec.src,
    name = spec.name,
    version = spec.version,
  }
end

local loaded = {}

local function spec_opts(spec)
  if type(spec.opts) == "function" then return spec.opts(spec) end
  return spec.opts
end

local function plugin_info(name)
  local ok_info, plugins = pcall(vim.pack.get, { name }, { info = false })
  if not ok_info then return nil end
  return plugins[1]
end

local function dependency_names(spec)
  local ret = {}
  for _, dep in ipairs(spec.dependencies or {}) do
    ret[#ret + 1] = type(dep) == "string" and dep or dep.name
  end
  return ret
end

local function load_plugin(name)
  if loaded[name] then return end
  local spec = spec_by_name[name]
  if not spec then
    vim.cmd.packadd(name)
    loaded[name] = true
    return
  end

  for _, dep in ipairs(dependency_names(spec)) do
    load_plugin(dep)
  end

  vim.cmd.packadd(name)
  loaded[name] = true

  local opts = spec_opts(spec)
  if spec.config then spec.config(spec, opts or {}) end
end

local function run_build(name)
  local spec = spec_by_name[name]
  if not (spec and spec.build) then return false end

  local info = plugin_info(name)
  if not (info and info.path) then return false end

  if type(spec.build) == "function" then
    spec.build(spec, info.path)
    return true
  end

  local cmd = type(spec.build) == "table" and spec.build or { vim.o.shell, vim.o.shellcmdflag, spec.build }
  local result = vim.system(cmd, { cwd = info.path, text = true }):wait()
  if result.code ~= 0 then
    error(("PackBuild failed for %s\n%s"):format(name, result.stderr ~= "" and result.stderr or result.stdout))
  end
  return true
end

Util.pack = {
  specs = spec_by_name,
  get = function(name) return spec_by_name[name] end,
  load = load_plugin,
  opts = spec_opts,
  build = function(names)
    names = names or vim.tbl_keys(spec_by_name)
    if type(names) == "string" then names = { names } end

    local built = {}
    for _, name in ipairs(names) do
      if run_build(name) then built[#built + 1] = name end
    end
    return built
  end,
}

vim.pack.add(pack_specs, { confirm = false, load = function() end })
