local fn, uv, api = vim.fn, vim.loop, vim.api
local is_mac = __editor_global.is_mac
local modules_dir = __editor_global.modules_dir
local packer_compiled = __editor_global.data_dir .. "lua/_compiled.lua"
local bak_compiled = __editor_global.data_dir .. "lua/bak_compiled.lua"
local packer = nil

local use_ssh = __editor_global.use_ssh

local Packer = {}
Packer.__index = Packer

function Packer:load_plugins()
  self.repos = {}

  local get_plugins_list = function()
    local list = {}
    local tmp = vim.split(fn.globpath(modules_dir, "*/plugins.lua"), "\n")
    local subtmp = vim.split(fn.globpath(modules_dir, "*/user/plugins.lua"), "\n")
    for _, v in ipairs(subtmp) do
      if v ~= "" then
        table.insert(tmp, v)
      end
    end
    for _, f in ipairs(tmp) do
      list[#list + 1] = f:sub(#modules_dir - 6, -1)
    end
    return list
  end

  local plugins_file = get_plugins_list()
  for _, m in ipairs(plugins_file) do
    local repos = require(m:sub(0, #m - 4))
    for repo, conf in pairs(repos) do
      self.repos[#self.repos + 1] = vim.tbl_extend("force", { repo }, conf)
    end
  end
end

local required_plugins = function(use)
  use({ "RishabhRD/popfix" })
  use({ "nvim-lua/plenary.nvim" })
  use({ "lewis6991/impatient.nvim" })
  use({ "nathom/filetype.nvim" })
  use({ "kyazdani42/nvim-web-devicons" })
  use({ "wbthomason/packer.nvim", opt = true })

  -- colorscheme
  use({
    "rose-pine/neovim",
    as = "rose-pine",
    config = function()
      require("rose-pine").setup({
        --- @usage 'main' | 'moon'
        dark_variant = "moon",
        bold_vert_split = true,
        dim_nc_background = false,
        disable_background = true,
        disable_float_background = false,
        disable_italics = false,
      })
    end,
  })
  use({
    "catppuccin/nvim",
    as = "catppuccin",
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- Can be one of: latte, frappe, macchiato, mocha
        background = { light = "latte", dark = "frappe" },
        dim_inactive = {
          enabled = false,
          -- Dim inactive splits/windows/buffers.
          -- NOT recommended if you use old palette (a.k.a., mocha).
          shade = "dark",
          percentage = 0.15,
        },
        transparent_background = false,
        term_colors = true,
        compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
        styles = {
          comments = { "italic" },
          properties = { "italic" },
          functions = { "italic", "bold" },
          keywords = { "italic" },
          operators = { "bold" },
          conditionals = { "bold" },
          loops = { "bold" },
          booleans = { "bold", "italic" },
          numbers = {},
          types = {},
          strings = {},
          variables = {},
        },
        integrations = {
          treesitter = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
          lsp_trouble = true,
          lsp_saga = true,
          gitgutter = false,
          gitsigns = true,
          telescope = true,
          nvimtree = true,
          which_key = true,
          indent_blankline = { enabled = true, colored_indent_levels = false },
          dashboard = true,
          neogit = false,
          mason = true,
          vim_sneak = false,
          fern = false,
          barbar = false,
          markdown = true,
          lightspeed = false,
          ts_rainbow = true,
          hop = true,
          illuminate = true,
          cmp = true,
          dap = { enabled = true, enable_ui = true },
          notify = false,
          symbols_outline = false,
          coc_nvim = false,
          leap = false,
          neotree = { enabled = false },
          telekasten = false,
          mini = false,
          aerial = false,
          vimwiki = true,
          beacon = false,
          navic = false,
          overseer = false,
          fidget = true,
        },
        color_overrides = {
          mocha = {
            rosewater = "#F5E0DC",
            flamingo = "#F2CDCD",
            mauve = "#DDB6F2",
            pink = "#F5C2E7",
            red = "#F28FAD",
            maroon = "#E8A2AF",
            peach = "#F8BD96",
            yellow = "#FAE3B0",
            green = "#ABE9B3",
            blue = "#96CDFB",
            sky = "#89DCEB",
            teal = "#B5E8E0",
            lavender = "#C9CBFF",

            text = "#D9E0EE",
            subtext1 = "#BAC2DE",
            subtext0 = "#A6ADC8",
            overlay2 = "#C3BAC6",
            overlay1 = "#988BA2",
            overlay0 = "#6E6C7E",
            surface2 = "#6E6C7E",
            surface1 = "#575268",
            surface0 = "#302D41",

            base = "#1E1E2E",
            mantle = "#1A1826",
            crust = "#161320",
          },
        },
        highlight_overrides = {
          mocha = function(cp)
            return {
              -- For base configs.
              CursorLineNr = { fg = cp.green },
              Search = { bg = cp.surface1, fg = cp.pink, style = { "bold" } },
              IncSearch = { bg = cp.pink, fg = cp.surface1 },

              -- For native lsp configs.
              DiagnosticVirtualTextError = { bg = cp.none },
              DiagnosticVirtualTextWarn = { bg = cp.none },
              DiagnosticVirtualTextInfo = { bg = cp.none },
              DiagnosticVirtualTextHint = { fg = cp.rosewater, bg = cp.none },

              DiagnosticHint = { fg = cp.rosewater },
              LspDiagnosticsDefaultHint = { fg = cp.rosewater },
              LspDiagnosticsHint = { fg = cp.rosewater },
              LspDiagnosticsVirtualTextHint = { fg = cp.rosewater },
              LspDiagnosticsUnderlineHint = { sp = cp.rosewater },

              -- For fidget.
              FidgetTask = { bg = cp.none, fg = cp.surface2 },
              FidgetTitle = { fg = cp.blue, style = { "bold" } },

              -- For treesitter.
              ["@field"] = { fg = cp.rosewater },
              ["@property"] = { fg = cp.yellow },

              ["@include"] = { fg = cp.teal },
              ["@operator"] = { fg = cp.sky },
              ["@keyword.operator"] = { fg = cp.sky },
              ["@punctuation.special"] = { fg = cp.maroon },

              ["@float"] = { fg = cp.peach },
              ["@number"] = { fg = cp.peach },
              ["@boolean"] = { fg = cp.peach },

              ["@constructor"] = { fg = cp.lavender },
              ["@constant"] = { fg = cp.peach },
              ["@conditional"] = { fg = cp.mauve },
              ["@repeat"] = { fg = cp.mauve },
              ["@exception"] = { fg = cp.peach },

              ["@constant.builtin"] = { fg = cp.lavender },
              -- ["@function.builtin"] = { fg = cp.peach, style = { "italic" } },
              -- ["@type.builtin"] = { fg = cp.yellow, style = { "italic" } },
              ["@variable.builtin"] = { fg = cp.red, style = { "italic" } },

              -- ["@function"] = { fg = cp.blue },
              ["@function.macro"] = { fg = cp.red, style = {} },
              ["@parameter"] = { fg = cp.rosewater },
              ["@keyword.function"] = { fg = cp.maroon },
              ["@keyword"] = { fg = cp.red },
              ["@keyword.return"] = { fg = cp.pink, style = {} },

              -- ["@text.note"] = { fg = cp.base, bg = cp.blue },
              -- ["@text.warning"] = { fg = cp.base, bg = cp.yellow },
              -- ["@text.danger"] = { fg = cp.base, bg = cp.red },
              -- ["@constant.macro"] = { fg = cp.mauve },

              -- ["@label"] = { fg = cp.blue },
              ["@method"] = { style = { "italic" } },
              ["@namespace"] = { fg = cp.rosewater, style = {} },

              ["@punctuation.delimiter"] = { fg = cp.teal },
              ["@punctuation.bracket"] = { fg = cp.overlay2 },
              -- ["@string"] = { fg = cp.green },
              -- ["@string.regex"] = { fg = cp.peach },
              -- ["@type"] = { fg = cp.yellow },
              ["@variable"] = { fg = cp.text },
              ["@tag.attribute"] = { fg = cp.mauve, style = { "italic" } },
              ["@tag"] = { fg = cp.peach },
              ["@tag.delimiter"] = { fg = cp.maroon },
              ["@text"] = { fg = cp.text },

              -- ["@text.uri"] = { fg = cp.rosewater, style = { "italic", "underline" } },
              -- ["@text.literal"] = { fg = cp.teal, style = { "italic" } },
              -- ["@text.reference"] = { fg = cp.lavender, style = { "bold" } },
              -- ["@text.title"] = { fg = cp.blue, style = { "bold" } },
              -- ["@text.emphasis"] = { fg = cp.maroon, style = { "italic" } },
              -- ["@text.strong"] = { fg = cp.maroon, style = { "bold" } },
              -- ["@string.escape"] = { fg = cp.pink },

              -- ["@property.toml"] = { fg = cp.blue },
              -- ["@field.yaml"] = { fg = cp.blue },

              -- ["@label.json"] = { fg = cp.blue },

              ["@function.builtin.bash"] = { fg = cp.red, style = { "italic" } },
              ["@parameter.bash"] = { fg = cp.yellow, style = { "italic" } },

              ["@field.lua"] = { fg = cp.lavender },
              ["@constructor.lua"] = { fg = cp.flamingo },

              ["@constant.java"] = { fg = cp.teal },

              ["@property.typescript"] = { fg = cp.lavender, style = { "italic" } },
              -- ["@constructor.typescript"] = { fg = cp.lavender },

              -- ["@constructor.tsx"] = { fg = cp.lavender },
              -- ["@tag.attribute.tsx"] = { fg = cp.mauve },

              ["@type.css"] = { fg = cp.lavender },
              ["@property.css"] = { fg = cp.yellow, style = { "italic" } },

              ["@property.cpp"] = { fg = cp.text },
            }
          end,
        },
      })
    end,
  })

  use({ "stevearc/dressing.nvim", after = "nvim-web-devicons" })

  -- tpope
  use({ "tpope/vim-repeat" })
  use({ "tpope/vim-sleuth" })
  use({ "tpope/vim-fugitive", cmd = { "Git", "G", "Ggrep", "GBrowse" } })
end

function Packer:load_packer()
  if not packer then
    api.nvim_command("packadd packer.nvim")
    packer = require("packer")
  end
  local clone_prefix = use_ssh and "git@github.com:%s" or "https://github.com/%s"

  local packer_config = {
    compile_path = packer_compiled,
    git = { clone_timeout = 60, default_url_format = clone_prefix },
    disable_commands = true,
    display = {
      open_fn = function()
        return require("packer.util").float({ border = "rounded" })
      end,
    },
    max_jobs = 50,
  }
  if not is_mac then
    packer_config.max_jobs = 20
  end

  packer.init(packer_config)
  packer.reset()
  local use = packer.use
  self:load_plugins()
  required_plugins(use)
  for _, repo in ipairs(self.repos) do
    use(repo)
  end
end

function Packer:init_ensure_plugins()
  local packer_dir = __editor_global.data_dir .. "pack/packer/opt/packer.nvim"
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = (
      (
        use_ssh and "!git clone git@github.com:wbthomason/packer.nvim.git "
        or "!git clone https://github.com/wbthomason/packer.nvim "
      ) .. packer_dir
    )
    api.nvim_command(cmd)
    uv.fs_mkdir(__editor_global.data_dir .. "lua", 511, function()
      assert(nil, "Failed to make packer compile dir. Please restart Nvim and we'll try it again!")
    end)
    self:load_packer()
    packer.install()
  end
end

local M = setmetatable({}, {
  __index = function(_, key)
    if not packer then
      Packer:load_packer()
    end
    return packer[key]
  end,
})

function M.ensure_plugins()
  Packer:init_ensure_plugins()
end

function M.back_compile()
  if vim.fn.filereadable(packer_compiled) == 1 then
    os.rename(packer_compiled, bak_compiled)
  end
  M.compile()
  vim.notify("Packer Compile Success!", vim.log.levels.INFO, { title = "Success!" })
end

function M.auto_compile()
  local file = vim.fn.expand("%:p")
  if file:match(modules_dir) then
    M.clean()
    M.back_compile()
  end
end

function M.load_compile()
  if vim.fn.filereadable(packer_compiled) == 1 then
    require("_compiled")
  else
    M.back_compile()
  end

  local cmds = { "Compile", "Install", "Update", "Sync", "Clean", "Status" }
  for _, cmd in ipairs(cmds) do
    api.nvim_create_user_command("Packer" .. cmd, function()
      require("core.pack")[cmd == "Compile" and "back_compile" or string.lower(cmd)]()
    end, { force = true })
  end

  api.nvim_create_autocmd("User", {
    pattern = "PackerComplete",
    callback = function()
      require("core.pack").back_compile()
    end,
  })
end

return M
