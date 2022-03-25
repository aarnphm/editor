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
  ["DAPInstall.nvim"] = {
    commands = { "DIInstall", "DIUninstall", "DIList" },
    load_after = {
      ["nvim-dap-ui"] = true
    },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/DAPInstall.nvim",
    url = "git@github.com:Pocco81/DAPInstall.nvim"
  },
  ["FTerm.nvim"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/FTerm.nvim",
    url = "git@github.com:numtostr/FTerm.nvim"
  },
  LuaSnip = {
    after = { "cmp_luasnip" },
    config = { "\27LJ\2\n∞\1\0\0\3\0\a\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0009\0\3\0005\2\4\0B\0\2\0016\0\0\0'\2\5\0B\0\2\0029\0\6\0B\0\1\1K\0\1\0\tload luasnip/loaders/from_vscode\1\0\2\17updateevents\29TextChanged,TextChangedI\fhistory\2\15set_config\vconfig\fluasnip\frequire\0" },
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/LuaSnip",
    url = "git@github.com:L3MON4D3/LuaSnip"
  },
  ["better-escape.vim"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/better-escape.vim",
    url = "git@github.com:jdhao/better-escape.vim"
  },
  ["bufdelete.nvim"] = {
    commands = { "Bdelete", "Bwipeout", "Bdelete!", "Bwipeout!" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/bufdelete.nvim",
    url = "git@github.com:famiu/bufdelete.nvim"
  },
  ["cheatsheet.nvim"] = {
    config = { "\27LJ\2\nÜ\3\0\0\a\0\15\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\6\0006\4\0\0'\6\4\0B\4\2\0029\4\5\4=\4\a\0036\4\0\0'\6\4\0B\4\2\0029\4\b\4=\4\t\0036\4\0\0'\6\4\0B\4\2\0029\4\n\4=\4\v\0036\4\0\0'\6\4\0B\4\2\0029\4\f\4=\4\r\3=\3\14\2B\0\2\1K\0\1\0\23telescope_mappings\n<C-E>\25edit_user_cheatsheet\n<C-Y>\21copy_cheat_value\v<A-CR>\22select_or_execute\t<CR>\1\0\0\31select_or_fill_commandline!cheatsheet.telescope.actions\1\0\3\31bundled_plugin_cheatsheets\2\24bundled_cheatsheets\2#include_only_installed_plugins\2\nsetup\15cheatsheet\frequire\0" },
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
      ["cmp-spell"] = true
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
    after = { "cmp-tmux" },
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
    after = { "cmp-spell" },
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-path/after/plugin/cmp_path.lua" },
    load_after = {
      ["cmp-tmux"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-path",
    url = "git@github.com:hrsh7th/cmp-path"
  },
  ["cmp-spell"] = {
    after = { "cmp-buffer" },
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-spell/after/plugin/cmp-spell.lua" },
    load_after = {
      ["cmp-path"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-spell",
    url = "git@github.com:f3fora/cmp-spell"
  },
  ["cmp-tmux"] = {
    after = { "cmp-path" },
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-tmux/after/plugin/cmp_tmux.vim" },
    load_after = {
      ["cmp-nvim-lua"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-tmux",
    url = "git@github.com:andersevenrud/cmp-tmux"
  },
  ["cmp-under-comparator"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/cmp-under-comparator",
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
  ["competitest.nvim"] = {
    after = { "nui.nvim" },
    config = { "\27LJ\2\n9\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\16competitest\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/competitest.nvim",
    url = "git@github.com:xeluxee/competitest.nvim"
  },
  ["cphelper.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cphelper.nvim",
    url = "git@github.com:p00f/cphelper.nvim"
  },
  ["dashboard-nvim"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/dashboard-nvim",
    url = "git@github.com:glepnir/dashboard-nvim"
  },
  ["dressing.nvim"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/dressing.nvim",
    url = "git@github.com:stevearc/dressing.nvim"
  },
  ["efmls-configs-nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/efmls-configs-nvim",
    url = "git@github.com:creativenull/efmls-configs-nvim"
  },
  ["fidget.nvim"] = {
    config = { "\27LJ\2\n8\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\vfidget\frequire\0" },
    load_after = {
      ["nvim-gps"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/fidget.nvim",
    url = "git@github.com:j-hui/fidget.nvim"
  },
  ["filetype.nvim"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/filetype.nvim",
    url = "git@github.com:nathom/filetype.nvim"
  },
  ["friendly-snippets"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/friendly-snippets",
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
    config = { "\27LJ\2\n◊\f\0\0\5\0\28\0\0316\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\14\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\0035\4\f\0=\4\r\3=\3\15\0025\3\16\0005\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\0025\3\26\0=\3\27\2B\0\2\1K\0\1\0\14diff_opts\1\0\1\rinternal\2\28current_line_blame_opts\1\0\2\ndelay\3Ë\a\21virtual_text_pos\beol\17watch_gitdir\1\0\2\17follow_files\2\rinterval\3Ë\a\fkeymaps\17n <leader>[g\1\2\1\0@&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'\texpr\2\17n <leader>]g\1\2\1\0@&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'\texpr\2\1\0\f\tx ih4:<C-U>lua require(\"gitsigns\").text_object()<CR>\17v <leader>hrV<cmd>lua require(\"gitsigns\").reset_hunk({vim.fn.line(\".\"), vim.fn.line(\"v\")})<CR>\17n <leader>hb6<cmd>lua require(\"gitsigns\").blame_line(true)<CR>\17n <leader>hp4<cmd>lua require(\"gitsigns\").preview_hunk()<CR>\17n <leader>hr2<cmd>lua require(\"gitsigns\").reset_hunk()<CR>\to ih4:<C-U>lua require(\"gitsigns\").text_object()<CR>\17n <leader>hu7<cmd>lua require(\"gitsigns\").undo_stage_hunk()<CR>\fnoremap\2\17n <leader>hs2<cmd>lua require(\"gitsigns\").stage_hunk()<CR>\vbuffer\2\17v <leader>hsV<cmd>lua require(\"gitsigns\").stage_hunk({vim.fn.line(\".\"), vim.fn.line(\"v\")})<CR>\17n <leader>hR4<cmd>lua require(\"gitsigns\").reset_buffer()<CR>\nsigns\1\0\4\20update_debounce\3d\18sign_priority\3\6\14word_diff\1\23current_line_blame\2\17changedelete\1\0\4\ttext\6~\vlinehl\21GitSignsChangeLn\nnumhl\21GitSignsChangeNr\ahl\19GitSignsChange\14topdelete\1\0\4\ttext\b‚Äæ\vlinehl\21GitSignsDeleteLn\nnumhl\21GitSignsDeleteNr\ahl\19GitSignsDelete\vdelete\1\0\4\ttext\6_\vlinehl\21GitSignsDeleteLn\nnumhl\21GitSignsDeleteNr\ahl\19GitSignsDelete\vchange\1\0\4\ttext\b‚îÇ\vlinehl\21GitSignsChangeLn\nnumhl\21GitSignsChangeNr\ahl\19GitSignsChange\badd\1\0\0\1\0\4\ttext\b‚îÇ\vlinehl\18GitSignsAddLn\nnumhl\18GitSignsAddNr\ahl\16GitSignsAdd\nsetup\rgitsigns\frequire\0" },
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
    config = { "\27LJ\2\n˜\4\0\0\4\0\14\0\0216\0\0\0009\0\1\0+\1\2\0=\1\2\0006\0\0\0009\0\1\0+\1\2\0=\1\3\0006\0\4\0'\2\5\0B\0\2\0029\0\6\0005\2\a\0005\3\b\0=\3\t\0025\3\n\0=\3\v\0025\3\f\0=\3\r\2B\0\2\1K\0\1\0\21context_patterns\1\15\0\0\nclass\rfunction\vmethod\nblock\17list_literal\rselector\b^if\v^table\17if_statement\nwhile\bfor\ttype\bvar\vimport\20buftype_exclude\1\3\0\0\rterminal\vnofile\21filetype_exclude\1\21\0\0\rstartify\14dashboard\blog\rfugitive\14gitcommit\vpacker\fvimwiki\rmarkdown\tjson\btxt\nvista\thelp\ftodoist\rNvimTree\rpeekaboo\bgit\20TelescopePrompt\rundotree\24flutterToolsOutline\5\1\0\6\28show_first_indent_level\2\25show_current_context\2\31show_current_context_start\2#show_trailing_blankline_indent\2\tchar\b‚îÇ\25space_char_blankline\6 \nsetup\21indent_blankline\frequire\tlist\18termguicolors\bopt\bvim\0" },
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
    config = { "\27LJ\2\n⁄\2\0\0\4\0\t\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0004\3\0\0=\3\4\0024\3\0\0=\3\5\2B\0\2\0016\0\6\0009\0\a\0'\2\b\0B\0\2\1K\0\1\0!silent! colorscheme kanagawa\bcmd\bvim\14overrides\vcolors\1\0\v\18functionStyle\16bold,italic\17keywordStyle\vitalic\19statementStyle\tbold\14typeStyle\tNONE\25variablebuiltinStyle\vitalic\18specialReturn\2\21specialException\2\16transparent\1\16dimInactive\2\14undercurl\2\17commentStyle\vitalic\nsetup\rkanagawa\frequire\0" },
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/kanagawa",
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
    config = { "\27LJ\2\nT\0\0\2\1\3\0\f-\0\0\0009\0\0\0B\0\1\2\15\0\0\0X\1\4Ä-\0\0\0009\0\1\0D\0\1\0X\0\2Ä'\0\2\0L\0\2\0K\0\1\0\0¿\5\17get_location\17is_available◊\a\1\0\f\0000\0c6\0\0\0'\2\1\0B\0\2\0023\1\2\0005\2\3\0004\3\0\0=\3\4\0024\3\0\0=\3\5\0024\3\0\0=\3\6\0024\3\0\0=\3\a\0024\3\0\0=\3\b\0025\3\t\0=\3\n\0025\3\v\0=\2\f\0035\4\r\0=\4\14\0035\4\19\0005\5\16\0005\6\15\0=\6\4\0055\6\17\0=\6\5\0054\6\0\0=\6\6\0054\6\0\0=\6\a\0054\6\0\0=\6\b\0055\6\18\0=\6\n\5=\5\f\0045\5\20\0=\5\14\0046\5\0\0'\a\21\0B\5\2\0029\5\22\0055\a\25\0005\b\23\0004\t\0\0=\t\24\b=\b\26\a5\b\28\0005\t\27\0=\t\4\b4\t\3\0005\n\29\0>\n\1\t5\n\30\0>\n\2\t=\t\5\b4\t\3\0005\n \0>\1\1\n9\v\31\0=\v!\n>\n\1\t=\t\6\b4\t\3\0005\n\"\0005\v#\0=\v$\n5\v%\0=\v&\n>\n\1\t=\t\a\b5\t'\0=\t\b\b5\t(\0=\t\n\b=\b\f\a5\b)\0004\t\0\0=\t\4\b4\t\0\0=\t\5\b5\t*\0=\t\6\b5\t+\0=\t\a\b4\t\0\0=\t\b\b4\t\0\0=\t\n\b=\b,\a4\b\0\0=\b-\a5\b.\0>\3\5\b>\4\6\b=\b/\aB\5\2\0012\0\0ÄK\0\1\0\15extensions\1\5\0\0\rquickfix\14nvim-tree\15toggleterm\rfugitive\ftabline\22inactive_sections\1\2\0\0\rlocation\1\2\0\0\rfilename\1\0\0\1\3\0\0\rprogress\rlocation\1\4\0\0\rfiletype\rencoding\15fileformat\fsymbols\1\0\3\nerror\tÔÅó \twarn\tÔÅ± \tinfo\tÔÅ™ \fsources\1\2\0\0\20nvim_diagnostic\1\2\0\0\16diagnostics\tcond\1\0\0\17is_available\1\2\0\0\tdiff\1\2\0\0\vbranch\1\0\0\1\2\0\0\tmode\foptions\1\0\0\23disabled_filetypes\1\0\3\18icons_enabled\2\25component_separators\6|\ntheme\tauto\nsetup\flualine\1\2\0\0\fOutline\1\0\0\1\2\0\0\rlocation\1\2\0\0\rfiletype\1\0\0\1\2\0\0\tmode\14filetypes\1\2\0\0\fminimap\rsections\1\0\0\14lualine_z\1\2\0\0\rlocation\14lualine_y\14lualine_x\14lualine_c\14lualine_b\14lualine_a\1\0\0\0\rnvim-gps\frequire\0" },
    load_after = {
      ["nvim-gps"] = true
    },
    loaded = false,
    needs_bufread = false,
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
  ["minimap.vim"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/minimap.vim",
    url = "git@github.com:wfxr/minimap.vim"
  },
  ["nui.nvim"] = {
    load_after = {
      ["competitest.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nui.nvim",
    url = "git@github.com:MunifTanjim/nui.nvim"
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
    config = { "\27LJ\2\n√\3\0\0\6\0\b\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0004\4\3\0005\5\4\0>\5\1\4=\4\5\3=\3\a\2B\0\2\1K\0\1\0\foptions\1\0\0\foffsets\1\0\4\ttext\18File Explorer\15text_align\vcenter\rfiletype\rNvimTree\fpadding\3\1\1\0\14\22buffer_close_icon\bÔôï\27always_show_bufferline\2\20separator_style\tthin\24show_tab_indicators\2\22show_buffer_icons\2\16diagnostics\rnvim_lsp\18modified_icon\b‚ú•\rtab_size\3\20\22left_trunc_marker\bÔÇ®\20max_name_length\3\14\22max_prefix_length\3\r\vnumber\tnone\23right_trunc_marker\bÔÇ©\28show_buffer_close_icons\2\nsetup\15bufferline\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-bufferline.lua",
    url = "git@github.com:akinsho/nvim-bufferline.lua"
  },
  ["nvim-cmp"] = {
    after = { "nvim-autopairs", "LuaSnip" },
    config = { "\27LJ\2\nF\0\1\a\0\3\0\b6\1\0\0009\1\1\0019\1\2\1\18\3\0\0+\4\2\0+\5\2\0+\6\2\0D\1\5\0\27nvim_replace_termcodes\bapi\bvim–\1\0\0\b\0\b\2!6\0\0\0006\2\1\0009\2\2\0029\2\3\2)\4\0\0B\2\2\0A\0\0\3\b\1\0\0X\2\20Ä6\2\1\0009\2\2\0029\2\4\2)\4\0\0\23\5\1\0\18\6\0\0+\a\2\0B\2\5\2:\2\1\2\18\4\2\0009\2\5\2\18\5\1\0\18\6\1\0B\2\4\2\18\4\2\0009\2\6\2'\5\a\0B\2\3\2\n\2\0\0X\2\2Ä+\2\1\0X\3\1Ä+\2\2\0L\2\2\0\a%s\nmatch\bsub\23nvim_buf_get_lines\24nvim_win_get_cursor\bapi\bvim\vunpack\0\2â\4\0\2\b\0\t\0\0155\2\0\0006\3\2\0009\3\3\3'\5\4\0009\6\1\0018\6\6\0029\a\1\1B\3\4\2=\3\1\0015\3\6\0009\4\a\0009\4\b\0048\3\4\3=\3\5\1L\1\2\0\tname\vsource\1\0\b\tpath\v[PATH]\fluasnip\v[SNIP]\forgmode\n[ORG]\vbuffer\n[BUF]\rnvim_lsp\n[LSP]\nspell\f[SPELL]\ttmux\v[TMUX]\rnvim_lua\n[LUA]\tmenu\n%s %s\vformat\vstring\tkind\1\0\25\15EnumMember\bÔÖù\nClass\bÔ¥Ø\tText\bÓòí\tUnit\bÓàü\nColor\bÔ£ó\14Reference\bÔíÅ\vFolder\bÔùä\rProperty\bÔ∞†\vMethod\bÔö¶\vModule\bÔíá\nField\bÔõº\tFile\bÔúò\18TypeParameter\bÔô±\fKeyword\bÔ†ä\nValue\bÔ¢ü\16Constructor\bÔê£\14Interface\bÔÉ®\rConstant\bÔ£æ\tEnum\bÔÖù\rOperator\bÔöî\vStruct\bÔÜ≥\nEvent\bÔÉß\fSnippet\bÔëè\rFunction\bÔûî\rVariable\bÔñ†}\0\1\3\2\3\0\20-\1\0\0009\1\0\1B\1\1\2\15\0\1\0X\2\4Ä-\1\0\0009\1\1\1B\1\1\1X\1\nÄ-\1\1\0B\1\1\2\15\0\1\0X\2\4Ä-\1\0\0009\1\2\1B\1\1\1X\1\2Ä\18\1\0\0B\1\1\1K\0\1\0\2¿\1¿\rcomplete\21select_next_item\fvisibleR\0\1\3\1\2\0\f-\1\0\0009\1\0\1B\1\1\2\15\0\1\0X\2\4Ä-\1\0\0009\1\1\1B\1\1\1X\1\2Ä\18\1\0\0B\1\1\1K\0\1\0\2¿\21select_prev_item\fvisibleõ\1\0\1\6\1\b\0\0206\1\0\0'\3\1\0B\1\2\0029\1\2\1)\3ˇˇB\1\2\2\15\0\1\0X\2\tÄ6\1\3\0009\1\4\0019\1\5\1-\3\0\0'\5\6\0B\3\2\2'\4\a\0B\1\3\1X\1\2Ä\18\1\0\0B\1\1\1K\0\1\0\0¿\5\28<Plug>luasnip-jump-prev\rfeedkeys\afn\bvim\rjumpable\fluasnip\frequire¶\1\0\1\6\1\b\0\0196\1\0\0'\3\1\0B\1\2\0029\1\2\1B\1\1\2\15\0\1\0X\2\tÄ6\1\3\0009\1\4\0019\1\5\1-\3\0\0'\5\6\0B\3\2\2'\4\a\0B\1\3\1X\1\2Ä\18\1\0\0B\1\1\1K\0\1\0\0¿\5!<Plug>luasnip-expand-or-jump\rfeedkeys\afn\bvim\23expand_or_jumpable\fluasnip\frequireC\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\15lsp_expand\fluasnip\frequireÆ\14\1\0\v\0L\0¶\0016\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\0016\0\0\0009\0\1\0'\2\4\0B\0\2\0016\0\0\0009\0\1\0'\2\5\0B\0\2\0016\0\0\0009\0\1\0'\2\6\0B\0\2\0016\0\0\0009\0\1\0'\2\a\0B\0\2\0016\0\0\0009\0\1\0'\2\b\0B\0\2\0016\0\0\0009\0\1\0'\2\t\0B\0\2\0016\0\0\0009\0\1\0'\2\n\0B\0\2\0016\0\0\0009\0\1\0'\2\v\0B\0\2\0016\0\0\0009\0\1\0'\2\f\0B\0\2\0016\0\0\0009\0\1\0'\2\r\0B\0\2\0013\0\14\0003\1\15\0006\2\16\0'\4\17\0B\2\2\0029\3\18\0025\5 \0005\6\30\0004\a\t\0009\b\19\0029\b\20\b9\b\21\b>\b\1\a9\b\19\0029\b\20\b9\b\22\b>\b\2\a9\b\19\0029\b\20\b9\b\23\b>\b\3\a6\b\16\0'\n\24\0B\b\2\0029\b\25\b>\b\4\a9\b\19\0029\b\20\b9\b\26\b>\b\5\a9\b\19\0029\b\20\b9\b\27\b>\b\6\a9\b\19\0029\b\20\b9\b\28\b>\b\a\a9\b\19\0029\b\20\b9\b\29\b>\b\b\a=\a\31\6=\6!\0055\6#\0003\a\"\0=\a$\6=\6%\0055\6)\0009\a&\0029\a'\a5\t(\0B\a\2\2=\a*\0069\a&\0029\a+\aB\a\1\2=\a,\0069\a&\0029\a-\aB\a\1\2=\a.\0069\a&\0029\a/\a)\t¸ˇB\a\2\2=\a0\0069\a&\0029\a/\a)\t\4\0B\a\2\2=\a1\0069\a&\0029\a2\aB\a\1\2=\a3\0069\a&\0023\t4\0005\n5\0B\a\3\2=\a6\0069\a&\0023\t7\0005\n8\0B\a\3\2=\a9\0063\a:\0=\a;\0063\a<\0=\a=\6=\6&\0055\6?\0003\a>\0=\a@\6=\6A\0054\6\n\0005\aB\0>\a\1\0065\aC\0>\a\2\0065\aD\0>\a\3\0065\aE\0>\a\4\0065\aF\0>\a\5\0065\aG\0>\a\6\0065\aH\0>\a\a\0065\aI\0>\a\b\0065\aJ\0>\a\t\6=\6K\5B\3\2\0012\0\0ÄK\0\1\0\fsources\1\0\1\tname\18latex_symbols\1\0\1\tname\vbuffer\1\0\1\tname\forgmode\1\0\1\tname\ttmux\1\0\1\tname\nspell\1\0\1\tname\tpath\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lua\1\0\1\tname\rnvim_lsp\fsnippet\vexpand\1\0\0\0\n<C-l>\0\n<C-h>\0\f<S-Tab>\1\3\0\0\6i\6s\0\n<Tab>\1\3\0\0\6i\6s\0\n<C-e>\nclose\n<C-f>\n<C-d>\16scroll_docs\n<C-n>\21select_next_item\n<C-p>\21select_prev_item\t<CR>\1\0\0\1\0\1\vselect\2\fconfirm\fmapping\15formatting\vformat\1\0\0\0\fsorting\1\0\0\16comparators\1\0\0\norder\vlength\14sort_text\tkind\nunder\25cmp-under-comparator\nscore\nexact\voffset\fcompare\vconfig\nsetup\bcmp\frequire\0\0009highlight CmpItemKindMethod guifg=#B48EAD guibg=NONE;highlight CmpItemKindFunction guifg=#B48EAD guibg=NONE7highlight CmpItemKindText guifg=#81A1C1 guibg=NONE<highlight CmpItemKindInterface guifg=#88C0D0 guibg=NONE;highlight CmpItemKindVariable guifg=#8FBCBB guibg=NONE=highlight CmpItemAbbrMatchFuzzy guifg=#5E81AC guibg=NONE8highlight CmpItemAbbrMatch guifg=#5E81AC guibg=NONE:highlight CmpItemKindKeyword guifg=#EBCB8B guibg=NONE;highlight CmpItemKindProperty guifg=#A3BE8C guibg=NONE7highlight CmpItemKindUnit guifg=#D08770 guibg=NONE:highlight CmpItemKindSnippet guifg=#BF616A guibg=NONEOhighlight CmpItemAbbrDeprecated guifg=#D8DEE9 guibg=NONE gui=strikethrough\bcmd\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
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
  ["nvim-comment"] = {
    config = { "\27LJ\2\n^\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\25update_commentstring&ts_context_commentstring.internal\frequireO\1\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\2B\0\2\1K\0\1\0\thook\1\0\0\0\nsetup\17nvim_comment\frequire\0" },
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/nvim-comment",
    url = "git@github.com:terrortylor/nvim-comment"
  },
  ["nvim-dap"] = {
    config = { "\27LJ\2\n\30\0\0\2\1\1\0\4-\0\0\0009\0\0\0B\0\1\1K\0\1\0\1¿\topen\31\0\0\2\1\1\0\4-\0\0\0009\0\0\0B\0\1\1K\0\1\0\1¿\nclose\31\0\0\2\1\1\0\4-\0\0\0009\0\0\0B\0\1\1K\0\1\0\1¿\ncloseg\0\0\5\0\a\0\f6\0\0\0009\0\1\0009\0\2\0'\2\3\0006\3\0\0009\3\1\0039\3\4\3B\3\1\2'\4\5\0&\3\4\3'\4\6\0D\0\4\0\tfile\6/\vgetcwd\25Path to executable: \ninput\afn\bvimi\0\1\5\2\3\1\15-\1\0\0\18\3\1\0009\1\0\1B\1\2\1-\1\1\0\18\3\1\0009\1\0\1B\1\2\1\b\0\0\0X\1\4Ä6\1\1\0'\3\2\0\18\4\0\0B\1\3\1K\0\1\0\2¿\3Ä\25dlv exited with code\nprint\nclose\0=\0\0\3\1\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0-\2\0\0B\0\2\1K\0\1\0\1¿\vappend\rdap.repl\frequireL\1\2\6\0\4\0\f6\2\0\0\19\4\0\0\18\5\0\0B\2\3\1\15\0\1\0X\2\4Ä6\2\1\0009\2\2\0023\4\3\0B\2\2\0012\0\0ÄK\0\1\0\0\rschedule\bvim\vassertF\0\0\4\2\2\0\6-\0\0\0005\2\0\0-\3\1\0=\3\1\2B\0\2\1K\0\1\0\0¿\5¿\tport\1\0\2\ttype\vserver\thost\014127.0.0.1∆\2\1\2\14\0\19\1-6\2\0\0009\2\1\0029\2\2\2+\4\1\0B\2\2\2,\3\4\0*\5\0\0005\6\4\0005\a\3\0>\2\2\a=\a\5\0065\a\6\0'\b\a\0\18\t\5\0&\b\t\b>\b\3\a=\a\b\0066\a\0\0009\a\1\a9\a\t\a'\t\n\0\18\n\6\0003\v\v\0B\a\4\3\18\4\b\0\18\3\a\0006\a\f\0\18\t\3\0'\n\r\0006\v\14\0\18\r\4\0B\v\2\2&\n\v\nB\a\3\1\18\t\2\0009\a\15\0023\n\16\0B\a\3\0016\a\0\0009\a\17\a3\t\18\0)\nd\0B\a\3\0012\0\0ÄK\0\1\0\0\rdefer_fn\0\15read_start\rtostring\24Error running dlv: \vassert\0\bdlv\nspawn\targs\015127.0.0.1:\1\3\0\0\bdap\a-l\nstdio\1\0\1\rdetached\2\1\0\0\rnew_pipe\tloop\bvim“‹\4‡\1\0\0\5\0\a\1#6\0\0\0009\0\1\0009\0\2\0B\0\1\0026\1\0\0009\1\1\0019\1\3\1\18\3\0\0'\4\4\0&\3\4\3B\1\2\2\t\1\0\0X\1\5Ä\18\1\0\0'\2\4\0&\1\2\1L\1\2\0X\1\16Ä6\1\0\0009\1\1\0019\1\3\1\18\3\0\0'\4\5\0&\3\4\3B\1\2\2\t\1\0\0X\1\5Ä\18\1\0\0'\2\5\0&\1\2\1L\1\2\0X\1\2Ä'\1\6\0L\1\2\0K\0\1\0\20/usr/bin/python\22/.venv/bin/python\21/venv/bin/python\15executable\vgetcwd\afn\bvim\2à\t\1\0\a\0.\0X6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\0016\0\4\0'\2\5\0B\0\2\0026\1\4\0'\3\6\0B\1\2\0029\2\a\0009\2\b\0029\2\t\0023\3\n\0=\3\6\0029\2\a\0009\2\b\0029\2\v\0023\3\f\0=\3\6\0029\2\a\0009\2\b\0029\2\r\0023\3\14\0=\3\6\0026\2\0\0009\2\15\0029\2\16\2'\4\17\0005\5\18\0B\2\3\0019\2\19\0005\3\21\0=\3\20\0029\2\22\0004\3\3\0005\4\24\0003\5\25\0=\5\26\0044\5\0\0=\5\27\4>\4\1\3=\3\23\0029\2\22\0009\3\22\0009\3\23\3=\3\28\0029\2\22\0009\3\22\0009\3\23\3=\3\29\0029\2\19\0003\3\31\0=\3\30\0029\2\22\0004\3\4\0005\4 \0>\4\1\0035\4!\0>\4\2\0035\4\"\0>\4\3\3=\3\30\0029\2\19\0005\3$\0006\4%\0009\4&\4'\6'\0B\4\2\2'\5(\0&\4\5\4=\4)\0035\4*\0=\4\27\3=\3#\0029\2\22\0004\3\3\0005\4+\0003\5,\0=\5-\4>\4\1\3=\3#\0022\0\0ÄK\0\1\0\15pythonPath\0\1\0\4\tname\16Launch file\fprogram\f${file}\frequest\vlaunch\ttype\vpython\1\3\0\0\a-m\20debugpy.adapter\fcommand4/.local/share/nvim/dapinstall/python/bin/python\tHOME\vgetenv\aos\1\0\1\ttype\15executable\vpython\1\0\5\frequest\vlaunch\ttype\ago\tmode\ttest\tname\24Debug test (go.mod)\fprogram\29./${relativeFileDirname}\1\0\5\frequest\vlaunch\ttype\ago\tmode\ttest\tname\15Debug test\fprogram\f${file}\1\0\4\tname\nDebug\fprogram\f${file}\frequest\vlaunch\ttype\ago\0\ago\trust\6c\targs\fprogram\0\1\0\6\frequest\vlaunch\18runInTerminal\1\bcwd\23${workspaceFolder}\16stopOnEntry\1\tname\vLaunch\ttype\tlldb\bcpp\19configurations\1\0\3\tname\tlldb\fcommand\25/usr/bin/lldb-vscode\ttype\15executable\tlldb\radapters\1\0\4\vlinehl\5\vtexthl\5\nnumhl\5\ttext\tüõë\18DapBreakpoint\16sign_define\afn\0\17event_exited\0\21event_terminated\0\22event_initialized\nafter\14listeners\ndapui\bdap\frequire\18packadd dapui\16packadd dap\bcmd\bvim\0" },
    load_after = {
      ["nvim-dap-ui"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-dap",
    url = "git@github.com:mfussenegger/nvim-dap"
  },
  ["nvim-dap-ui"] = {
    after = { "DAPInstall.nvim", "nvim-dap" },
    config = { "\27LJ\2\né\4\0\0\6\0\27\0%6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\a\0005\4\6\0=\4\b\3=\3\t\0025\3\14\0004\4\5\0005\5\n\0>\5\1\0045\5\v\0>\5\2\0045\5\f\0>\5\3\0045\5\r\0>\5\4\4=\4\15\3=\3\16\0025\3\18\0005\4\17\0=\4\15\3=\3\19\0025\3\20\0005\4\22\0005\5\21\0=\5\23\4=\4\t\3=\3\24\0025\3\25\0=\3\26\2B\0\2\1K\0\1\0\fwindows\1\0\1\vindent\3\1\rfloating\nclose\1\0\0\1\3\0\0\6q\n<Esc>\1\0\0\ttray\1\0\2\tsize\3\n\rposition\vbottom\1\2\0\0\trepl\fsidebar\relements\1\0\2\tsize\3(\rposition\tleft\1\0\2\tsize\4\0ÄÄ¿˛\3\aid\fwatches\1\0\2\tsize\4\0ÄÄ¿˛\3\aid\vstacks\1\0\2\tsize\4\0ÄÄ¿˛\3\aid\16breakpoints\1\0\2\tsize\4\0ÄÄ¿˛\3\aid\vscopes\rmappings\vexpand\1\0\4\trepl\6r\vremove\6d\topen\6o\tedit\6e\1\3\0\0\t<CR>\18<2-LeftMouse>\nicons\1\0\0\1\0\2\14collapsed\b‚ñ∏\rexpanded\b‚ñæ\nsetup\ndapui\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-dap-ui",
    url = "git@github.com:rcarriga/nvim-dap-ui"
  },
  ["nvim-gps"] = {
    after = { "lualine.nvim", "fidget.nvim" },
    config = { "\27LJ\2\n◊\1\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\14languages\1\0\b\15javascript\2\vpython\2\6c\2\tjava\2\bcpp\2\trust\2\ago\2\blua\2\nicons\1\0\1\14separator\t ¬ª \1\0\3\16method-name\tÔö¶ \15class-name\tÔ†ñ \18function-name\tÔûî \nsetup\rnvim-gps\frequire\0" },
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-gps",
    url = "git@github.com:SmiteshP/nvim-gps"
  },
  ["nvim-lightbulb"] = {
    config = { "\27LJ\2\në\4\0\0\5\0\20\0\0316\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0004\4\0\0=\4\t\3=\3\n\0025\3\v\0=\3\f\0025\3\r\0=\3\14\2B\0\2\0016\0\15\0009\0\16\0'\2\17\0B\0\2\0016\0\15\0009\0\16\0'\2\18\0B\0\2\0016\0\15\0009\0\16\0'\2\19\0B\0\2\1K\0\1\0-hi link LightBulbVirtualText YellowFloat*hi link LightBulbFloatWin YellowFloatTautocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()\bcmd\bvim\16status_text\1\0\3\ttext\tüí°\fenabled\1\21text_unavailable\5\17virtual_text\1\0\3\ttext\tüí°\fenabled\1\fhl_mode\freplace\nfloat\rwin_opts\1\0\2\ttext\tüí°\fenabled\1\tsign\1\0\2\rpriority\3\n\fenabled\2\vignore\1\0\0\1\3\0\0\16sumneko_lua\fnull-ls\nsetup\19nvim-lightbulb\frequire\0" },
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-lightbulb",
    url = "git@github.com:kosayoda/nvim-lightbulb"
  },
  ["nvim-lsp-installer"] = {
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-lsp-installer",
    url = "git@github.com:williamboman/nvim-lsp-installer"
  },
  ["nvim-lspconfig"] = {
    after = { "texmagic.nvim", "lsp_signature.nvim", "lspsaga.nvim", "nvim-lsp-installer", "nvim-lightbulb", "nvim-lsputils" },
    config = { "\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27modules.completion.lsp\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-lspconfig",
    url = "git@github.com:neovim/nvim-lspconfig"
  },
  ["nvim-lsputils"] = {
    config = { "\27LJ\2\nZ\0\3\n\0\3\0\t6\3\0\0'\5\1\0B\3\2\0029\3\2\3+\5\0\0\18\6\2\0,\a\t\0B\3\6\1K\0\1\0\24code_action_handler\23lsputil.codeAction\frequireo\0\3\t\1\5\0\f6\3\0\0'\5\1\0B\3\2\0029\3\2\3+\5\0\0\18\6\2\0005\a\3\0-\b\0\0=\b\4\a+\b\0\0B\3\5\1K\0\1\0\0¿\nbufnr\1\0\0\23references_handler\22lsputil.locations\frequirez\0\3\t\1\6\0\r6\3\0\0'\5\1\0B\3\2\0029\3\2\3+\5\0\0\18\6\2\0005\a\3\0-\b\0\0=\b\4\a=\1\5\a+\b\0\0B\3\5\1K\0\1\0\0¿\vmethod\nbufnr\1\0\0\23definition_handler\22lsputil.locations\frequire{\0\3\t\1\6\0\r6\3\0\0'\5\1\0B\3\2\0029\3\2\3+\5\0\0\18\6\2\0005\a\3\0-\b\0\0=\b\4\a=\1\5\a+\b\0\0B\3\5\1K\0\1\0\0¿\vmethod\nbufnr\1\0\0\24declaration_handler\22lsputil.locations\frequire~\0\3\t\1\6\0\r6\3\0\0'\5\1\0B\3\2\0029\3\2\3+\5\0\0\18\6\2\0005\a\3\0-\b\0\0=\b\4\a=\1\5\a+\b\0\0B\3\5\1K\0\1\0\0¿\vmethod\nbufnr\1\0\0\27typeDefinition_handler\22lsputil.locations\frequire~\0\3\t\1\6\0\r6\3\0\0'\5\1\0B\3\2\0029\3\2\3+\5\0\0\18\6\2\0005\a\3\0-\b\0\0=\b\4\a=\1\5\a+\b\0\0B\3\5\1K\0\1\0\0¿\vmethod\nbufnr\1\0\0\27implementation_handler\22lsputil.locations\frequiree\0\5\v\0\5\0\v6\5\0\0'\a\1\0B\5\2\0029\5\2\5+\a\0\0\18\b\2\0005\t\3\0=\4\4\t+\n\0\0B\5\5\1K\0\1\0\nbufnr\1\0\0\21document_handler\20lsputil.symbols\frequiref\0\5\v\0\5\0\v6\5\0\0'\a\1\0B\5\2\0029\5\2\5+\a\0\0\18\b\2\0005\t\3\0=\4\4\t+\n\0\0B\5\5\1K\0\1\0\nbufnr\1\0\0\22workspace_handler\20lsputil.symbols\frequire›\a\1\0\4\0%\1w6\0\0\0009\0\1\0009\0\2\0'\2\3\0B\0\2\2\t\0\0\0X\0AÄ6\0\0\0009\0\4\0009\0\5\0006\1\a\0'\3\b\0B\1\2\0029\1\t\1=\1\6\0006\0\0\0009\0\4\0009\0\5\0006\1\a\0'\3\v\0B\1\2\0029\1\f\1=\1\n\0006\0\0\0009\0\4\0009\0\5\0006\1\a\0'\3\v\0B\1\2\0029\1\14\1=\1\r\0006\0\0\0009\0\4\0009\0\5\0006\1\a\0'\3\v\0B\1\2\0029\1\16\1=\1\15\0006\0\0\0009\0\4\0009\0\5\0006\1\a\0'\3\v\0B\1\2\0029\1\18\1=\1\17\0006\0\0\0009\0\4\0009\0\5\0006\1\a\0'\3\v\0B\1\2\0029\1\20\1=\1\19\0006\0\0\0009\0\4\0009\0\5\0006\1\a\0'\3\22\0B\1\2\0029\1\23\1=\1\21\0006\0\0\0009\0\4\0009\0\5\0006\1\a\0'\3\22\0B\1\2\0029\1\25\1=\1\24\0X\0.Ä6\0\0\0009\0\26\0009\0\27\0)\2\0\0B\0\2\0026\1\0\0009\1\4\0019\1\5\0013\2\28\0=\2\6\0016\1\0\0009\1\4\0019\1\5\0013\2\29\0=\2\n\0016\1\0\0009\1\4\0019\1\5\0013\2\30\0=\2\r\0016\1\0\0009\1\4\0019\1\5\0013\2\31\0=\2\15\0016\1\0\0009\1\4\0019\1\5\0013\2 \0=\2\17\0016\1\0\0009\1\4\0019\1\5\0013\2!\0=\2\19\0016\1\0\0009\1\4\0019\1\5\0013\2\"\0=\2\21\0016\1\0\0009\1\4\0019\1\5\0013\2$\0=\2#\0012\0\0ÄK\0\1\0\0\24textDocument/symbol\0\0\0\0\0\0\0\24nvim_buf_get_number\bapi\22workspace_handler\21workspace/symbol\21document_handler\20lsputil.symbols textDocument/documentSymbol\27implementation_handler textDocument/implementation\27typeDefinition_handler textDocument/typeDefinition\24declaration_handler\29textDocument/declaration\23definition_handler\28textDocument/definition\23references_handler\22lsputil.locations\28textDocument/references\24code_action_handler\23lsputil.codeAction\frequire\28textDocument/codeAction\rhandlers\blsp\15nvim-0.5.1\bhas\afn\bvim\2\0" },
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-lsputils",
    url = "git@github.com:RishabhRD/nvim-lsputils"
  },
  ["nvim-notify"] = {
    config = { "\27LJ\2\n˝\1\0\0\6\0\b\0\0166\0\0\0006\2\1\0'\3\2\0B\0\3\3\14\0\0\0X\2\1ÄK\0\1\0005\2\3\0005\3\4\0=\3\5\0029\3\6\1\18\5\2\0B\3\2\0016\3\a\0=\1\2\3K\0\1\0\bvim\nsetup\nicons\1\0\5\nERROR\bÔÅó\tWARN\bÔÅ™\tINFO\bÔÅö\nDEBUG\bÔÜà\nTRACE\b‚úé\1\0\6\14max_width\0032\vrender\fdefault\vstages\tfade\18minimum_width\3\20\ftimeout\3à'\22background_colour\vNormal\vnotify\frequire\npcall\0" },
    load_after = {
      ["packer.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-notify",
    url = "git@github.com:rcarriga/nvim-notify"
  },
  ["nvim-tmux-navigation"] = {
    config = { "\27LJ\2\n—\6\0\0\6\0\26\00076\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\0016\0\4\0009\0\5\0009\0\6\0'\2\a\0'\3\b\0'\4\t\0005\5\n\0B\0\5\0016\0\4\0009\0\5\0009\0\6\0'\2\a\0'\3\v\0'\4\f\0005\5\r\0B\0\5\0016\0\4\0009\0\5\0009\0\6\0'\2\a\0'\3\14\0'\4\15\0005\5\16\0B\0\5\0016\0\4\0009\0\5\0009\0\6\0'\2\a\0'\3\17\0'\4\18\0005\5\19\0B\0\5\0016\0\4\0009\0\5\0009\0\6\0'\2\a\0'\3\20\0'\4\21\0005\5\22\0B\0\5\0016\0\4\0009\0\5\0009\0\6\0'\2\a\0'\3\23\0'\4\24\0005\5\25\0B\0\5\1K\0\1\0\1\0\2\vsilent\2\fnoremap\2B:lua require'nvim-tmux-navigation'.NvimTmuxNavigateNext()<cr>\14<C-Space>\1\0\2\vsilent\2\fnoremap\2H:lua require'nvim-tmux-navigation'.NvimTmuxNavigateLastActive()<cr>\n<C-\\>\1\0\2\vsilent\2\fnoremap\2C:lua require'nvim-tmux-navigation'.NvimTmuxNavigateRight()<cr>\n<C-l>\1\0\2\vsilent\2\fnoremap\2@:lua require'nvim-tmux-navigation'.NvimTmuxNavigateUp()<cr>\n<C-k>\1\0\2\vsilent\2\fnoremap\2B:lua require'nvim-tmux-navigation'.NvimTmuxNavigateDown()<cr>\n<C-j>\1\0\2\vsilent\2\fnoremap\2B:lua require'nvim-tmux-navigation'.NvimTmuxNavigateLeft()<cr>\n<C-h>\6n\20nvim_set_keymap\bapi\bvim\1\0\1\24disable_when_zoomed\2\nsetup\25nvim-tmux-navigation\frequire\0" },
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/nvim-tmux-navigation",
    url = "git@github.com:alexghergh/nvim-tmux-navigation"
  },
  ["nvim-toggleterm.lua"] = {
    config = { "\27LJ\2\ny\0\1\2\0\6\1\0159\1\0\0\a\1\1\0X\1\3Ä)\1\15\0L\1\2\0X\1\bÄ9\1\0\0\a\1\2\0X\1\5Ä6\1\3\0009\1\4\0019\1\5\1\24\1\0\1L\1\2\0K\0\1\0\fcolumns\6o\bvim\rvertical\15horizontal\14directionµÊÃô\19ô≥Ê˛\3ñ\2\1\0\4\0\n\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\0024\3\0\0=\3\6\0026\3\a\0009\3\b\0039\3\t\3=\3\t\2B\0\2\1K\0\1\0\nshell\6o\bvim\20shade_filetypes\tsize\1\0\t\14direction\rvertical\18close_on_exit\2\20shade_terminals\1\19shading_factor\0061\20insert_mappings\2\17persist_size\2\20start_in_insert\2\17open_mapping\n<c-\\>\17hide_numbers\2\0\nsetup\15toggleterm\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-toggleterm.lua",
    url = "git@github.com:akinsho/nvim-toggleterm.lua"
  },
  ["nvim-tree.lua"] = {
    commands = { "NvimTreeToggle", "NvimTreeOpen" },
    config = { "\27LJ\2\n›\5\0\0\6\0\29\0%6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0004\3\0\0=\3\4\0025\3\5\0=\3\6\0025\3\a\0005\4\b\0=\4\t\3=\3\n\0025\3\v\0004\4\0\0=\4\f\3=\3\r\0025\3\14\0004\4\0\0=\4\15\3=\3\16\0025\3\17\0004\4\0\0=\4\18\3=\3\19\0025\3\20\0=\3\21\0025\3\22\0005\4\23\0004\5\0\0=\5\24\4=\4\25\3=\3\26\0025\3\27\0=\3\28\2B\0\2\1K\0\1\0\ntrash\1\0\2\20require_confirm\2\bcmd\brip\tview\rmappings\tlist\1\0\1\16custom_only\1\1\0\b\vnumber\1\21hide_root_folder\1\nwidth\3\30\vheight\3\30\15signcolumn\byes\16auto_resize\1\19relativenumber\1\tside\tleft\bgit\1\0\3\venable\2\ftimeout\3Ù\3\vignore\2\ffilters\vcustom\1\0\1\rdotfiles\2\16system_open\targs\1\0\0\24update_focused_file\16ignore_list\1\0\2\15update_cwd\2\venable\2\16diagnostics\nicons\1\0\4\thint\bÔÅ™\nerror\bÔÅó\fwarning\bÔÅ±\tinfo\bÔÅö\1\0\1\venable\1\22update_to_buf_dir\1\0\2\venable\2\14auto_open\2\23ignore_ft_on_setup\1\0\b\17hijack_netrw\2\18hijack_cursor\2\18open_on_setup\1\15auto_close\2\21hide_root_folder\2\16open_on_tab\1\15update_cwd\1\18disable_netrw\2\nsetup\14nvim-tree\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-tree.lua",
    url = "git@github.com:kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    after = { "vim-matchup", "nvim-ts-autotag", "nvim-ts-hint-textobject", "nvim-ts-context-commentstring", "nvim-treesitter-context", "nvim-treesitter-textobjects", "spellsitter.nvim", "playground", "zen-mode.nvim", "nvim-gps" },
    config = { "\27LJ\2\nß\b\0\0\6\0,\00066\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\0016\0\4\0'\2\5\0B\0\2\0029\0\6\0005\2\b\0005\3\a\0=\3\t\0025\3\n\0=\3\v\0025\3\f\0=\3\r\0025\3\14\0=\3\15\0025\3\16\0=\3\17\0025\3\18\0=\3\19\0025\3\20\0005\4\21\0005\5\22\0=\5\23\4=\4\24\0035\4\25\0005\5\26\0=\5\27\0045\5\28\0=\5\29\0045\5\30\0=\5\31\0045\5 \0=\5!\4=\4\"\3=\3#\2B\0\2\0016\0$\0009\0%\0009\0&\0'\2'\0B\0\2\0029\0(\0\18\1\0\0B\1\1\0029\1)\1'\2+\0=\2*\1K\0\1\0\tocto\27filetype_to_parsername\rmarkdown\23get_parser_configs\28nvim-treesitter.parsers\29require_on_exported_call\v__lazy\a_G\16textobjects\tmove\22goto_previous_end\1\0\2\a[]\17@class.outer\a[M\20@function.outer\24goto_previous_start\1\0\2\a[[\17@class.outer\a[m\20@function.outer\18goto_next_end\1\0\2\a][\17@class.outer\a]M\20@function.outer\20goto_next_start\1\0\2\a]m\20@function.outer\a]]\17@class.outer\1\0\2\venable\2\14set_jumps\2\vselect\fkeymaps\1\0\4\aaf\20@function.outer\aac\17@class.outer\aic\17@class.inner\aif\20@function.inner\1\0\1\venable\2\1\0\1\venable\2\fcontext\1\0\2\rthrottle\2\venable\2\fmatchup\1\0\1\venable\2\26context_commentstring\1\0\2\venable\2\19enable_autocmd\1\frainbow\1\0\3\19max_file_lines\3Ë\a\venable\2\18extended_mode\2\14highlight\1\0\1\venable\2\21ensure_installed\1\0\0\1\v\0\0\vpython\ago\bnix\bhcl\trust\15typescript\6c\tjava\blua\15javascript\nsetup\28nvim-treesitter.configs\frequire,set foldexpr=nvim_treesitter#foldexpr()\24set foldmethod=expr\bcmd\bvim\0" },
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
    config = { "\27LJ\2\nÜ\20\0\0\5\0\21\0\0256\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\t\0005\4\b\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\a\3=\3\20\2B\0\2\1K\0\1\0\rmappings\1\0\n\22select_next_entry\a]q\17toggle_files\14<leader>b\15prev_entry\6k\15next_entry\6j\22select_prev_entry\a[q\18toggle_viewed\20<leader><space>\21close_review_tab\n<C-c>\18refresh_files\6R\17select_entry\t<cr>\16focus_files\14<leader>e\16review_diff\1\0\n\22select_next_entry\a]q\17toggle_files\14<leader>b\23add_review_comment\14<space>ca\16prev_thread\a[t\22select_prev_entry\a[q\16next_thread\a]t\18toggle_viewed\20<leader><space>\21close_review_tab\n<C-c>\26add_review_suggestion\14<space>sa\16focus_files\14<leader>e\15submit_win\1\0\4\21close_review_tab\n<C-c>\19comment_review\n<C-m>\19approve_review\n<C-a>\20request_changes\n<C-r>\18review_thread\1\0\17\17next_comment\a]c\22select_next_entry\a]q\19delete_comment\14<space>cd\16react_heart\14<space>rh\22select_prev_entry\a[q\16add_comment\14<space>ca\15goto_issue\14<space>gi\20react_thumbs_up\14<space>r+\15react_eyes\14<space>re\19add_suggestion\14<space>sa\19react_confused\14<space>rc\16react_laugh\14<space>rl\17react_rocket\14<space>rr\22react_thumbs_down\14<space>r-\21close_review_tab\n<C-c>\17react_hooray\14<space>rp\17prev_comment\a[c\17pull_request\1\0\31\16close_issue\14<space>ic\17remove_label\14<space>ld\20remove_reviewer\14<space>vd\15goto_issue\14<space>gi\vreload\n<C-r>\16add_comment\14<space>ca\17add_reviewer\14<space>va\17show_pr_diff\14<space>pd\rmerge_pr\14<space>pm\23list_changed_files\14<space>pf\19delete_comment\14<space>cd\17list_commits\14<space>pc\17next_comment\a]c\14add_label\14<space>la\17prev_comment\a[c\16checkout_pr\14<space>po\17react_hooray\14<space>rp\17create_label\14<space>lc\19react_confused\14<space>rc\15react_eyes\14<space>re\20remove_assignee\14<space>ad\20react_thumbs_up\14<space>r+\17add_assignee\14<space>aa\22react_thumbs_down\14<space>r-\rcopy_url\n<C-y>\17react_rocket\14<space>rr\20open_in_browser\n<C-b>\16react_laugh\14<space>rl\16list_issues\14<space>il\16react_heart\14<space>rh\17reopen_issue\14<space>io\nissue\1\0\0\1\0\24\17next_comment\a]c\17reopen_issue\14<space>io\19delete_comment\14<space>cd\17remove_label\14<space>ld\vreload\n<C-r>\16close_issue\14<space>ic\17react_hooray\14<space>rp\16react_heart\14<space>rh\20react_thumbs_up\14<space>r+\16add_comment\14<space>ca\22react_thumbs_down\14<space>r-\15goto_issue\14<space>gi\17react_rocket\14<space>rr\14add_label\14<space>la\16react_laugh\14<space>rl\15react_eyes\14<space>re\17create_label\14<space>lc\19react_confused\14<space>rc\20remove_assignee\14<space>ad\17add_assignee\14<space>aa\rcopy_url\n<C-y>\20open_in_browser\n<C-b>\16list_issues\14<space>il\17prev_comment\a[c\15file_panel\1\0\2\tsize\3\n\14use_icons\2\19default_remote\1\0\b\20timeline_marker\bÔë†\30reaction_viewer_hint_icon\bÔëÑ\20timeline_indent\0062\26snippet_context_lines\3\4\27right_bubble_delimiter\bÓÇ¥\26left_bubble_delimiter\bÓÇ∂\14user_icon\tÔäΩ \20github_hostname\5\1\3\0\0\rupstream\vorigin\nsetup\tocto\frequire\0" },
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
    after = { "nvim-notify" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/packer.nvim",
    url = "git@github.com:wbthomason/packer.nvim"
  },
  playground = {
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/playground",
    url = "git@github.com:nvim-treesitter/playground"
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
  ["popup.nvim"] = {
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/popup.nvim",
    url = "git@github.com:nvim-lua/popup.nvim"
  },
  ["rust-tools.nvim"] = {
    config = { "\27LJ\2\n≈\5\0\0\5\0\24\0&5\0\18\0005\1\0\0005\2\1\0=\2\2\0015\2\3\0=\2\4\0015\2\5\0=\2\6\0015\2\15\0004\3\t\0005\4\a\0>\4\1\0035\4\b\0>\4\2\0035\4\t\0>\4\3\0035\4\n\0>\4\4\0035\4\v\0>\4\5\0035\4\f\0>\4\6\0035\4\r\0>\4\a\0035\4\14\0>\4\b\3=\3\16\2=\2\17\1=\1\19\0004\1\0\0=\1\20\0006\1\21\0'\3\22\0B\1\2\0029\1\23\1\18\3\0\0B\1\2\1K\0\1\0\nsetup\15rust-tools\frequire\vserver\ntools\1\0\0\18hover_actions\vborder\1\0\1\15auto_focus\1\1\3\0\0\b‚îÇ\16FloatBorder\1\3\0\0\b‚ï∞\16FloatBorder\1\3\0\0\b‚îÄ\16FloatBorder\1\3\0\0\b‚ïØ\16FloatBorder\1\3\0\0\b‚îÇ\16FloatBorder\1\3\0\0\b‚ïÆ\16FloatBorder\1\3\0\0\b‚îÄ\16FloatBorder\1\3\0\0\b‚ï≠\16FloatBorder\16inlay_hints\1\0\t\16right_align\1\22only_current_line\1\30only_current_line_autocmd\15CursorHold\27parameter_hints_prefix\b<- \23other_hints_prefix\t ¬ª \18max_len_align\1\26max_len_align_padding\3\1\24right_align_padding\3\a\25show_parameter_hints\2\16debuggables\1\0\1\18use_telescope\2\14runnables\1\0\1\18use_telescope\2\1\0\2\17autoSetHints\2\23hover_with_actions\2\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/rust-tools.nvim",
    url = "git@github.com:simrat39/rust-tools.nvim"
  },
  ["spellsitter.nvim"] = {
    config = { "\27LJ\2\n9\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\16spellsitter\frequire\0" },
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/spellsitter.nvim",
    url = "git@github.com:lewis6991/spellsitter.nvim"
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
    config = { "\27LJ\2\nô\v\0\0\5\0=\0A6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0024\3\0\0=\3\6\0025\3\b\0005\4\a\0=\4\t\0035\4\n\0=\4\v\0035\4\f\0=\4\r\0035\4\14\0=\4\15\0035\4\16\0=\4\17\0035\4\18\0=\4\19\0035\4\20\0=\4\21\0035\4\22\0=\4\23\0035\4\24\0=\4\25\0035\4\26\0=\4\27\0035\4\28\0=\4\29\0035\4\30\0=\4\31\0035\4 \0=\4!\0035\4\"\0=\4#\0035\4$\0=\4%\0035\4&\0=\4'\0035\4(\0=\4)\0035\4*\0=\4+\0035\4,\0=\4-\0035\4.\0=\4/\0035\0040\0=\0041\0035\0042\0=\0043\0035\0044\0=\0045\0035\0046\0=\0047\0035\0048\0=\0049\0035\4:\0=\4;\3=\3<\2B\0\2\1K\0\1\0\fsymbols\18TypeParameter\1\0\2\ahl\16TSParameter\ticon\tùôè\rOperator\1\0\2\ahl\15TSOperator\ticon\6+\nEvent\1\0\2\ahl\vTSType\ticon\tüó≤\vStruct\1\0\2\ahl\vTSType\ticon\tùì¢\15EnumMember\1\0\2\ahl\fTSField\ticon\bÔÖù\tNull\1\0\2\ahl\vTSType\ticon\tNULL\bKey\1\0\2\ahl\vTSType\ticon\tüîê\vObject\1\0\2\ahl\vTSType\ticon\b‚¶ø\nArray\1\0\2\ahl\15TSConstant\ticon\bÔô©\fBoolean\1\0\2\ahl\14TSBoolean\ticon\b‚ä®\vNumber\1\0\2\ahl\rTSNumber\ticon\6#\vString\1\0\2\ahl\rTSString\ticon\tùìê\rConstant\1\0\2\ahl\15TSConstant\ticon\bÓà¨\rVariable\1\0\2\ahl\15TSConstant\ticon\bÓûõ\rFunction\1\0\2\ahl\15TSFunction\ticon\bÔÇö\14Interface\1\0\2\ahl\vTSType\ticon\bÔ∞Æ\tEnum\1\0\2\ahl\vTSType\ticon\b‚Ñ∞\16Constructor\1\0\2\ahl\18TSConstructor\ticon\bÓàè\nField\1\0\2\ahl\fTSField\ticon\bÔöß\rProperty\1\0\2\ahl\rTSMethod\ticon\bÓò§\vMethod\1\0\2\ahl\rTSMethod\ticon\a∆í\nClass\1\0\2\ahl\vTSType\ticon\tùìí\fPackage\1\0\2\ahl\16TSNamespace\ticon\bÔ£ñ\14Namespace\1\0\2\ahl\16TSNamespace\ticon\bÔô©\vModule\1\0\2\ahl\16TSNamespace\ticon\bÔö¶\tFile\1\0\0\1\0\2\ahl\nTSURI\ticon\bÔúì\18lsp_blacklist\fkeymaps\1\0\6\19focus_location\6o\17code_actions\6a\nclose\n<Esc>\17hover_symbol\14<C-space>\18rename_symbol\6r\18goto_location\t<Cr>\1\0\t\25preview_bg_highlight\nPmenu\27highlight_hovered_item\2\16show_guides\2\17auto_preview\2\nwidth\3<\rposition\nright\17show_numbers\2\26show_relative_numbers\2\24show_symbol_details\2\nsetup\20symbols-outline\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/symbols-outline.nvim",
    url = "git@github.com:simrat39/symbols-outline.nvim"
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
    after = { "telescope-zoxide", "sqlite.lua" },
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
  ["telescope-project.nvim"] = {
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope-project.nvim",
    url = "git@github.com:nvim-telescope/telescope-project.nvim"
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
  ["telescope-zoxide"] = {
    load_after = {
      ["telescope-frecency.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope-zoxide",
    url = "git@github.com:jvgrootveld/telescope-zoxide"
  },
  ["telescope.nvim"] = {
    after = { "popup.nvim", "telescope-frecency.nvim", "telescope-file-browser.nvim", "telescope-project.nvim", "telescope-ui-select.nvim", "telescope-fzf-native.nvim", "cheatsheet.nvim", "telescope-emoji.nvim", "octo.nvim" },
    commands = { "Telescope" },
    config = { "\27LJ\2\nΩ\1\0\0\3\3\b\0\28-\0\0\0-\2\1\0B\0\2\1-\0\2\0'\2\0\0B\0\2\1-\0\2\0'\2\1\0B\0\2\1-\0\2\0'\2\2\0B\0\2\1-\0\2\0'\2\3\0B\0\2\1-\0\2\0'\2\4\0B\0\2\1-\0\2\0'\2\5\0B\0\2\1-\0\2\0'\2\6\0B\0\2\1-\0\2\0'\2\a\0B\0\2\1K\0\1\0\1¿\2¿\0¿\nemoji\vnotify\fproject\17file_browser\14ui-select\rfrecency\vzoxide\bfzfÈ\v\1\0\b\0;\1q6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\0016\0\0\0009\0\1\0'\2\4\0B\0\2\0016\0\0\0009\0\1\0'\2\5\0B\0\2\0016\0\0\0009\0\1\0'\2\6\0B\0\2\0016\0\0\0009\0\1\0'\2\a\0B\0\2\0016\0\0\0009\0\1\0'\2\b\0B\0\2\0016\0\0\0009\0\1\0'\2\t\0B\0\2\0016\0\n\0009\0\v\0009\0\f\0'\2\r\0B\0\2\0029\0\14\0006\1\n\0009\1\v\0019\1\f\1'\3\r\0B\1\2\0029\1\15\0015\2,\0005\3\16\0005\4\18\0005\5\17\0=\5\19\0045\5\20\0=\5\21\4=\4\22\0036\4\23\0'\6\24\0B\4\2\0029\4\25\0049\4\26\4=\4\27\0036\4\23\0'\6\24\0B\4\2\0029\4\28\0049\4\26\4=\4\29\0036\4\23\0'\6\24\0B\4\2\0029\4\30\0049\4\26\4=\4\31\0036\4\23\0'\6 \0B\4\2\0029\4!\4=\4\"\0035\4#\0=\4$\0036\4\23\0'\6 \0B\4\2\0029\4%\4=\4&\0035\4'\0=\4(\0034\4\0\0=\4)\0035\4*\0=\4+\3=\3-\0025\0030\0004\4\3\0006\5\23\0'\a.\0B\5\2\0029\5/\0054\a\0\0B\5\2\0?\5\0\0=\0041\0035\0042\0=\0043\0035\0044\0005\0055\0=\0056\4=\0047\3=\0038\0026\3\0\0009\0039\0033\5:\0)\6\0\0B\3\3\0012\0\0ÄK\0\1\0\0\rdefer_fn\15extensions\rfrecency\20ignore_patterns\1\3\0\0\f*.git/*\f*/tmp/*\1\0\2\19show_unindexed\2\16show_scores\2\bfzf\1\0\4\28override_generic_sorter\2\nfuzzy\1\25override_file_sorter\2\14case_mode\15smart_case\14ui-select\1\0\0\17get_dropdown\21telescope.themes\rdefaults\1\0\0\fset_env\1\0\1\14COLORTERM\14truecolor\vborder\17path_display\1\2\0\0\rabsolute\19generic_sorter\29get_generic_fuzzy_sorter\25file_ignore_patterns\1\2\0\0\19__compiled.lua\16file_sorter\19get_fuzzy_file\22telescope.sorters\21qflist_previewer\22vim_buffer_qflist\19grep_previewer\23vim_buffer_vimgrep\19file_previewer\bnew\19vim_buffer_cat\25telescope.previewers\frequire\18layout_config\rvertical\1\0\1\vmirror\1\15horizontal\1\0\0\1\0\2\18results_width\4≥ÊÃô\3≥Êåˇ\3\20prompt_position\vbottom\1\0\5\20selection_caret\b¬ª \18prompt_prefix\nüî≠ \rwinblend\3\0\19color_devicons\2\ruse_less\2\nsetup\19load_extension\14telescope\29require_on_exported_call\v__lazy\a_G%packadd telescope-ui-select.nvim!packadd telescope-emoji.nvim\29packadd telescope-zoxide$packadd telescope-frecency.nvim#packadd telescope-project.nvim(packadd telescope-file-browser.nvim&packadd telescope-fzf-native.nvim\23packadd sqlite.lua\bcmd\bvim\3ÄÄ¿ô\4\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope.nvim",
    url = "git@github.com:nvim-telescope/telescope.nvim"
  },
  ["texmagic.nvim"] = {
    config = { "\27LJ\2\n:\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\rtexmagic\frequire\0" },
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/texmagic.nvim",
    url = "git@github.com:jakewvincent/texmagic.nvim"
  },
  ["trouble.nvim"] = {
    commands = { "Trouble", "TroubleToggle", "TroubleRefresh" },
    config = { "\27LJ\2\nõ\5\0\0\5\0\24\0\0276\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\2B\0\2\1K\0\1\0\nsigns\1\0\5\thint\bÔ†µ\nother\bÔ´†\nerror\bÔôô\16information\bÔëâ\fwarning\bÔî©\16action_keys\16toggle_fold\1\3\0\0\azA\aza\15open_folds\1\3\0\0\azR\azr\16close_folds\1\3\0\0\azM\azm\15jump_close\1\2\0\0\6o\ropen_tab\1\2\0\0\n<c-t>\16open_vsplit\1\2\0\0\n<c-v>\15open_split\1\2\0\0\n<c-x>\tjump\1\3\0\0\t<cr>\n<tab>\1\0\t\19toggle_preview\6P\frefresh\6r\16toggle_mode\6m\tnext\6j\rprevious\6k\nclose\6q\vcancel\n<esc>\nhover\6K\fpreview\6p\1\0\r\rposition\vbottom\14auto_open\1\14fold_open\bÔëº\15auto_close\1\vheight\3\n\nwidth\0032\17indent_lines\2\29use_lsp_diagnostic_signs\1\nicons\2\14auto_fold\1\tmode\25document_diagnostics\16fold_closed\bÔë†\17auto_preview\2\nsetup\ftrouble\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/trouble.nvim",
    url = "git@github.com:folke/trouble.nvim"
  },
  ["twilight.nvim"] = {
    config = { "\27LJ\2\nˆ\1\0\0\6\0\f\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\3\0005\3\6\0005\4\3\0005\5\4\0=\5\5\4=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\3>\3\1\2B\0\2\1K\0\1\0\fexclude\1\2\0\0\n.git*\vexpand\1\5\0\0\rfunction\vmethod\ntable\17if_statement\fdimming\1\0\2\15treesitter\2\fcontext\0032\ncolor\1\3\0\0\vNormal\f#ffffff\1\0\2\rinactive\2\nalpha\4\0ÄÄÄˇ\3\nsetup\rtwilight\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/twilight.nvim",
    url = "git@github.com:folke/twilight.nvim"
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
    commands = { "Git", "G" },
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
  ["vim-startuptime"] = {
    commands = { "StartupTime" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-startuptime",
    url = "git@github.com:dstein64/vim-startuptime"
  },
  ["vim-surround"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-surround",
    url = "git@github.com:tpope/vim-surround"
  },
  ["vim-wakatime"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-wakatime",
    url = "git@github.com:wakatime/vim-wakatime"
  },
  vimtex = {
    config = { "\27LJ\2\nµ\1\0\0\2\0\6\0\t6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0K\0\1\0\23-r @line @pdf @tex vimtex_view_general_options>/Applications/Skim.app/Contents/SharedSupport/displayline\31vimtex_view_general_viewer\6g\bvim\0" },
    loaded = false,
    needs_bufread = true,
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
    config = { "\27LJ\2\nà\17\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0Ë\16call wilder#setup({'modes': [':', '/', '?']})\n\ncall wilder#set_option('pipeline', [\n      \\   wilder#branch(\n      \\     wilder#python_file_finder_pipeline({\n      \\       'file_command': {_, arg -> stridx(arg, '.') != -1 ? ['fd', '-tf', '-H'] : ['fd', '-tf']},\n      \\       'dir_command': ['fd', '-td'],\n      \\     }),\n      \\     wilder#substitute_pipeline({\n      \\       'pipeline': wilder#python_search_pipeline({\n      \\         'skip_cmdtype_check': 1,\n      \\         'pattern': wilder#python_fuzzy_pattern({\n      \\           'start_at_boundary': 0,\n      \\         }),\n      \\       }),\n      \\     }),\n      \\     wilder#cmdline_pipeline({\n      \\       'fuzzy': 1,\n      \\       'fuzzy_filter': has('nvim') ? wilder#lua_fzy_filter() : wilder#vim_fuzzy_filter(),\n      \\     }),\n      \\     [\n      \\       wilder#check({_, x -> empty(x)}),\n      \\       wilder#history(),\n      \\     ],\n      \\     wilder#python_search_pipeline({\n      \\       'pattern': wilder#python_fuzzy_pattern({\n      \\         'start_at_boundary': 0,\n      \\       }),\n      \\     }),\n      \\   ),\n      \\ ])\n\nlet s:highlighters = [\n      \\ wilder#pcre2_highlighter(),\n      \\ wilder#lua_fzy_highlighter(),\n      \\ ]\n\nlet s:popupmenu_renderer = wilder#popupmenu_renderer(wilder#popupmenu_border_theme({\n      \\ 'empty_message': wilder#popupmenu_empty_message_with_spinner(),\n      \\ 'highlighter': s:highlighters,\n      \\ 'left': [\n      \\   ' ',\n      \\   wilder#popupmenu_devicons(),\n      \\   wilder#popupmenu_buffer_flags({\n      \\     'flags': ' a + ',\n      \\     'icons': {'+': 'Ô£™', 'a': 'Ôúì', 'h': 'Ôú£'},\n      \\   }),\n      \\ ],\n      \\ 'right': [\n      \\   ' ',\n      \\   wilder#popupmenu_scrollbar(),\n      \\ ],\n      \\ }))\n\nlet s:wildmenu_renderer = wilder#wildmenu_renderer({\n      \\ 'highlighter': s:highlighters,\n      \\ 'separator': ' ¬∑ ',\n      \\ 'left': [' ', wilder#wildmenu_spinner(), ' '],\n      \\ 'right': [' ', wilder#wildmenu_index()],\n      \\ })\n\ncall wilder#set_option('renderer', wilder#renderer_mux({\n      \\ ':': s:popupmenu_renderer,\n      \\ '/': s:wildmenu_renderer,\n      \\ 'substitute': s:wildmenu_renderer,\n      \\ }))\n\bcmd\bvim\0" },
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

-- Setup for: wilder.nvim
time([[Setup for wilder.nvim]], true)
try_loadstring("\27LJ\2\nS\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\16wilder.nvim\21packer_lazy_load\15core.utils\frequire\0", "setup", "wilder.nvim")
time([[Setup for wilder.nvim]], false)
-- Setup for: vim-matchup
time([[Setup for vim-matchup]], true)
try_loadstring("\27LJ\2\nS\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0'\2\3\0B\0\2\1K\0\1\0\16vim-matchup\21packer_lazy_load\15core.utils\frequire\0", "setup", "vim-matchup")
time([[Setup for vim-matchup]], false)
-- Config for: nvim-comment
time([[Config for nvim-comment]], true)
try_loadstring("\27LJ\2\n^\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\25update_commentstring&ts_context_commentstring.internal\frequireO\1\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\2B\0\2\1K\0\1\0\thook\1\0\0\0\nsetup\17nvim_comment\frequire\0", "config", "nvim-comment")
time([[Config for nvim-comment]], false)
-- Config for: kanagawa
time([[Config for kanagawa]], true)
try_loadstring("\27LJ\2\n⁄\2\0\0\4\0\t\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0004\3\0\0=\3\4\0024\3\0\0=\3\5\2B\0\2\0016\0\6\0009\0\a\0'\2\b\0B\0\2\1K\0\1\0!silent! colorscheme kanagawa\bcmd\bvim\14overrides\vcolors\1\0\v\18functionStyle\16bold,italic\17keywordStyle\vitalic\19statementStyle\tbold\14typeStyle\tNONE\25variablebuiltinStyle\vitalic\18specialReturn\2\21specialException\2\16transparent\1\16dimInactive\2\14undercurl\2\17commentStyle\vitalic\nsetup\rkanagawa\frequire\0", "config", "kanagawa")
time([[Config for kanagawa]], false)
-- Config for: nvim-tmux-navigation
time([[Config for nvim-tmux-navigation]], true)
try_loadstring("\27LJ\2\n—\6\0\0\6\0\26\00076\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\0016\0\4\0009\0\5\0009\0\6\0'\2\a\0'\3\b\0'\4\t\0005\5\n\0B\0\5\0016\0\4\0009\0\5\0009\0\6\0'\2\a\0'\3\v\0'\4\f\0005\5\r\0B\0\5\0016\0\4\0009\0\5\0009\0\6\0'\2\a\0'\3\14\0'\4\15\0005\5\16\0B\0\5\0016\0\4\0009\0\5\0009\0\6\0'\2\a\0'\3\17\0'\4\18\0005\5\19\0B\0\5\0016\0\4\0009\0\5\0009\0\6\0'\2\a\0'\3\20\0'\4\21\0005\5\22\0B\0\5\0016\0\4\0009\0\5\0009\0\6\0'\2\a\0'\3\23\0'\4\24\0005\5\25\0B\0\5\1K\0\1\0\1\0\2\vsilent\2\fnoremap\2B:lua require'nvim-tmux-navigation'.NvimTmuxNavigateNext()<cr>\14<C-Space>\1\0\2\vsilent\2\fnoremap\2H:lua require'nvim-tmux-navigation'.NvimTmuxNavigateLastActive()<cr>\n<C-\\>\1\0\2\vsilent\2\fnoremap\2C:lua require'nvim-tmux-navigation'.NvimTmuxNavigateRight()<cr>\n<C-l>\1\0\2\vsilent\2\fnoremap\2@:lua require'nvim-tmux-navigation'.NvimTmuxNavigateUp()<cr>\n<C-k>\1\0\2\vsilent\2\fnoremap\2B:lua require'nvim-tmux-navigation'.NvimTmuxNavigateDown()<cr>\n<C-j>\1\0\2\vsilent\2\fnoremap\2B:lua require'nvim-tmux-navigation'.NvimTmuxNavigateLeft()<cr>\n<C-h>\6n\20nvim_set_keymap\bapi\bvim\1\0\1\24disable_when_zoomed\2\nsetup\25nvim-tmux-navigation\frequire\0", "config", "nvim-tmux-navigation")
time([[Config for nvim-tmux-navigation]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Octo lua require("packer.load")({'octo.nvim'}, { cmd = "Octo", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file NvimTreeToggle lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file G lua require("packer.load")({'vim-fugitive'}, { cmd = "G", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SymbolsOutline lua require("packer.load")({'symbols-outline.nvim'}, { cmd = "SymbolsOutline", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Git lua require("packer.load")({'vim-fugitive'}, { cmd = "Git", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DIInstall lua require("packer.load")({'DAPInstall.nvim'}, { cmd = "DIInstall", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DIUninstall lua require("packer.load")({'DAPInstall.nvim'}, { cmd = "DIUninstall", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DIList lua require("packer.load")({'DAPInstall.nvim'}, { cmd = "DIList", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Trouble lua require("packer.load")({'trouble.nvim'}, { cmd = "Trouble", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TroubleRefresh lua require("packer.load")({'trouble.nvim'}, { cmd = "TroubleRefresh", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file EasyAlign lua require("packer.load")({'vim-easy-align'}, { cmd = "EasyAlign", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TroubleToggle lua require("packer.load")({'trouble.nvim'}, { cmd = "TroubleToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file StartupTime lua require("packer.load")({'vim-startuptime'}, { cmd = "StartupTime", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Telescope lua require("packer.load")({'telescope.nvim'}, { cmd = "Telescope", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file NvimTreeOpen lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SymbolsOutlineOpen lua require("packer.load")({'symbols-outline.nvim'}, { cmd = "SymbolsOutlineOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Bdelete lua require("packer.load")({'bufdelete.nvim'}, { cmd = "Bdelete", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Bwipeout lua require("packer.load")({'bufdelete.nvim'}, { cmd = "Bwipeout", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[au CmdUndefined Bdelete! ++once lua require"packer.load"({'bufdelete.nvim'}, {}, _G.packer_plugins)]])
pcall(vim.cmd, [[au CmdUndefined Bwipeout! ++once lua require"packer.load"({'bufdelete.nvim'}, {}, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file JupyterExecuteAll lua require("packer.load")({'jupyter_ascending.vim'}, { cmd = "JupyterExecuteAll", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file JupyterExecute lua require("packer.load")({'jupyter_ascending.vim'}, { cmd = "JupyterExecute", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType xml ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "xml" }, _G.packer_plugins)]]
vim.cmd [[au FileType go ++once lua require("packer.load")({'vim-go'}, { ft = "go" }, _G.packer_plugins)]]
vim.cmd [[au FileType rust ++once lua require("packer.load")({'rust-tools.nvim'}, { ft = "rust" }, _G.packer_plugins)]]
vim.cmd [[au FileType html ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "html" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'markdown-preview.nvim'}, { ft = "markdown" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au BufNewFile * ++once lua require("packer.load")({'dashboard-nvim', 'gitsigns.nvim'}, { event = "BufNewFile *" }, _G.packer_plugins)]]
vim.cmd [[au BufRead * ++once lua require("packer.load")({'nvim-toggleterm.lua', 'gitsigns.nvim', 'nvim-treesitter', 'nvim-colorizer.lua', 'FTerm.nvim', 'nvim-bufferline.lua', 'minimap.vim', 'indent-blankline.nvim'}, { event = "BufRead *" }, _G.packer_plugins)]]
vim.cmd [[au CmdlineEnter * ++once lua require("packer.load")({'wilder.nvim'}, { event = "CmdlineEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'nvim-lspconfig'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
vim.cmd [[au BufEnter * ++once lua require("packer.load")({'nvim-notify', 'dressing.nvim', 'which-key.nvim'}, { event = "BufEnter *" }, _G.packer_plugins)]]
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'jupyter_ascending.vim', 'better-escape.vim', 'nvim-cmp'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufWrite * ++once lua require("packer.load")({'jupyter_ascending.vim'}, { event = "BufWrite *" }, _G.packer_plugins)]]
vim.cmd [[au BufWinEnter * ++once lua require("packer.load")({'dashboard-nvim'}, { event = "BufWinEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], true)
vim.cmd [[source /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
