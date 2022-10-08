-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

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
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

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
    after = { "cmp_luasnip" },
    config = { "\27LJ\2\n�\2\0\0\3\0\t\0\0236\0\0\0'\2\1\0B\0\2\0029\0\2\0009\0\3\0005\2\4\0B\0\2\0016\0\0\0'\2\5\0B\0\2\0029\0\6\0B\0\1\0016\0\0\0'\2\a\0B\0\2\0029\0\6\0B\0\1\0016\0\0\0'\2\b\0B\0\2\0029\0\6\0B\0\1\1K\0\1\0\"luasnip.loaders.from_snipmate luasnip.loaders.from_vscode\14lazy_load\29luasnip.loaders.from_lua\1\0\2\17updateevents\29TextChanged,TextChangedI\fhistory\2\15set_config\vconfig\fluasnip\frequire\0" },
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/LuaSnip",
    url = "git@github.com:L3MON4D3/LuaSnip"
  },
  ["alpha-nvim"] = {
    cond = { "\27LJ\2\nM\0\0\2\0\3\0\f6\0\0\0009\0\1\0009\0\2\0B\0\1\2\21\0\0\0)\1\0\0\0\1\0\0X\0\2�+\0\1\0X\1\1�+\0\2\0L\0\2\0\18nvim_list_uis\bapi\bvim\0" },
    config = { "\27LJ\2\n�\1\0\0\6\1\6\0\0186\0\0\0009\0\1\0009\0\2\0-\2\0\0'\3\3\0&\2\3\2+\3\2\0+\4\1\0+\5\2\0B\0\5\0026\1\0\0009\1\1\0019\1\4\1\18\3\0\0'\4\5\0+\5\1\0B\1\4\1K\0\1\0\5�\6t\18nvim_feedkeys\r<Ignore>\27nvim_replace_termcodes\bapi\bvim�\2\1\5\f\0\17\0\"\18\a\0\0009\5\0\0'\b\1\0'\t\2\0B\5\4\2\18\a\5\0009\5\0\5\18\b\2\0'\t\3\0B\5\4\0023\6\4\0005\a\5\0=\0\6\a\v\3\0\0X\b\1�\18\3\5\0006\b\a\0009\b\b\b9\b\t\b\18\n\4\0005\v\n\0B\b\3\2\18\4\b\0005\b\f\0>\5\2\b>\3\3\b>\4\4\b=\b\v\a5\b\r\0=\1\14\b=\6\15\b=\a\16\b2\0\0�L\b\2\0\topts\ron_press\bval\1\0\1\ttype\vbutton\1\2\0\0\6n\vkeymap\1\0\3\fnoremap\2\vsilent\2\vnowait\2\vif_nil\6F\bvim\rshortcut\1\0\5\vcursor\3\5\rposition\vcenter\16hl_shortcut\fKeyword\19align_shortcut\nright\nwidth\0032\0\r<leader>\5\a%s\tgsub�\1\0\0\v\0\f\0\0266\0\0\0009\0\1\0006\2\2\0B\0\2\2\21\0\0\0'\1\3\0'\2\4\0006\3\0\0009\3\5\3B\3\1\0029\3\6\3'\4\a\0006\5\0\0009\5\5\5B\5\1\0029\5\b\5'\6\a\0006\a\0\0009\a\5\aB\a\1\0029\a\t\a'\b\n\0\18\t\0\0'\n\v\0&\1\n\1L\1\2\0\r plugins\v   \npatch\nminor\6.\nmajor\fversion\f   v\28🍱 github.com/aarnphm\19packer_plugins\rtbl_keys\bvim�_\1\0\17\0007\3�\0016\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\2+\2\0\0006\3\3\0009\3\4\3\a\3\5\0X\3\2�5\2\6\0X\3\1�5\2\a\0003\3\b\0009\4\t\0019\4\n\4=\2\v\4'\4\f\0'\5\r\0009\6\t\0019\6\14\0064\a\b\0\18\b\3\0'\n\15\0'\v\16\0\18\f\4\0'\r\17\0B\b\5\2>\b\1\a\18\b\3\0'\n\18\0'\v\19\0\18\f\4\0'\r\20\0B\b\5\2>\b\2\a\18\b\3\0'\n\21\0'\v\22\0\18\f\4\0'\r\23\0B\b\5\2>\b\3\a\18\b\3\0'\n\24\0'\v\25\0\18\f\4\0'\r\26\0B\b\5\2>\b\4\a\18\b\3\0'\n\27\0'\v\28\0\18\f\5\0'\r\29\0B\b\5\2>\b\5\a\18\b\3\0'\n\30\0'\v\31\0\18\f\5\0'\r \0B\b\5\2>\b\6\a\18\b\3\0'\n!\0'\v\"\0\18\f\5\0'\r#\0B\b\5\0?\b\0\0=\a\v\0069\6\t\0019\6\14\0069\6$\6'\a&\0=\a%\0063\6'\0009\a\t\0019\a(\a\18\b\6\0B\b\1\2=\b\v\a9\a\t\0019\a(\a9\a$\a'\b)\0=\b%\a)\a\2\0009\b\t\0019\b\n\b9\b\v\b\21\b\b\0009\t\t\0019\t\14\t9\t\v\t\21\t\t\0\29\t\1\t \b\t\b \b\a\b6\t*\0009\t+\t)\v\0\0006\f*\0009\f,\f6\14-\0009\14.\0149\14/\14'\0160\0B\14\2\2!\14\b\14\24\14\2\14B\f\2\0A\t\1\2)\n\1\0009\v1\0014\f\a\0005\r3\0=\t\v\r>\r\1\f9\r\t\0019\r\n\r>\r\2\f5\r4\0=\a\v\r>\r\3\f9\r\t\0019\r\14\r>\r\4\f5\r5\0=\n\v\r>\r\5\f9\r\t\0019\r(\r>\r\6\f=\f2\v9\v6\0009\r$\1B\v\2\1K\0\1\0\nsetup\1\0\1\ttype\fpadding\1\0\1\ttype\fpadding\1\0\1\ttype\fpadding\vlayout\vconfig\6$\14winheight\afn\bvim\tceil\bmax\tmath\rFunction\vfooter\0\vString\ahl\toptsC<cmd>Telescope find_files {cwd = vim.fn.stdpath('config')}<cr>\21  NVIM access\14kplus e r!:e $MYVIMRC | :cd %:p:h <CR>\18  Settings\14kplus e s\29<cmd>e ~/.editor.lua<cr>\16  Editor\14kplus e c\"<cmd>Telescope find_files<cr>\19  File find\14comma f f!<cmd>Telescope live_grep<cr>\19  Word find\14comma f w <cmd>Telescope oldfiles<cr>\22  File history\14comma f e <cmd>Telescope frecency<cr>\23  File frecency\14comma f r\fbuttons\nkplus\ncomma\bval\vheader\fsection\0\1\31\0\0�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣶⣶⣿⣿⣶⣤⣄⡀⢀⡠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⢻⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⠏⠙⠻⠷⠤⠀⠉⠙⠿⠿⠛⢁⣠⣤⣄⠀⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠚⠴⠶⠛⠛⠂⠀⠀⢠⠈⣁⣤⣶⡤⣼⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⠐⠜⠠⠶⣶⣶⣒⡶⢤⡤⠾⣞⠿⠟⠀⠀⢸⡀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡔⣯⡛⣷⠒⠠⠶⡏⠙⠋⠀⠀⢸⠀⠀⢻⡤⠤⠒⠚⠋⣇⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣼⠀⡽⢺⠀⠂⠀⠣⠤⠴⠒⠒⠋⠀⠀⢀⡇⠀⠀⠀⠀⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡄⠀⠓⢌⢣⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠈⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠢⢔⣋⠼⡇⠀⠀⠀⠀⠀⠀⠀⣠⠤⠤⠒⠀⠀⠀⡸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠉⠓⠶⢤⣄⣀⠀⠀⢀⣀⡠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⣾⠁⠀⠀⠀⠀⠀⠉⠉⠉⠉⢹⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣎⠀⠈⠑⠦⣀⠀⠀⠀⠀⠀⠀⠀⣼⠋⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣿⣿⣿⣷⣄⠀⠀⠀⠉⠒⣤⣀⠀⣠⣎⠀⢀⣿⣷⣦⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣤⣀⣰⣿⣾⣿⣿⣿⣷⣼⣿⣿⣿⣿⣿⣿⣷⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀\1\31\0\0�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠉⠉⠀⠀⠉⠛⠻⢿⡿⢟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⡄⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⣰⣦⣄⣈⣛⣿⣶⣦⣀⣀⣤⡾⠟⠛⠻⣿⡘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⣿⣿⣥⣋⣉⣤⣤⣽⣿⣿⡟⣷⠾⠛⠉⢛⠃⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⣯⣣⣟⣉⠉⠉⠭⢉⡛⢛⣁⠡⣀⣠⣿⣿⡇⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢫⠐⢤⠈⣭⣟⣉⢰⣦⣴⣿⣿⡇⣿⣿⡄⢛⣛⣭⣥⣴⠸⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠃⣿⢂⡅⣿⣽⣿⣜⣛⣛⣭⣭⣴⣿⣿⡿⢸⣿⣿⣿⣿⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢻⣿⣬⡻⡜⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣷⣿⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣝⡫⠴⣃⢸⣿⣿⣿⣿⣿⣿⣿⠟⣛⣛⣭⣿⣿⣿⢇⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢋⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⣶⣬⣉⡛⠻⠿⣿⣿⡿⠿⢟⣡⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢋⠁⣾⣿⣿⣿⣿⣿⣶⣶⣶⣶⡆⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠱⣿⣷⣮⣙⠿⣿⣿⣿⣿⣿⣿⣿⠃⣴⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠈⠻⣿⣿⣿⣶⣭⠛⠿⣿⠟⠱⣿⡿⠀⠈⠙⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⠏⠀⠁⠀⠀⠀⠈⠃⠀⠀⠀⠀⠀⠀⠈⠉⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿\tdark\15background\20__editor_config\27alpha.themes.dashboard\nalpha\frequire\15����\4\4\1����\3\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/alpha-nvim",
    url = "git@github.com:goolord/alpha-nvim"
  },
  ["auto-session"] = {
    commands = { "SaveSession", "RestoreSession", "DeleteSession" },
    config = { "\27LJ\2\n�\2\0\0\5\0\n\0\0166\0\0\0009\0\1\0009\0\2\0'\2\3\0B\0\2\2'\1\4\0&\0\1\0005\1\5\0=\0\6\0016\2\a\0'\4\b\0B\2\2\0029\2\t\2\18\4\1\0B\2\2\1K\0\1\0\nsetup\17auto-session\frequire\26auto_session_root_dir\1\0\5\22auto_save_enabled\2\25auto_restore_enabled\2\14log_level\tinfo\25auto_session_enabled\2%auto_session_enable_last_session\2\15/sessions/\tdata\fstdpath\afn\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/auto-session",
    url = "git@github.com:rmagatti/auto-session"
  },
  catppuccin = {
    config = { "\27LJ\2\n�\5\0\0\3\0:\0?6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\2'\1\4\0=\1\3\0006\1\5\0009\1\6\0019\1\a\1\a\1\b\0X\0012�'\1\n\0=\1\t\0'\1\f\0=\1\v\0'\1\14\0=\1\r\0'\1\16\0=\1\15\0'\1\18\0=\1\17\0'\1\20\0=\1\19\0'\1\22\0=\1\21\0'\1\24\0=\1\23\0'\1\26\0=\1\25\0'\1\28\0=\1\27\0'\1\30\0=\1\29\0'\1 \0=\1\31\0'\1\"\0=\1!\0'\1$\0=\1#\0'\1&\0=\1%\0'\1(\0=\1'\0'\1*\0=\1)\0'\1,\0=\1+\0'\1.\0=\1-\0'\1.\0=\1/\0'\0011\0=\0010\0'\0013\0=\0012\0'\0015\0=\0014\0'\0017\0=\0016\0'\0019\0=\0018\0L\0\2\0\f#161320\ncrust\f#1A1826\vmantle\f#1E1E2E\tbase\f#302D41\rsurface0\f#575268\rsurface1\rsurface2\f#6E6C7E\roverlay0\f#988BA2\roverlay1\f#C3BAC6\roverlay2\f#A6ADC8\rsubtext0\f#BAC2DE\rsubtext1\f#D9E0EE\ttext\f#C9CBFF\rlavender\f#B5E8E0\tteal\f#89DCEB\bsky\f#96CDFB\tblue\f#ABE9B3\ngreen\f#FAE3B0\vyellow\f#F8BD96\npeach\f#E8A2AF\vmaroon\f#F28FAD\bred\f#F5C2E7\tpink\f#DDB6F2\nmauve\f#F2CDCD\rflamingo\f#F5E0DC\14rosewater\nmocha\23catppuccin_flavour\6g\bvim\tNONE\tnone\16get_palette\24catppuccin.palettes\frequire:\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\27colorscheme catppuccin\bcmd\bvim\\\1\0\4\0\6\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0016\0\3\0009\0\4\0003\2\5\0)\3\0\0B\0\3\1K\0\1\0\0\rdefer_fn\bvim\fcompile\15catppuccin\frequire�\1\1\1\6\0\n\0\17\15\0\0\0X\1\14�6\1\0\0009\1\1\0019\1\2\1'\3\3\0005\4\4\0B\1\3\0016\1\0\0009\1\1\0019\1\5\1'\3\6\0005\4\a\0003\5\b\0=\5\t\4B\1\3\1K\0\1\0\rcallback\0\1\0\2\ngroup\16_catppuccin\fpattern\22PackerCompileDone\tUser\24nvim_create_autocmd\1\0\1\nclear\2\16_catppuccin\24nvim_create_augroup\bapi\bvim�\30\1\0\n\0�\1\0�\0023\0\0\0003\1\1\0006\2\2\0009\2\3\2'\3\5\0=\3\4\2\18\2\0\0B\2\1\0026\3\6\0009\3\a\3\a\3\b\0X\3\4�+\3\2\0\18\4\1\0\18\6\3\0B\4\2\0016\3\t\0'\5\b\0B\3\2\0029\3\n\0035\5\f\0005\6\v\0=\6\r\0055\6\14\0006\a\15\0=\a\16\0066\a\2\0009\a\17\a9\a\18\a'\t\19\0B\a\2\2'\b\20\0&\a\b\a=\a\21\6=\6\22\0055\6\24\0005\a\23\0=\a\25\0065\a\26\0=\a\27\0065\a\28\0=\a\29\0065\a\30\0=\a\31\0065\a \0=\a!\0065\a\"\0=\a#\0065\a$\0=\a%\0065\a&\0=\a'\0064\a\0\0=\a(\0064\a\0\0=\a)\0064\a\0\0=\a*\0064\a\0\0=\a+\6=\6,\0055\6-\0005\a.\0005\b0\0005\t/\0=\t1\b5\t2\0=\t3\b5\t4\0=\t5\b5\t6\0=\t7\b=\b8\a5\b:\0005\t9\0=\t1\b5\t;\0=\t3\b5\t<\0=\t5\b5\t=\0=\t7\b=\b>\a=\a?\0065\a@\0=\aA\0065\aB\0=\aC\0065\aD\0=\aE\0065\aF\0=\aG\6=\6H\0055\6J\0005\aI\0=\aK\6=\6L\0055\6�\0005\aP\0005\bN\0009\tM\2=\tO\b=\bQ\a5\bS\0009\tR\2=\tT\b9\tU\2=\tO\b5\tV\0=\tW\b=\bX\a5\bY\0009\tU\2=\tT\b9\tR\2=\tO\b=\bZ\a5\b\\\0009\t[\2=\tT\b=\b]\a5\b^\0009\t[\2=\tT\b=\b_\a5\b`\0009\t[\2=\tT\b=\ba\a5\bc\0009\tb\2=\tO\b9\t[\2=\tT\b=\bd\a5\be\0009\tb\2=\tO\b=\bf\a5\bg\0009\tb\2=\tO\b=\bh\a5\bi\0009\tb\2=\tO\b=\bj\a5\bk\0009\tb\2=\tO\b=\bl\a5\bm\0009\tb\2=\tn\b=\bo\a5\bp\0009\t[\2=\tT\b9\tq\2=\tO\b=\br\a5\bt\0009\ts\2=\tO\b5\tu\0=\tW\b=\bv\a5\bw\0009\tb\2=\tO\b=\bx\a5\bz\0009\ty\2=\tO\b=\b{\a5\b}\0009\t|\2=\tO\b=\b~\a5\b�\0009\t\127\2=\tO\b=\b�\a5\b�\0009\t\127\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b5\t�\0=\tW\b=\b�\a5\b�\0009\t�\2=\tO\b4\t\0\0=\tW\b=\b�\a5\b�\0009\tb\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\tU\2=\tO\b4\t\0\0=\tW\b=\b�\a5\b�\0005\t�\0=\tW\b=\b�\a5\b�\0009\tb\2=\tO\b=\b�\a5\b�\0009\t|\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b5\t�\0=\tW\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b5\t�\0=\tW\b=\b�\a5\b�\0009\ty\2=\tO\b5\t�\0=\tW\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t|\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b5\t�\0=\tW\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\ty\2=\tO\b5\t�\0=\tW\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a=\aK\6=\6�\5B\3\2\0016\3\2\0009\3�\0036\4\6\0009\4�\4=\4�\3K\0\1\0\15background\6o\24highlight_overrides\1\0\0\18cppTSProperty\1\0\0\18cssTSProperty\1\2\0\0\vitalic\1\0\0\14cssTSType\1\0\0\25typescriptTSProperty\1\2\0\0\vitalic\1\0\0\19javaTSConstant\1\0\0\21luaTSConstructor\1\0\0\rflamingo\15luaTSField\1\0\0\20bashTSParameter\1\2\0\0\vitalic\1\0\0\22bashTSFuncBuiltin\1\2\0\0\vitalic\1\0\0\vTSText\1\0\0\19TSTagDelimiter\1\0\0\nTSTag\1\0\0\19TSTagAttribute\1\2\0\0\vitalic\1\0\0\nmauve\15TSVariable\1\0\0\ttext\19TSPunctBracket\1\0\0\roverlay2\21TSPunctDelimiter\1\0\0\16TSNamespace\1\0\0\rTSMethod\1\0\0\1\2\0\0\vitalic\20TSKeywordReturn\1\0\0\14TSKeyword\1\0\0\22TSKeywordFunction\1\0\0\16TSParameter\1\0\0\16TSFuncMacro\1\0\0\22TSVariableBuiltin\1\2\0\0\vitalic\1\0\0\bred\19TSConstBuiltin\1\0\0\16TSException\1\0\0\npeach\18TSConstructor\1\0\0\rlavender\19TSPunctSpecial\1\0\0\vmaroon\22TSKeywordOperator\1\0\0\15TSOperator\1\0\0\bsky\14TSInclude\1\0\0\tteal\15TSProperty\1\0\0\vyellow\fTSField\1\0\0\16FidgetTitle\1\2\0\0\tbold\1\0\0\tblue\15FidgetTask\rsurface2\1\0\0 LspDiagnosticsUnderlineHint\asp\1\0\0\"LspDiagnosticsVirtualTextHint\1\0\0\23LspDiagnosticsHint\1\0\0\30LspDiagnosticsDefaultHint\1\0\0\19DiagnosticHint\1\0\0\30DiagnosticVirtualTextHint\1\0\0\14rosewater\30DiagnosticVirtualTextInfo\1\0\0\30DiagnosticVirtualTextWarn\1\0\0\31DiagnosticVirtualTextError\1\0\0\tnone\14IncSearch\1\0\0\vSearch\nstyle\1\2\0\0\tbold\tpink\abg\1\0\0\rsurface1\17CursorLineNr\1\0\0\afg\1\0\0\ngreen\20color_overrides\nmocha\1\0\0\1\0\25\rsubtext1\f#BAC2DE\ttext\f#D9E0EE\rsubtext0\f#A6ADC8\rsurface1\f#575268\roverlay2\f#C3BAC6\14rosewater\f#F5E0DC\roverlay1\f#988BA2\rflamingo\f#F2CDCD\roverlay0\f#6E6C7E\nmauve\f#DDB6F2\rsurface2\f#6E6C7E\tpink\f#F5C2E7\rsurface0\f#302D41\bred\f#F28FAD\tbase\f#1E1E2E\vmaroon\f#E8A2AF\vmantle\f#1A1826\npeach\f#F8BD96\ncrust\f#161320\vyellow\f#FAE3B0\ngreen\f#ABE9B3\tblue\f#96CDFB\bsky\f#89DCEB\tteal\f#B5E8E0\rlavender\f#C9CBFF\17integrations\nnavic\1\0\2\14custom_bg\tNONE\fenabled\2\fneotree\1\0\3\22transparent_panel\1\fenabled\1\14show_root\2\bdap\1\0\2\14enable_ui\2\fenabled\2\21indent_blankline\1\0\2\26colored_indent_levels\1\fenabled\2\15native_lsp\15underlines\1\2\0\0\14underline\1\2\0\0\14underline\1\2\0\0\14underline\1\0\0\1\2\0\0\14underline\17virtual_text\16information\1\2\0\0\vitalic\rwarnings\1\2\0\0\vitalic\nhints\1\2\0\0\vitalic\verrors\1\0\0\1\2\0\0\vitalic\1\0\1\fenabled\2\1\0\29\15telekasten\1\rgitsigns\2\16lsp_trouble\2\bhop\2\fvimwiki\2\rmarkdown\2\14telescope\2\rcoc_nvim\1\tleap\1\tmini\1\vaerial\1\vbeacon\1\roverseer\1\rlsp_saga\2\14gitgutter\2\rnvimtree\2\14which_key\2\14dashboard\2\vneogit\1\14vim_sneak\1\tfern\1\vbarbar\1\15lightspeed\1\15ts_rainbow\2\20symbols_outline\1\bcmp\2\vnotify\2\vfidget\2\15treesitter\2\vstyles\14variables\fstrings\ntypes\fnumbers\rbooleans\1\3\0\0\tbold\vitalic\nloops\1\2\0\0\tbold\17conditionals\1\2\0\0\tbold\14operators\1\2\0\0\tbold\rkeywords\1\2\0\0\vitalic\14functions\1\3\0\0\vitalic\tbold\15properties\1\2\0\0\vitalic\rcomments\1\0\0\1\2\0\0\vitalic\fcompile\tpath\16/catppuccin\ncache\fstdpath\afn\fenabled\19enable_compile\1\0\0\17dim_inactive\1\0\2\27transparent_background\2\16term_colors\2\1\0\3\fenabled\1\nshade\nlight\15percentage\4��̙\3���\3\nsetup\frequire\15catppuccin\16colorscheme\20__editor_config\nlatte\23catppuccin_flavour\6g\bvim\0\0\0" },
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "git@github.com:catppuccin/nvim"
  },
  ["cheatsheet.nvim"] = {
    config = { "\27LJ\2\n�\3\0\0\a\0\15\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\6\0006\4\0\0'\6\4\0B\4\2\0029\4\5\4=\4\a\0036\4\0\0'\6\4\0B\4\2\0029\4\b\4=\4\t\0036\4\0\0'\6\4\0B\4\2\0029\4\n\4=\4\v\0036\4\0\0'\6\4\0B\4\2\0029\4\f\4=\4\r\3=\3\14\2B\0\2\1K\0\1\0\23telescope_mappings\n<C-E>\25edit_user_cheatsheet\n<C-Y>\21copy_cheat_value\v<A-CR>\22select_or_execute\t<CR>\1\0\0\31select_or_fill_commandline!cheatsheet.telescope.actions\1\0\3\24bundled_cheatsheets\2\31bundled_plugin_cheatsheets\2#include_only_installed_plugins\2\nsetup\15cheatsheet\frequire\0" },
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cheatsheet.nvim",
    url = "git@github.com:sudormrfbin/cheatsheet.nvim"
  },
  ["cmp-buffer"] = {
    after = { "cmp-latex-symbols", "cmp-emoji" },
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-buffer/after/plugin/cmp_buffer.lua" },
    load_after = {
      ["cmp-path"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-buffer",
    url = "git@github.com:hrsh7th/cmp-buffer"
  },
  ["cmp-emoji"] = {
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-emoji/after/plugin/cmp_emoji.lua" },
    load_after = {
      ["cmp-buffer"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-emoji",
    url = "git@github.com:hrsh7th/cmp-emoji"
  },
  ["cmp-latex-symbols"] = {
    after = { "cmp-spell" },
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
  ["cmp-spell"] = {
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-spell/after/plugin/cmp-spell.lua" },
    load_after = {
      ["cmp-latex-symbols"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-spell",
    url = "git@github.com:f3fora/cmp-spell"
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
  ["copilot.vim"] = {
    commands = { "Copilot" },
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/copilot.vim",
    url = "git@github.com:github/copilot.vim"
  },
  ["diffview.nvim"] = {
    commands = { "DiffviewOpen", "DiffviewFileHistory" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/diffview.nvim",
    url = "git@github.com:sindrets/diffview.nvim"
  },
  ["dressing.nvim"] = {
    load_after = {},
    loaded = true,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/dressing.nvim",
    url = "git@github.com:stevearc/dressing.nvim"
  },
  ["efmls-configs-nvim"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/efmls-configs-nvim",
    url = "git@github.com:creativenull/efmls-configs-nvim"
  },
  ["fidget.nvim"] = {
    config = { "\27LJ\2\nr\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\vwindow\1\0\1\nblend\3\0\ttext\1\0\0\1\0\1\fspinner\tdots\nsetup\vfidget\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/fidget.nvim",
    url = "git@github.com:j-hui/fidget.nvim"
  },
  ["filetype.nvim"] = {
    config = { "\27LJ\2\nm\0\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\4\0005\4\3\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\14overrides\1\0\0\fshebang\1\0\0\1\0\1\tdash\ash\nsetup\rfiletype\frequire\0" },
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/filetype.nvim",
    url = "git@github.com:nathom/filetype.nvim"
  },
  ["friendly-snippets"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/friendly-snippets",
    url = "git@github.com:rafamadriz/friendly-snippets"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\n�\r\0\0\5\0\28\0\0316\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\14\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\0035\4\f\0=\4\r\3=\3\15\0025\3\16\0005\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\0025\3\26\0=\3\27\2B\0\2\1K\0\1\0\14diff_opts\1\0\1\rinternal\2\28current_line_blame_opts\1\0\2\ndelay\3�\a\21virtual_text_pos\beol\17watch_gitdir\1\0\2\17follow_files\2\rinterval\3�\a\fkeymaps\22n <LocalLeader>[g\1\2\1\0@&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'\texpr\2\22n <LocalLeader>]g\1\2\1\0@&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'\texpr\2\1\0\f\fnoremap\2\vbuffer\2\22n <LocalLeader>hp4<cmd>lua require(\"gitsigns\").preview_hunk()<CR>\22n <LocalLeader>hu7<cmd>lua require(\"gitsigns\").undo_stage_hunk()<CR>\tx ih4:<C-U>lua require(\"gitsigns\").text_object()<CR>\22n <LocalLeader>hr2<cmd>lua require(\"gitsigns\").reset_hunk()<CR>\to ih4:<C-U>lua require(\"gitsigns\").text_object()<CR>\22v <LocalLeader>hrV<cmd>lua require(\"gitsigns\").reset_hunk({vim.fn.line(\".\"), vim.fn.line(\"v\")})<CR>\22n <LocalLeader>hs2<cmd>lua require(\"gitsigns\").stage_hunk()<CR>\22n <LocalLeader>hR4<cmd>lua require(\"gitsigns\").reset_buffer()<CR>\22n <LocalLeader>hb6<cmd>lua require(\"gitsigns\").blame_line(true)<CR>\22v <LocalLeader>hsV<cmd>lua require(\"gitsigns\").stage_hunk({vim.fn.line(\".\"), vim.fn.line(\"v\")})<CR>\nsigns\1\0\4\18sign_priority\3\6\20update_debounce\3d\14word_diff\1\23current_line_blame\2\17changedelete\1\0\4\ttext\6~\ahl\19GitSignsChange\vlinehl\21GitSignsChangeLn\nnumhl\21GitSignsChangeNr\14topdelete\1\0\4\ttext\b‾\ahl\19GitSignsDelete\vlinehl\21GitSignsDeleteLn\nnumhl\21GitSignsDeleteNr\vdelete\1\0\4\ttext\6_\ahl\19GitSignsDelete\vlinehl\21GitSignsDeleteLn\nnumhl\21GitSignsDeleteNr\vchange\1\0\4\ttext\b│\ahl\19GitSignsChange\vlinehl\21GitSignsChangeLn\nnumhl\21GitSignsChangeNr\badd\1\0\0\1\0\4\ttext\b│\ahl\16GitSignsAdd\vlinehl\18GitSignsAddLn\nnumhl\18GitSignsAddNr\nsetup\rgitsigns\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/gitsigns.nvim",
    url = "git@github.com:lewis6991/gitsigns.nvim"
  },
  ["hop.nvim"] = {
    config = { "\27LJ\2\n1\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\bhop\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/hop.nvim",
    url = "git@github.com:phaazon/hop.nvim"
  },
  ["impatient.nvim"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/impatient.nvim",
    url = "git@github.com:lewis6991/impatient.nvim"
  },
  ["indent-blankline.nvim"] = {
    config = { "\27LJ\2\n�\4\0\0\4\0\r\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0=\3\t\2B\0\2\0016\0\n\0009\0\v\0'\2\f\0B\0\2\1K\0\1\0001autocmd CursorMoved * IndentBlanklineRefresh\bcmd\bvim\21context_patterns\1\15\0\0\nclass\rfunction\vmethod\nblock\17list_literal\rselector\b^if\v^table\17if_statement\nwhile\bfor\ttype\bvar\vimport\20buftype_exclude\1\3\0\0\rterminal\vnofile\21filetype_exclude\1\21\0\0\rstartify\14dashboard\nalpha\blog\rfugitive\14gitcommit\vpacker\fvimwiki\rmarkdown\tjson\btxt\nvista\thelp\ftodoist\rNvimTree\rpeekaboo\bgit\20TelescopePrompt\24flutterToolsOutline\5\1\0\6\25show_current_context\2\tchar\b│\31show_current_context_start\2#show_trailing_blankline_indent\2\28show_first_indent_level\2\25space_char_blankline\6 \nsetup\21indent_blankline\frequire\0" },
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
  ["kanagawa.nvim"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/kanagawa.nvim",
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
    config = { "\27LJ\2\n�\1\0\0\v\0\t\0\0195\0\0\0006\1\1\0\18\3\0\0B\1\2\4H\4\v�'\6\2\0\18\a\4\0&\6\a\0066\a\3\0009\a\4\a9\a\5\a\18\t\6\0005\n\6\0=\5\a\n=\6\b\nB\a\3\1F\4\3\3R\4�\127K\0\1\0\vtexthl\ttext\1\0\0\16sign_define\afn\bvim\19DiagnosticSign\npairs\1\0\4\tWarn\t \nError\t \tHint\t \tInfo\t �\2\0\0\3\0\19\0\0296\0\0\0009\0\1\0009\0\2\0\a\0\3\0X\0\6�6\0\4\0'\2\5\0B\0\2\0029\0\6\0D\0\1\0X\0\17�6\0\4\0'\2\a\0B\0\2\0029\0\b\0009\1\n\0=\1\t\0009\1\n\0=\1\v\0009\1\r\0=\1\f\0009\1\15\0=\1\14\0009\1\17\0=\1\16\0009\1\n\0=\1\18\0L\0\2\0K\0\1\0\vmaroon\tblue\rsapphire\vviolet\nmauve\vyellow\14rosewater\rflamingo\vorange\npeach\vcolors\20lspsaga.lspkind\16get_palette\24catppuccin.palettes\frequire\15catppuccin\16colors_name\6g\bvim�\t\1\0\t\0P\0�\0013\0\0\0003\1\1\0\18\2\0\0B\2\1\1\18\2\1\0B\2\1\0026\3\2\0'\5\3\0B\3\2\0029\3\4\0035\5\6\0005\6\5\0=\6\a\0055\6\n\0005\a\b\0009\b\t\2>\b\2\a=\a\v\0065\a\f\0009\b\r\2>\b\2\a=\a\14\0065\a\15\0009\b\r\2>\b\2\a=\a\16\0065\a\17\0009\b\r\2>\b\2\a=\a\18\0065\a\19\0009\b\20\2>\b\2\a=\a\21\0065\a\22\0009\b\r\2>\b\2\a=\a\23\0065\a\24\0009\b\25\2>\b\2\a=\a\26\0065\a\27\0009\b\25\2>\b\2\a=\a\28\0065\a\29\0009\b\30\2>\b\2\a=\a\31\0065\a \0009\b\20\2>\b\2\a=\a!\0065\a\"\0009\b\20\2>\b\2\a=\a#\0065\a$\0009\b\r\2>\b\2\a=\a%\0065\a&\0009\b'\2>\b\2\a=\a(\0065\a)\0009\b'\2>\b\2\a=\a*\0065\a+\0009\b,\2>\b\2\a=\a-\0065\a.\0009\b'\2>\b\2\a=\a/\0065\a0\0009\b'\2>\b\2\a=\a1\0065\a2\0009\b'\2>\b\2\a=\a3\0065\a4\0009\b\20\2>\b\2\a=\a5\0065\a6\0009\b7\2>\b\2\a=\a8\0065\a9\0009\b\20\2>\b\2\a=\a:\0065\a;\0009\b\25\2>\b\2\a=\a<\0065\a=\0009\b\20\2>\b\2\a=\a>\0065\a?\0009\b\20\2>\b\2\a=\a@\0065\aA\0009\bB\2>\b\2\a=\aC\0065\aD\0009\bE\2>\b\2\a=\aF\0065\aG\0009\b,\2>\b\2\a=\aH\0065\aI\0009\b\r\2>\b\2\a=\aJ\0065\aK\0009\b'\2>\b\2\a=\aL\0065\aM\0009\b7\2>\b\2\a=\aN\6=\6O\5B\3\2\1K\0\1\0\16custom_kind\nMacro\1\2\0\0\t \17StaticMethod\1\2\0\0\tﴂ \14Parameter\1\2\0\0\t \14TypeAlias\1\2\0\0\t \18TypeParameter\vmaroon\1\2\0\0\t \rOperator\bsky\1\2\0\0\t \nEvent\1\2\0\0\t \vStruct\1\2\0\0\t \15EnumMember\1\2\0\0\t \tNull\1\2\0\0\tﳠ \bKey\bred\1\2\0\0\t \vObject\1\2\0\0\t \nArray\1\2\0\0\t \fBoolean\1\2\0\0\t \vNumber\1\2\0\0\t \vString\ngreen\1\2\0\0\t \rConstant\1\2\0\0\t \rVariable\npeach\1\2\0\0\t \rFunction\1\2\0\0\t \14Interface\1\2\0\0\t \tEnum\1\2\0\0\t \16Constructor\rsapphire\1\2\0\0\t \nField\1\2\0\0\t \rProperty\tteal\1\2\0\0\tﰠ \vMethod\1\2\0\0\t \nClass\vyellow\1\2\0\0\tﴯ \fPackage\1\2\0\0\t \14Namespace\1\2\0\0\t \vModule\tblue\1\2\0\0\t \tFile\1\0\0\14rosewater\1\2\0\0\t \22diagnostic_header\1\0\0\1\5\0\0\t \t \n  \t \18init_lsp_saga\flspsaga\frequire\0\0\0" },
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/lspsaga.nvim",
    url = "git@github.com:glepnir/lspsaga.nvim"
  },
  ["lua-dev.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/lua-dev.nvim",
    url = "git@github.com:folke/lua-dev.nvim"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\ne\0\0\4\0\6\0\r6\0\0\0006\2\1\0'\3\2\0B\0\3\3\15\0\0\0X\2\5�9\2\3\1\15\0\2\0X\3\2�'\2\4\0X\3\1�'\2\5\0L\2\2\0\5\t✺ \fwaiting\18better_escape\frequire\npcall|\0\0\3\0\b\0\0146\0\0\0009\0\1\0009\0\2\0\15\0\0\0X\1\b�5\1\4\0009\2\3\0=\2\3\0019\2\5\0=\2\6\0019\2\a\0=\2\a\1L\1\2\0K\0\1\0\fremoved\rmodified\fchanged\1\0\0\nadded\25gitsigns_status_dict\6b\bviml\0\1\t\0\5\0\0186\1\0\0009\1\1\1\18\3\0\0'\4\2\0B\1\3\2\15\0\1\0X\2\n�\18\1\0\0\18\4\0\0009\2\3\0'\5\4\0B\2\3\4X\5\1�\18\1\5\0E\5\3\2R\5�\127\18\0\1\0L\0\2\0\f([^/]+)\vgmatch\6/\tfind\vstring�\1\1\0\b\0\r\0&3\0\0\0006\1\1\0009\1\2\0019\1\3\1\a\1\4\0X\1\29�6\1\5\0009\1\6\1'\3\a\0B\1\2\2\15\0\1\0X\2\b�6\2\b\0009\2\t\2'\4\n\0\18\5\0\0\18\a\1\0B\5\2\0002\0\0�C\2\1\0006\2\5\0009\2\6\2'\4\v\0B\2\2\2\18\1\2\0\15\0\1\0X\2\b�6\2\b\0009\2\t\2'\4\n\0\18\5\0\0\18\a\1\0B\5\2\0002\0\0�C\2\1\0'\1\f\0002\0\0�L\1\2\0\5\16VIRTUAL_ENV\a%s\vformat\vstring\22CONDA_DEFAULT_ENV\vgetenv\aos\vpython\rfiletype\abo\bvim\0�\n\1\0\18\0A\0�\0016\0\0\0'\2\1\0B\0\2\0023\1\2\0003\2\3\0005\3\4\0004\4\0\0=\4\5\0034\4\0\0=\4\6\0034\4\0\0=\4\a\0034\4\0\0=\4\b\0034\4\0\0=\4\t\0035\4\n\0=\4\v\0035\4\r\0005\5\f\0=\5\5\0045\5\14\0=\5\6\0044\5\0\0=\5\a\0044\5\0\0=\5\b\0044\5\0\0=\5\t\0045\5\15\0=\5\v\0045\5\16\0=\3\17\0055\6\18\0=\6\19\0055\6\20\0=\4\17\0065\a\21\0=\a\19\0065\a\22\0=\4\17\a5\b\23\0=\b\19\a5\b\24\0=\4\17\b5\t\25\0=\t\19\b5\t\26\0=\4\17\t5\n\27\0=\n\19\t3\n\28\0006\v\0\0'\r\29\0B\v\2\0029\v\30\v5\r%\0005\14\31\0006\15 \0009\15!\15=\15!\0144\15\0\0=\15\"\0145\15#\0=\15$\14=\14&\r5\14(\0005\15'\0=\15\5\0144\15\3\0005\16)\0>\16\1\0155\16*\0=\2+\16>\16\2\15=\15\6\0144\15\3\0005\16.\0009\17,\0>\17\1\0169\17-\0=\17/\16>\16\1\15=\15\a\0144\15\3\0004\16\3\0>\1\1\16>\16\1\0155\0160\0005\0171\0=\0172\0165\0173\0=\0174\16>\16\2\15=\15\b\0144\15\5\0005\0165\0>\16\1\0154\16\3\0>\n\1\16>\16\2\0155\0166\0>\16\3\0155\0167\0005\0178\0=\0174\16>\16\4\15=\15\t\0145\0159\0=\15\v\14=\14\17\r5\14:\0004\15\0\0=\15\5\0144\15\0\0=\15\6\0145\15;\0=\15\a\0145\15<\0=\15\b\0144\15\0\0=\15\t\0144\15\0\0=\15\v\14=\14=\r4\14\0\0=\14>\r5\14?\0>\5\5\14>\6\6\14>\a\a\14>\b\b\14>\t\t\14=\14@\rB\v\2\1K\0\1\0\15extensions\1\5\0\0\rquickfix\14nvim-tree\15toggleterm\rfugitive\ftabline\22inactive_sections\1\2\0\0\rlocation\1\2\0\0\rfilename\1\0\0\1\3\0\0\rprogress\rlocation\1\0\3\tunix\aLF\bmac\aCR\bdos\tCRLF\1\2\1\0\15fileformat\18icons_enabled\2\1\2\0\0\rencoding\1\2\2\0\rfiletype\14icon_only\2\fcolored\2\fsymbols\1\0\3\tinfo\t \nerror\t \twarn\t \fsources\1\2\0\0\20nvim_diagnostic\1\2\0\0\16diagnostics\tcond\1\0\0\17is_available\17get_location\vsource\1\2\0\0\tdiff\1\2\0\0\vbranch\1\0\0\1\2\0\0\tmode\foptions\1\0\0\23section_separators\1\0\2\nright\6 \tleft\6 \23disabled_filetypes\ntheme\20__editor_config\1\0\2\18icons_enabled\2\25component_separators\6|\nsetup\flualine\0\1\2\0\0\18dapui_watches\1\0\0\1\2\0\0\17dapui_stacks\1\0\0\1\2\0\0\22dapui_breakpoints\1\0\0\1\2\0\0\17dapui_scopes\1\0\0\14filetypes\1\2\0\0\19lspsagaoutline\rsections\1\0\0\1\2\0\0\rlocation\1\2\0\0\rfiletype\1\0\0\1\2\0\0\tmode\14lualine_z\1\2\0\0\rlocation\14lualine_y\14lualine_x\14lualine_c\14lualine_b\14lualine_a\1\0\0\0\0\15nvim-navic\frequire\0" },
    load_after = {
      ["nvim-navic"] = true
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
  ["mason-lspconfig.nvim"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/mason-lspconfig.nvim",
    url = "git@github.com:williamboman/mason-lspconfig.nvim"
  },
  ["mason-tool-installer.nvim"] = {
    config = { "\27LJ\2\n�\3\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\21ensure_installed\1\0\2\17run_on_start\1\16auto_update\2\1\26\0\0\befm\18rust-analyzer\vclangd\tdeno\31typescript-language-server\31dockerfile-language-server\ngopls\rrnix-lsp\fpyright\njdtls\25bash-language-server\24lua-language-server\vstylua\vselene\nblack\vpylint\rprettier\15shellcheck\nshfmt\tvint\ntaplo\vclangd\24vim-language-server\bbuf\vtflint\nsetup\25mason-tool-installer\frequire\0" },
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/mason-tool-installer.nvim",
    url = "git@github.com:WhoIsSethDaniel/mason-tool-installer.nvim"
  },
  ["mason.nvim"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/mason.nvim",
    url = "git@github.com:williamboman/mason.nvim"
  },
  ["nvim-autopairs"] = {
    config = { "\27LJ\2\n�\3\0\0\15\0\26\00036\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\0016\0\0\0'\2\6\0B\0\2\0026\1\0\0'\3\a\0B\1\2\0029\2\b\0\18\4\2\0009\2\t\2'\5\n\0009\6\v\1B\6\1\0A\2\2\0016\2\0\0'\4\f\0B\2\2\0029\3\b\0\18\5\3\0009\3\t\3'\6\n\0009\a\v\0015\t\24\0005\n\23\0005\v\21\0005\f\17\0004\r\3\0009\14\r\0009\14\14\0149\14\15\14>\14\1\r9\14\r\0009\14\14\0149\14\16\14>\14\2\r=\r\18\f9\r\19\2=\r\20\f=\f\22\v=\v\19\n=\n\25\tB\a\2\0A\3\2\1K\0\1\0\14filetypes\1\0\0\1\0\0\6(\1\0\0\fhandler\6*\tkind\1\0\0\vMethod\rFunction\23CompletionItemKind\blsp'nvim-autopairs.completion.handlers\20on_confirm_done\17confirm_done\aon\nevent\"nvim-autopairs.completion.cmp\bcmp\21disable_filetype\1\0\0\1\3\0\0\20TelescopePrompt\bvim\nsetup\19nvim-autopairs\frequire\0" },
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-autopairs",
    url = "git@github.com:windwp/nvim-autopairs"
  },
  ["nvim-bqf"] = {
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-bqf",
    url = "git@github.com:kevinhwang91/nvim-bqf"
  },
  ["nvim-bufferline.lua"] = {
    config = { "\27LJ\2\n\31\0\1\4\0\2\0\5'\1\0\0\18\2\0\0'\3\1\0&\1\3\1L\1\2\0\6)\6(�\v\1\0\n\0G\0{5\0\5\0005\1\0\0004\2\3\0005\3\1\0>\3\1\2=\2\2\0013\2\3\0=\2\4\1=\1\6\0004\1\0\0=\1\a\0006\1\b\0009\1\t\0019\1\n\1\a\1\v\0X\1d�6\1\f\0'\3\r\0B\1\2\0029\1\14\1B\1\1\2'\2\16\0=\2\15\0015\2B\0006\3\f\0'\5\17\0B\3\2\0029\3\18\0035\5\20\0005\6\19\0=\6\21\0055\6?\0005\a\25\0005\b\23\0009\t\22\1=\t\24\b=\b\26\a5\b\27\0009\t\22\1=\t\24\b=\b\28\a5\b\29\0009\t\22\1=\t\24\b=\b\30\a5\b\31\0009\t\22\1=\t\24\b=\b \a5\b!\0009\t\22\1=\t\24\b=\b\"\a5\b#\0009\t\22\1=\t\24\b=\b$\a5\b&\0009\t%\1=\t\24\b=\b'\a5\b(\0009\t%\1=\t\24\b=\b)\a5\b*\0009\t%\1=\t\24\b=\b+\a5\b,\0009\t%\1=\t\24\b=\b-\a5\b.\0009\t%\1=\t\24\b=\b/\a5\b0\0009\t%\1=\t\24\b=\b1\a5\b3\0009\t2\1=\t\24\b=\b4\a5\b5\0009\t2\1=\t\24\b=\b6\a5\b7\0009\t2\1=\t\24\b=\b8\a5\b9\0009\t2\1=\t\24\b=\b:\a5\b;\0009\t2\1=\t\24\b=\b<\a5\b=\0009\t2\1=\t\24\b=\b>\a=\a@\6=\6A\5B\3\2\2=\3\a\0026\3\b\0009\3C\3'\5D\0\18\6\0\0\18\a\2\0B\3\4\2\18\0\3\0006\1\f\0'\3E\0B\1\2\0029\1F\1\18\3\0\0B\1\2\1K\0\1\0\nsetup\15bufferline\nforce\20tbl_deep_extend\1\0\0\vcustom\nmocha\1\0\0\29hint_diagnostic_selected\1\0\0\28hint_diagnostic_visible\1\0\0\20hint_diagnostic\1\0\0\18hint_selected\1\0\0\17hint_visible\1\0\0\thint\1\0\0\14rosewater\29info_diagnostic_selected\1\0\0\28info_diagnostic_visible\1\0\0\20info_diagnostic\1\0\0\18info_selected\1\0\0\17info_visible\1\0\0\tinfo\1\0\0\bsky warning_diagnostic_selected\1\0\0\31warning_diagnostic_visible\1\0\0\23warning_diagnostic\1\0\0\21warning_selected\1\0\0\20warning_visible\1\0\0\fwarning\1\0\0\afg\1\0\0\vyellow\vstyles\1\0\0\1\3\0\0\vitalic\tbold\bget.catppuccin.groups.integrations.bufferline\tNONE\tnone\16get_palette\24catppuccin.palettes\frequire\15catppuccin\16colors_name\6g\bvim\15highlights\foptions\1\0\0\26diagnostics_indicator\0\foffsets\1\0\4\ttext\18File Explorer\rfiletype\rNvimTree\15text_align\vcenter\fpadding\3\1\1\0\r\20max_name_length\3\14\22max_prefix_length\3\r\rtab_size\3\20\28show_buffer_close_icons\2\22show_buffer_icons\2\24show_tab_indicators\2\27always_show_bufferline\2\22left_trunc_marker\b\20separator_style\tthin\18modified_icon\b✥\22buffer_close_icon\b\16diagnostics\rnvim_lsp\23right_trunc_marker\b\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-bufferline.lua",
    url = "git@github.com:akinsho/nvim-bufferline.lua"
  },
  ["nvim-cmp"] = {
    after = { "nvim-autopairs", "LuaSnip", "copilot.vim" },
    config = { "\27LJ\2\n�\1\0\0\b\0\b\2!6\0\0\0006\2\1\0009\2\2\0029\2\3\2)\4\0\0B\2\2\0A\0\0\3\b\1\0\0X\2\20�6\2\1\0009\2\2\0029\2\4\2)\4\0\0\23\5\1\0\18\6\0\0+\a\2\0B\2\5\2:\2\1\2\18\4\2\0009\2\5\2\18\5\1\0\18\6\1\0B\2\4\2\18\4\2\0009\2\6\2'\5\a\0B\2\3\2\n\2\0\0X\2\2�+\2\1\0X\3\1�+\2\2\0L\2\2\0\a%s\nmatch\bsub\23nvim_buf_get_lines\24nvim_win_get_cursor\bapi\bvim\vunpack\0\2F\0\1\a\0\3\0\b6\1\0\0009\1\1\0019\1\2\1\18\3\0\0+\4\2\0+\5\2\0+\6\2\0D\1\5\0\27nvim_replace_termcodes\bapi\bvim�\1\0\0\6\0\b\2\0276\0\0\0009\0\1\0009\0\2\0'\2\3\0B\0\2\2\23\0\0\0\b\0\1\0X\1\17�6\1\0\0009\1\1\0019\1\4\1'\3\3\0B\1\2\2\18\3\1\0009\1\5\1\18\4\0\0\18\5\0\0B\1\4\2\18\3\1\0009\1\6\1'\4\a\0B\1\3\2X\2\3�+\1\1\0X\2\1�+\1\2\0L\1\2\0\a%s\nmatch\bsub\fgetline\6.\bcol\afn\bvim\2\0�\1\0\1\3\0\b\0\0264\1\t\0005\2\0\0>\0\2\2>\2\1\0015\2\1\0>\0\2\2>\2\2\0015\2\2\0>\0\2\2>\2\3\0015\2\3\0>\0\2\2>\2\4\0015\2\4\0>\0\2\2>\2\5\0015\2\5\0>\0\2\2>\2\6\0015\2\6\0>\0\2\2>\2\a\0015\2\a\0>\0\2\2>\2\b\1L\1\2\0\1\2\0\0\b│\1\2\0\0\b╰\1\2\0\0\b─\1\2\0\0\b╯\1\2\0\0\b│\1\2\0\0\b╮\1\2\0\0\b─\1\2\0\0\b╭0\0\1\4\0\2\0\6\18\3\0\0009\1\0\0B\1\2\2+\2\1\0=\2\1\1L\1\2\0\15scrollable\ninfo_�\2\0\1\a\3\16\00076\1\0\0009\1\1\0019\1\2\1B\1\1\2\6\1\3\0X\2\b�6\2\0\0009\2\4\0029\2\5\2\18\4\1\0'\5\6\0+\6\2\0B\2\4\1X\2(�-\2\0\0009\2\a\2B\2\1\2\15\0\2\0X\3\4�-\2\0\0009\2\b\2B\2\1\1X\2\31�6\2\t\0'\4\n\0B\2\2\0029\2\v\2B\2\1\2\15\0\2\0X\3\t�6\2\0\0009\2\1\0029\2\f\2-\4\1\0'\6\r\0B\4\2\2'\5\3\0B\2\3\1X\2\15�-\2\2\0B\2\1\2\15\0\2\0X\3\t�6\2\0\0009\2\1\0029\2\f\2-\4\1\0'\6\14\0B\4\2\2'\5\15\0B\2\3\1X\2\2�\18\2\0\0B\2\1\1K\0\1\0\6�\1�\2�\6n\n<Tab>!<Plug>luasnip-expand-or-jump\rfeedkeys\23expand_or_jumpable\fluasnip\frequire\21select_next_item\fvisible\6i\18nvim_feedkeys\bapi\5\19copilot#Accept\afn\bvim�\2\0\1\6\3\v\0%-\1\0\0009\1\0\1B\1\1\2\15\0\1\0X\2\4�-\1\0\0009\1\1\1B\1\1\1X\1\27�6\1\2\0'\3\3\0B\1\2\0029\1\4\1)\3��B\1\2\2\15\0\1\0X\2\t�6\1\5\0009\1\6\0019\1\a\1-\3\1\0'\5\b\0B\3\2\2'\4\t\0B\1\3\1X\1\n�-\1\2\0B\1\1\2\15\0\1\0X\2\4�-\1\0\0009\1\n\1B\1\1\1X\1\2�\18\1\0\0B\1\1\1K\0\1\0\6�\1�\0�\rcomplete\5\28<Plug>luasnip-jump-prev\rfeedkeys\afn\bvim\rjumpable\fluasnip\frequire\21select_prev_item\fvisible�\4\0\2\b\0\t\0\0155\2\0\0006\3\2\0009\3\3\3'\5\4\0009\6\1\0018\6\6\0029\a\1\1B\3\4\2=\3\1\0015\3\6\0009\4\a\0009\4\b\0048\3\4\3=\3\5\1L\1\2\0\tname\vsource\1\0\b\rnvim_lsp\n[LSP]\vbuffer\n[BUF]\rnvim_lua\n[LUA]\tpath\v[PATH]\nspell\f[SPELL]\forgmode\n[ORG]\fluasnip\v[SNIP]\ttmux\v[TMUX]\tmenu\n%s %s\vformat\vstring\tkind\1\0\25\vFolder\b\14Reference\b\rOperator\b\rVariable\b\rProperty\bﰠ\nValue\b\tFile\b\vStruct\b\tText\b\nClass\bﴯ\15EnumMember\b\18TypeParameter\b\nField\b\fKeyword\b\vMethod\b\vModule\b\nEvent\b\tEnum\b\16Constructor\b\14Interface\b\fSnippet\b\rConstant\b\rFunction\b\tUnit\b\nColor\b�\1\0\1\a\1\t\0\0216\1\0\0009\1\1\0019\1\2\1B\1\1\2\6\1\3\0X\2\b�6\2\0\0009\2\4\0029\2\5\2\18\4\1\0'\5\6\0+\6\2\0B\2\4\1X\2\6�-\2\0\0009\2\a\0029\2\b\2B\2\1\2\18\4\0\0B\2\2\1K\0\1\0\6�\nabort\fmapping\6i\18nvim_feedkeys\bapi\5\19copilot#Accept\afn\bvim}\0\1\3\2\3\0\20-\1\0\0009\1\0\1B\1\1\2\15\0\1\0X\2\4�-\1\0\0009\1\1\1B\1\1\1X\1\n�-\1\1\0B\1\1\2\15\0\1\0X\2\4�-\1\0\0009\1\2\1B\1\1\1X\1\2�\18\1\0\0B\1\1\1K\0\1\0\6�\0�\rcomplete\21select_next_item\fvisibleR\0\1\3\1\2\0\f-\1\0\0009\1\0\1B\1\1\2\15\0\1\0X\2\4�-\1\0\0009\1\1\1B\1\1\1X\1\2�\18\1\0\0B\1\1\1K\0\1\0\6�\21select_prev_item\fvisibleC\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\15lsp_expand\fluasnip\frequire�\t\1\0\20\0R\0�\0013\0\0\0003\1\1\0003\2\2\0003\3\3\0006\4\4\0'\6\5\0B\4\2\0029\5\a\4=\5\6\0043\5\b\0=\5\a\0046\5\4\0'\a\t\0B\5\2\0026\6\4\0'\b\n\0B\6\2\0023\a\v\0003\b\f\0009\t\r\0065\v\22\0005\f\17\0005\r\15\0\18\14\3\0'\16\14\0B\14\2\2=\14\16\r=\r\18\f5\r\20\0\18\14\3\0'\16\19\0B\14\2\2=\14\16\r=\r\21\f=\f\23\v5\f!\0004\r\t\0009\14\24\5>\14\1\r9\14\25\5>\14\2\r9\14\26\5>\14\3\r6\14\4\0'\16\27\0B\14\2\0029\14\28\14>\14\4\r9\14\29\5>\14\5\r9\14\30\5>\14\6\r9\14\31\5>\14\a\r9\14 \5>\14\b\r=\r\"\f=\f#\v5\f%\0003\r$\0=\r&\f=\f'\v9\f(\0069\f)\f9\f*\f5\14-\0009\15(\0069\15+\0155\17,\0B\15\2\2=\15.\0149\15(\0069\15/\15B\15\1\2=\0150\0149\15(\0069\0151\15B\15\1\2=\0152\0149\15(\0069\0153\15)\17��B\15\2\2=\0154\0149\15(\0069\0153\15)\17\4\0B\15\2\2=\0155\14=\a6\14=\b7\0149\15(\0065\0179\0003\0188\0=\18:\0179\18(\0069\18;\18B\18\1\2=\18<\17B\15\2\2=\15=\0149\15(\0063\17>\0005\18?\0B\15\3\2=\15@\0149\15(\0063\17A\0005\18B\0B\15\3\2=\15C\14B\f\2\2=\f(\v5\fE\0003\rD\0=\rF\f=\fG\v4\f\n\0005\rH\0>\r\1\f5\rI\0>\r\2\f5\rJ\0>\r\3\f5\rK\0>\r\4\f5\rL\0>\r\5\f5\rM\0>\r\6\f5\rN\0>\r\a\f5\rO\0>\r\b\f5\rP\0>\r\t\f=\fQ\vB\t\2\0012\0\0�K\0\1\0\fsources\1\0\1\tname\nemoji\1\0\1\tname\nspell\1\0\1\tname\18latex_symbols\1\0\1\tname\vbuffer\1\0\1\tname\ttmux\1\0\1\tname\tpath\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lua\1\0\1\tname\rnvim_lsp\fsnippet\vexpand\1\0\0\0\n<C-k>\1\3\0\0\6i\6s\0\n<C-j>\1\3\0\0\6i\6s\0\n<C-e>\6c\nclose\6i\1\0\0\0\f<S-Tab>\n<Tab>\n<C-f>\n<C-d>\16scroll_docs\n<C-n>\21select_next_item\n<C-p>\21select_prev_item\t<CR>\1\0\0\1\0\1\vselect\2\fconfirm\vinsert\vpreset\fmapping\15formatting\vformat\1\0\0\0\fsorting\16comparators\1\0\0\norder\vlength\14sort_text\tkind\nunder\25cmp-under-comparator\nscore\nexact\voffset\vwindow\1\0\0\18documentation\1\0\0\17CmpDocBorder\15completion\1\0\0\vborder\1\0\1\17winhighlight4Normal:CmpPmenu,CursorLine:PmenuSel,Search:None\14CmpBorder\nsetup\0\0\bcmp\23cmp.config.compare\0\tinfo\ninfo_\21cmp.utils.window\frequire\0\0\0\0\0" },
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
  ["nvim-lspconfig"] = {
    after = { "nvim-navic", "lsp_signature.nvim", "lspsaga.nvim" },
    config = { "\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27modules.completion.lsp\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-lspconfig",
    url = "git@github.com:neovim/nvim-lspconfig"
  },
  ["nvim-navic"] = {
    after = { "lualine.nvim" },
    config = { "\27LJ\2\n�\4\0\0\4\0\t\0\r6\0\0\0009\0\1\0+\1\2\0=\1\2\0006\0\3\0'\2\4\0B\0\2\0029\0\5\0005\2\a\0005\3\6\0=\3\b\2B\0\2\1K\0\1\0\nicons\1\0\4\16depth_limit\3\0\26depth_limit_indicator\a..\14highlight\2\14separator\t » \1\0\26\nEvent\t \14Interface\t \rOperator\t \vNumber\t \rProperty\tﰠ \rVariable\t \fBoolean\t \vStruct\t \tEnum\t \nClass\tﴯ \15EnumMember\t \18TypeParameter\t \nField\t \14Namespace\t \vMethod\t \vModule\t \tNull\tﳠ \nArray\t \16Constructor\t \tFile\t \vObject\t \rConstant\t \bKey\t \vString\t \fPackage\t \rFunction\t \nsetup\15nvim-navic\frequire\18navic_silence\6g\bvim\0" },
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-navic",
    url = "git@github.com:SmiteshP/nvim-navic"
  },
  ["nvim-spectre"] = {
    config = { "\27LJ\2\n�\15\0\0\a\0009\0C6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\5\0005\4\4\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\20\0035\4\21\0=\4\22\0035\4\23\0=\4\24\3=\3\25\0025\3#\0005\4\26\0005\5\27\0=\5\28\0045\5\30\0005\6\29\0=\6\31\0055\6 \0=\6!\5=\5\"\4=\4$\0035\4%\0005\5&\0=\5\28\0045\5(\0005\6'\0=\6\31\0055\6)\0=\6!\5=\5\"\4=\4*\3=\3+\0025\3-\0005\4,\0=\4.\0035\0040\0005\5/\0=\5\31\4=\4\"\3=\0031\0025\0034\0005\0042\0005\0053\0=\5\"\4=\0045\0035\0046\0=\0047\3=\0038\2B\0\2\1K\0\1\0\fdefault\freplace\1\0\1\bcmd\bsed\tfind\1\0\0\1\2\0\0\16ignore-case\1\0\1\bcmd\arg\19replace_engine\1\0\0\1\0\3\ticon\b[I]\nvalue\18--ignore-case\tdesc\16ignore case\bsed\1\0\0\1\0\1\bcmd\bsed\16find_engine\aag\1\0\3\ticon\b[H]\nvalue\r--hidden\tdesc\16hidden file\1\0\0\1\0\3\ticon\b[I]\nvalue\a-i\tdesc\16ignore case\1\3\0\0\14--vimgrep\a-s\1\0\1\bcmd\aag\arg\1\0\0\foptions\vhidden\1\0\3\ticon\b[H]\nvalue\r--hidden\tdesc\16hidden file\16ignore-case\1\0\0\1\0\3\ticon\b[I]\nvalue\18--ignore-case\tdesc\16ignore case\targs\1\6\0\0\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\1\0\1\bcmd\arg\fmapping\25toggle_ignore_hidden\1\0\3\bmap\ath\bcmd=<cmd>lua require('spectre').change_options('hidden')<CR>\tdesc\25toggle search hidden\23toggle_ignore_case\1\0\3\bmap\ati\bcmdB<cmd>lua require('spectre').change_options('ignore-case')<CR>\tdesc\23toggle ignore case\23toggle_live_update\1\0\3\bmap\atu\bcmd9<cmd>lua require('spectre').toggle_live_update()<CR>\tdesc'update change when vim write file.\21change_view_mode\1\0\3\bmap\14<leader>v\bcmd2<cmd>lua require('spectre').change_view()<CR>\tdesc\28change result view mode\16run_replace\1\0\3\bmap\14<leader>R\bcmd:<cmd>lua require('spectre.actions').run_replace()<CR>\tdesc\16replace all\21show_option_menu\1\0\3\bmap\14<leader>o\bcmd3<cmd>lua require('spectre').show_options()<CR>\tdesc\16show option\16replace_cmd\1\0\3\bmap\14<leader>c\bcmd:<cmd>lua require('spectre.actions').replace_cmd()<CR>\tdesc\30input replace vim command\15send_to_qf\1\0\3\bmap\14<leader>q\bcmd9<cmd>lua require('spectre.actions').send_to_qf()<CR>\tdesc\30send all item to quickfix\15enter_file\1\0\3\bmap\t<cr>\bcmd;<cmd>lua require('spectre.actions').select_entry()<CR>\tdesc\22goto current file\16toggle_line\1\0\0\1\0\3\bmap\add\bcmd2<cmd>lua require('spectre').toggle_line()<CR>\tdesc\24toggle current item\1\0\6\20replace_vim_cmd\bcdo\16live_update\2\19is_insert_mode\1\23is_open_target_win\2\19color_devicons\2\ropen_cmd\tvnew\nsetup\fspectre\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-spectre",
    url = "git@github.com:windwp/nvim-spectre"
  },
  ["nvim-surround"] = {
    config = { "\27LJ\2\n;\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\18nvim-surround\frequire\0" },
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/nvim-surround",
    url = "git@github.com:kylechui/nvim-surround"
  },
  ["nvim-tmux-navigation"] = {
    cond = { "\27LJ\2\nV\0\0\3\0\4\1\v6\0\0\0009\0\1\0009\0\2\0'\2\3\0B\0\2\2\t\0\0\0X\0\2�+\0\1\0X\1\1�+\0\2\0L\0\2\0\20exists(\"$TMUX\")\14nvim_eval\bapi\bvim\0\0" },
    config = { "\27LJ\2\n^\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\1\24disable_when_zoomed\2\nsetup\25nvim-tmux-navigation\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-tmux-navigation",
    url = "git@github.com:alexghergh/nvim-tmux-navigation"
  },
  ["nvim-toggleterm.lua"] = {
    config = { "\27LJ\2\ny\0\1\2\0\6\1\0159\1\0\0\a\1\1\0X\1\3�)\1\15\0L\1\2\0X\1\b�9\1\0\0\a\1\2\0X\1\5�6\1\3\0009\1\4\0019\1\5\1\24\1\0\1L\1\2\0K\0\1\0\fcolumns\6o\bvim\rvertical\15horizontal\14direction��̙\19����\3�\2\1\0\4\0\n\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\0024\3\0\0=\3\6\0026\3\a\0009\3\b\0039\3\t\3=\3\t\2B\0\2\1K\0\1\0\nshell\6o\bvim\20shade_filetypes\tsize\1\0\t\17hide_numbers\2\14direction\rvertical\17open_mapping\n<C-t>\20shade_terminals\1\19shading_factor\0061\20start_in_insert\2\20insert_mappings\2\17persist_size\2\18close_on_exit\2\0\nsetup\15toggleterm\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-toggleterm.lua",
    url = "git@github.com:akinsho/nvim-toggleterm.lua"
  },
  ["nvim-tree.lua"] = {
    commands = { "NvimTreeToggle" },
    config = { "\27LJ\2\n�\n\0\0\b\0000\00076\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0005\4\a\0005\5\b\0005\6\t\0=\6\n\0055\6\v\0=\6\f\5=\5\r\4=\4\14\0035\4\15\0005\5\16\0=\5\14\4=\4\17\3=\3\18\0025\3\19\0=\3\20\0025\3\21\0004\4\0\0=\4\22\3=\3\23\0025\3\24\0004\4\0\0=\4\25\3=\3\26\0025\3\27\0005\4\28\0=\4\29\3=\3\30\0025\3\31\0=\3\n\0025\3 \0=\3!\0025\3\"\0=\3#\0025\3-\0005\4$\0005\5%\0005\6'\0005\a&\0=\a(\0065\a)\0=\a*\6=\6+\5=\5,\4=\4.\3=\3/\2B\0\2\1K\0\1\0\factions\14open_file\1\0\0\18window_picker\fexclude\fbuftype\1\4\0\0\vnofile\rterminal\thelp\rfiletype\1\0\0\1\a\0\0\vnotify\vpacker\aqf\tdiff\rfugitive\18fugitiveblame\1\0\2\venable\2\nchars)ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890\1\0\1\18resize_window\1\24filesystem_watchers\1\0\2\venable\2\19debounce_delay\0032\ntrash\1\0\2\bcmd\brip\20require_confirm\2\1\0\2\ftimeout\3�\3\vignore\1\ffilters\vcustom\1\5\0\0\v^.git$\14.DS_Store\16__pycache__\26*/packer_compiled.lua\1\0\1\rdotfiles\1\16system_open\targs\1\0\1\bcmd\topen\24update_focused_file\16ignore_list\1\0\2\16update_root\1\venable\2\23hijack_directories\1\0\2\venable\2\14auto_open\2\rrenderer\19indent_markers\1\0\3\tedge\t│ \tnone\a  \vcorner\t└ \1\0\1\venable\2\nicons\vglyphs\vfolder\1\0\b\fdefault\b\17symlink_open\b\nempty\b\15empty_open\b\fsymlink\b\15arrow_open\5\17arrow_closed\5\topen\b\bgit\1\0\a\fignored\b\frenamed\b\fdeleted\b\runstaged\b\14untracked\bﲉ\vstaged\b\runmerged\bשׂ\1\0\2\fdefault\b\fsymlink\b\1\0\2\fpadding\6 \18symlink_arrow\n  \1\0\1\25root_folder_modifier\a:e\tview\1\0\3\tside\nright\nwidth\3\16\18adaptive_size\1\1\0\6\20respect_buf_cwd\2\18disable_netrw\2\18hijack_cursor\2\23reload_on_bufenter\2\24prefer_startup_root\2\fsort_by\15extensions\nsetup\14nvim-tree\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-tree.lua",
    url = "git@github.com:kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    after = { "nvim-ts-hint-textobject", "nvim-ts-context-commentstring", "nvim-treesitter-textobjects", "nvim-treesitter-context", "vim-matchup", "refactoring.nvim", "zen-mode.nvim" },
    config = { "\27LJ\2\n�\r\0\0\f\0?\0Y6\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0004\4\0\0B\0\4\0016\0\0\0009\0\1\0009\0\2\0'\2\5\0'\3\6\0004\4\0\0B\0\4\0016\0\a\0'\2\b\0B\0\2\0029\0\t\0005\2\n\0005\3\v\0=\3\f\0025\3\r\0=\3\14\0025\3\15\0005\4\16\0=\4\17\3=\3\18\0025\3\19\0=\3\20\0025\3\21\0=\3\22\0025\3\25\0005\4\23\0005\5\24\0=\5\17\4=\4\26\0035\4\27\0005\5\28\0=\5\29\0045\5\30\0=\5\31\4=\4 \0035\4!\0005\5\"\0=\5#\0045\5$\0=\5%\0045\5&\0=\5'\0045\5(\0=\5)\4=\4*\0035\4+\0005\5,\0=\5-\4=\4.\3=\3/\0025\0030\0=\0031\2B\0\2\0016\0\a\0'\0022\0B\0\2\2+\1\2\0=\0013\0006\0\a\0'\0024\0B\0\2\0029\0005\0B\0\1\0026\0016\0\18\3\0\0B\1\2\4H\4\t�9\0067\0059\a7\0059\a8\a\18\t\a\0009\a9\a'\n:\0'\v;\0B\a\4\2=\a8\6F\4\3\3R\4�\1279\1<\0'\2>\0=\2=\1K\0\1\0\tocto\27filetype_to_parsername\rmarkdown\20git@github.com:\24https://github.com/\tgsub\burl\17install_info\npairs\23get_parser_configs\28nvim-treesitter.parsers\15prefer_git\28nvim-treesitter.install\frainbow\1\0\3\venable\2\19max_file_lines\3�\a\18extended_mode\2\16textobjects\16lsp_interop\25peek_definition_code\1\0\2\15<leader>sD\17@class.outer\15<leader>sd\20@function.outer\1\0\2\vborder\tnone\venable\2\tmove\22goto_previous_end\1\0\2\a[M\17@class.outer\a[]\20@function.outer\24goto_previous_start\1\0\2\a[m\17@class.outer\a[[\20@function.outer\18goto_next_end\1\0\2\a]M\17@class.outer\a]]\20@function.outer\20goto_next_start\1\0\2\a]m\17@class.outer\a][\20@function.outer\1\0\2\venable\2\14set_jumps\2\tswap\18swap_previous\1\0\1\14<leader>A\21@parameter.inner\14swap_next\1\0\1\14<leader>a\21@parameter.inner\1\0\1\venable\2\vselect\1\0\0\1\0\14\ais\21@statement.inner\aai\16@call.outer\aif\20@function.inner\aal\16@loop.outer\aaf\20@function.outer\aii\16@call.inner\ail\16@loop.inner\aas\21@statement.outer\aab\17@block.outer\aaC\17@class.outer\aiC\17@class.inner\aac\23@conditional.outer\aib\17@block.inner\aic\23@conditional.inner\1\0\2\venable\2\14lookahead\2\fmatchup\1\0\1\venable\2\26context_commentstring\1\0\2\venable\2\19enable_autocmd\1\26incremental_selection\fkeymaps\1\0\4\21node_incremental\bgrn\19init_selection\bgnn\22scope_incremental\bgrc\21node_decremental\bgrm\1\0\1\venable\2\14highlight\1\0\1\venable\2\19ignore_install\1\6\0\0\vphpdoc\tvala\ntiger\nslint\beex\1\0\1\21ensure_installed\ball\nsetup\28nvim-treesitter.configs\frequire\31nvim_treesitter#foldexpr()\rfoldexpr\texpr\15foldmethod\26nvim_set_option_value\bapi\bvim\0" },
    loaded = true,
    only_config = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "git@github.com:nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-context"] = {
    load_after = {},
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-context",
    url = "git@github.com:romgrk/nvim-treesitter-context"
  },
  ["nvim-treesitter-textobjects"] = {
    load_after = {},
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-treesitter-textobjects",
    url = "git@github.com:nvim-treesitter/nvim-treesitter-textobjects"
  },
  ["nvim-ts-context-commentstring"] = {
    load_after = {},
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-ts-context-commentstring",
    url = "git@github.com:JoosepAlviste/nvim-ts-context-commentstring"
  },
  ["nvim-ts-hint-textobject"] = {
    load_after = {},
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
    config = { "\27LJ\2\n�\20\0\0\5\0\21\0\0256\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\t\0005\4\b\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\a\3=\3\20\2B\0\2\1K\0\1\0\rmappings\1\0\n\16focus_files\14<leader>e\18toggle_viewed\20<leader><space>\17toggle_files\14<leader>b\21close_review_tab\n<C-c>\22select_next_entry\a]q\22select_prev_entry\a[q\15next_entry\6j\15prev_entry\6k\17select_entry\t<cr>\18refresh_files\6R\16review_diff\1\0\n\16next_thread\a]t\16focus_files\14<leader>e\23add_review_comment\14<space>ca\18toggle_viewed\20<leader><space>\26add_review_suggestion\14<space>sa\17toggle_files\14<leader>b\16prev_thread\a[t\21close_review_tab\n<C-c>\22select_next_entry\a]q\22select_prev_entry\a[q\15submit_win\1\0\4\20request_changes\n<C-r>\19approve_review\n<C-a>\21close_review_tab\n<C-c>\19comment_review\n<C-m>\18review_thread\1\0\17\17next_comment\a]c\20react_thumbs_up\14<space>r+\17prev_comment\a[c\21close_review_tab\n<C-c>\17react_hooray\14<space>rp\19add_suggestion\14<space>sa\15goto_issue\14<space>gi\19delete_comment\14<space>cd\22react_thumbs_down\14<space>r-\17react_rocket\14<space>rr\16react_laugh\14<space>rl\22select_next_entry\a]q\19react_confused\14<space>rc\22select_prev_entry\a[q\15react_eyes\14<space>re\16add_comment\14<space>ca\16react_heart\14<space>rh\17pull_request\1\0\31\17add_assignee\14<space>aa\17next_comment\a]c\17show_pr_diff\14<space>pd\20react_thumbs_up\14<space>r+\20remove_assignee\14<space>ad\17prev_comment\a[c\17add_reviewer\14<space>va\17react_hooray\14<space>rp\17create_label\14<space>lc\19delete_comment\14<space>cd\20remove_reviewer\14<space>vd\17remove_label\14<space>ld\14add_label\14<space>la\15react_eyes\14<space>re\16close_issue\14<space>ic\15goto_issue\14<space>gi\17reopen_issue\14<space>io\22react_thumbs_down\14<space>r-\16list_issues\14<space>il\19react_confused\14<space>rc\16checkout_pr\14<space>po\vreload\n<C-r>\17react_rocket\14<space>rr\rmerge_pr\14<space>pm\16react_laugh\14<space>rl\20open_in_browser\n<C-b>\17list_commits\14<space>pc\rcopy_url\n<C-y>\16add_comment\14<space>ca\23list_changed_files\14<space>pf\16react_heart\14<space>rh\nissue\1\0\0\1\0\24\17add_assignee\14<space>aa\17next_comment\a]c\16list_issues\14<space>il\20react_thumbs_up\14<space>r+\20remove_assignee\14<space>ad\17prev_comment\a[c\15goto_issue\14<space>gi\17react_hooray\14<space>rp\17create_label\14<space>lc\15react_eyes\14<space>re\14add_label\14<space>la\17remove_label\14<space>ld\16close_issue\14<space>ic\17reopen_issue\14<space>io\19delete_comment\14<space>cd\22react_thumbs_down\14<space>r-\vreload\n<C-r>\17react_rocket\14<space>rr\16react_laugh\14<space>rl\20open_in_browser\n<C-b>\19react_confused\14<space>rc\rcopy_url\n<C-y>\16add_comment\14<space>ca\16react_heart\14<space>rh\15file_panel\1\0\2\tsize\3\n\14use_icons\2\19default_remote\1\0\b\20github_hostname\5\30reaction_viewer_hint_icon\b\14user_icon\t \26snippet_context_lines\3\4\20timeline_marker\b\20timeline_indent\0062\27right_bubble_delimiter\b\26left_bubble_delimiter\b\1\3\0\0\rupstream\vorigin\nsetup\tocto\frequire\0" },
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
  ["popup.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/popup.nvim",
    url = "git@github.com:nvim-lua/popup.nvim"
  },
  ["refactoring.nvim"] = {
    config = { "\27LJ\2\n�\1\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\27prompt_func_param_type\1\0\4\ago\2\tjava\2\bcpp\2\6c\2\28prompt_func_return_type\1\0\0\1\0\4\ago\2\tjava\2\bcpp\2\6c\2\nsetup\16refactoring\frequire\0" },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/refactoring.nvim",
    url = "git@github.com:ThePrimeagen/refactoring.nvim"
  },
  ["rose-pine"] = {
    config = { "\27LJ\2\n�\1\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\6\17dark_variant\tmoon\29disable_float_background\1\20disable_italics\1\20bold_vert_split\2\22dim_nc_background\1\23disable_background\2\nsetup\14rose-pine\frequire\0" },
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/rose-pine",
    url = "git@github.com:rose-pine/neovim"
  },
  ["rust-tools.nvim"] = {
    config = { "\27LJ\2\n�\5\0\0\5\0\27\0*6\0\0\0009\0\1\0'\2\2\0B\0\2\0015\0\21\0005\1\3\0005\2\4\0=\2\5\0015\2\6\0=\2\a\0015\2\b\0=\2\t\0015\2\18\0004\3\t\0005\4\n\0>\4\1\0035\4\v\0>\4\2\0035\4\f\0>\4\3\0035\4\r\0>\4\4\0035\4\14\0>\4\5\0035\4\15\0>\4\6\0035\4\16\0>\4\a\0035\4\17\0>\4\b\3=\3\19\2=\2\20\1=\1\22\0004\1\0\0=\1\23\0006\1\24\0'\3\25\0B\1\2\0029\1\26\1\18\3\0\0B\1\2\1K\0\1\0\nsetup\15rust-tools\frequire\vserver\ntools\1\0\0\18hover_actions\vborder\1\0\1\15auto_focus\1\1\3\0\0\b│\16FloatBorder\1\3\0\0\b╰\16FloatBorder\1\3\0\0\b─\16FloatBorder\1\3\0\0\b╯\16FloatBorder\1\3\0\0\b│\16FloatBorder\1\3\0\0\b╮\16FloatBorder\1\3\0\0\b─\16FloatBorder\1\3\0\0\b╭\16FloatBorder\16inlay_hints\1\0\t\30only_current_line_autocmd\15CursorHold\22only_current_line\1\24right_align_padding\3\a\16right_align\1\26max_len_align_padding\3\1\18max_len_align\1\23other_hints_prefix\t » \27parameter_hints_prefix\b<- \25show_parameter_hints\2\16debuggables\1\0\1\18use_telescope\2\14runnables\1\0\1\18use_telescope\2\1\0\2\23hover_with_actions\2\17autoSetHints\2\27packadd nvim-lspconfig\bcmd\bvim\0" },
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
    url = "git@github.com:kkharji/sqlite.lua"
  },
  ["stabilize.nvim"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/stabilize.nvim",
    url = "git@github.com:luukvbaal/stabilize.nvim"
  },
  tablify = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/tablify",
    url = "git@github.com:Stormherz/tablify"
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
    after = { "telescope-frecency.nvim" },
    load_after = {
      ["telescope-fzf-native.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope-file-browser.nvim",
    url = "git@github.com:nvim-telescope/telescope-file-browser.nvim"
  },
  ["telescope-frecency.nvim"] = {
    after = { "sqlite.lua" },
    load_after = {
      ["telescope-file-browser.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope-frecency.nvim",
    url = "git@github.com:nvim-telescope/telescope-frecency.nvim"
  },
  ["telescope-fzf-native.nvim"] = {
    after = { "telescope-file-browser.nvim" },
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope-fzf-native.nvim",
    url = "git@github.com:nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope.nvim"] = {
    after = { "cheatsheet.nvim", "telescope-fzf-native.nvim", "telescope-emoji.nvim", "octo.nvim" },
    commands = { "Telescope" },
    config = { "\27LJ\2\n/\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\16:normal! zx\bcmd\bvimM\1\1\6\1\5\0\v-\1\0\0009\1\0\1\18\3\1\0009\1\1\0015\4\3\0003\5\2\0=\5\4\4B\1\3\1+\1\2\0002\0\0�L\1\2\0\0�\tpost\1\0\0\0\fenhance\vselect�\1\0\1\t\0\14\0\0266\1\0\0'\3\1\0B\1\2\0029\1\2\1B\1\1\0026\2\3\0009\2\4\0029\2\5\0029\4\6\1'\5\a\0B\2\3\0026\3\0\0'\5\b\0B\3\2\0029\3\t\3\18\5\0\0B\3\2\0016\3\3\0009\3\n\0036\5\v\0009\5\f\5'\a\r\0\18\b\2\0B\5\3\0A\3\0\1K\0\1\0\18silent lcd %s\vformat\vstring\bcmd\nclose\22telescope.actions\t:p:h\tpath\16fnamemodify\afn\bvim\23get_selected_entry\28telescope.actions.state\frequire<\0\1\a\0\5\0\b5\1\3\0\18\4\0\0009\2\0\0'\5\1\0'\6\2\0B\2\4\2=\2\4\1L\1\2\0\vprompt\1\0\0\a.*\a%s\tgsub/\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\16:normal! zx\bcmd\bvimM\1\1\6\1\5\0\v-\1\0\0009\1\0\1\18\3\1\0009\1\1\0015\4\3\0003\5\2\0=\5\4\4B\1\3\1+\1\2\0002\0\0�L\1\2\0\0�\tpost\1\0\0\0\fenhance\vselect�\19\1\0\f\0e\0�\0016\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\0016\0\0\0009\0\1\0'\2\4\0B\0\2\0016\0\0\0009\0\1\0'\2\5\0B\0\2\0016\0\0\0009\0\1\0'\2\6\0B\0\2\0016\0\a\0'\2\b\0B\0\2\0025\1\t\0003\2\n\0=\2\v\0016\2\a\0'\4\f\0B\2\2\0029\2\r\0029\2\14\0029\2\15\0026\3\a\0'\5\f\0B\3\2\0029\3\16\0035\0059\0005\6\17\0005\a\18\0=\a\19\0065\a\26\0005\b\21\0005\t\20\0=\t\22\b6\t\a\0'\v\23\0B\t\2\0029\t\24\t=\t\25\b=\b\27\a5\b\28\0006\t\a\0'\v\23\0B\t\2\0029\t\24\t=\t\29\b=\b\30\a=\a\31\0065\a!\0005\b \0=\b\"\a5\b#\0=\b$\a=\a%\0065\a&\0=\a'\0066\a\a\0'\t(\0B\a\2\0029\a)\a=\a*\0066\a\a\0'\t+\0B\a\2\0029\a,\a9\a-\a=\a.\0066\a\a\0'\t+\0B\a\2\0029\a/\a9\a-\a=\a0\0066\a\a\0'\t+\0B\a\2\0029\a1\a9\a-\a=\a2\0066\a\a\0'\t(\0B\a\2\0029\a3\a=\a4\0066\a\a\0'\t+\0B\a\2\0029\a5\a=\a5\0065\a6\0=\a7\0064\a\0\0=\a8\6=\6:\0055\6D\0005\aC\0005\bB\0005\t<\0009\n;\2=\n=\t9\n>\2=\n?\t9\n@\2=\nA\t=\t\27\b=\b\31\a=\a\14\0065\aE\0=\aF\0065\aG\0005\bH\0=\bI\a=\aJ\6=\6\r\0055\6K\0=\1L\0065\aQ\0005\bP\0005\tN\0003\nM\0=\nO\t=\t\30\b=\b\31\a=\aR\6=\1S\6=\1T\0065\aV\0003\bU\0=\bW\a3\bX\0=\b\v\a=\aY\6=\1Z\0065\a[\0=\a\\\0065\a]\0005\b^\0=\b%\a=\a_\0065\a`\0=\aa\6=\6b\5B\3\2\0016\3\a\0'\5\f\0B\3\2\0029\3c\3'\5F\0B\3\2\0016\3\a\0'\5\f\0B\3\2\0029\3c\3'\5J\0B\3\2\0016\3\a\0'\5\f\0B\3\2\0029\3c\3'\5\14\0B\3\2\0016\3\a\0'\5\f\0B\3\2\0029\3c\3'\5d\0B\3\2\0012\0\0�K\0\1\0\nemoji\19load_extension\fpickers\21lsp_code_actions\1\0\2\ntheme\vcursor\17initial_mode\vnormal\19lsp_references\1\0\2\nwidth\4����\t����\3\vheight\4����\t����\3\1\0\2\ntheme\vcursor\17initial_mode\vnormal\16diagnostics\1\0\1\17initial_mode\vnormal\roldfiles\14live_grep\0\23on_input_filter_cb\1\0\0\0\16grep_string\14git_files\15find_files\1\0\0\1\0\0\acd\1\0\0\0\fbuffers\1\0\0\rfrecency\20ignore_patterns\1\3\0\0\f*.git/*\f*/tmp/*\1\0\2\19show_unindexed\2\16show_scores\2\bfzf\1\0\4\14case_mode\15smart_case\nfuzzy\2\28override_generic_sorter\2\25override_file_sorter\2\1\0\0\1\0\0\1\0\0\n<C-c>\vcreate\n<C-e>\vrename\n<C-h>\1\0\0\20goto_parent_dir\rdefaults\1\0\0\vborder\17path_display\1\2\0\0\nsmart\27buffer_previewer_maker\19generic_sorter\29get_generic_fuzzy_sorter\21qflist_previewer\22vim_buffer_qflist\19grep_previewer\23vim_buffer_vimgrep\19file_previewer\bnew\19vim_buffer_cat\25telescope.previewers\16file_sorter\19get_fuzzy_file\22telescope.sorters\25file_ignore_patterns\1\v\0\0\24packer_compiled.lua\19static_content\17node_modules\n.git/\v.cache\f%.class\n%.pdf\n%.mkv\n%.mp4\n%.zip\18layout_config\rvertical\1\0\1\vmirror\1\15horizontal\1\0\3\19preview_cutoff\3x\vheight\4����\t����\3\nwidth\4����\3����\3\1\0\3\20prompt_position\btop\18preview_width\4����\t����\3\18results_width\4����\t����\3\rmappings\6n\6q\1\0\0\6i\1\0\0\n<Esc>\nclose\22telescope.actions\n<C-a>\1\0\0\1\2\1\0\f<esc>0i\ttype\fcommand\22vimgrep_arguments\1\t\0\0\arg\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\17--smart-case\r--hidden\1\0\t\21sorting_strategy\14ascending\23selection_strategy\nreset\rwinblend\3\0\20scroll_strategy\nlimit\18prompt_prefix\n🔭 \20selection_caret\b» \18initial_model\vnormal\20layout_strategy\15horizontal\19color_devicons\2\nsetup\factions\17file_browser\15extensions\14telescope\20attach_mappings\0\1\0\1\vhidden\2\26telescope.actions.set\frequire!packadd telescope-emoji.nvim$packadd telescope-frecency.nvim(packadd telescope-file-browser.nvim&packadd telescope-fzf-native.nvim\23packadd sqlite.lua\bcmd\bvim\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope.nvim",
    url = "git@github.com:nvim-telescope/telescope.nvim"
  },
  ["trouble.nvim"] = {
    commands = { "Trouble", "TroubleToggle", "TroubleRefresh" },
    config = { "\27LJ\2\n�\2\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\nsigns\1\0\5\16information\b\nerror\b\nother\b﫠\thint\b\fwarning\b\14auto_jump\1\2\0\0\20lsp_definitions\1\0\b\17indent_lines\1\14fold_open\b\17auto_preview\2\15auto_close\2\29use_lsp_diagnostic_signs\1\14auto_fold\1\tmode\25document_diagnostics\16fold_closed\b\nsetup\ftrouble\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/trouble.nvim",
    url = "git@github.com:folke/trouble.nvim"
  },
  ["twilight.nvim"] = {
    config = { "\27LJ\2\n�\1\0\0\6\0\f\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\3\0005\3\6\0005\4\3\0005\5\4\0=\5\5\4=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\3>\3\1\2B\0\2\1K\0\1\0\fexclude\1\2\0\0\n.git*\vexpand\1\5\0\0\rfunction\vmethod\ntable\17if_statement\fdimming\1\0\2\fcontext\0032\15treesitter\2\ncolor\1\3\0\0\vNormal\f#ffffff\1\0\2\nalpha\4\0����\3\rinactive\2\nsetup\rtwilight\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/twilight.nvim",
    url = "git@github.com:folke/twilight.nvim"
  },
  ["vim-bazel"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-bazel",
    url = "git@github.com:bazelbuild/vim-bazel"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/vim-commentary",
    url = "git@github.com:tpope/vim-commentary"
  },
  ["vim-cool"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-cool",
    url = "git@github.com:romainl/vim-cool"
  },
  ["vim-easy-align"] = {
    commands = { "EasyAlign" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-easy-align",
    url = "git@github.com:junegunn/vim-easy-align"
  },
  ["vim-eft"] = {
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-eft",
    url = "git@github.com:hrsh7th/vim-eft"
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
    config = { "\27LJ\2\n�\1\0\0\2\0\5\0\r6\0\0\0009\0\1\0)\1\0\0=\1\2\0006\0\0\0009\0\1\0)\1\0\0=\1\3\0006\0\0\0009\0\1\0)\1\0\0=\1\4\0K\0\1\0\31go_code_completion_enabled\27go_def_mapping_enabled\30go_doc_keywordprg_enabled\6g\bvim\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-go",
    url = "git@github.com:fatih/vim-go"
  },
  ["vim-illuminate"] = {
    config = { "\27LJ\2\n�\1\0\0\2\0\5\0\t6\0\0\0009\0\1\0)\1\0\0=\1\2\0006\0\0\0009\0\1\0005\1\4\0=\1\3\0K\0\1\0\1\f\0\0\thelp\14dashboard\nalpha\vpacker\tnorg\rDoomInfo\rNvimTree\fOutline\15toggleterm\fTrouble\rquickfix\27Illuminate_ftblacklist$Illuminate_highlightUnderCursor\6g\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-illuminate",
    url = "git@github.com:RRethy/vim-illuminate"
  },
  ["vim-maktaba"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/vim-maktaba",
    url = "git@github.com:google/vim-maktaba"
  },
  ["vim-matchup"] = {
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-matchup/after/plugin/matchit.vim" },
    load_after = {},
    loaded = false,
    needs_bufread = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-matchup",
    url = "git@github.com:andymass/vim-matchup"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/vim-repeat",
    url = "git@github.com:tpope/vim-repeat"
  },
  ["vim-sleuth"] = {
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/vim-sleuth",
    url = "git@github.com:tpope/vim-sleuth"
  },
  vimtex = {
    config = { "\27LJ\2\n�\5\0\0\3\0\n\0\0176\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0006\0\0\0009\0\1\0'\1\a\0=\1\6\0006\0\0\0009\0\b\0'\2\t\0B\0\2\1K\0\1\0�\3augroup vimtex_mac\n    autocmd!\n    autocmd User VimtexEventCompileSuccess call UpdateSkim()\naugroup END\n\nfunction! UpdateSkim() abort\n    let l:out = b:vimtex.out()\n    let l:src_file_path = expand('%:p')\n    let l:cmd = [g:vimtex_view_general_viewer, '-r']\n\n    if !empty(system('pgrep Skim'))\n    call extend(l:cmd, ['-g'])\n    endif\n\n    call jobstart(l:cmd + [line('.'), l:out, l:src_file_path])\nendfunction\n  \bcmd\23-r @line @pdf @tex vimtex_view_general_options>/Applications/Skim.app/Contents/SharedSupport/displayline\31vimtex_view_general_viewer\tskim\23vimtex_view_method\6g\bvim\0" },
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
  ["zen-mode.nvim"] = {
    config = { "\27LJ\2\n:\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\rzen-mode\frequire\0" },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/zen-mode.nvim",
    url = "git@github.com:folke/zen-mode.nvim"
  }
}

time([[Defining packer_plugins]], false)
local module_lazy_loads = {
  ["^octo"] = "octo.nvim",
  ["^refactoring"] = "refactoring.nvim",
  ["^spectre"] = "nvim-spectre"
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
try_loadstring("\27LJ\2\n�\1\0\0\2\0\6\0\r6\0\0\0009\0\1\0+\1\2\0=\1\2\0006\0\0\0009\0\1\0+\1\2\0=\1\3\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0K\0\1\0\5\25copilot_tab_fallback\26copilot_assume_mapped\23copilot_no_tab_map\6g\bvim\0", "setup", "copilot.vim")
time([[Setup for copilot.vim]], false)
-- Config for: filetype.nvim
time([[Config for filetype.nvim]], true)
try_loadstring("\27LJ\2\nm\0\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\4\0005\4\3\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\14overrides\1\0\0\fshebang\1\0\0\1\0\1\tdash\ash\nsetup\rfiletype\frequire\0", "config", "filetype.nvim")
time([[Config for filetype.nvim]], false)
-- Config for: mason-tool-installer.nvim
time([[Config for mason-tool-installer.nvim]], true)
try_loadstring("\27LJ\2\n�\3\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\21ensure_installed\1\0\2\17run_on_start\1\16auto_update\2\1\26\0\0\befm\18rust-analyzer\vclangd\tdeno\31typescript-language-server\31dockerfile-language-server\ngopls\rrnix-lsp\fpyright\njdtls\25bash-language-server\24lua-language-server\vstylua\vselene\nblack\vpylint\rprettier\15shellcheck\nshfmt\tvint\ntaplo\vclangd\24vim-language-server\bbuf\vtflint\nsetup\25mason-tool-installer\frequire\0", "config", "mason-tool-installer.nvim")
time([[Config for mason-tool-installer.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n�\r\0\0\f\0?\0Y6\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0004\4\0\0B\0\4\0016\0\0\0009\0\1\0009\0\2\0'\2\5\0'\3\6\0004\4\0\0B\0\4\0016\0\a\0'\2\b\0B\0\2\0029\0\t\0005\2\n\0005\3\v\0=\3\f\0025\3\r\0=\3\14\0025\3\15\0005\4\16\0=\4\17\3=\3\18\0025\3\19\0=\3\20\0025\3\21\0=\3\22\0025\3\25\0005\4\23\0005\5\24\0=\5\17\4=\4\26\0035\4\27\0005\5\28\0=\5\29\0045\5\30\0=\5\31\4=\4 \0035\4!\0005\5\"\0=\5#\0045\5$\0=\5%\0045\5&\0=\5'\0045\5(\0=\5)\4=\4*\0035\4+\0005\5,\0=\5-\4=\4.\3=\3/\0025\0030\0=\0031\2B\0\2\0016\0\a\0'\0022\0B\0\2\2+\1\2\0=\0013\0006\0\a\0'\0024\0B\0\2\0029\0005\0B\0\1\0026\0016\0\18\3\0\0B\1\2\4H\4\t�9\0067\0059\a7\0059\a8\a\18\t\a\0009\a9\a'\n:\0'\v;\0B\a\4\2=\a8\6F\4\3\3R\4�\1279\1<\0'\2>\0=\2=\1K\0\1\0\tocto\27filetype_to_parsername\rmarkdown\20git@github.com:\24https://github.com/\tgsub\burl\17install_info\npairs\23get_parser_configs\28nvim-treesitter.parsers\15prefer_git\28nvim-treesitter.install\frainbow\1\0\3\venable\2\19max_file_lines\3�\a\18extended_mode\2\16textobjects\16lsp_interop\25peek_definition_code\1\0\2\15<leader>sD\17@class.outer\15<leader>sd\20@function.outer\1\0\2\vborder\tnone\venable\2\tmove\22goto_previous_end\1\0\2\a[M\17@class.outer\a[]\20@function.outer\24goto_previous_start\1\0\2\a[m\17@class.outer\a[[\20@function.outer\18goto_next_end\1\0\2\a]M\17@class.outer\a]]\20@function.outer\20goto_next_start\1\0\2\a]m\17@class.outer\a][\20@function.outer\1\0\2\venable\2\14set_jumps\2\tswap\18swap_previous\1\0\1\14<leader>A\21@parameter.inner\14swap_next\1\0\1\14<leader>a\21@parameter.inner\1\0\1\venable\2\vselect\1\0\0\1\0\14\ais\21@statement.inner\aai\16@call.outer\aif\20@function.inner\aal\16@loop.outer\aaf\20@function.outer\aii\16@call.inner\ail\16@loop.inner\aas\21@statement.outer\aab\17@block.outer\aaC\17@class.outer\aiC\17@class.inner\aac\23@conditional.outer\aib\17@block.inner\aic\23@conditional.inner\1\0\2\venable\2\14lookahead\2\fmatchup\1\0\1\venable\2\26context_commentstring\1\0\2\venable\2\19enable_autocmd\1\26incremental_selection\fkeymaps\1\0\4\21node_incremental\bgrn\19init_selection\bgnn\22scope_incremental\bgrc\21node_decremental\bgrm\1\0\1\venable\2\14highlight\1\0\1\venable\2\19ignore_install\1\6\0\0\vphpdoc\tvala\ntiger\nslint\beex\1\0\1\21ensure_installed\ball\nsetup\28nvim-treesitter.configs\frequire\31nvim_treesitter#foldexpr()\rfoldexpr\texpr\15foldmethod\26nvim_set_option_value\bapi\bvim\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: nvim-surround
time([[Config for nvim-surround]], true)
try_loadstring("\27LJ\2\n;\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\18nvim-surround\frequire\0", "config", "nvim-surround")
time([[Config for nvim-surround]], false)
-- Config for: rose-pine
time([[Config for rose-pine]], true)
try_loadstring("\27LJ\2\n�\1\0\0\3\0\4\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0B\0\2\1K\0\1\0\1\0\6\17dark_variant\tmoon\29disable_float_background\1\20disable_italics\1\20bold_vert_split\2\22dim_nc_background\1\23disable_background\2\nsetup\14rose-pine\frequire\0", "config", "rose-pine")
time([[Config for rose-pine]], false)
-- Config for: catppuccin
time([[Config for catppuccin]], true)
try_loadstring("\27LJ\2\n�\5\0\0\3\0:\0?6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\2'\1\4\0=\1\3\0006\1\5\0009\1\6\0019\1\a\1\a\1\b\0X\0012�'\1\n\0=\1\t\0'\1\f\0=\1\v\0'\1\14\0=\1\r\0'\1\16\0=\1\15\0'\1\18\0=\1\17\0'\1\20\0=\1\19\0'\1\22\0=\1\21\0'\1\24\0=\1\23\0'\1\26\0=\1\25\0'\1\28\0=\1\27\0'\1\30\0=\1\29\0'\1 \0=\1\31\0'\1\"\0=\1!\0'\1$\0=\1#\0'\1&\0=\1%\0'\1(\0=\1'\0'\1*\0=\1)\0'\1,\0=\1+\0'\1.\0=\1-\0'\1.\0=\1/\0'\0011\0=\0010\0'\0013\0=\0012\0'\0015\0=\0014\0'\0017\0=\0016\0'\0019\0=\0018\0L\0\2\0\f#161320\ncrust\f#1A1826\vmantle\f#1E1E2E\tbase\f#302D41\rsurface0\f#575268\rsurface1\rsurface2\f#6E6C7E\roverlay0\f#988BA2\roverlay1\f#C3BAC6\roverlay2\f#A6ADC8\rsubtext0\f#BAC2DE\rsubtext1\f#D9E0EE\ttext\f#C9CBFF\rlavender\f#B5E8E0\tteal\f#89DCEB\bsky\f#96CDFB\tblue\f#ABE9B3\ngreen\f#FAE3B0\vyellow\f#F8BD96\npeach\f#E8A2AF\vmaroon\f#F28FAD\bred\f#F5C2E7\tpink\f#DDB6F2\nmauve\f#F2CDCD\rflamingo\f#F5E0DC\14rosewater\nmocha\23catppuccin_flavour\6g\bvim\tNONE\tnone\16get_palette\24catppuccin.palettes\frequire:\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\27colorscheme catppuccin\bcmd\bvim\\\1\0\4\0\6\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0016\0\3\0009\0\4\0003\2\5\0)\3\0\0B\0\3\1K\0\1\0\0\rdefer_fn\bvim\fcompile\15catppuccin\frequire�\1\1\1\6\0\n\0\17\15\0\0\0X\1\14�6\1\0\0009\1\1\0019\1\2\1'\3\3\0005\4\4\0B\1\3\0016\1\0\0009\1\1\0019\1\5\1'\3\6\0005\4\a\0003\5\b\0=\5\t\4B\1\3\1K\0\1\0\rcallback\0\1\0\2\ngroup\16_catppuccin\fpattern\22PackerCompileDone\tUser\24nvim_create_autocmd\1\0\1\nclear\2\16_catppuccin\24nvim_create_augroup\bapi\bvim�\30\1\0\n\0�\1\0�\0023\0\0\0003\1\1\0006\2\2\0009\2\3\2'\3\5\0=\3\4\2\18\2\0\0B\2\1\0026\3\6\0009\3\a\3\a\3\b\0X\3\4�+\3\2\0\18\4\1\0\18\6\3\0B\4\2\0016\3\t\0'\5\b\0B\3\2\0029\3\n\0035\5\f\0005\6\v\0=\6\r\0055\6\14\0006\a\15\0=\a\16\0066\a\2\0009\a\17\a9\a\18\a'\t\19\0B\a\2\2'\b\20\0&\a\b\a=\a\21\6=\6\22\0055\6\24\0005\a\23\0=\a\25\0065\a\26\0=\a\27\0065\a\28\0=\a\29\0065\a\30\0=\a\31\0065\a \0=\a!\0065\a\"\0=\a#\0065\a$\0=\a%\0065\a&\0=\a'\0064\a\0\0=\a(\0064\a\0\0=\a)\0064\a\0\0=\a*\0064\a\0\0=\a+\6=\6,\0055\6-\0005\a.\0005\b0\0005\t/\0=\t1\b5\t2\0=\t3\b5\t4\0=\t5\b5\t6\0=\t7\b=\b8\a5\b:\0005\t9\0=\t1\b5\t;\0=\t3\b5\t<\0=\t5\b5\t=\0=\t7\b=\b>\a=\a?\0065\a@\0=\aA\0065\aB\0=\aC\0065\aD\0=\aE\0065\aF\0=\aG\6=\6H\0055\6J\0005\aI\0=\aK\6=\6L\0055\6�\0005\aP\0005\bN\0009\tM\2=\tO\b=\bQ\a5\bS\0009\tR\2=\tT\b9\tU\2=\tO\b5\tV\0=\tW\b=\bX\a5\bY\0009\tU\2=\tT\b9\tR\2=\tO\b=\bZ\a5\b\\\0009\t[\2=\tT\b=\b]\a5\b^\0009\t[\2=\tT\b=\b_\a5\b`\0009\t[\2=\tT\b=\ba\a5\bc\0009\tb\2=\tO\b9\t[\2=\tT\b=\bd\a5\be\0009\tb\2=\tO\b=\bf\a5\bg\0009\tb\2=\tO\b=\bh\a5\bi\0009\tb\2=\tO\b=\bj\a5\bk\0009\tb\2=\tO\b=\bl\a5\bm\0009\tb\2=\tn\b=\bo\a5\bp\0009\t[\2=\tT\b9\tq\2=\tO\b=\br\a5\bt\0009\ts\2=\tO\b5\tu\0=\tW\b=\bv\a5\bw\0009\tb\2=\tO\b=\bx\a5\bz\0009\ty\2=\tO\b=\b{\a5\b}\0009\t|\2=\tO\b=\b~\a5\b�\0009\t\127\2=\tO\b=\b�\a5\b�\0009\t\127\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b5\t�\0=\tW\b=\b�\a5\b�\0009\t�\2=\tO\b4\t\0\0=\tW\b=\b�\a5\b�\0009\tb\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\tU\2=\tO\b4\t\0\0=\tW\b=\b�\a5\b�\0005\t�\0=\tW\b=\b�\a5\b�\0009\tb\2=\tO\b=\b�\a5\b�\0009\t|\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b5\t�\0=\tW\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b5\t�\0=\tW\b=\b�\a5\b�\0009\ty\2=\tO\b5\t�\0=\tW\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\t|\2=\tO\b=\b�\a5\b�\0009\t�\2=\tO\b5\t�\0=\tW\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a5\b�\0009\ty\2=\tO\b5\t�\0=\tW\b=\b�\a5\b�\0009\t�\2=\tO\b=\b�\a=\aK\6=\6�\5B\3\2\0016\3\2\0009\3�\0036\4\6\0009\4�\4=\4�\3K\0\1\0\15background\6o\24highlight_overrides\1\0\0\18cppTSProperty\1\0\0\18cssTSProperty\1\2\0\0\vitalic\1\0\0\14cssTSType\1\0\0\25typescriptTSProperty\1\2\0\0\vitalic\1\0\0\19javaTSConstant\1\0\0\21luaTSConstructor\1\0\0\rflamingo\15luaTSField\1\0\0\20bashTSParameter\1\2\0\0\vitalic\1\0\0\22bashTSFuncBuiltin\1\2\0\0\vitalic\1\0\0\vTSText\1\0\0\19TSTagDelimiter\1\0\0\nTSTag\1\0\0\19TSTagAttribute\1\2\0\0\vitalic\1\0\0\nmauve\15TSVariable\1\0\0\ttext\19TSPunctBracket\1\0\0\roverlay2\21TSPunctDelimiter\1\0\0\16TSNamespace\1\0\0\rTSMethod\1\0\0\1\2\0\0\vitalic\20TSKeywordReturn\1\0\0\14TSKeyword\1\0\0\22TSKeywordFunction\1\0\0\16TSParameter\1\0\0\16TSFuncMacro\1\0\0\22TSVariableBuiltin\1\2\0\0\vitalic\1\0\0\bred\19TSConstBuiltin\1\0\0\16TSException\1\0\0\npeach\18TSConstructor\1\0\0\rlavender\19TSPunctSpecial\1\0\0\vmaroon\22TSKeywordOperator\1\0\0\15TSOperator\1\0\0\bsky\14TSInclude\1\0\0\tteal\15TSProperty\1\0\0\vyellow\fTSField\1\0\0\16FidgetTitle\1\2\0\0\tbold\1\0\0\tblue\15FidgetTask\rsurface2\1\0\0 LspDiagnosticsUnderlineHint\asp\1\0\0\"LspDiagnosticsVirtualTextHint\1\0\0\23LspDiagnosticsHint\1\0\0\30LspDiagnosticsDefaultHint\1\0\0\19DiagnosticHint\1\0\0\30DiagnosticVirtualTextHint\1\0\0\14rosewater\30DiagnosticVirtualTextInfo\1\0\0\30DiagnosticVirtualTextWarn\1\0\0\31DiagnosticVirtualTextError\1\0\0\tnone\14IncSearch\1\0\0\vSearch\nstyle\1\2\0\0\tbold\tpink\abg\1\0\0\rsurface1\17CursorLineNr\1\0\0\afg\1\0\0\ngreen\20color_overrides\nmocha\1\0\0\1\0\25\rsubtext1\f#BAC2DE\ttext\f#D9E0EE\rsubtext0\f#A6ADC8\rsurface1\f#575268\roverlay2\f#C3BAC6\14rosewater\f#F5E0DC\roverlay1\f#988BA2\rflamingo\f#F2CDCD\roverlay0\f#6E6C7E\nmauve\f#DDB6F2\rsurface2\f#6E6C7E\tpink\f#F5C2E7\rsurface0\f#302D41\bred\f#F28FAD\tbase\f#1E1E2E\vmaroon\f#E8A2AF\vmantle\f#1A1826\npeach\f#F8BD96\ncrust\f#161320\vyellow\f#FAE3B0\ngreen\f#ABE9B3\tblue\f#96CDFB\bsky\f#89DCEB\tteal\f#B5E8E0\rlavender\f#C9CBFF\17integrations\nnavic\1\0\2\14custom_bg\tNONE\fenabled\2\fneotree\1\0\3\22transparent_panel\1\fenabled\1\14show_root\2\bdap\1\0\2\14enable_ui\2\fenabled\2\21indent_blankline\1\0\2\26colored_indent_levels\1\fenabled\2\15native_lsp\15underlines\1\2\0\0\14underline\1\2\0\0\14underline\1\2\0\0\14underline\1\0\0\1\2\0\0\14underline\17virtual_text\16information\1\2\0\0\vitalic\rwarnings\1\2\0\0\vitalic\nhints\1\2\0\0\vitalic\verrors\1\0\0\1\2\0\0\vitalic\1\0\1\fenabled\2\1\0\29\15telekasten\1\rgitsigns\2\16lsp_trouble\2\bhop\2\fvimwiki\2\rmarkdown\2\14telescope\2\rcoc_nvim\1\tleap\1\tmini\1\vaerial\1\vbeacon\1\roverseer\1\rlsp_saga\2\14gitgutter\2\rnvimtree\2\14which_key\2\14dashboard\2\vneogit\1\14vim_sneak\1\tfern\1\vbarbar\1\15lightspeed\1\15ts_rainbow\2\20symbols_outline\1\bcmp\2\vnotify\2\vfidget\2\15treesitter\2\vstyles\14variables\fstrings\ntypes\fnumbers\rbooleans\1\3\0\0\tbold\vitalic\nloops\1\2\0\0\tbold\17conditionals\1\2\0\0\tbold\14operators\1\2\0\0\tbold\rkeywords\1\2\0\0\vitalic\14functions\1\3\0\0\vitalic\tbold\15properties\1\2\0\0\vitalic\rcomments\1\0\0\1\2\0\0\vitalic\fcompile\tpath\16/catppuccin\ncache\fstdpath\afn\fenabled\19enable_compile\1\0\0\17dim_inactive\1\0\2\27transparent_background\2\16term_colors\2\1\0\3\fenabled\1\nshade\nlight\15percentage\4��̙\3���\3\nsetup\frequire\15catppuccin\16colorscheme\20__editor_config\nlatte\23catppuccin_flavour\6g\bvim\0\0\0", "config", "catppuccin")
time([[Config for catppuccin]], false)
-- Conditional loads
time([[Conditional loading of nvim-tmux-navigation]], true)
  require("packer.load")({"nvim-tmux-navigation"}, {}, _G.packer_plugins)
time([[Conditional loading of nvim-tmux-navigation]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd nvim-web-devicons ]]
vim.cmd [[ packadd dressing.nvim ]]
time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Ggrep lua require("packer.load")({'vim-fugitive'}, { cmd = "Ggrep", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GBrowse lua require("packer.load")({'vim-fugitive'}, { cmd = "GBrowse", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file EasyAlign lua require("packer.load")({'vim-easy-align'}, { cmd = "EasyAlign", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TroubleToggle lua require("packer.load")({'trouble.nvim'}, { cmd = "TroubleToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SaveSession lua require("packer.load")({'auto-session'}, { cmd = "SaveSession", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file RestoreSession lua require("packer.load")({'auto-session'}, { cmd = "RestoreSession", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file JupyterExecute lua require("packer.load")({'jupyter_ascending.vim'}, { cmd = "JupyterExecute", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file JupyterExecuteAll lua require("packer.load")({'jupyter_ascending.vim'}, { cmd = "JupyterExecuteAll", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewOpen lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DiffviewFileHistory lua require("packer.load")({'diffview.nvim'}, { cmd = "DiffviewFileHistory", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file NvimTreeToggle lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Copilot lua require("packer.load")({'copilot.vim'}, { cmd = "Copilot", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file G lua require("packer.load")({'vim-fugitive'}, { cmd = "G", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Trouble lua require("packer.load")({'trouble.nvim'}, { cmd = "Trouble", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TroubleRefresh lua require("packer.load")({'trouble.nvim'}, { cmd = "TroubleRefresh", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Git lua require("packer.load")({'vim-fugitive'}, { cmd = "Git", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Octo lua require("packer.load")({'octo.nvim'}, { cmd = "Octo", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Telescope lua require("packer.load")({'telescope.nvim'}, { cmd = "Telescope", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file DeleteSession lua require("packer.load")({'auto-session'}, { cmd = "DeleteSession", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType rust ++once lua require("packer.load")({'rust-tools.nvim'}, { ft = "rust" }, _G.packer_plugins)]]
vim.cmd [[au FileType qf ++once lua require("packer.load")({'nvim-bqf'}, { ft = "qf" }, _G.packer_plugins)]]
vim.cmd [[au FileType rst ++once lua require("packer.load")({'tablify'}, { ft = "rst" }, _G.packer_plugins)]]
vim.cmd [[au FileType tex ++once lua require("packer.load")({'vimtex'}, { ft = "tex" }, _G.packer_plugins)]]
vim.cmd [[au FileType latex ++once lua require("packer.load")({'cmp-latex-symbols'}, { ft = "latex" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'markdown-preview.nvim'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType go ++once lua require("packer.load")({'vim-go'}, { ft = "go" }, _G.packer_plugins)]]
vim.cmd [[au FileType ipynb ++once lua require("packer.load")({'jupyter_ascending.vim'}, { ft = "ipynb" }, _G.packer_plugins)]]
vim.cmd [[au FileType bzl ++once lua require("packer.load")({'vim-bazel'}, { ft = "bzl" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au BufEnter * ++once lua require("packer.load")({'which-key.nvim'}, { event = "BufEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'nvim-lspconfig'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
vim.cmd [[au BufWinEnter * ++once lua require("packer.load")({'alpha-nvim'}, { event = "BufWinEnter *" }, _G.packer_plugins)]]
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'vim-cool', 'nvim-cmp'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au CursorMoved * ++once lua require("packer.load")({'vim-cool'}, { event = "CursorMoved *" }, _G.packer_plugins)]]
vim.cmd [[au BufRead * ++once lua require("packer.load")({'hop.nvim', 'gitsigns.nvim', 'nvim-toggleterm.lua', 'vim-illuminate', 'nvim-colorizer.lua', 'indent-blankline.nvim', 'fidget.nvim', 'nvim-bufferline.lua'}, { event = "BufRead *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPost * ++once lua require("packer.load")({'stabilize.nvim', 'vim-eft'}, { event = "BufReadPost *" }, _G.packer_plugins)]]
vim.cmd [[au BufNewFile * ++once lua require("packer.load")({'gitsigns.nvim'}, { event = "BufNewFile *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/cls.vim]], true)
vim.cmd [[source /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/cls.vim]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/cls.vim]], false)
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tex.vim]], true)
vim.cmd [[source /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tex.vim]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tex.vim]], false)
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tikz.vim]], true)
vim.cmd [[source /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tikz.vim]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vimtex/ftdetect/tikz.vim]], false)
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], true)
vim.cmd [[source /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-go/ftdetect/gofiletype.vim]], false)
vim.cmd("augroup END")

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
