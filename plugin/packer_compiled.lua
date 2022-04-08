-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/aarnphm/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/aarnphm/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/aarnphm/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/aarnphm/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/aarnphm/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  LuaSnip = {
    after = { "cmp_luasnip", "cmp-under-comparator" },
    config = { "\27LJ\2\n∞\1\0\0\3\0\a\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0009\0\3\0005\2\4\0B\0\2\0016\0\0\0'\2\5\0B\0\2\0029\0\6\0B\0\1\1K\0\1\0\tload luasnip/loaders/from_vscode\1\0\2\17updateevents\29TextChanged,TextChangedI\fhistory\2\15set_config\vconfig\fluasnip\frequire\0" },
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/LuaSnip",
    url = "git@github.com:L3MON4D3/LuaSnip",
    wants = { "friendly-snippets" }
  },
  ["calendar-vim"] = {
    load_after = {
      ["telekasten.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/calendar-vim",
    url = "git@github.com:renerocksai/calendar-vim"
  },
  catppuccin = {
    cond = { "\27LJ\2\nN\0\0\1\0\3\0\b6\0\0\0009\0\1\0\6\0\2\0X\0\2Ä+\0\1\0X\1\1Ä+\0\2\0L\0\2\0\15catppuccin\16colorscheme\20__editor_config\0" },
    config = { "\27LJ\2\n„\5\0\0\6\0\21\0\0256\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0005\4\a\0005\5\b\0=\5\t\0045\5\n\0=\5\v\4=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\3=\3\17\2B\0\2\0016\0\18\0009\0\19\0'\2\20\0B\0\2\1K\0\1\0#silent! colorscheme catppuccin\bcmd\bvim\17integrations\21indent_blankline\1\0\2\26colored_indent_levels\1\fenabled\2\rnvimtree\1\0\2\14show_root\1\fenabled\1\15native_lsp\15underlines\1\0\4\nhints\14underline\verrors\14underline\16information\14underline\rwarnings\14underline\17virtual_text\1\0\4\nhints\vitalic\verrors\vitalic\16information\vitalic\rwarnings\vitalic\1\0\1\fenabled\2\1\0\14\15bufferline\2\rgitsigns\2\tfern\1\15ts_rainbow\2\15lightspeed\1\rmarkdown\2\15treesitter\2\14vim_sneak\1\vneogit\1\14dashboard\2\14which_key\2\rlsp_saga\2\14gitgutter\1\14telescope\2\vstyles\1\0\5\fstrings\tNONE\rkeywords\vitalic\14functions\16italic,bold\rcomments\vitalic\14variables\tNONE\1\0\2\16term_colors\2\27transparent_background\1\nsetup\15catppuccin\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/catppuccin",
    url = "git@github.com:catppuccin/nvim"
  },
  ["cheatsheet.nvim"] = {
    config = { "\27LJ\2\nÜ\3\0\0\a\0\15\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\6\0006\4\0\0'\6\4\0B\4\2\0029\4\5\4=\4\a\0036\4\0\0'\6\4\0B\4\2\0029\4\b\4=\4\t\0036\4\0\0'\6\4\0B\4\2\0029\4\n\4=\4\v\0036\4\0\0'\6\4\0B\4\2\0029\4\f\4=\4\r\3=\3\14\2B\0\2\1K\0\1\0\23telescope_mappings\n<C-E>\25edit_user_cheatsheet\n<C-Y>\21copy_cheat_value\v<A-CR>\22select_or_execute\t<CR>\1\0\0\31select_or_fill_commandline!cheatsheet.telescope.actions\1\0\3\31bundled_plugin_cheatsheets\2#include_only_installed_plugins\2\24bundled_cheatsheets\2\nsetup\15cheatsheet\frequire\0" },
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cheatsheet.nvim",
    url = "git@github.com:sudormrfbin/cheatsheet.nvim"
  },
  ["cmp-buffer"] = {
    after = { "cmp-latex-symbols" },
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-buffer/after/plugin/cmp_buffer.lua" },
    load_after = {
      ["cmp-path"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-buffer",
    url = "git@github.com:hrsh7th/cmp-buffer"
  },
  ["cmp-latex-symbols"] = {
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-latex-symbols/after/plugin/cmp_latex.lua" },
    load_after = {
      ["cmp-buffer"] = true
    },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-latex-symbols",
    url = "git@github.com:kdheepak/cmp-latex-symbols"
  },
  ["cmp-nvim-lsp"] = {
    after = { "cmp-nvim-lua" },
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-nvim-lsp/after/plugin/cmp_nvim_lsp.lua" },
    load_after = {
      cmp_luasnip = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-nvim-lsp",
    url = "git@github.com:hrsh7th/cmp-nvim-lsp"
  },
  ["cmp-nvim-lua"] = {
    after = { "cmp-path" },
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-nvim-lua/after/plugin/cmp_nvim_lua.lua" },
    load_after = {
      ["cmp-nvim-lsp"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-nvim-lua",
    url = "git@github.com:hrsh7th/cmp-nvim-lua"
  },
  ["cmp-path"] = {
    after = { "cmp-buffer" },
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-path/after/plugin/cmp_path.lua" },
    load_after = {
      ["cmp-nvim-lua"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-path",
    url = "git@github.com:hrsh7th/cmp-path"
  },
  ["cmp-under-comparator"] = {
    load_after = {
      LuaSnip = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-under-comparator",
    url = "git@github.com:lukas-reineke/cmp-under-comparator"
  },
  cmp_luasnip = {
    after = { "cmp-nvim-lsp" },
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp_luasnip/after/plugin/cmp_luasnip.lua" },
    load_after = {
      LuaSnip = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp_luasnip",
    url = "git@github.com:saadparwaiz1/cmp_luasnip"
  },
  ["copilot.vim"] = {
    commands = { "Copilot" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/copilot.vim",
    url = "git@github.com:github/copilot.vim"
  },
  ["dashboard-nvim"] = {
    cond = { "\27LJ\2\nM\0\0\2\0\3\0\f6\0\0\0009\0\1\0009\0\2\0B\0\1\2\21\0\0\0)\1\0\0\0\1\0\0X\0\2Ä+\0\1\0X\1\1Ä+\0\2\0L\0\2\0\18nvim_list_uis\bapi\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/dashboard-nvim",
    url = "git@github.com:glepnir/dashboard-nvim"
  },
  ["dressing.nvim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/dressing.nvim",
    url = "git@github.com:stevearc/dressing.nvim"
  },
  ["efmls-configs-nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/efmls-configs-nvim",
    url = "git@github.com:creativenull/efmls-configs-nvim"
  },
  ["feline.nvim"] = {
    cond = { "\27LJ\2\nU\0\0\1\0\4\0\t6\0\0\0009\0\1\0009\0\2\0\6\0\3\0X\0\2Ä+\0\1\0X\1\1Ä+\0\2\0L\0\2\0\vfeline\15statusline\fplugins\20__editor_config\0" },
    config = { "\27LJ\2\n∑\1\0\0\b\0\n\0\0286\0\0\0009\0\1\0009\0\2\0'\2\3\0B\0\2\0026\1\0\0009\1\1\0019\1\2\1'\3\4\0B\1\2\0026\2\5\0'\4\6\0B\2\2\0029\2\a\2\18\4\0\0\18\5\1\0B\2\3\2\v\2\0\0X\3\2Ä'\2\b\0L\2\2\0'\3\t\0\18\4\2\0'\5\t\0\18\6\0\0'\a\t\0&\3\a\3L\3\2\0\6 \t ÔÉß\rget_icon\22nvim-web-devicons\frequire\b%:e\b%:t\vexpand\afn\bvimo\0\1\6\0\4\0\0176\1\0\0009\1\1\0019\1\2\0016\3\3\0\18\5\0\0B\3\2\2\14\0\3\0X\4\1Ä)\3\0\0B\1\2\2)\2F\0\0\2\1\0X\1\2Ä+\1\1\0X\2\1Ä+\1\2\0L\1\2\0\rtonumber\23nvim_win_get_width\bapi\bvimd\0\0\4\0\a\0\0146\0\0\0009\0\1\0009\0\2\0006\2\0\0009\2\1\0029\2\3\2B\2\1\2'\3\4\0B\0\3\2'\1\5\0\18\2\0\0'\3\6\0&\1\3\1L\1\2\0\6 \n Ôùï \a:t\vgetcwd\16fnamemodify\afn\bvimo\0\1\6\0\4\0\0176\1\0\0009\1\1\0019\1\2\0016\3\3\0\18\5\0\0B\3\2\2\14\0\3\0X\4\1Ä)\3\0\0B\1\2\2)\2P\0\0\2\1\0X\1\2Ä+\1\1\0X\2\1Ä+\1\2\0L\1\2\0\rtonumber\23nvim_win_get_width\bapi\bvimo\0\1\6\0\4\0\0176\1\0\0009\1\1\0019\1\2\0016\3\3\0\18\5\0\0B\3\2\2\14\0\3\0X\4\1Ä)\3\0\0B\1\2\2)\2F\0\0\2\1\0X\1\2Ä+\1\1\0X\2\1Ä+\1\2\0L\1\2\0\rtonumber\23nvim_win_get_width\bapi\bvimN\0\0\3\1\4\0\a-\0\0\0009\0\0\0009\0\1\0-\2\0\0009\2\2\0029\2\3\2D\0\2\0\2¿\nERROR\17lsp_severity\22diagnostics_exist\blspM\0\0\3\1\4\0\a-\0\0\0009\0\0\0009\0\1\0-\2\0\0009\2\2\0029\2\3\2D\0\2\0\2¿\tWARN\17lsp_severity\22diagnostics_exist\blspM\0\0\3\1\4\0\a-\0\0\0009\0\0\0009\0\1\0-\2\0\0009\2\2\0029\2\3\2D\0\2\0\2¿\tHINT\17lsp_severity\22diagnostics_exist\blspM\0\0\3\1\4\0\a-\0\0\0009\0\0\0009\0\1\0-\2\0\0009\2\2\0029\2\3\2D\0\2\0\2¿\tINFO\17lsp_severity\22diagnostics_exist\blspÜ\3\0\0\15\0\17\00386\0\0\0009\0\1\0009\0\2\0009\0\3\0B\0\1\2:\0\1\0\15\0\0\0X\1.Ä9\1\4\0\14\0\1\0X\2\1Ä'\1\5\0009\2\6\0\14\0\2\0X\3\1Ä)\2\0\0009\3\a\0\14\0\3\0X\4\1Ä'\3\5\0005\4\b\0005\5\t\0006\6\0\0009\6\n\0069\6\v\6B\6\1\2\25\6\0\0066\a\f\0009\a\r\a\25\t\1\6B\a\2\2\21\b\4\0$\a\b\a)\bF\0\3\b\2\0X\b\tÄ6\b\14\0009\b\15\b'\n\16\0\22\v\2\a8\v\v\5\18\f\3\0\18\r\1\0\18\14\2\0D\b\6\0006\b\14\0009\b\15\b'\n\16\0\22\v\2\a8\v\v\4\18\f\3\0\18\r\1\0\18\14\2\0D\b\6\0'\1\5\0L\1\2\0\27 %%<%s %s %s (%s%%%%) \vformat\vstring\nfloor\tmath\vhrtime\tloop\1\4\0\0\bÔÅò\bÔÅò\bÔÅò\1\4\0\0\bÔÑå\bÔîô\bÔÜí\ntitle\15percentage\5\fmessage\26get_progress_messages\tutil\blsp\bvimÄâz\1\2o\0\1\6\0\4\0\0176\1\0\0009\1\1\0019\1\2\0016\3\3\0\18\5\0\0B\3\2\2\14\0\3\0X\4\1Ä)\3\0\0B\1\2\2)\2P\0\0\2\1\0X\1\2Ä+\1\1\0X\2\1Ä+\1\2\0L\1\2\0\rtonumber\23nvim_win_get_width\bapi\bvimf\0\0\4\0\6\0\0146\0\0\0006\2\1\0009\2\2\0029\2\3\2B\2\1\0A\0\0\2\n\0\0\0X\0\3Ä'\0\4\0L\0\2\0X\0\2Ä'\0\5\0L\0\2\0K\0\1\0\5\rÔÇÖ  LSP\20buf_get_clients\blsp\bvim\tnexto\0\1\6\0\4\0\0176\1\0\0009\1\1\0019\1\2\0016\3\3\0\18\5\0\0B\3\2\2\14\0\3\0X\4\1Ä)\3\0\0B\1\2\2)\2F\0\0\2\1\0X\1\2Ä+\1\1\0X\2\1Ä+\1\2\0L\1\2\0\rtonumber\23nvim_win_get_width\bapi\bvimt\0\0\4\1\t\0\0155\0\4\0-\1\0\0009\1\0\0016\2\1\0009\2\2\0029\2\3\2B\2\1\0028\1\2\1:\1\2\1=\1\5\0-\1\0\0009\1\6\0019\1\a\1=\1\b\0L\0\2\0\2¿\abg\vone_bg\vcolors\afg\1\0\0\tmode\afn\bvim\16mode_colorsu\0\0\4\1\t\0\0155\0\4\0-\1\0\0009\1\0\0016\2\1\0009\2\2\0029\2\3\2B\2\1\0028\1\2\1:\1\2\1=\1\5\0-\1\0\0009\1\6\0019\1\a\1=\1\b\0L\0\2\0\2¿\abg\fone_bg2\vcolors\afg\1\0\0\tmode\afn\bvim\16mode_colors{\0\0\4\1\t\0\0155\0\2\0-\1\0\0009\1\0\0019\1\1\1=\1\3\0-\1\0\0009\1\4\0016\2\5\0009\2\6\0029\2\a\2B\2\1\0028\1\2\1:\1\2\1=\1\b\0L\0\2\0\2¿\abg\tmode\afn\bvim\16mode_colors\afg\1\0\0\18statusline_bg\vcolorsS\0\0\4\1\5\0\f'\0\0\0-\1\0\0009\1\1\0016\2\2\0009\2\3\0029\2\4\2B\2\1\0028\1\2\1:\1\1\1'\2\0\0&\0\2\0L\0\2\0\2¿\tmode\afn\bvim\16mode_colors\6 o\0\1\6\0\4\0\0176\1\0\0009\1\1\0019\1\2\0016\3\3\0\18\5\0\0B\3\2\2\14\0\3\0X\4\1Ä)\3\0\0B\1\2\2)\2Z\0\0\2\1\0X\1\2Ä+\1\1\0X\2\1Ä+\1\2\0L\1\2\0\rtonumber\23nvim_win_get_width\bapi\bvimo\0\1\6\0\4\0\0176\1\0\0009\1\1\0019\1\2\0016\3\3\0\18\5\0\0B\3\2\2\14\0\3\0X\4\1Ä)\3\0\0B\1\2\2)\2Z\0\0\2\1\0X\1\2Ä+\1\1\0X\2\1Ä+\1\2\0L\1\2\0\rtonumber\23nvim_win_get_width\bapi\bvimo\0\1\6\0\4\0\0176\1\0\0009\1\1\0019\1\2\0016\3\3\0\18\5\0\0B\3\2\2\14\0\3\0X\4\1Ä)\3\0\0B\1\2\2)\2Z\0\0\2\1\0X\1\2Ä+\1\1\0X\2\1Ä+\1\2\0L\1\2\0\rtonumber\23nvim_win_get_width\bapi\bvimæ\1\0\0\a\0\v\2\"6\0\0\0009\0\1\0009\0\2\0'\2\3\0B\0\2\0026\1\0\0009\1\1\0019\1\2\1'\3\4\0B\1\2\2\t\0\0\0X\2\3Ä'\2\5\0L\2\2\0X\2\tÄ6\2\0\0009\2\1\0029\2\2\2'\4\4\0B\2\2\2\5\0\2\0X\2\2Ä'\2\6\0L\2\2\0006\2\a\0009\2\b\2#\4\1\0\24\4\1\4B\2\2\3'\4\t\0\18\5\2\0'\6\n\0&\4\6\4L\4\2\0\b%% \6 \tmodf\tmath\n Bot \n Top \6$\6.\tline\afn\bvim\2»\1o\0\1\6\0\4\0\0176\1\0\0009\1\1\0019\1\2\0016\3\3\0\18\5\0\0B\3\2\2\14\0\3\0X\4\1Ä)\3\0\0B\1\2\2)\2Z\0\0\2\1\0X\1\2Ä+\1\1\0X\2\1Ä+\1\2\0L\1\2\0\rtonumber\23nvim_win_get_width\bapi\bvim,\0\2\6\0\2\0\0066\2\0\0009\2\1\2\18\4\0\0\18\5\1\0B\2\3\1K\0\1\0\vinsert\ntableÒ \1\0\t\0À\1\0—\0046\0\0\0006\2\1\0'\3\2\0B\0\3\3\14\0\0\0X\2\1Ä2\0IÇ5\2\5\0006\3\1\0'\5\3\0B\3\2\0029\3\4\3B\3\1\2=\3\6\0026\3\1\0'\5\a\0B\3\2\2=\3\b\0026\3\t\0009\3\n\0039\3\v\3=\3\f\0025\3\r\0=\3\14\0025\3\17\0005\4\16\0=\4\18\0035\4\19\0=\4\20\0035\4\21\0=\4\22\0035\4\23\0=\4\24\0035\4\25\0=\4\26\3=\3\15\0029\3\15\0029\4\14\0029\4\28\0048\3\4\3=\3\27\0029\3\14\0029\3\29\3\v\3\1\0X\3\2Ä+\3\2\0X\4\3Ä+\3\1\0X\4\1Ä+\3\2\0=\3\29\0025\3\31\0004\4\0\0=\4 \3=\3\30\0025\3\"\0009\4\27\0029\4!\4=\4#\0035\4%\0009\5\6\0029\5$\5=\5&\0049\5\6\0029\5'\5=\5(\4=\4)\0035\4+\0009\5\27\0029\5*\5=\5,\0045\5-\0009\6\6\0029\6'\6=\6&\0059\6\6\0029\6.\6=\6(\5=\5)\4=\4/\3=\3!\0025\0032\0003\0041\0=\4#\0039\4\29\2\14\0\4\0X\5\1Ä3\0043\0=\0044\0035\0046\0009\5\6\0029\0055\5=\5&\0049\5\6\0029\5.\5=\5(\4=\4)\0035\0047\0009\5\27\0029\5*\5=\5,\0045\0058\0009\6\6\0029\6.\6=\6&\0059\6\6\0029\0069\6=\6(\5=\5)\4=\4/\3=\0030\0025\3<\0003\4;\0=\4#\0039\4\29\2\14\0\4\0X\5\1Ä3\4=\0=\0044\0035\4?\0009\5\6\0029\5>\5=\5&\0049\5\6\0029\0059\5=\5(\4=\4)\0035\4@\0009\5\27\0029\5*\5=\5,\0045\5A\0009\6\6\0029\0069\6=\6&\0059\6\6\0029\6$\6=\6(\5=\5B\4=\4/\3=\3:\0025\3F\0005\4D\0005\5E\0009\6\6\0029\6>\6=\6&\0059\6\6\0029\6$\6=\6(\5=\5)\4=\4G\0035\4H\0005\5I\0009\6\6\0029\6>\6=\6&\0059\6\6\0029\6$\6=\6(\5=\5)\4=\4J\0035\4K\0005\5L\0009\6\6\0029\6>\6=\6&\0059\6\6\0029\6$\6=\6(\5=\5)\4=\4M\3=\3C\0025\3O\0009\4\29\2\14\0\4\0X\5\1Ä3\4P\0=\0044\0035\4Q\0009\5\6\0029\5>\5=\5&\0049\5\6\0029\5$\5=\5(\4=\4)\3=\3N\0025\3V\0005\4R\0003\5S\0=\0054\0045\5U\0009\6\6\0029\6T\6=\6&\5=\5)\4=\4W\0035\4X\0003\5Y\0=\0054\0045\5[\0009\6\6\0029\6Z\6=\6&\5=\5)\4=\4\\\0035\4]\0003\5^\0=\0054\0045\5_\0009\6\6\0029\6>\6=\6&\5=\5)\4=\4`\0035\4a\0003\5b\0=\0054\0045\5d\0009\6\6\0029\6c\6=\6&\5=\5)\4=\4e\3=\3\n\0025\3h\0003\4g\0=\4#\0039\4\29\2\14\0\4\0X\5\1Ä3\4i\0=\0044\0035\4j\0009\5\6\0029\5c\5=\5&\4=\4)\3=\3f\0025\3m\0003\4l\0=\4#\0039\4\29\2\14\0\4\0X\5\1Ä3\4n\0=\0044\0035\4o\0009\5\6\0029\5>\5=\5&\0049\5\6\0029\5$\5=\5(\4=\4)\3=\3k\0025\3r\0005\4q\0009\5\6\0029\5T\5>\5\2\4=\4s\0035\4t\0009\5\6\0029\5T\5>\5\2\4=\4u\0035\4v\0009\5\6\0029\5w\5>\5\2\4=\4x\0035\4y\0009\5\6\0029\5w\5>\5\2\4=\4z\0035\4{\0009\5\6\0029\5c\5>\5\2\4=\4|\0035\4}\0009\5\6\0029\5~\5>\5\2\4=\4\0035\4Ä\0009\5\6\0029\5~\5>\5\2\4=\4Å\0035\4Ç\0009\5\6\0029\5~\5>\5\2\4=\4É\0035\4Ñ\0009\5\6\0029\5Ö\5>\5\2\4=\4Ü\0035\4á\0009\5\6\0029\5Ö\5>\5\2\4=\4à\0035\4â\0009\5\6\0029\5'\5>\5\2\4=\4ä\0035\4ã\0009\5\6\0029\5'\5>\5\2\4=\4å\0035\4ç\0009\5\6\0029\5'\5>\5\2\4=\4é\0035\4è\0009\5\6\0029\5ê\5>\5\2\4=\4ë\0035\4í\0009\5\6\0029\5ê\5>\5\2\4=\4ì\0035\4î\0009\5\6\0029\5ê\5>\5\2\4=\4ï\0035\4ñ\0009\5\6\0029\5ó\5>\5\2\4=\4ò\0035\4ô\0009\5\6\0029\5ó\5>\5\2\4=\4ö\0035\4õ\0009\5\6\0029\5ó\5>\5\2\4=\4ú\0035\4ù\0009\5\6\0029\5c\5>\5\2\4=\4û\3=\3p\0023\3†\0=\3ü\0025\3§\0'\4¢\0009\5\27\0029\5£\5&\4\5\4=\4#\0035\4¶\0009\5\6\0029\5•\5=\5&\0049\5\6\0029\5$\5=\5(\4=\4)\3=\3°\0025\3®\0009\4\27\0029\4£\4=\4#\0033\4©\0=\4)\3=\3ß\0025\3¨\0009\4\27\0029\4´\4=\4#\0033\4≠\0=\4)\3=\3™\0025\3∞\0003\4Ø\0=\4#\0039\4ü\2=\4)\3=\3Æ\0025\3≤\0009\4\27\0029\4£\4=\4#\0039\4\29\2\14\0\4\0X\5\1Ä3\4≥\0=\0044\0035\4µ\0009\5\6\0029\5¥\5=\5&\0049\5\6\0029\5∂\5=\5(\4=\4)\3=\3±\0025\3∏\0009\4\27\0029\4£\4=\4#\0039\4\29\2\14\0\4\0X\5\1Ä3\4π\0=\0044\0035\4∫\0009\5\6\0029\5c\5=\5&\0049\5\6\0029\5¥\5=\5(\4=\4)\3=\3∑\0025\3º\0009\4\27\0029\4ª\4=\4#\0039\4\29\2\14\0\4\0X\5\1Ä3\4Ω\0=\0044\0035\4ø\0009\5\6\0029\5æ\5=\5&\0049\5\6\0029\5c\5=\5(\4=\4)\3=\3ª\0025\3¬\0003\4¡\0=\4#\0039\4\29\2\14\0\4\0X\5\1Ä3\4√\0=\0044\0035\4ƒ\0009\5\6\0029\5c\5=\5&\0049\5\6\0029\5∂\5=\5(\4=\4)\3=\3¿\0023\3≈\0004\4\0\0=\4£\0024\4\0\0=\4∆\0024\4\0\0=\4*\2\18\4\3\0009\6£\0029\a!\2B\4\3\1\18\4\3\0009\6£\0029\a0\2B\4\3\1\18\4\3\0009\6£\0029\a:\2B\4\3\1\18\4\3\0009\6£\0029\aC\0029\aG\aB\4\3\1\18\4\3\0009\6£\0029\aC\0029\aJ\aB\4\3\1\18\4\3\0009\6£\0029\aC\0029\aM\aB\4\3\1\18\4\3\0009\6£\0029\a\n\0029\aW\aB\4\3\1\18\4\3\0009\6£\0029\a\n\0029\a\\\aB\4\3\1\18\4\3\0009\6£\0029\a\n\0029\a`\aB\4\3\1\18\4\3\0009\6£\0029\a\n\0029\ae\aB\4\3\1\18\4\3\0009\6∆\0029\af\2B\4\3\1\18\4\3\0009\6*\0029\ak\2B\4\3\1\18\4\3\0009\6*\0029\aN\2B\4\3\1\18\4\3\0009\6*\0029\a°\2B\4\3\1\18\4\3\0009\6*\0029\aß\2B\4\3\1\18\4\3\0009\6*\0029\a™\2B\4\3\1\18\4\3\0009\6*\0029\aÆ\2B\4\3\1\18\4\3\0009\6*\0029\a±\2B\4\3\1\18\4\3\0009\6*\0029\a∑\2B\4\3\1\18\4\3\0009\6*\0029\aª\2B\4\3\1\18\4\3\0009\6*\0029\a¿\2B\4\3\0019\4\30\0029\4 \0049\5£\2>\5\1\0049\4\30\0029\4 \0049\5∆\2>\5\2\0049\4\30\0029\4 \0049\5*\2>\5\3\0049\4«\0015\6…\0005\a»\0009\b\6\0029\b$\b=\b(\a9\b\6\0029\b&\b=\b&\a=\a \0069\a\30\2=\a\30\6B\4\2\0012\0\0ÄK\0\1\0K\0\1\0\ntheme\1\0\0\1\0\0\nsetup\vmiddle\0\1\0\0\0\1\0\0\0\17current_line\1\0\0\nblack\0\1\0\0\18position_icon\1\0\0\0\1\0\0\21separator_right2\vone_bg\1\0\0\tgrey\0\1\0\0\20separator_right\1\0\0\0\17empty_space2\0\1\0\0\17vi_mode_icon\14mode_icon\0\1\0\0\23empty_spaceColored\1\0\0\fone_bg2\1\0\0\tleft\6 \16empty_space\0\17chad_mode_hl\6!\1\2\0\0\nSHELL\ar?\1\2\0\0\fCONFIRM\arm\1\2\0\0\tMORE\6r\tteal\1\2\0\0\vPROMPT\ace\1\2\0\0\fCOMMAND\acv\1\2\0\0\fCOMMAND\6c\tpink\1\2\0\0\fCOMMAND\6\19\1\2\0\0\fS-BLOCK\6S\1\2\0\0\vS-LINE\6s\1\2\0\0\vSELECT\aRv\1\2\0\0\14V-REPLACE\6R\vorange\1\2\0\0\fREPLACE\6\22\1\2\0\0\fV-BLOCK\6V\1\2\0\0\vV-LINE\6v\tcyan\1\2\0\0\vVISUAL\6t\1\2\0\0\rTERMINAL\aic\1\2\0\0\vINSERT\6i\16dark_purple\1\2\0\0\vINSERT\ano\1\2\0\0\14N-PENDING\6n\1\0\0\1\2\0\0\vNORMAL\16mode_colors\1\0\0\0\1\0\0\0\rlsp_icon\1\0\0\0\1\0\0\0\17lsp_progress\tinfo\1\0\0\ngreen\0\1\0\2\rprovider\20diagnostic_info\ticon\n Ôüª \thint\1\0\0\0\1\0\2\rprovider\21diagnostic_hints\ticon\n Ô†µ \fwarning\1\0\0\vyellow\0\1\0\2\rprovider\24diagnostic_warnings\ticon\n ÔÅ± \nerror\1\0\0\1\0\0\bred\0\1\0\2\rprovider\22diagnostic_errors\ticon\n ÔÅó \1\0\0\0\1\0\2\rprovider\15git_branch\ticon\n Óú• \15git_branch\vremove\1\0\0\1\0\2\rprovider\21git_diff_removed\ticon\n ÔÅñ \vchange\1\0\0\1\0\2\rprovider\21git_diff_changed\ticon\n Ôëô \badd\1\0\0\1\0\0\1\0\2\rprovider\19git_diff_added\ticon\tÔÅï \tdiff\ahi\1\0\0\1\0\0\1\0\0\rgrey_fg2\0\1\0\0\0\rdir_name\rlightbg2\1\0\0\1\0\0\1\0\0\nwhite\fenabled\0\1\0\0\0\14file_name\14right_sep\flightbg\1\0\0\bstr\1\0\0\nright\ahl\abg\14nord_blue\afg\1\0\0\18statusline_bg\rprovider\1\0\0\14main_icon\vactive\1\0\0\15components\14shortline\nstyle\21statusline_style\nslant\1\0\5\14main_icon\n Ôîó \tleft\tÓÇ∫ \18position_icon\tÓúî \nright\tÓÇº \17vi_mode_icon\tÓâæ \nround\1\0\5\14main_icon\n Ôîó \tleft\bÓÇ∂\18position_icon\tÓúî \nright\bÓÇ¥\17vi_mode_icon\tÓâæ \nblock\1\0\5\14main_icon\v Ôîó  \tleft\6 \18position_icon\n Óúî \nright\6 \17vi_mode_icon\n Óâæ \narrow\1\0\5\14main_icon\n Ôîó \tleft\bÓÇ≤\18position_icon\tÓúî \nright\bÓÇ∞\17vi_mode_icon\tÓâæ \fdefault\1\0\0\1\0\5\14main_icon\n Ôîó \tleft\bÓÇ∂\18position_icon\tÓúî \nright\tÓÇº \17vi_mode_icon\tÓâæ \16icon_styles\vconfig\1\0\2\nstyle\fdefault\14shortline\2\17lsp_severity\rseverity\15diagnostic\bvim\blsp\25feline.providers.lsp\vcolors\1\0\0\bget\vthemes\vfeline\frequire\npcall\0" },
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    only_cond = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/feline.nvim",
    url = "git@github.com:feline-nvim/feline.nvim"
  },
  ["fidget.nvim"] = {
    config = { "\27LJ\2\nX\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\ttext\1\0\0\1\0\1\fspinner\tdots\nsetup\vfidget\frequire\0" },
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/fidget.nvim",
    url = "git@github.com:j-hui/fidget.nvim"
  },
  ["filetype.nvim"] = {
    config = { "\27LJ\2\n:\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\rfiletype\frequire\0" },
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/filetype.nvim",
    url = "git@github.com:nathom/filetype.nvim"
  },
  ["friendly-snippets"] = {
    after = { "nvim-cmp" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/friendly-snippets",
    url = "git@github.com:rafamadriz/friendly-snippets"
  },
  ["fzy-lua-native"] = {
    load_after = {
      ["wilder.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/fzy-lua-native",
    url = "git@github.com:romgrk/fzy-lua-native"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\nâ\r\0\0\5\0\28\0\0316\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\14\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\0035\4\f\0=\4\r\3=\3\15\0025\3\16\0005\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\0025\3\26\0=\3\27\2B\0\2\1K\0\1\0\14diff_opts\1\0\1\rinternal\2\28current_line_blame_opts\1\0\2\21virtual_text_pos\beol\ndelay\3Ë\a\17watch_gitdir\1\0\2\17follow_files\2\rinterval\3Ë\a\fkeymaps\22n <LocalLeader>[g\1\2\1\0@&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'\texpr\2\22n <LocalLeader>]g\1\2\1\0@&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'\texpr\2\1\0\f\fnoremap\2\22n <LocalLeader>hb6<cmd>lua require(\"gitsigns\").blame_line(true)<CR>\22v <LocalLeader>hsV<cmd>lua require(\"gitsigns\").stage_hunk({vim.fn.line(\".\"), vim.fn.line(\"v\")})<CR>\vbuffer\2\22n <LocalLeader>hp4<cmd>lua require(\"gitsigns\").preview_hunk()<CR>\22n <LocalLeader>hs2<cmd>lua require(\"gitsigns\").stage_hunk()<CR>\22n <LocalLeader>hR4<cmd>lua require(\"gitsigns\").reset_buffer()<CR>\22v <LocalLeader>hrV<cmd>lua require(\"gitsigns\").reset_hunk({vim.fn.line(\".\"), vim.fn.line(\"v\")})<CR>\22n <LocalLeader>hu7<cmd>lua require(\"gitsigns\").undo_stage_hunk()<CR>\22n <LocalLeader>hr2<cmd>lua require(\"gitsigns\").reset_hunk()<CR>\to ih4:<C-U>lua require(\"gitsigns\").text_object()<CR>\tx ih4:<C-U>lua require(\"gitsigns\").text_object()<CR>\nsigns\1\0\4\23current_line_blame\2\18sign_priority\3\6\14word_diff\1\20update_debounce\3d\17changedelete\1\0\4\ttext\6~\nnumhl\21GitSignsChangeNr\ahl\19GitSignsChange\vlinehl\21GitSignsChangeLn\14topdelete\1\0\4\ttext\b‚Äæ\nnumhl\21GitSignsDeleteNr\ahl\19GitSignsDelete\vlinehl\21GitSignsDeleteLn\vdelete\1\0\4\ttext\6_\nnumhl\21GitSignsDeleteNr\ahl\19GitSignsDelete\vlinehl\21GitSignsDeleteLn\vchange\1\0\4\ttext\b‚îÇ\nnumhl\21GitSignsChangeNr\ahl\19GitSignsChange\vlinehl\21GitSignsChangeLn\badd\1\0\0\1\0\4\ttext\b‚îÇ\nnumhl\18GitSignsAddNr\ahl\16GitSignsAdd\vlinehl\18GitSignsAddLn\nsetup\rgitsigns\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/gitsigns.nvim",
    url = "git@github.com:lewis6991/gitsigns.nvim"
  },
  ["impatient.nvim"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/impatient.nvim",
    url = "git@github.com:lewis6991/impatient.nvim"
  },
  ["indent-blankline.nvim"] = {
    config = { "\27LJ\2\n∏\5\0\0\4\0\16\0\0256\0\0\0009\0\1\0+\1\2\0=\1\2\0006\0\0\0009\0\1\0+\1\2\0=\1\3\0006\0\4\0'\2\5\0B\0\2\0029\0\6\0005\2\a\0005\3\b\0=\3\t\0025\3\n\0=\3\v\0025\3\f\0=\3\r\2B\0\2\0016\0\0\0009\0\14\0'\2\15\0B\0\2\1K\0\1\0001autocmd CursorMoved * IndentBlanklineRefresh\bcmd\21context_patterns\1\15\0\0\nclass\rfunction\vmethod\nblock\17list_literal\rselector\b^if\v^table\17if_statement\nwhile\bfor\ttype\bvar\vimport\20buftype_exclude\1\3\0\0\rterminal\vnofile\21filetype_exclude\1\21\0\0\rstartify\14dashboard\blog\rfugitive\14gitcommit\vpacker\fvimwiki\rmarkdown\tjson\btxt\nvista\thelp\ftodoist\rNvimTree\rpeekaboo\bgit\20TelescopePrompt\rundotree\24flutterToolsOutline\5\1\0\6\25show_current_context\2\25space_char_blankline\6 #show_trailing_blankline_indent\2\28show_first_indent_level\2\tchar\b‚îÇ\31show_current_context_start\2\nsetup\21indent_blankline\frequire\tlist\18termguicolors\bopt\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/indent-blankline.nvim",
    url = "git@github.com:lukas-reineke/indent-blankline.nvim"
  },
  ["jupyter_ascending.vim"] = {
    commands = { "JupyterExecute", "JupyterExecuteAll" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/jupyter_ascending.vim",
    url = "git@github.com:untitled-ai/jupyter_ascending.vim"
  },
  kanagawa = {
    cond = { "\27LJ\2\nL\0\0\1\0\3\0\b6\0\0\0009\0\1\0\6\0\2\0X\0\2Ä+\0\1\0X\1\1Ä+\0\2\0L\0\2\0\rkanagawa\16colorscheme\20__editor_config\0" },
    config = { "\27LJ\2\n⁄\2\0\0\4\0\t\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0004\3\0\0=\3\4\0024\3\0\0=\3\5\2B\0\2\0016\0\6\0009\0\a\0'\2\b\0B\0\2\1K\0\1\0!silent! colorscheme kanagawa\bcmd\bvim\14overrides\vcolors\1\0\v\17commentStyle\vitalic\14undercurl\2\18functionStyle\16bold,italic\17keywordStyle\vitalic\19statementStyle\tbold\14typeStyle\tNONE\25variablebuiltinStyle\vitalic\18specialReturn\2\16transparent\1\16dimInactive\2\21specialException\2\nsetup\rkanagawa\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/kanagawa",
    url = "git@github.com:rebelot/kanagawa.nvim"
  },
  ["lsp_signature.nvim"] = {
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/lsp_signature.nvim",
    url = "git@github.com:ray-x/lsp_signature.nvim"
  },
  ["lspsaga.nvim"] = {
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/lspsaga.nvim",
    url = "git@github.com:tami5/lspsaga.nvim"
  },
  ["lua-dev.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/lua-dev.nvim",
    url = "git@github.com:folke/lua-dev.nvim"
  },
  ["lualine.nvim"] = {
    cond = { "\27LJ\2\nV\0\0\1\0\4\0\t6\0\0\0009\0\1\0009\0\2\0\6\0\3\0X\0\2Ä+\0\1\0X\1\1Ä+\0\2\0L\0\2\0\flualine\15statusline\fplugins\20__editor_config\0" },
    config = { "\27LJ\2\nò\6\0\0\b\0$\0G5\0\t\0005\1\0\0004\2\0\0=\2\1\0014\2\0\0=\2\2\0014\2\0\0=\2\3\0014\2\0\0=\2\4\0015\2\5\0=\2\6\0015\2\a\0=\2\b\1=\1\n\0005\1\v\0=\1\f\0006\1\r\0'\3\14\0B\1\2\0029\1\15\0015\3\20\0005\4\16\0004\5\0\0=\5\17\0045\5\18\0=\5\19\4=\4\21\0035\4\22\0004\5\0\0=\5\1\0044\5\0\0=\5\2\0044\5\0\0=\5\3\0044\5\3\0005\6\23\0005\a\24\0=\a\25\0065\a\26\0=\a\27\6>\6\1\5=\5\4\0045\5\28\0005\6\29\0>\6\5\5=\5\6\0045\5\30\0=\5\b\4=\4\n\0035\4\31\0004\5\0\0=\5\1\0044\5\0\0=\5\2\0044\5\0\0=\5\3\0044\5\0\0=\5\4\0044\5\0\0=\5\6\0044\5\0\0=\5\b\4=\4 \0034\4\0\0=\4!\0035\4\"\0>\0\4\4=\4#\3B\1\2\1K\0\1\0\15extensions\1\4\0\0\rquickfix\15toggleterm\rfugitive\ftabline\22inactive_sections\1\0\0\1\2\0\0\tmode\1\2\1\0\15fileformat\fpadding\3\1\1\5\0\0\rfiletype\vbranch\tdiff\rlocation\fsymbols\1\0\3\twarn\nÔÅ±  \tinfo\tÔÅ™ \nerror\nÔÅó  \fsources\1\2\0\0\20nvim_diagnostic\1\2\0\0\16diagnostics\1\0\0\foptions\1\0\0\23section_separators\1\0\2\nright\6 \tleft\6 \23disabled_filetypes\1\0\3\18icons_enabled\2\ntheme\tauto\25component_separators\6|\nsetup\flualine\frequire\14filetypes\1\2\0\0\fOutline\rsections\1\0\0\14lualine_z\1\2\0\0\tmode\14lualine_y\1\3\0\0\rfiletype\rlocation\14lualine_x\14lualine_c\14lualine_b\14lualine_a\1\0\0\0" },
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/lualine.nvim",
    url = "git@github.com:nvim-lualine/lualine.nvim"
  },
  ["markdown-preview.nvim"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/markdown-preview.nvim",
    url = "git@github.com:iamcco/markdown-preview.nvim"
  },
  ["nvim-autopairs"] = {
    config = { "\27LJ\2\nÅ\2\0\0\n\0\14\1\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\0016\0\0\0'\2\3\0B\0\2\0026\1\0\0'\3\4\0B\1\2\0029\2\5\1\18\4\2\0009\2\6\2'\5\a\0009\6\b\0005\b\n\0005\t\t\0=\t\v\bB\6\2\0A\2\2\0019\2\f\0009\3\f\0\21\3\3\0\22\3\0\3'\4\r\0<\4\3\2K\0\1\0\vracket\tlisp\rmap_char\1\0\0\1\0\1\btex\5\20on_confirm_done\17confirm_done\aon\nevent\bcmp\"nvim-autopairs.completion.cmp\nsetup\19nvim-autopairs\frequire\2\0" },
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-autopairs",
    url = "git@github.com:windwp/nvim-autopairs"
  },
  ["nvim-bufferline.lua"] = {
    config = { "\27LJ\2\n√\3\0\0\6\0\b\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0004\4\3\0005\5\4\0>\5\1\4=\4\5\3=\3\a\2B\0\2\1K\0\1\0\foptions\1\0\0\foffsets\1\0\4\ttext\18File Explorer\rfiletype\rNvimTree\fpadding\3\1\15text_align\vcenter\1\0\14\20max_name_length\3\14\16diagnostics\rnvim_lsp\18modified_icon\b‚ú•\22max_prefix_length\3\r\24show_tab_indicators\2\22buffer_close_icon\bÔôï\rtab_size\3\20\27always_show_bufferline\2\22show_buffer_icons\2\20separator_style\tthin\22left_trunc_marker\bÔÇ®\vnumber\tnone\23right_trunc_marker\bÔÇ©\28show_buffer_close_icons\2\nsetup\15bufferline\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-bufferline.lua",
    url = "git@github.com:akinsho/nvim-bufferline.lua"
  },
  ["nvim-cmp"] = {
    after = { "nvim-autopairs", "LuaSnip" },
    config = { "\27LJ\2\nF\0\1\a\0\3\0\b6\1\0\0009\1\1\0019\1\2\1\18\3\0\0+\4\2\0+\5\2\0+\6\2\0D\1\5\0\27nvim_replace_termcodes\bapi\bvim–\1\0\0\b\0\b\2!6\0\0\0006\2\1\0009\2\2\0029\2\3\2)\4\0\0B\2\2\0A\0\0\3\b\1\0\0X\2\20Ä6\2\1\0009\2\2\0029\2\4\2)\4\0\0\23\5\1\0\18\6\0\0+\a\2\0B\2\5\2:\2\1\2\18\4\2\0009\2\5\2\18\5\1\0\18\6\1\0B\2\4\2\18\4\2\0009\2\6\2'\5\a\0B\2\3\2\n\2\0\0X\2\2Ä+\2\1\0X\3\1Ä+\2\2\0L\2\2\0\a%s\nmatch\bsub\23nvim_buf_get_lines\24nvim_win_get_cursor\bapi\bvim\vunpack\0\2¯\3\0\2\b\0\t\0\0155\2\0\0006\3\2\0009\3\3\3'\5\4\0009\6\1\0018\6\6\0029\a\1\1B\3\4\2=\3\1\0015\3\6\0009\4\a\0009\4\b\0048\3\4\3=\3\5\1L\1\2\0\tname\vsource\1\0\5\rnvim_lua\18[Óò† NvimLua]\tpath\r[~ Path]\vbuffer\14[Ô¨ò Buf]\fluasnip\16[Ôô® LSnip]\rnvim_lsp\14[Óûñ LSP]\tmenu\n%s %s\vformat\vstring\tkind\1\0\25\vStruct\bÔÜ≥\rConstant\bÔ£æ\rOperator\bÔöî\tUnit\bÓàü\fKeyword\bÔ†ä\fSnippet\bÔëè\rProperty\bÔ∞†\14Reference\bÔíÅ\nEvent\bÔÉß\nColor\bÔ£ó\15EnumMember\bÔÖù\vFolder\bÔùä\rVariable\bÔñ†\nField\bÔõº\tFile\bÔúò\nValue\bÔ¢ü\tEnum\bÔÖù\vModule\bÔíá\14Interface\bÔÉ®\16Constructor\bÔê£\rFunction\bÔûî\nClass\bÔ¥Ø\tText\bÓòí\vMethod\bÔö¶\18TypeParameter\bÔô±}\0\1\3\2\3\0\20-\1\0\0009\1\0\1B\1\1\2\15\0\1\0X\2\4Ä-\1\0\0009\1\1\1B\1\1\1X\1\nÄ-\1\1\0B\1\1\2\15\0\1\0X\2\4Ä-\1\0\0009\1\2\1B\1\1\1X\1\2Ä\18\1\0\0B\1\1\1K\0\1\0\2¿\1¿\rcomplete\21select_next_item\fvisibleR\0\1\3\1\2\0\f-\1\0\0009\1\0\1B\1\1\2\15\0\1\0X\2\4Ä-\1\0\0009\1\1\1B\1\1\1X\1\2Ä\18\1\0\0B\1\1\1K\0\1\0\2¿\21select_prev_item\fvisibleõ\1\0\1\6\1\b\0\0206\1\0\0'\3\1\0B\1\2\0029\1\2\1)\3ˇˇB\1\2\2\15\0\1\0X\2\tÄ6\1\3\0009\1\4\0019\1\5\1-\3\0\0'\5\6\0B\3\2\2'\4\a\0B\1\3\1X\1\2Ä\18\1\0\0B\1\1\1K\0\1\0\0¿\5\28<Plug>luasnip-jump-prev\rfeedkeys\afn\bvim\rjumpable\fluasnip\frequire¶\1\0\1\6\1\b\0\0196\1\0\0'\3\1\0B\1\2\0029\1\2\1B\1\1\2\15\0\1\0X\2\tÄ6\1\3\0009\1\4\0019\1\5\1-\3\0\0'\5\6\0B\3\2\2'\4\a\0B\1\3\1X\1\2Ä\18\1\0\0B\1\1\1K\0\1\0\0¿\5!<Plug>luasnip-expand-or-jump\rfeedkeys\afn\bvim\23expand_or_jumpable\fluasnip\frequireC\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\15lsp_expand\fluasnip\frequireî\14\1\0\v\0J\0§\0016\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\0016\0\0\0009\0\1\0'\2\4\0B\0\2\0016\0\0\0009\0\1\0'\2\5\0B\0\2\0016\0\0\0009\0\1\0'\2\6\0B\0\2\0016\0\0\0009\0\1\0'\2\a\0B\0\2\0016\0\0\0009\0\1\0'\2\b\0B\0\2\0016\0\0\0009\0\1\0'\2\t\0B\0\2\0016\0\0\0009\0\1\0'\2\n\0B\0\2\0016\0\0\0009\0\1\0'\2\v\0B\0\2\0016\0\0\0009\0\1\0'\2\f\0B\0\2\0016\0\0\0009\0\1\0'\2\r\0B\0\2\0016\0\0\0009\0\1\0'\2\14\0B\0\2\0013\0\15\0003\1\16\0006\2\17\0'\4\18\0B\2\2\0029\3\19\0025\5!\0005\6\31\0004\a\t\0009\b\20\0029\b\21\b9\b\22\b>\b\1\a9\b\20\0029\b\21\b9\b\23\b>\b\2\a9\b\20\0029\b\21\b9\b\24\b>\b\3\a6\b\17\0'\n\25\0B\b\2\0029\b\26\b>\b\4\a9\b\20\0029\b\21\b9\b\27\b>\b\5\a9\b\20\0029\b\21\b9\b\28\b>\b\6\a9\b\20\0029\b\21\b9\b\29\b>\b\a\a9\b\20\0029\b\21\b9\b\30\b>\b\b\a=\a \6=\6\"\0055\6$\0003\a#\0=\a%\6=\6&\0055\6*\0009\a'\0029\a(\a5\t)\0B\a\2\2=\a+\0069\a'\0029\a,\aB\a\1\2=\a-\0069\a'\0029\a.\aB\a\1\2=\a/\0069\a'\0029\a0\a)\t¸ˇB\a\2\2=\a1\0069\a'\0029\a0\a)\t\4\0B\a\2\2=\a2\0069\a'\0029\a3\aB\a\1\2=\a4\0069\a'\0023\t5\0005\n6\0B\a\3\2=\a7\0069\a'\0023\t8\0005\n9\0B\a\3\2=\a:\0063\a;\0=\a<\0063\a=\0=\a>\6=\6'\0055\6@\0003\a?\0=\aA\6=\6B\0054\6\a\0005\aC\0>\a\1\0065\aD\0>\a\2\0065\aE\0>\a\3\0065\aF\0>\a\4\0065\aG\0>\a\5\0065\aH\0>\a\6\6=\6I\5B\3\2\0012\0\0ÄK\0\1\0\fsources\1\0\1\tname\18latex_symbols\1\0\1\tname\vbuffer\1\0\1\tname\tpath\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lua\1\0\1\tname\rnvim_lsp\fsnippet\vexpand\1\0\0\0\n<C-l>\0\n<C-h>\0\bC-o\1\3\0\0\6i\6s\0\n<Tab>\1\3\0\0\6i\6s\0\n<C-e>\nclose\n<C-f>\n<C-d>\16scroll_docs\n<C-n>\21select_next_item\n<C-p>\21select_prev_item\t<CR>\1\0\0\1\0\1\vselect\2\fconfirm\fmapping\15formatting\vformat\1\0\0\0\fsorting\1\0\0\16comparators\1\0\0\norder\vlength\14sort_text\tkind\nunder\25cmp-under-comparator\nscore\nexact\voffset\fcompare\vconfig\nsetup\bcmp\frequire\0\0!packadd cmp-under-comparator9highlight CmpItemKindMethod guifg=#B48EAD guibg=NONE;highlight CmpItemKindFunction guifg=#B48EAD guibg=NONE7highlight CmpItemKindText guifg=#81A1C1 guibg=NONE<highlight CmpItemKindInterface guifg=#88C0D0 guibg=NONE;highlight CmpItemKindVariable guifg=#8FBCBB guibg=NONE=highlight CmpItemAbbrMatchFuzzy guifg=#5E81AC guibg=NONE8highlight CmpItemAbbrMatch guifg=#5E81AC guibg=NONE:highlight CmpItemKindKeyword guifg=#EBCB8B guibg=NONE;highlight CmpItemKindProperty guifg=#A3BE8C guibg=NONE7highlight CmpItemKindUnit guifg=#D08770 guibg=NONE:highlight CmpItemKindSnippet guifg=#BF616A guibg=NONEOhighlight CmpItemAbbrDeprecated guifg=#D8DEE9 guibg=NONE gui=strikethrough\bcmd\bvim\0" },
    load_after = {
      ["friendly-snippets"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-cmp",
    url = "git@github.com:hrsh7th/nvim-cmp"
  },
  ["nvim-colorizer.lua"] = {
    config = { "\27LJ\2\n;\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\14colorizer\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-colorizer.lua",
    url = "git@github.com:norcalli/nvim-colorizer.lua"
  },
  ["nvim-lightbulb"] = {
    config = { "\27LJ\2\në\4\0\0\5\0\20\0\0316\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0004\4\0\0=\4\t\3=\3\n\0025\3\v\0=\3\f\0025\3\r\0=\3\14\2B\0\2\0016\0\15\0009\0\16\0'\2\17\0B\0\2\0016\0\15\0009\0\16\0'\2\18\0B\0\2\0016\0\15\0009\0\16\0'\2\19\0B\0\2\1K\0\1\0-hi link LightBulbVirtualText YellowFloat*hi link LightBulbFloatWin YellowFloatTautocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()\bcmd\bvim\16status_text\1\0\3\ttext\tüí°\21text_unavailable\5\fenabled\1\17virtual_text\1\0\3\ttext\tüí°\fhl_mode\freplace\fenabled\1\nfloat\rwin_opts\1\0\2\ttext\tüí°\fenabled\1\tsign\1\0\2\rpriority\3\n\fenabled\2\vignore\1\0\0\1\3\0\0\16sumneko_lua\fnull-ls\nsetup\19nvim-lightbulb\frequire\0" },
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-lightbulb",
    url = "git@github.com:kosayoda/nvim-lightbulb"
  },
  ["nvim-lsp-installer"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-lsp-installer",
    url = "git@github.com:williamboman/nvim-lsp-installer"
  },
  ["nvim-lspconfig"] = {
    after = { "lsp_signature.nvim", "nvim-lightbulb", "lspsaga.nvim" },
    config = { "\27LJ\2\n<\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0!modules.completion.lspconfig\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-lspconfig",
    url = "git@github.com:neovim/nvim-lspconfig"
  },
  ["nvim-lsputils"] = {
    config = { "\27LJ\2\nZ\0\3\n\0\3\0\t6\3\0\0'\5\1\0B\3\2\0029\3\2\3+\5\0\0\18\6\2\0,\a\t\0B\3\6\1K\0\1\0\24code_action_handler\23lsputil.codeAction\frequireo\0\3\t\1\5\0\f6\3\0\0'\5\1\0B\3\2\0029\3\2\3+\5\0\0\18\6\2\0005\a\3\0-\b\0\0=\b\4\a+\b\0\0B\3\5\1K\0\1\0\0¿\nbufnr\1\0\0\23references_handler\22lsputil.locations\frequirez\0\3\t\1\6\0\r6\3\0\0'\5\1\0B\3\2\0029\3\2\3+\5\0\0\18\6\2\0005\a\3\0-\b\0\0=\b\4\a=\1\5\a+\b\0\0B\3\5\1K\0\1\0\0¿\vmethod\nbufnr\1\0\0\23definition_handler\22lsputil.locations\frequire{\0\3\t\1\6\0\r6\3\0\0'\5\1\0B\3\2\0029\3\2\3+\5\0\0\18\6\2\0005\a\3\0-\b\0\0=\b\4\a=\1\5\a+\b\0\0B\3\5\1K\0\1\0\0¿\vmethod\nbufnr\1\0\0\24declaration_handler\22lsputil.locations\frequire~\0\3\t\1\6\0\r6\3\0\0'\5\1\0B\3\2\0029\3\2\3+\5\0\0\18\6\2\0005\a\3\0-\b\0\0=\b\4\a=\1\5\a+\b\0\0B\3\5\1K\0\1\0\0¿\vmethod\nbufnr\1\0\0\27typeDefinition_handler\22lsputil.locations\frequire~\0\3\t\1\6\0\r6\3\0\0'\5\1\0B\3\2\0029\3\2\3+\5\0\0\18\6\2\0005\a\3\0-\b\0\0=\b\4\a=\1\5\a+\b\0\0B\3\5\1K\0\1\0\0¿\vmethod\nbufnr\1\0\0\27implementation_handler\22lsputil.locations\frequiree\0\5\v\0\5\0\v6\5\0\0'\a\1\0B\5\2\0029\5\2\5+\a\0\0\18\b\2\0005\t\3\0=\4\4\t+\n\0\0B\5\5\1K\0\1\0\nbufnr\1\0\0\21document_handler\20lsputil.symbols\frequiref\0\5\v\0\5\0\v6\5\0\0'\a\1\0B\5\2\0029\5\2\5+\a\0\0\18\b\2\0005\t\3\0=\4\4\t+\n\0\0B\5\5\1K\0\1\0\nbufnr\1\0\0\22workspace_handler\20lsputil.symbols\frequireÅ\b\1\0\4\0'\1{6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\3\0009\0\4\0'\2\5\0B\0\2\2\t\0\0\0X\0AÄ6\0\0\0009\0\6\0009\0\a\0006\1\t\0'\3\n\0B\1\2\0029\1\v\1=\1\b\0006\0\0\0009\0\6\0009\0\a\0006\1\t\0'\3\r\0B\1\2\0029\1\14\1=\1\f\0006\0\0\0009\0\6\0009\0\a\0006\1\t\0'\3\r\0B\1\2\0029\1\16\1=\1\15\0006\0\0\0009\0\6\0009\0\a\0006\1\t\0'\3\r\0B\1\2\0029\1\18\1=\1\17\0006\0\0\0009\0\6\0009\0\a\0006\1\t\0'\3\r\0B\1\2\0029\1\20\1=\1\19\0006\0\0\0009\0\6\0009\0\a\0006\1\t\0'\3\r\0B\1\2\0029\1\22\1=\1\21\0006\0\0\0009\0\6\0009\0\a\0006\1\t\0'\3\24\0B\1\2\0029\1\25\1=\1\23\0006\0\0\0009\0\6\0009\0\a\0006\1\t\0'\3\24\0B\1\2\0029\1\27\1=\1\26\0X\0.Ä6\0\0\0009\0\28\0009\0\29\0)\2\0\0B\0\2\0026\1\0\0009\1\6\0019\1\a\0013\2\30\0=\2\b\0016\1\0\0009\1\6\0019\1\a\0013\2\31\0=\2\f\0016\1\0\0009\1\6\0019\1\a\0013\2 \0=\2\15\0016\1\0\0009\1\6\0019\1\a\0013\2!\0=\2\17\0016\1\0\0009\1\6\0019\1\a\0013\2\"\0=\2\19\0016\1\0\0009\1\6\0019\1\a\0013\2#\0=\2\21\0016\1\0\0009\1\6\0019\1\a\0013\2$\0=\2\23\0016\1\0\0009\1\6\0019\1\a\0013\2&\0=\2%\0012\0\0ÄK\0\1\0\0\24textDocument/symbol\0\0\0\0\0\0\0\24nvim_buf_get_number\bapi\22workspace_handler\21workspace/symbol\21document_handler\20lsputil.symbols textDocument/documentSymbol\27implementation_handler textDocument/implementation\27typeDefinition_handler textDocument/typeDefinition\24declaration_handler\29textDocument/declaration\23definition_handler\28textDocument/definition\23references_handler\22lsputil.locations\28textDocument/references\24code_action_handler\23lsputil.codeAction\frequire\28textDocument/codeAction\rhandlers\blsp\15nvim-0.5.1\bhas\afn\20packadd lsputil\bcmd\bvim\2\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-lsputils",
    url = "git@github.com:RishabhRD/nvim-lsputils"
  },
  ["nvim-spectre"] = {
    config = { "\27LJ\2\n©\17\0\0\a\0;\0E6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\a\0005\4\6\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\20\0035\4\21\0=\4\22\0035\4\23\0=\4\24\0035\4\25\0=\4\26\3=\3\27\0025\3%\0005\4\28\0005\5\29\0=\5\30\0045\5 \0005\6\31\0=\6!\0055\6\"\0=\6#\5=\5$\4=\4&\0035\4'\0005\5(\0=\5\30\0045\5*\0005\6)\0=\6!\0055\6+\0=\6#\5=\5$\4=\4,\3=\3-\0025\3/\0005\4.\0=\0040\0035\0042\0005\0051\0=\5!\4=\4$\3=\0033\0025\0036\0005\0044\0005\0055\0=\5$\4=\0047\0035\0048\0=\0049\3=\3:\2B\0\2\1K\0\1\0\fdefault\freplace\1\0\1\bcmd\bsed\tfind\1\0\0\1\2\0\0\16ignore-case\1\0\1\bcmd\arg\19replace_engine\1\0\0\1\0\3\tdesc\16ignore case\nvalue\18--ignore-case\ticon\b[I]\bsed\1\0\0\1\0\1\bcmd\bsed\16find_engine\aag\1\0\3\tdesc\16hidden file\nvalue\r--hidden\ticon\b[H]\1\0\0\1\0\3\tdesc\16ignore case\nvalue\a-i\ticon\b[I]\1\3\0\0\14--vimgrep\a-s\1\0\1\bcmd\aag\arg\1\0\0\foptions\vhidden\1\0\3\tdesc\16hidden file\nvalue\r--hidden\ticon\b[H]\16ignore-case\1\0\0\1\0\3\tdesc\16ignore case\nvalue\18--ignore-case\ticon\b[I]\targs\1\6\0\0\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\1\0\1\bcmd\arg\fmapping\25toggle_ignore_hidden\1\0\3\tdesc\25toggle search hidden\bmap\ath\bcmd=<cmd>lua require('spectre').change_options('hidden')<CR>\23toggle_ignore_case\1\0\3\tdesc\23toggle ignore case\bmap\ati\bcmdB<cmd>lua require('spectre').change_options('ignore-case')<CR>\23toggle_live_update\1\0\3\tdesc'update change when vim write file.\bmap\atu\bcmd9<cmd>lua require('spectre').toggle_live_update()<CR>\21change_view_mode\1\0\3\tdesc\28change result view mode\bmap\14<leader>v\bcmd2<cmd>lua require('spectre').change_view()<CR>\16run_replace\1\0\3\tdesc\16replace all\bmap\14<leader>R\bcmd:<cmd>lua require('spectre.actions').run_replace()<CR>\21show_option_menu\1\0\3\tdesc\16show option\bmap\14<leader>o\bcmd3<cmd>lua require('spectre').show_options()<CR>\16replace_cmd\1\0\3\tdesc\30input replace vim command\bmap\14<leader>c\bcmd:<cmd>lua require('spectre.actions').replace_cmd()<CR>\15send_to_qf\1\0\3\tdesc\30send all item to quickfix\bmap\14<leader>q\bcmd9<cmd>lua require('spectre.actions').send_to_qf()<CR>\15enter_file\1\0\3\tdesc\22goto current file\bmap\t<cr>\bcmd;<cmd>lua require('spectre.actions').select_entry()<CR>\16toggle_line\1\0\0\1\0\3\tdesc\24toggle current item\bmap\add\bcmd2<cmd>lua require('spectre').toggle_line()<CR>\14highlight\1\0\3\vsearch\15DiffChange\freplace\15DiffDelete\aui\vString\1\0\t\19line_sep_start1‚îå-----------------------------------------\23is_open_target_win\2\ropen_cmd\tvnew\20replace_vim_cmd\bcdo\19is_insert_mode\1\16live_update\1\19result_padding\t¬¶  \19color_devicons\2\rline_sep1‚îî-----------------------------------------\nsetup\fspectre\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-spectre",
    url = "git@github.com:windwp/nvim-spectre"
  },
  ["nvim-tmux-navigation"] = {
    cond = { "\27LJ\2\nV\0\0\3\0\4\1\v6\0\0\0009\0\1\0009\0\2\0'\2\3\0B\0\2\2\t\0\0\0X\0\2Ä+\0\1\0X\1\1Ä+\0\2\0L\0\2\0\20exists(\"$TMUX\")\14nvim_eval\bapi\bvim\0\0" },
    config = { "\27LJ\2\n^\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\1\24disable_when_zoomed\2\nsetup\25nvim-tmux-navigation\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-tmux-navigation",
    url = "git@github.com:alexghergh/nvim-tmux-navigation"
  },
  ["nvim-toggleterm.lua"] = {
    config = { "\27LJ\2\ny\0\1\2\0\6\1\0159\1\0\0\a\1\1\0X\1\3Ä)\1\15\0L\1\2\0X\1\bÄ9\1\0\0\a\1\2\0X\1\5Ä6\1\3\0009\1\4\0019\1\5\1\24\1\0\1L\1\2\0K\0\1\0\fcolumns\6o\bvim\rvertical\15horizontal\14directionµÊÃô\19ô≥Ê˛\3ñ\2\1\0\4\0\n\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\0024\3\0\0=\3\6\0026\3\a\0009\3\b\0039\3\t\3=\3\t\2B\0\2\1K\0\1\0\nshell\6o\bvim\20shade_filetypes\tsize\1\0\t\20insert_mappings\2\19shading_factor\0061\17hide_numbers\2\20start_in_insert\2\14direction\rvertical\18close_on_exit\2\20shade_terminals\1\17persist_size\2\17open_mapping\n<C-t>\0\nsetup\15toggleterm\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-toggleterm.lua",
    url = "git@github.com:akinsho/nvim-toggleterm.lua"
  },
  ["nvim-tree.lua"] = {
    commands = { "NvimTreeToggle", "NvimTreeOpen" },
    config = { "\27LJ\2\n¶\6\0\0\b\0$\0.6\0\0\0009\0\1\0006\1\3\0009\1\4\0015\3\5\0006\4\6\0009\4\a\4'\6\b\0)\aË\3B\4\3\2>\4\2\3B\1\2\2=\1\2\0006\0\t\0'\2\n\0B\0\2\0029\0\v\0005\2\f\0005\3\r\0=\3\14\0025\3\15\0=\3\16\0025\3\17\0005\4\18\0=\4\19\3=\3\20\0025\3\21\0004\4\0\0=\4\22\3=\3\23\0025\3\24\0004\4\0\0=\4\25\3=\3\26\0025\3\27\0004\4\0\0=\4\28\3=\3\29\0025\3\30\0=\3\31\0025\3 \0=\3!\0025\3\"\0=\3#\2B\0\2\1K\0\1\0\ntrash\1\0\2\20require_confirm\2\bcmd\brip\tview\1\0\6\15signcolumn\byes\16auto_resize\1\tside\tleft\21hide_root_folder\2\nwidth\3\30\vheight\3\30\bgit\1\0\3\ftimeout\3Ù\3\vignore\2\venable\2\ffilters\vcustom\1\0\1\rdotfiles\1\16system_open\targs\1\0\0\24update_focused_file\16ignore_list\1\0\2\15update_cwd\2\venable\2\16diagnostics\nicons\1\0\4\fwarning\bÔÅ±\tinfo\bÔÅö\thint\bÔÅ™\nerror\bÔÅó\1\0\1\venable\1\22update_to_buf_dir\1\0\2\14auto_open\2\venable\2\23ignore_ft_on_setup\1\2\0\0\14dashboard\1\0\a\18hijack_cursor\2\18disable_netrw\2\17hijack_netrw\2\18open_on_setup\1\16open_on_tab\1\15update_cwd\1\21hide_root_folder\2\nsetup\14nvim-tree\frequire\6 \brep\vstring\1\4\0\0\16:t:gs?$?/..\0\r?:gs?^??\vconcat\ntable#nvim_tree_root_folder_modifier\6g\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-tree.lua",
    url = "git@github.com:kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    after = { "feline.nvim", "fidget.nvim", "nvim-ts-autotag", "lualine.nvim", "nvim-treesitter-context", "nvim-ts-context-commentstring", "nvim-ts-hint-textobject", "vim-matchup", "nvim-treesitter-textobjects", "zen-mode.nvim" },
    config = { "\27LJ\2\nb\0\2\5\0\4\1\14\a\0\0\0X\2\bÄ6\2\1\0009\2\2\0029\2\3\2\18\4\1\0B\2\2\2*\3\0\0\0\3\2\0X\2\2Ä+\2\1\0X\3\1Ä+\2\2\0L\2\2\0\24nvim_buf_line_count\bapi\bvim\bcpp†ç\6™\b\1\0\6\0,\00076\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\0016\0\4\0'\2\5\0B\0\2\0029\0\6\0005\2\b\0005\3\a\0=\3\t\0025\3\n\0005\4\v\0=\4\f\3=\3\r\0025\3\14\0003\4\15\0=\4\16\3=\3\17\0025\3\18\0=\3\19\0025\3\20\0=\3\21\0025\3\22\0=\3\23\0025\3\24\0005\4\25\0005\5\26\0=\5\f\4=\4\27\0035\4\28\0005\5\29\0=\5\30\0045\5\31\0=\5 \0045\5!\0=\5\"\0045\5#\0=\5$\4=\4%\3=\3&\2B\0\2\0016\0\4\0'\2'\0B\0\2\0029\0(\0B\0\1\0029\1)\0'\2+\0=\2*\1K\0\1\0\tocto\27filetype_to_parsername\rmarkdown\23get_parser_configs\28nvim-treesitter.parsers\16textobjects\tmove\22goto_previous_end\1\0\2\a[M\20@function.outer\a[]\17@class.outer\24goto_previous_start\1\0\2\a[m\20@function.outer\a[[\17@class.outer\18goto_next_end\1\0\2\a][\17@class.outer\a]M\20@function.outer\20goto_next_start\1\0\2\a]]\17@class.outer\a]m\20@function.outer\1\0\2\14set_jumps\2\venable\2\vselect\1\0\4\aif\20@function.inner\aic\17@class.inner\aac\17@class.outer\aaf\20@function.outer\1\0\1\venable\2\1\0\1\venable\2\fcontext\1\0\2\rthrottle\2\venable\2\fmatchup\1\0\1\venable\2\26context_commentstring\1\0\2\19enable_autocmd\1\venable\2\14highlight\fdisable\0\1\0\1\venable\2\26incremental_selection\fkeymaps\1\0\4\22scope_incremental\bgrc\19init_selection\bgnn\21node_decremental\bgrm\21node_incremental\bgrn\1\0\1\venable\2\21ensure_installed\1\0\0\1\4\0\0\vpython\ago\blua\nsetup\28nvim-treesitter.configs\frequire,set foldexpr=nvim_treesitter#foldexpr()\24set foldmethod=expr\bcmd\bvim\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-treesitter",
    url = "git@github.com:nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-context"] = {
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-context",
    url = "git@github.com:romgrk/nvim-treesitter-context"
  },
  ["nvim-treesitter-textobjects"] = {
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-textobjects",
    url = "git@github.com:nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["nvim-ts-autotag"] = {
    config = { "\27LJ\2\ní\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\14filetypes\1\0\0\1\a\0\0\thtml\bxml\15javascript\20typescriptreact\20javascriptreact\bvue\nsetup\20nvim-ts-autotag\frequire\0" },
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-ts-autotag",
    url = "git@github.com:windwp/nvim-ts-autotag"
  },
  ["nvim-ts-context-commentstring"] = {
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-ts-context-commentstring",
    url = "git@github.com:JoosepAlviste/nvim-ts-context-commentstring"
  },
  ["nvim-ts-hint-textobject"] = {
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-ts-hint-textobject",
    url = "git@github.com:mfussenegger/nvim-ts-hint-textobject"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "git@github.com:kyazdani42/nvim-web-devicons"
  },
  ["octo.nvim"] = {
    commands = { "Octo" },
    config = { "\27LJ\2\nÜ\20\0\0\5\0\21\0\0256\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\t\0005\4\b\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\a\3=\3\20\2B\0\2\1K\0\1\0\rmappings\1\0\n\15next_entry\6j\17select_entry\t<cr>\15prev_entry\6k\18toggle_viewed\20<leader><space>\17toggle_files\14<leader>b\16focus_files\14<leader>e\22select_next_entry\a]q\21close_review_tab\n<C-c>\18refresh_files\6R\22select_prev_entry\a[q\16review_diff\1\0\n\23add_review_comment\14<space>ca\16next_thread\a]t\18toggle_viewed\20<leader><space>\17toggle_files\14<leader>b\16focus_files\14<leader>e\16prev_thread\a[t\22select_next_entry\a]q\21close_review_tab\n<C-c>\26add_review_suggestion\14<space>sa\22select_prev_entry\a[q\15submit_win\1\0\4\21close_review_tab\n<C-c>\20request_changes\n<C-r>\19approve_review\n<C-a>\19comment_review\n<C-m>\18review_thread\1\0\17\19delete_comment\14<space>cd\17prev_comment\a[c\16add_comment\14<space>ca\15goto_issue\14<space>gi\19react_confused\14<space>rc\16react_laugh\14<space>rl\17react_rocket\14<space>rr\22react_thumbs_down\14<space>r-\20react_thumbs_up\14<space>r+\15react_eyes\14<space>re\19add_suggestion\14<space>sa\16react_heart\14<space>rh\17react_hooray\14<space>rp\22select_next_entry\a]q\21close_review_tab\n<C-c>\17next_comment\a]c\22select_prev_entry\a[q\17pull_request\1\0\31\19delete_comment\14<space>cd\17list_commits\14<space>pc\20open_in_browser\n<C-b>\16list_issues\14<space>il\20react_thumbs_up\14<space>r+\rmerge_pr\14<space>pm\22react_thumbs_down\14<space>r-\16add_comment\14<space>ca\17react_rocket\14<space>rr\14add_label\14<space>la\16react_laugh\14<space>rl\17create_label\14<space>lc\vreload\n<C-r>\20remove_assignee\14<space>ad\19react_confused\14<space>rc\17add_assignee\14<space>aa\17remove_label\14<space>ld\rcopy_url\n<C-y>\15goto_issue\14<space>gi\17reopen_issue\14<space>io\16checkout_pr\14<space>po\15react_eyes\14<space>re\16close_issue\14<space>ic\16react_heart\14<space>rh\20remove_reviewer\14<space>vd\17react_hooray\14<space>rp\17add_reviewer\14<space>va\17prev_comment\a[c\17show_pr_diff\14<space>pd\17next_comment\a]c\23list_changed_files\14<space>pf\nissue\1\0\0\1\0\24\19delete_comment\14<space>cd\20open_in_browser\n<C-b>\20react_thumbs_up\14<space>r+\16list_issues\14<space>il\22react_thumbs_down\14<space>r-\17react_rocket\14<space>rr\16react_laugh\14<space>rl\17remove_label\14<space>ld\19react_confused\14<space>rc\14add_label\14<space>la\15goto_issue\14<space>gi\17create_label\14<space>lc\vreload\n<C-r>\20remove_assignee\14<space>ad\16add_comment\14<space>ca\17add_assignee\14<space>aa\rcopy_url\n<C-y>\17reopen_issue\14<space>io\15react_eyes\14<space>re\16close_issue\14<space>ic\16react_heart\14<space>rh\17react_hooray\14<space>rp\17prev_comment\a[c\17next_comment\a]c\15file_panel\1\0\2\tsize\3\n\14use_icons\2\19default_remote\1\0\b\20timeline_indent\0062\27right_bubble_delimiter\bÓÇ¥\20timeline_marker\bÔë†\20github_hostname\5\26left_bubble_delimiter\bÓÇ∂\30reaction_viewer_hint_icon\bÔëÑ\26snippet_context_lines\3\4\14user_icon\tÔäΩ \1\3\0\0\rupstream\vorigin\nsetup\tocto\frequire\0" },
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/octo.nvim",
    url = "git@github.com:pwntester/octo.nvim"
  },
  ["packer.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/packer.nvim",
    url = "git@github.com:wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "git@github.com:nvim-lua/plenary.nvim"
  },
  popfix = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/popfix",
    url = "git@github.com:RishabhRD/popfix"
  },
  ["rose-pine"] = {
    cond = { "\27LJ\2\nM\0\0\1\0\3\0\b6\0\0\0009\0\1\0\6\0\2\0X\0\2Ä+\0\1\0X\1\1Ä+\0\2\0L\0\2\0\14rose-pine\16colorscheme\20__editor_config\0" },
    config = { "\27LJ\2\n∆\3\0\0\5\0\v\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\3=\3\a\2B\0\2\0016\0\b\0009\0\t\0'\2\n\0B\0\2\1K\0\1\0\"silent! colorscheme rose-pine\bcmd\bvim\vgroups\rheadings\1\0\6\ah4\tgold\ah2\tfoam\ah6\tfoam\ah1\tiris\ah3\trose\ah5\tpine\1\0\n\16punctuation\vsubtle\tinfo\tfoam\fcomment\nmuted\15background\tbase\nerror\tlove\npanel\fsurface\vborder\18highlight_med\twarn\tgold\tlink\tiris\thint\tiris\1\0\6\17dark_variant\tdawn\20bold_vert_split\1\22dim_nc_background\1\23disable_background\1\29disable_float_background\1\20disable_italics\1\nsetup\14rose-pine\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/rose-pine",
    url = "git@github.com:rose-pine/neovim"
  },
  ["rust-tools.nvim"] = {
    config = { "\27LJ\2\n≈\5\0\0\5\0\24\0&5\0\18\0005\1\0\0005\2\1\0=\2\2\0015\2\3\0=\2\4\0015\2\5\0=\2\6\0015\2\15\0004\3\t\0005\4\a\0>\4\1\0035\4\b\0>\4\2\0035\4\t\0>\4\3\0035\4\n\0>\4\4\0035\4\v\0>\4\5\0035\4\f\0>\4\6\0035\4\r\0>\4\a\0035\4\14\0>\4\b\3=\3\16\2=\2\17\1=\1\19\0004\1\0\0=\1\20\0006\1\21\0'\3\22\0B\1\2\0029\1\23\1\18\3\0\0B\1\2\1K\0\1\0\nsetup\15rust-tools\frequire\vserver\ntools\1\0\0\18hover_actions\vborder\1\0\1\15auto_focus\1\1\3\0\0\b‚îÇ\16FloatBorder\1\3\0\0\b‚ï∞\16FloatBorder\1\3\0\0\b‚îÄ\16FloatBorder\1\3\0\0\b‚ïØ\16FloatBorder\1\3\0\0\b‚îÇ\16FloatBorder\1\3\0\0\b‚ïÆ\16FloatBorder\1\3\0\0\b‚îÄ\16FloatBorder\1\3\0\0\b‚ï≠\16FloatBorder\16inlay_hints\1\0\t\24right_align_padding\3\a\22only_current_line\1\16right_align\1\27parameter_hints_prefix\b<- \26max_len_align_padding\3\1\30only_current_line_autocmd\15CursorHold\25show_parameter_hints\2\23other_hints_prefix\t ¬ª \18max_len_align\1\16debuggables\1\0\1\18use_telescope\2\14runnables\1\0\1\18use_telescope\2\1\0\2\17autoSetHints\2\23hover_with_actions\2\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/rust-tools.nvim",
    url = "git@github.com:simrat39/rust-tools.nvim"
  },
  ["sqlite.lua"] = {
    load_after = {
      ["telescope-frecency.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/sqlite.lua",
    url = "git@github.com:tami5/sqlite.lua"
  },
  ["symbols-outline.nvim"] = {
    commands = { "SymbolsOutline", "SymbolsOutlineOpen" },
    config = { "\27LJ\2\nô\v\0\0\5\0=\0A6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0024\3\0\0=\3\6\0025\3\b\0005\4\a\0=\4\t\0035\4\n\0=\4\v\0035\4\f\0=\4\r\0035\4\14\0=\4\15\0035\4\16\0=\4\17\0035\4\18\0=\4\19\0035\4\20\0=\4\21\0035\4\22\0=\4\23\0035\4\24\0=\4\25\0035\4\26\0=\4\27\0035\4\28\0=\4\29\0035\4\30\0=\4\31\0035\4 \0=\4!\0035\4\"\0=\4#\0035\4$\0=\4%\0035\4&\0=\4'\0035\4(\0=\4)\0035\4*\0=\4+\0035\4,\0=\4-\0035\4.\0=\4/\0035\0040\0=\0041\0035\0042\0=\0043\0035\0044\0=\0045\0035\0046\0=\0047\0035\0048\0=\0049\0035\4:\0=\4;\3=\3<\2B\0\2\1K\0\1\0\fsymbols\18TypeParameter\1\0\2\ahl\16TSParameter\ticon\tùôè\rOperator\1\0\2\ahl\15TSOperator\ticon\6+\nEvent\1\0\2\ahl\vTSType\ticon\tüó≤\vStruct\1\0\2\ahl\vTSType\ticon\tùì¢\15EnumMember\1\0\2\ahl\fTSField\ticon\bÔÖù\tNull\1\0\2\ahl\vTSType\ticon\tNULL\bKey\1\0\2\ahl\vTSType\ticon\tüîê\vObject\1\0\2\ahl\vTSType\ticon\b‚¶ø\nArray\1\0\2\ahl\15TSConstant\ticon\bÔô©\fBoolean\1\0\2\ahl\14TSBoolean\ticon\b‚ä®\vNumber\1\0\2\ahl\rTSNumber\ticon\6#\vString\1\0\2\ahl\rTSString\ticon\tùìê\rConstant\1\0\2\ahl\15TSConstant\ticon\bÓà¨\rVariable\1\0\2\ahl\15TSConstant\ticon\bÓûõ\rFunction\1\0\2\ahl\15TSFunction\ticon\bÔÇö\14Interface\1\0\2\ahl\vTSType\ticon\bÔ∞Æ\tEnum\1\0\2\ahl\vTSType\ticon\b‚Ñ∞\16Constructor\1\0\2\ahl\18TSConstructor\ticon\bÓàè\nField\1\0\2\ahl\fTSField\ticon\bÔöß\rProperty\1\0\2\ahl\rTSMethod\ticon\bÓò§\vMethod\1\0\2\ahl\rTSMethod\ticon\a∆í\nClass\1\0\2\ahl\vTSType\ticon\tùìí\fPackage\1\0\2\ahl\16TSNamespace\ticon\bÔ£ñ\14Namespace\1\0\2\ahl\16TSNamespace\ticon\bÔô©\vModule\1\0\2\ahl\16TSNamespace\ticon\bÔö¶\tFile\1\0\0\1\0\2\ahl\nTSURI\ticon\bÔúì\18lsp_blacklist\fkeymaps\1\0\6\18rename_symbol\6r\17code_actions\6a\18goto_location\t<Cr>\nclose\n<Esc>\19focus_location\6o\17hover_symbol\14<C-space>\1\0\t\rposition\nright\nwidth\3\30\17auto_preview\2\27highlight_hovered_item\2\16show_guides\2\17show_numbers\2\26show_relative_numbers\2\24show_symbol_details\2\25preview_bg_highlight\nPmenu\nsetup\20symbols-outline\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/symbols-outline.nvim",
    url = "git@github.com:simrat39/symbols-outline.nvim"
  },
  ["telekasten.nvim"] = {
    after = { "calendar-vim" },
    config = { "\27LJ\2\nÃ\a\0\0\t\0\25\0A6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\3\0009\0\4\0006\1\3\0009\1\5\1'\2\6\0&\0\2\0006\1\a\0'\3\b\0B\1\2\0029\1\t\0015\3\n\0=\0\v\3\18\4\0\0006\5\3\0009\5\5\5'\6\f\0&\4\6\4=\4\r\3\18\4\0\0006\5\3\0009\5\5\5'\6\14\0&\4\6\4=\4\15\3\18\4\0\0006\5\3\0009\5\5\5'\6\16\0&\4\6\4=\4\16\0035\4\17\0=\4\18\3\18\4\0\0006\5\3\0009\5\5\5'\6\16\0006\a\3\0009\a\5\a'\b\19\0&\4\b\4=\4\20\3\18\4\0\0006\5\3\0009\5\5\5'\6\16\0006\a\3\0009\a\5\a'\b\21\0&\4\b\4=\4\22\3\18\4\0\0006\5\3\0009\5\5\5'\6\16\0006\a\3\0009\a\5\a'\b\23\0&\4\b\4=\4\24\3B\1\2\1K\0\1\0\24template_new_weekly\14weekly.md\23template_new_daily\rdaily.md\22template_new_note\16new_note.md\18calendar_opts\1\0\3\20calendar_monday\3\1\18calendar_mark\rleft-fit\vweeknm\3\4\14templates\rweeklies\vweekly\fdailies\ndaily\thome\1\0\18\22new_note_location\nsmart\24rename_update_links\2\26command_palette_theme\bivy\27insert_after_inserting\2\31follow_creates_nonexisting\2\31dailies_create_nonexisting\2 weeklies_create_nonexisting\2\23plug_into_calendar\2\22take_over_my_home\2\22auto_set_filetype\2\17image_subdir\vimages\21image_link_style\rmarkdown\24close_after_yanking\1\17tag_notation\t#tag\14extension\b.md\20show_tags_theme\bivy\21subdirs_in_links\2\22template_handling\nsmart\nsetup\15telekasten\frequire\17zettelkasten\rpath_sep\rvim_path\20__editor_global\27 packadd calendar-vim \bcmd\bvim\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telekasten.nvim",
    url = "git@github.com:renerocksai/telekasten.nvim"
  },
  ["telescope-emoji.nvim"] = {
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope-emoji.nvim",
    url = "git@github.com:xiyaowong/telescope-emoji.nvim"
  },
  ["telescope-file-browser.nvim"] = {
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope-file-browser.nvim",
    url = "git@github.com:nvim-telescope/telescope-file-browser.nvim"
  },
  ["telescope-frecency.nvim"] = {
    after = { "sqlite.lua" },
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope-frecency.nvim",
    url = "git@github.com:nvim-telescope/telescope-frecency.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope-fzf-native.nvim",
    url = "git@github.com:nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope-ui-select.nvim"] = {
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope-ui-select.nvim",
    url = "git@github.com:nvim-telescope/telescope-ui-select.nvim"
  },
  ["telescope.nvim"] = {
    after = { "telescope-file-browser.nvim", "telescope-fzf-native.nvim", "telescope-ui-select.nvim", "octo.nvim", "telescope-frecency.nvim", "telescope-emoji.nvim", "cheatsheet.nvim" },
    commands = { "Telescope" },
    config = { "\27LJ\2\nƒ\v\0\0\6\0006\1{6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\0016\0\0\0009\0\1\0'\2\4\0B\0\2\0016\0\0\0009\0\1\0'\2\5\0B\0\2\0016\0\0\0009\0\1\0'\2\6\0B\0\2\0016\0\0\0009\0\1\0'\2\a\0B\0\2\0015\0$\0005\1\b\0005\2\n\0005\3\t\0=\3\v\0025\3\f\0=\3\r\2=\2\14\0016\2\15\0'\4\16\0B\2\2\0029\2\17\0029\2\18\2=\2\19\0016\2\15\0'\4\16\0B\2\2\0029\2\20\0029\2\18\2=\2\21\0016\2\15\0'\4\16\0B\2\2\0029\2\22\0029\2\18\2=\2\23\0016\2\15\0'\4\24\0B\2\2\0029\2\25\2=\2\26\0015\2\27\0=\2\28\0016\2\15\0'\4\24\0B\2\2\0029\2\29\2=\2\30\0015\2\31\0=\2 \0014\2\0\0=\2!\0015\2\"\0=\2#\1=\1%\0005\1(\0004\2\3\0006\3\15\0'\5&\0B\3\2\0029\3'\0034\5\0\0B\3\2\0?\3\0\0=\2)\0015\2*\0=\2+\0015\2,\0005\3-\0=\3.\2=\2/\1=\0010\0006\1\15\0'\0031\0B\1\2\0029\0012\1\18\3\0\0B\1\2\0016\1\15\0'\0031\0B\1\2\0029\0013\1'\3+\0B\1\2\0016\1\15\0'\0031\0B\1\2\0029\0013\1'\3/\0B\1\2\0016\1\15\0'\0031\0B\1\2\0029\0013\1'\3)\0B\1\2\0016\1\15\0'\0031\0B\1\2\0029\0013\1'\0034\0B\1\2\0016\1\15\0'\0031\0B\1\2\0029\0013\1'\0035\0B\1\2\1K\0\1\0\nemoji\17file_browser\19load_extension\nsetup\14telescope\15extensions\rfrecency\20ignore_patterns\1\3\0\0\f*.git/*\f*/tmp/*\1\0\2\16show_scores\2\19show_unindexed\2\bfzf\1\0\4\nfuzzy\1\28override_generic_sorter\2\25override_file_sorter\2\14case_mode\15smart_case\14ui-select\1\0\0\17get_dropdown\21telescope.themes\rdefaults\1\0\0\fset_env\1\0\1\14COLORTERM\14truecolor\vborder\17path_display\1\2\0\0\rabsolute\19generic_sorter\29get_generic_fuzzy_sorter\25file_ignore_patterns\1\2\0\0\24packer_compiled.lua\16file_sorter\19get_fuzzy_file\22telescope.sorters\21qflist_previewer\22vim_buffer_qflist\19grep_previewer\23vim_buffer_vimgrep\19file_previewer\bnew\19vim_buffer_cat\25telescope.previewers\frequire\18layout_config\rvertical\1\0\1\vmirror\1\15horizontal\1\0\0\1\0\2\20prompt_position\vbottom\18results_width\4≥ÊÃô\3≥Êåˇ\3\1\0\5\rwinblend\3\0\20selection_caret\b¬ª \19color_devicons\2\18prompt_prefix\nüî≠ \ruse_less\2%packadd telescope-ui-select.nvim!packadd telescope-emoji.nvim$packadd telescope-frecency.nvim(packadd telescope-file-browser.nvim&packadd telescope-fzf-native.nvim\23packadd sqlite.lua\bcmd\bvim\3ÄÄ¿ô\4\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope.nvim",
    url = "git@github.com:nvim-telescope/telescope.nvim"
  },
  tokyonight = {
    cond = { "\27LJ\2\nN\0\0\1\0\3\0\b6\0\0\0009\0\1\0\6\0\2\0X\0\2Ä+\0\1\0X\1\1Ä+\0\2\0L\0\2\0\15tokyonight\16colorscheme\20__editor_config\0" },
    config = { "\27LJ\2\n”\1\0\0\4\0\t\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\2B\0\2\0016\0\6\0009\0\a\0'\2\b\0B\0\2\1K\0\1\0\21color tokyonight\bcmd\bvim\24tokyonight_sidebars\1\3\0\0\rterminal\vpacker\1\0\2 tokyonight_italic_functions\2\21tokyonight_style\nstorm\nsetup\22tokyonight.colors\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/tokyonight",
    url = "git@github.com:folke/tokyonight.nvim"
  },
  ["trouble.nvim"] = {
    commands = { "Trouble", "TroubleToggle", "TroubleRefresh" },
    config = { "\27LJ\2\nõ\5\0\0\5\0\24\0\0276\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\2B\0\2\1K\0\1\0\nsigns\1\0\5\nother\bÔ´†\16information\bÔëâ\fwarning\bÔî©\nerror\bÔôô\thint\bÔ†µ\16action_keys\16toggle_fold\1\3\0\0\azA\aza\15open_folds\1\3\0\0\azR\azr\16close_folds\1\3\0\0\azM\azm\15jump_close\1\2\0\0\6o\ropen_tab\1\2\0\0\n<c-t>\16open_vsplit\1\2\0\0\n<c-v>\15open_split\1\2\0\0\n<c-x>\tjump\1\3\0\0\t<cr>\n<tab>\1\0\t\nclose\6q\16toggle_mode\6m\fpreview\6p\rprevious\6k\19toggle_preview\6P\frefresh\6r\nhover\6K\tnext\6j\vcancel\n<esc>\1\0\r\rposition\vbottom\14fold_open\bÔëº\16fold_closed\bÔë†\17indent_lines\2\17auto_preview\2\vheight\3\n\nwidth\0032\tmode\25document_diagnostics\14auto_fold\1\nicons\2\15auto_close\1\29use_lsp_diagnostic_signs\1\14auto_open\1\nsetup\ftrouble\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/trouble.nvim",
    url = "git@github.com:folke/trouble.nvim"
  },
  ["twilight.nvim"] = {
    config = { "\27LJ\2\nˆ\1\0\0\6\0\f\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\3\0005\3\6\0005\4\3\0005\5\4\0=\5\5\4=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\3>\3\1\2B\0\2\1K\0\1\0\fexclude\1\2\0\0\n.git*\vexpand\1\5\0\0\rfunction\vmethod\ntable\17if_statement\fdimming\1\0\2\fcontext\0032\15treesitter\2\ncolor\1\3\0\0\vNormal\f#ffffff\1\0\2\nalpha\4\0ÄÄÄˇ\3\rinactive\2\nsetup\rtwilight\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/twilight.nvim",
    url = "git@github.com:folke/twilight.nvim"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/vim-commentary",
    url = "git@github.com:tpope/vim-commentary"
  },
  ["vim-dispatch"] = {
    commands = { "Dispatch" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-dispatch",
    url = "git@github.com:tpope/vim-dispatch"
  },
  ["vim-easy-align"] = {
    commands = { "EasyAlign" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-easy-align",
    url = "git@github.com:junegunn/vim-easy-align"
  },
  ["vim-fugitive"] = {
    commands = { "Git", "G", "Ggrep", "GBrowse" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-fugitive",
    url = "git@github.com:tpope/vim-fugitive"
  },
  ["vim-go"] = {
    config = { "\27LJ\2\nb\0\0\2\0\4\0\t6\0\0\0009\0\1\0+\1\1\0=\1\2\0006\0\0\0009\0\1\0+\1\1\0=\1\3\0K\0\1\0\27go_def_mapping_enabled\30go_doc_keywordprg_enabled\6g\bvim\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-go",
    url = "git@github.com:fatih/vim-go"
  },
  ["vim-markdown-toc"] = {
    commands = { "GenTocGFM" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc",
    url = "git@github.com:mzlogin/vim-markdown-toc"
  },
  ["vim-matchup"] = {
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-matchup/after/plugin/matchit.vim" },
    config = { "\27LJ\2\n\\\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0=let g:matchup_matchparen_offscreen = {'method': 'popup'}\bcmd\bvim\0" },
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-matchup",
    url = "git@github.com:andymass/vim-matchup"
  },
  ["vim-sleuth"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/vim-sleuth",
    url = "git@github.com:tpope/vim-sleuth"
  },
  ["vim-startuptime"] = {
    commands = { "StartupTime" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-startuptime",
    url = "git@github.com:dstein64/vim-startuptime"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "git@github.com:tpope/vim-surround"
  },
  ["vim-wakatime"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-wakatime",
    url = "git@github.com:wakatime/vim-wakatime"
  },
  vimtex = {
    config = { "\27LJ\2\ní\5\0\0\3\0\n\0\0176\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0006\0\0\0009\0\1\0'\1\a\0=\1\6\0006\0\0\0009\0\b\0'\2\t\0B\0\2\1K\0\1\0§\3augroup vimtex_mac\n    autocmd!\n    autocmd User VimtexEventCompileSuccess call UpdateSkim()\naugroup END\n\nfunction! UpdateSkim() abort\n    let l:out = b:vimtex.out()\n    let l:src_file_path = expand('%:p')\n    let l:cmd = [g:vimtex_view_general_viewer, '-r']\n\n    if !empty(system('pgrep Skim'))\n    call extend(l:cmd, ['-g'])\n    endif\n\n    call jobstart(l:cmd + [line('.'), l:out, l:src_file_path])\nendfunction\n  \bcmd\23-r @line @pdf @tex vimtex_view_general_options>/Applications/Skim.app/Contents/SharedSupport/displayline\31vimtex_view_general_viewer\tskim\23vimtex_view_method\6g\bvim\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex",
    url = "git@github.com:lervag/vimtex"
  },
  ["which-key.nvim"] = {
    config = { "\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14which-key\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/which-key.nvim",
    url = "git@github.com:folke/which-key.nvim"
  },
  ["wilder.nvim"] = {
    after = { "fzy-lua-native" },
    config = { "\27LJ\2\nÉ\17\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0„\16call wilder#setup({'modes': [':', '/', '?']})\ncall wilder#set_option('pipeline', [\n      \\   wilder#branch(\n      \\     wilder#python_file_finder_pipeline({\n      \\       'file_command': {_, arg -> stridx(arg, '.') != -1 ? ['fd', '-tf', '-H'] : ['fd', '-tf']},\n      \\       'dir_command': ['fd', '-td'],\n      \\     }),\n      \\     wilder#substitute_pipeline({\n      \\       'pipeline': wilder#python_search_pipeline({\n      \\         'skip_cmdtype_check': 1,\n      \\         'pattern': wilder#python_fuzzy_pattern({\n      \\           'start_at_boundary': 0,\n      \\         }),\n      \\       }),\n      \\     }),\n      \\     wilder#cmdline_pipeline({\n      \\       'fuzzy': 1,\n      \\       'fuzzy_filter': has('nvim') ? wilder#lua_fzy_filter() : wilder#vim_fuzzy_filter(),\n      \\     }),\n      \\     [\n      \\       wilder#check({_, x -> empty(x)}),\n      \\       wilder#history(),\n      \\     ],\n      \\     wilder#python_search_pipeline({\n      \\       'pattern': wilder#python_fuzzy_pattern({\n      \\         'start_at_boundary': 0,\n      \\       }),\n      \\     }),\n      \\   ),\n      \\ ])\nlet s:highlighters = [\n      \\ wilder#pcre2_highlighter(),\n      \\ wilder#lua_fzy_highlighter(),\n      \\ ]\nlet s:popupmenu_renderer = wilder#popupmenu_renderer(wilder#popupmenu_border_theme({\n      \\ 'empty_message': wilder#popupmenu_empty_message_with_spinner(),\n      \\ 'highlighter': s:highlighters,\n      \\ 'left': [\n      \\   ' ',\n      \\   wilder#popupmenu_devicons(),\n      \\   wilder#popupmenu_buffer_flags({\n      \\     'flags': ' a + ',\n      \\     'icons': {'+': 'Ô£™', 'a': 'Ôúì', 'h': 'Ôú£'},\n      \\   }),\n      \\ ],\n      \\ 'right': [\n      \\   ' ',\n      \\   wilder#popupmenu_scrollbar(),\n      \\ ],\n      \\ }))\nlet s:wildmenu_renderer = wilder#wildmenu_renderer({\n      \\ 'highlighter': s:highlighters,\n      \\ 'separator': ' ¬∑ ',\n      \\ 'left': [' ', wilder#wildmenu_spinner(), ' '],\n      \\ 'right': [' ', wilder#wildmenu_index()],\n      \\ })\ncall wilder#set_option('renderer', wilder#renderer_mux({\n      \\ ':': s:popupmenu_renderer,\n      \\ '/': s:wildmenu_renderer,\n      \\ 'substitute': s:wildmenu_renderer,\n      \\ }))\n\bcmd\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/wilder.nvim",
    url = "git@github.com:gelguy/wilder.nvim"
  },
  ["zen-mode.nvim"] = {
    config = { "\27LJ\2\n:\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\rzen-mode\frequire\0" },
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/zen-mode.nvim",
    url = "git@github.com:folke/zen-mode.nvim"
  }
}

time([[Defining packer_plugins]], false)
local module_lazy_loads = {
  ["^cmp_nvim_lsp"] = "friendly-snippets",
  ["^lspconfig"] = "nvim-lspconfig",
  ["^octo"] = "octo.nvim",
  ["^spectre"] = "nvim-spectre",
  ["^telekasten"] = "telekasten.nvim",
  ["^telescope"] = "telescope.nvim"
}
local lazy_load_called = {['packer.load'] = true}
local function lazy_load_module(module_name)
  local to_load = {}
  if lazy_load_called[module_name] then return nil end
  lazy_load_called[module_name] = true
  for module_pat, plugin_name in pairs(module_lazy_loads) do
    if not _G.packer_plugins[plugin_name].loaded and string.match(module_name, module_pat) then
      to_load[#to_load + 1] = plugin_name
    end
  end

  if #to_load > 0 then
    require('packer.load')(to_load, {module = module_name}, _G.packer_plugins)
    local loaded_mod = package.loaded[module_name]
    if loaded_mod then
      return function(modname) return loaded_mod end
    end
  end
end

if not vim.g.packer_custom_loader_enabled then
  table.insert(package.loaders, 1, lazy_load_module)
  vim.g.packer_custom_loader_enabled = true
end

-- Setup for: copilot.vim
time([[Setup for copilot.vim]], true)
try_loadstring("\27LJ\2\nò\1\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0ypackadd copilot.vim\nimap <silent><script><expr> <C-J> copilot#Accept(\"\\<CR>\")\nlet g:copilot_no_tab_map = v:true\n    \bcmd\bvim\0", "setup", "copilot.vim")
time([[Setup for copilot.vim]], false)
-- Setup for: kanagawa
time([[Setup for kanagawa]], true)
try_loadstring("\27LJ\2\ni\0\0\3\0\6\0\t6\0\0\0009\0\1\0\a\0\2\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\1K\0\1\0\21packadd kanagawa\bcmd\bvim\rkanagawa\16colorscheme\20__editor_config\0", "setup", "kanagawa")
time([[Setup for kanagawa]], false)
-- Setup for: rose-pine
time([[Setup for rose-pine]], true)
try_loadstring("\27LJ\2\nk\0\0\3\0\6\0\t6\0\0\0009\0\1\0\a\0\2\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\1K\0\1\0\22packadd rose-pine\bcmd\bvim\14rose-pine\16colorscheme\20__editor_config\0", "setup", "rose-pine")
time([[Setup for rose-pine]], false)
-- Setup for: catppuccin
time([[Setup for catppuccin]], true)
try_loadstring("\27LJ\2\nm\0\0\3\0\6\0\t6\0\0\0009\0\1\0\a\0\2\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\1K\0\1\0\23packadd catppuccin\bcmd\bvim\15catppuccin\16colorscheme\20__editor_config\0", "setup", "catppuccin")
time([[Setup for catppuccin]], false)
-- Setup for: tokyonight
time([[Setup for tokyonight]], true)
try_loadstring("\27LJ\2\nm\0\0\3\0\6\0\t6\0\0\0009\0\1\0\a\0\2\0X\0\4Ä6\0\3\0009\0\4\0'\2\5\0B\0\2\1K\0\1\0\23packadd tokyonight\bcmd\bvim\15tokyonight\16colorscheme\20__editor_config\0", "setup", "tokyonight")
time([[Setup for tokyonight]], false)
-- Config for: filetype.nvim
time([[Config for filetype.nvim]], true)
try_loadstring("\27LJ\2\n:\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\rfiletype\frequire\0", "config", "filetype.nvim")
time([[Config for filetype.nvim]], false)
-- Conditional loads
time([[Conditional loading of dashboard-nvim]], true)
  require("packer.load")({"dashboard-nvim"}, {}, _G.packer_plugins)
time([[Conditional loading of dashboard-nvim]], false)
time([[Conditional loading of rose-pine]], true)
  require("packer.load")({"rose-pine"}, {}, _G.packer_plugins)
time([[Conditional loading of rose-pine]], false)
time([[Conditional loading of feline.nvim]], true)
  require("packer.load")({"feline.nvim"}, {}, _G.packer_plugins)
time([[Conditional loading of feline.nvim]], false)
time([[Conditional loading of kanagawa]], true)
  require("packer.load")({"kanagawa"}, {}, _G.packer_plugins)
time([[Conditional loading of kanagawa]], false)
time([[Conditional loading of nvim-tmux-navigation]], true)
  require("packer.load")({"nvim-tmux-navigation"}, {}, _G.packer_plugins)
time([[Conditional loading of nvim-tmux-navigation]], false)
time([[Conditional loading of catppuccin]], true)
  require("packer.load")({"catppuccin"}, {}, _G.packer_plugins)
time([[Conditional loading of catppuccin]], false)
time([[Conditional loading of tokyonight]], true)
  require("packer.load")({"tokyonight"}, {}, _G.packer_plugins)
time([[Conditional loading of tokyonight]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd nvim-web-devicons ]]
vim.cmd [[ packadd dressing.nvim ]]
time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file NvimTreeToggle lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file NvimTreeOpen lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Git lua require("packer.load")({'vim-fugitive'}, { cmd = "Git", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Dispatch lua require("packer.load")({'vim-dispatch'}, { cmd = "Dispatch", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file EasyAlign lua require("packer.load")({'vim-easy-align'}, { cmd = "EasyAlign", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file JupyterExecute lua require("packer.load")({'jupyter_ascending.vim'}, { cmd = "JupyterExecute", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file JupyterExecuteAll lua require("packer.load")({'jupyter_ascending.vim'}, { cmd = "JupyterExecuteAll", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GBrowse lua require("packer.load")({'vim-fugitive'}, { cmd = "GBrowse", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Telescope lua require("packer.load")({'telescope.nvim'}, { cmd = "Telescope", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file G lua require("packer.load")({'vim-fugitive'}, { cmd = "G", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SymbolsOutline lua require("packer.load")({'symbols-outline.nvim'}, { cmd = "SymbolsOutline", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SymbolsOutlineOpen lua require("packer.load")({'symbols-outline.nvim'}, { cmd = "SymbolsOutlineOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TroubleToggle lua require("packer.load")({'trouble.nvim'}, { cmd = "TroubleToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GenTocGFM lua require("packer.load")({'vim-markdown-toc'}, { cmd = "GenTocGFM", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Octo lua require("packer.load")({'octo.nvim'}, { cmd = "Octo", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file StartupTime lua require("packer.load")({'vim-startuptime'}, { cmd = "StartupTime", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Trouble lua require("packer.load")({'trouble.nvim'}, { cmd = "Trouble", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TroubleRefresh lua require("packer.load")({'trouble.nvim'}, { cmd = "TroubleRefresh", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Copilot lua require("packer.load")({'copilot.vim'}, { cmd = "Copilot", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Ggrep lua require("packer.load")({'vim-fugitive'}, { cmd = "Ggrep", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType go ++once lua require("packer.load")({'vim-go'}, { ft = "go" }, _G.packer_plugins)]]
vim.cmd [[au FileType html ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "html" }, _G.packer_plugins)]]
vim.cmd [[au FileType xml ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "xml" }, _G.packer_plugins)]]
vim.cmd [[au FileType tex ++once lua require("packer.load")({'vimtex'}, { ft = "tex" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'markdown-preview.nvim'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType latex ++once lua require("packer.load")({'cmp-latex-symbols'}, { ft = "latex" }, _G.packer_plugins)]]
vim.cmd [[au FileType ipynb ++once lua require("packer.load")({'jupyter_ascending.vim'}, { ft = "ipynb" }, _G.packer_plugins)]]
vim.cmd [[au FileType md ++once lua require("packer.load")({'vim-markdown-toc'}, { ft = "md" }, _G.packer_plugins)]]
vim.cmd [[au FileType rust ++once lua require("packer.load")({'rust-tools.nvim'}, { ft = "rust" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au BufRead * ++once lua require("packer.load")({'nvim-treesitter', 'indent-blankline.nvim', 'nvim-toggleterm.lua', 'lualine.nvim', 'nvim-colorizer.lua', 'gitsigns.nvim', 'nvim-bufferline.lua'}, { event = "BufRead *" }, _G.packer_plugins)]]
vim.cmd [[au BufNewFile * ++once lua require("packer.load")({'nvim-treesitter', 'gitsigns.nvim'}, { event = "BufNewFile *" }, _G.packer_plugins)]]
vim.cmd [[au BufEnter * ++once lua require("packer.load")({'which-key.nvim'}, { event = "BufEnter *" }, _G.packer_plugins)]]
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'friendly-snippets'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au CmdlineEnter * ++once lua require("packer.load")({'wilder.nvim'}, { event = "CmdlineEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'nvim-lspconfig'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], true)
vim.cmd [[source /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], false)
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc/ftdetect/markdown.vim]], true)
vim.cmd [[source /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc/ftdetect/markdown.vim]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc/ftdetect/markdown.vim]], false)
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/cls.vim]], true)
vim.cmd [[source /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/cls.vim]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/cls.vim]], false)
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tex.vim]], true)
vim.cmd [[source /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tex.vim]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tex.vim]], false)
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tikz.vim]], true)
vim.cmd [[source /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tikz.vim]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tikz.vim]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
