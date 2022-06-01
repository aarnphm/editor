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
    after = { "cmp_luasnip" },
    config = { "\27LJ\2\n�\1\0\0\3\0\a\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0009\0\3\0005\2\4\0B\0\2\0016\0\0\0'\2\5\0B\0\2\0029\0\6\0B\0\1\1K\0\1\0\tload luasnip/loaders/from_vscode\1\0\2\fhistory\2\17updateevents\29TextChanged,TextChangedI\15set_config\vconfig\fluasnip\frequire\0" },
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/LuaSnip",
    url = "git@github.com:L3MON4D3/LuaSnip",
    wants = { "friendly-snippets" }
  },
  ["alpha-nvim"] = {
    cond = { "\27LJ\2\nM\0\0\2\0\3\0\f6\0\0\0009\0\1\0009\0\2\0B\0\1\2\21\0\0\0)\1\0\0\0\1\0\0X\0\2�+\0\1\0X\1\1�+\0\2\0L\0\2\0\18nvim_list_uis\bapi\bvim\0" },
    config = { "\27LJ\2\n�\1\0\0\6\1\6\0\0186\0\0\0009\0\1\0009\0\2\0-\2\0\0'\3\3\0&\2\3\2+\3\2\0+\4\1\0+\5\2\0B\0\5\0026\1\0\0009\1\1\0019\1\4\1\18\3\0\0'\4\5\0+\5\1\0B\1\4\1K\0\1\0\5�\6t\18nvim_feedkeys\r<Ignore>\27nvim_replace_termcodes\bapi\bvim�\2\1\5\f\0\17\0\"\18\a\0\0009\5\0\0'\b\1\0'\t\2\0B\5\4\2\18\a\5\0009\5\0\5\18\b\2\0'\t\3\0B\5\4\0023\6\4\0005\a\5\0=\0\6\a\v\3\0\0X\b\1�\18\3\5\0006\b\a\0009\b\b\b9\b\t\b\18\n\4\0005\v\n\0B\b\3\2\18\4\b\0005\b\f\0>\5\2\b>\3\3\b>\4\4\b=\b\v\a5\b\r\0=\1\14\b=\6\15\b=\a\16\b2\0\0�L\b\2\0\topts\ron_press\bval\1\0\1\ttype\vbutton\1\2\0\0\6n\vkeymap\1\0\3\vnowait\2\vsilent\2\fnoremap\2\vif_nil\6F\bvim\rshortcut\1\0\5\19align_shortcut\nright\rposition\vcenter\16hl_shortcut\fKeyword\nwidth\0032\vcursor\3\5\0\r<leader>\5\a%s\tgsub�\1\0\0\v\0\f\0\0266\0\0\0009\0\1\0006\2\2\0B\0\2\2\21\0\0\0'\1\3\0'\2\4\0006\3\0\0009\3\5\3B\3\1\0029\3\6\3'\4\a\0006\5\0\0009\5\5\5B\5\1\0029\5\b\5'\6\a\0006\a\0\0009\a\5\aB\a\1\0029\a\t\a'\b\n\0\18\t\0\0'\n\v\0&\1\n\1L\1\2\0\r plugins\v   \npatch\nminor\6.\nmajor\fversion\f   v#🍱 github.com/aarnphm/editor\19packer_plugins\rtbl_keys\bvim�`\1\0\17\0:\3�\0016\0\0\0'\2\1\0B\0\2\0026\1\0\0'\3\2\0B\1\2\2+\2\0\0006\3\3\0009\3\4\3\a\3\5\0X\3\2�5\2\6\0X\3\1�5\2\a\0003\3\b\0009\4\t\0019\4\n\4=\2\v\4'\4\f\0'\5\r\0009\6\t\0019\6\14\0064\a\t\0\18\b\3\0'\n\15\0'\v\16\0\18\f\4\0'\r\17\0B\b\5\2>\b\1\a\18\b\3\0'\n\18\0'\v\19\0\18\f\4\0'\r\20\0B\b\5\2>\b\2\a\18\b\3\0'\n\21\0'\v\22\0\18\f\4\0'\r\23\0B\b\5\2>\b\3\a\18\b\3\0'\n\24\0'\v\25\0\18\f\4\0'\r\26\0B\b\5\2>\b\4\a\18\b\3\0'\n\27\0'\v\28\0\18\f\4\0'\r\29\0B\b\5\2>\b\5\a\18\b\3\0'\n\30\0'\v\31\0\18\f\5\0'\r \0B\b\5\2>\b\6\a\18\b\3\0'\n!\0'\v\"\0\18\f\5\0'\r#\0B\b\5\2>\b\a\a\18\b\3\0'\n$\0'\v%\0\18\f\5\0'\r&\0B\b\5\0?\b\0\0=\a\v\0069\6\t\0019\6\14\0069\6'\6'\a)\0=\a(\0063\6*\0009\a\t\0019\a+\a\18\b\6\0B\b\1\2=\b\v\a9\a\t\0019\a+\a9\a'\a'\b,\0=\b(\a)\a\2\0009\b\t\0019\b\n\b9\b\v\b\21\b\b\0009\t\t\0019\t\14\t9\t\v\t\21\t\t\0\29\t\1\t \b\t\b \b\a\b6\t-\0009\t.\t)\v\0\0006\f-\0009\f/\f6\0140\0009\0141\0149\0142\14'\0163\0B\14\2\2!\14\b\14\24\14\2\14B\f\2\0A\t\1\2)\n\1\0009\v4\0014\f\a\0005\r6\0=\t\v\r>\r\1\f9\r\t\0019\r\n\r>\r\2\f5\r7\0=\a\v\r>\r\3\f9\r\t\0019\r\14\r>\r\4\f5\r8\0=\n\v\r>\r\5\f9\r\t\0019\r+\r>\r\6\f=\f5\v9\v9\0009\r'\1B\v\2\1K\0\1\0\nsetup\1\0\1\ttype\fpadding\1\0\1\ttype\fpadding\1\0\1\ttype\fpadding\vlayout\vconfig\6$\14winheight\afn\bvim\tceil\bmax\tmath\rFunction\vfooter\0\vString\ahl\topts�\1<cmd>lua require('core.utils').exec_telescope('telescope.builtin.files', 'find_files', {cwd = vim.fn.stdpath('config')})<cr>\21  NVIM access\14kplus e r!:e $MYVIMRC | :cd %:p:h <CR>\18  Settings\14kplus e s\29<cmd>e ~/.editor.lua<cr>\16  Editor\14kplus e cC<cmd>lua require('telescope').extensions.project.project{}<cr>\22  Project find\14comma f g\"<cmd>Telescope find_files<cr>\19  File find\14comma f f!<cmd>Telescope live_grep<cr>\19  Word find\14comma f w <cmd>Telescope oldfiles<cr>\22  File history\14comma f e <cmd>Telescope frecency<cr>\23  File frecency\14comma f r\fbuttons\nkplus\ncomma\bval\vheader\fsection\0\1\31\0\0�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣶⣶⣿⣿⣶⣤⣄⡀⢀⡠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⢻⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⠏⠙⠻⠷⠤⠀⠉⠙⠿⠿⠛⢁⣠⣤⣄⠀⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠚⠴⠶⠛⠛⠂⠀⠀⢠⠈⣁⣤⣶⡤⣼⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⠐⠜⠠⠶⣶⣶⣒⡶⢤⡤⠾⣞⠿⠟⠀⠀⢸⡀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡔⣯⡛⣷⠒⠠⠶⡏⠙⠋⠀⠀⢸⠀⠀⢻⡤⠤⠒⠚⠋⣇⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣼⠀⡽⢺⠀⠂⠀⠣⠤⠴⠒⠒⠋⠀⠀⢀⡇⠀⠀⠀⠀⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡄⠀⠓⢌⢣⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠈⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠢⢔⣋⠼⡇⠀⠀⠀⠀⠀⠀⠀⣠⠤⠤⠒⠀⠀⠀⡸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠉⠓⠶⢤⣄⣀⠀⠀⢀⣀⡠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⣾⠁⠀⠀⠀⠀⠀⠉⠉⠉⠉⢹⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣎⠀⠈⠑⠦⣀⠀⠀⠀⠀⠀⠀⠀⣼⠋⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣿⣿⣿⣷⣄⠀⠀⠀⠉⠒⣤⣀⠀⣠⣎⠀⢀⣿⣷⣦⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣤⣀⣰⣿⣾⣿⣿⣿⣷⣼⣿⣿⣿⣿⣿⣿⣷⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀�\1⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀\1\31\0\0�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠉⠉⠀⠀⠉⠛⠻⢿⡿⢟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⡄⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⣰⣦⣄⣈⣛⣿⣶⣦⣀⣀⣤⡾⠟⠛⠻⣿⡘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⣿⣿⣥⣋⣉⣤⣤⣽⣿⣿⡟⣷⠾⠛⠉⢛⠃⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⣯⣣⣟⣉⠉⠉⠭⢉⡛⢛⣁⠡⣀⣠⣿⣿⡇⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢫⠐⢤⠈⣭⣟⣉⢰⣦⣴⣿⣿⡇⣿⣿⡄⢛⣛⣭⣥⣴⠸⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠃⣿⢂⡅⣿⣽⣿⣜⣛⣛⣭⣭⣴⣿⣿⡿⢸⣿⣿⣿⣿⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢻⣿⣬⡻⡜⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣷⣿⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣝⡫⠴⣃⢸⣿⣿⣿⣿⣿⣿⣿⠟⣛⣛⣭⣿⣿⣿⢇⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢋⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⣶⣬⣉⡛⠻⠿⣿⣿⡿⠿⢟⣡⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢋⠁⣾⣿⣿⣿⣿⣿⣶⣶⣶⣶⡆⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠱⣿⣷⣮⣙⠿⣿⣿⣿⣿⣿⣿⣿⠃⣴⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠈⠻⣿⣿⣿⣶⣭⠛⠿⣿⠟⠱⣿⡿⠀⠈⠙⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⠏⠀⠁⠀⠀⠀⠈⠃⠀⠀⠀⠀⠀⠀⠈⠉⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿�\1⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿\tdark\15background\20__editor_config\27alpha.themes.dashboard\nalpha\frequire\17����\4\4\1����\3\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/alpha-nvim",
    url = "git@github.com:goolord/alpha-nvim"
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
    config = { "\27LJ\2\n�\5\0\0\6\0\18\0\0216\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0005\4\a\0005\5\b\0=\5\t\0045\5\n\0=\5\v\4=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\3=\3\17\2B\0\2\1K\0\1\0\17integrations\21indent_blankline\1\0\2\26colored_indent_levels\1\fenabled\2\rnvimtree\1\0\3\14show_root\2\22transparent_panel\1\fenabled\2\15native_lsp\15underlines\1\0\4\16information\14underline\verrors\14underline\nhints\14underline\rwarnings\14underline\17virtual_text\1\0\4\16information\vitalic\verrors\vitalic\nhints\vitalic\rwarnings\vitalic\1\0\1\fenabled\2\1\0\21\14dashboard\2\vneogit\1\14vim_sneak\1\tfern\1\vbarbar\1\14which_key\2\14telescope\2\15treesitter\2\rmarkdown\2\15lightspeed\1\rgitsigns\2\vnotify\2\15bufferline\2\bcmp\2\15ts_rainbow\2\bhop\1\15telekasten\2\20symbols_outline\2\16lsp_trouble\2\rlsp_saga\2\14gitgutter\2\vstyles\1\0\4\17conditionals\vitalic\nloops\vitalic\14functions\vitalic\rcomments\vitalic\1\0\2\16term_colors\2\27transparent_background\1\nsetup\15catppuccin\frequire\0" },
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "git@github.com:catppuccin/nvim"
  },
  ["cheatsheet.nvim"] = {
    config = { "\27LJ\2\n�\3\0\0\a\0\15\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\6\0006\4\0\0'\6\4\0B\4\2\0029\4\5\4=\4\a\0036\4\0\0'\6\4\0B\4\2\0029\4\b\4=\4\t\0036\4\0\0'\6\4\0B\4\2\0029\4\n\4=\4\v\0036\4\0\0'\6\4\0B\4\2\0029\4\f\4=\4\r\3=\3\14\2B\0\2\1K\0\1\0\23telescope_mappings\n<C-E>\25edit_user_cheatsheet\n<C-Y>\21copy_cheat_value\v<A-CR>\22select_or_execute\t<CR>\1\0\0\31select_or_fill_commandline!cheatsheet.telescope.actions\1\0\3\31bundled_plugin_cheatsheets\2#include_only_installed_plugins\2\24bundled_cheatsheets\2\nsetup\15cheatsheet\frequire\0" },
    load_after = {
      ["telescope.nvim"] = true
    },
    loaded = false,
    needs_bufread = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cheatsheet.nvim",
    url = "git@github.com:sudormrfbin/cheatsheet.nvim"
  },
  ["cmp-buffer"] = {
    after = { "cmp-tmux", "cmp-latex-symbols", "cmp-emoji", "cmp-cmdline" },
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-buffer/after/plugin/cmp_buffer.lua" },
    load_after = {
      ["cmp-path"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-buffer",
    url = "git@github.com:hrsh7th/cmp-buffer"
  },
  ["cmp-cmdline"] = {
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-cmdline/after/plugin/cmp_cmdline.lua" },
    load_after = {
      ["cmp-buffer"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-cmdline",
    url = "git@github.com:hrsh7th/cmp-cmdline"
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
  ["cmp-tmux"] = {
    after_files = { "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/cmp-tmux/after/plugin/cmp_tmux.vim" },
    load_after = {
      ["cmp-buffer"] = true
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
  ["copilot.vim"] = {
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/copilot.vim",
    url = "git@github.com:github/copilot.vim"
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
  ["fidget.nvim"] = {
    config = { "\27LJ\2\nX\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\ttext\1\0\0\1\0\1\fspinner\tdots\nsetup\vfidget\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
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
    config = { "\27LJ\2\n�\r\0\0\5\0\28\0\0316\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\14\0005\3\4\0005\4\3\0=\4\5\0035\4\6\0=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\0035\4\f\0=\4\r\3=\3\15\0025\3\16\0005\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\0025\3\26\0=\3\27\2B\0\2\1K\0\1\0\14diff_opts\1\0\1\rinternal\2\28current_line_blame_opts\1\0\2\21virtual_text_pos\beol\ndelay\3�\a\17watch_gitdir\1\0\2\17follow_files\2\rinterval\3�\a\fkeymaps\22n <LocalLeader>[g\1\2\1\0@&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'\texpr\2\22n <LocalLeader>]g\1\2\1\0@&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'\texpr\2\1\0\f\22n <LocalLeader>hb6<cmd>lua require(\"gitsigns\").blame_line(true)<CR>\vbuffer\2\22n <LocalLeader>hu7<cmd>lua require(\"gitsigns\").undo_stage_hunk()<CR>\fnoremap\2\22n <LocalLeader>hp4<cmd>lua require(\"gitsigns\").preview_hunk()<CR>\to ih4:<C-U>lua require(\"gitsigns\").text_object()<CR>\22n <LocalLeader>hr2<cmd>lua require(\"gitsigns\").reset_hunk()<CR>\22v <LocalLeader>hrV<cmd>lua require(\"gitsigns\").reset_hunk({vim.fn.line(\".\"), vim.fn.line(\"v\")})<CR>\22n <LocalLeader>hs2<cmd>lua require(\"gitsigns\").stage_hunk()<CR>\22n <LocalLeader>hR4<cmd>lua require(\"gitsigns\").reset_buffer()<CR>\tx ih4:<C-U>lua require(\"gitsigns\").text_object()<CR>\22v <LocalLeader>hsV<cmd>lua require(\"gitsigns\").stage_hunk({vim.fn.line(\".\"), vim.fn.line(\"v\")})<CR>\nsigns\1\0\4\18sign_priority\3\6\20update_debounce\3d\14word_diff\1\23current_line_blame\2\17changedelete\1\0\4\ahl\19GitSignsChange\vlinehl\21GitSignsChangeLn\nnumhl\21GitSignsChangeNr\ttext\6~\14topdelete\1\0\4\ahl\19GitSignsDelete\vlinehl\21GitSignsDeleteLn\nnumhl\21GitSignsDeleteNr\ttext\b‾\vdelete\1\0\4\ahl\19GitSignsDelete\vlinehl\21GitSignsDeleteLn\nnumhl\21GitSignsDeleteNr\ttext\6_\vchange\1\0\4\ahl\19GitSignsChange\vlinehl\21GitSignsChangeLn\nnumhl\21GitSignsChangeNr\ttext\b│\badd\1\0\0\1\0\4\ahl\16GitSignsAdd\vlinehl\18GitSignsAddLn\nnumhl\18GitSignsAddNr\ttext\b│\nsetup\rgitsigns\frequire\0" },
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
    config = { "\27LJ\2\n�\5\0\0\4\0\r\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0=\3\a\0025\3\b\0=\3\t\2B\0\2\0016\0\n\0009\0\v\0'\2\f\0B\0\2\1K\0\1\0001autocmd CursorMoved * IndentBlanklineRefresh\bcmd\bvim\21context_patterns\1\15\0\0\nclass\rfunction\vmethod\nblock\17list_literal\rselector\b^if\v^table\17if_statement\nwhile\bfor\ttype\bvar\vimport\20buftype_exclude\1\3\0\0\rterminal\vnofile\21filetype_exclude\1\22\0\0\rstartify\14dashboard\nalpha\blog\rfugitive\14gitcommit\vpacker\fvimwiki\rmarkdown\tjson\btxt\nvista\thelp\ftodoist\rNvimTree\rpeekaboo\bgit\20TelescopePrompt\rundotree\24flutterToolsOutline\5\1\0\6#show_trailing_blankline_indent\2\28show_first_indent_level\2\tchar\b│\25space_char_blankline\6 \25show_current_context\2\31show_current_context_start\2\nsetup\21indent_blankline\frequire\0" },
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
    load_after = {
      ["nvim-lspconfig"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/lua-dev.nvim",
    url = "git@github.com:folke/lua-dev.nvim"
  },
  ["lualine.nvim"] = {
    config = { "\27LJ\2\nT\0\0\2\1\3\0\f-\0\0\0009\0\0\0B\0\1\2\15\0\0\0X\1\4�-\0\0\0009\0\1\0D\0\1\0X\0\2�'\0\2\0L\0\2\0K\0\1\0\0�\5\17get_location\17is_availablel\0\1\t\0\5\0\0186\1\0\0009\1\1\1\18\3\0\0'\4\2\0B\1\3\2\15\0\1\0X\2\n�\18\1\0\0\18\4\0\0009\2\3\0'\5\4\0B\2\3\4X\5\1�\18\1\5\0E\5\3\2R\5�\127\18\0\1\0L\0\2\0\f([^/]+)\vgmatch\6/\tfind\vstring�\1\1\0\b\0\r\0&3\0\0\0006\1\1\0009\1\2\0019\1\3\1\a\1\4\0X\1\29�6\1\5\0009\1\6\1'\3\a\0B\1\2\2\15\0\1\0X\2\b�6\2\b\0009\2\t\2'\4\n\0\18\5\0\0\18\a\1\0B\5\2\0002\0\0�C\2\1\0006\2\5\0009\2\6\2'\4\v\0B\2\2\2\18\1\2\0\15\0\1\0X\2\b�6\2\b\0009\2\t\2'\4\n\0\18\5\0\0\18\a\1\0B\5\2\0002\0\0�C\2\1\0'\1\f\0002\0\0�L\1\2\0\5\16VIRTUAL_ENV\a%s\vformat\vstring\22CONDA_DEFAULT_ENV\vgetenv\aos\vpython\rfiletype\abo\bvim\0�\t\1\0\17\0;\0~6\0\0\0'\2\1\0B\0\2\0023\1\2\0005\2\3\0004\3\0\0=\3\4\0024\3\0\0=\3\5\0024\3\0\0=\3\6\0024\3\0\0=\3\a\0024\3\0\0=\3\b\0025\3\t\0=\3\n\0025\3\f\0005\4\v\0=\4\4\0035\4\r\0=\4\5\0034\4\0\0=\4\6\0034\4\0\0=\4\a\0034\4\0\0=\4\b\0035\4\14\0=\4\n\0035\4\15\0=\2\16\0045\5\17\0=\5\18\0045\5\19\0=\3\16\0055\6\20\0=\6\18\0055\6\21\0=\3\16\0065\a\22\0=\a\18\0065\a\23\0=\3\16\a5\b\24\0=\b\18\a5\b\25\0=\3\16\b5\t\26\0=\t\18\b3\t\27\0006\n\0\0'\f\28\0B\n\2\0029\n\29\n5\f\"\0005\r\30\0004\14\0\0=\14\31\r5\14 \0=\14!\r=\r#\f5\r%\0005\14$\0=\14\4\r4\14\3\0005\15&\0>\15\1\0145\15'\0>\15\2\14=\14\5\r4\14\3\0005\15)\0>\1\1\0159\16(\0=\16*\15>\15\1\14=\14\6\r4\14\3\0005\15+\0005\16,\0=\16-\0155\16.\0=\16/\15>\15\1\14=\14\a\r4\14\5\0005\0150\0>\15\1\0144\15\3\0>\t\1\15>\15\2\0145\0151\0>\15\3\0145\0152\0>\15\4\14=\14\b\r5\0143\0=\14\n\r=\r\16\f5\r4\0004\14\0\0=\14\4\r4\14\0\0=\14\5\r5\0145\0=\14\6\r5\0146\0=\14\a\r4\14\0\0=\14\b\r4\14\0\0=\14\n\r=\r7\f4\r\0\0=\r8\f5\r9\0>\4\5\r>\5\6\r>\6\a\r>\a\b\r>\b\t\r=\r:\fB\n\2\0012\0\0�K\0\1\0\15extensions\1\5\0\0\rquickfix\14nvim-tree\15toggleterm\rfugitive\ftabline\22inactive_sections\1\2\0\0\rlocation\1\2\0\0\rfilename\1\0\0\1\3\0\0\rprogress\rlocation\1\2\2\0\15fileformat\fpadding\3\1\18icons_enabled\2\1\2\0\0\rencoding\1\2\2\0\rfiletype\fcolored\2\14icon_only\2\fsymbols\1\0\3\tinfo\t \twarn\t \nerror\t \fsources\1\2\0\0\20nvim_diagnostic\1\2\0\0\16diagnostics\tcond\1\0\0\17is_available\1\2\0\0\tdiff\1\2\0\0\vbranch\1\0\0\1\2\0\0\tmode\foptions\1\0\0\23section_separators\1\0\2\tleft\6 \nright\6 \23disabled_filetypes\1\0\3\25component_separators\6|\ntheme\tauto\18icons_enabled\2\nsetup\flualine\0\1\2\0\0\18dapui_watches\1\0\0\1\2\0\0\17dapui_stacks\1\0\0\1\2\0\0\22dapui_breakpoints\1\0\0\1\2\0\0\17dapui_scopes\1\0\0\14filetypes\1\2\0\0\vaerial\rsections\1\0\0\1\2\0\0\rlocation\1\2\0\0\rfiletype\1\0\0\1\2\0\0\tmode\14lualine_z\1\2\0\0\rlocation\14lualine_y\14lualine_x\14lualine_c\14lualine_b\14lualine_a\1\0\0\0\rnvim-gps\frequire\0" },
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
  ["nvim-autopairs"] = {
    config = { "\27LJ\2\n�\2\0\0\n\0\17\1\0316\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\0016\0\0\0'\2\6\0B\0\2\0026\1\0\0'\3\a\0B\1\2\0029\2\b\1\18\4\2\0009\2\t\2'\5\n\0009\6\v\0005\b\r\0005\t\f\0=\t\14\bB\6\2\0A\2\2\0019\2\15\0009\3\15\0\21\3\3\0\22\3\0\3'\4\16\0<\4\3\2K\0\1\0\vracket\tlisp\rmap_char\1\0\0\1\0\1\btex\5\20on_confirm_done\17confirm_done\aon\nevent\bcmp\"nvim-autopairs.completion.cmp\21disable_filetype\1\0\0\1\3\0\0\20TelescopePrompt\bvim\nsetup\19nvim-autopairs\frequire\2\0" },
    load_after = {
      ["nvim-cmp"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-autopairs",
    url = "git@github.com:windwp/nvim-autopairs"
  },
  ["nvim-bqf"] = {
    commands = { "BqfEnable", "BqfAutoToggle" },
    config = { "\27LJ\2\n�\1\0\2\t\0\a\1\24+\2\2\0006\3\0\0009\3\1\0039\3\2\3\18\5\0\0B\3\2\0026\4\0\0009\4\3\0049\4\4\4\18\6\3\0B\4\2\2*\5\0\0\1\5\4\0X\5\2�+\2\1\0X\5\a�\18\a\3\0009\5\5\3'\b\6\0B\5\3\2\15\0\5\0X\6\1�+\2\1\0L\2\2\0\17^fugitive://\nmatch\rgetfsize\afn\22nvim_buf_get_name\bapi\bvim��\f�\4\1\0\6\0\23\0\0276\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\3\0'\2\4\0B\0\2\0029\0\5\0005\2\6\0005\3\a\0005\4\b\0=\4\t\0033\4\n\0=\4\v\3=\3\f\0025\3\r\0=\3\14\0025\3\20\0005\4\16\0005\5\15\0=\5\17\0045\5\18\0=\5\19\4=\4\21\3=\3\22\2B\0\2\1K\0\1\0\vfilter\bfzf\1\0\0\15extra_opts\1\5\0\0\v--bind\22ctrl-o:toggle-all\r--prompt\a> \15action_for\1\0\0\1\0\2\vctrl-s\nsplit\vctrl-t\rtab drop\rfunc_map\1\0\6\nsplit\n<C-s>\tdrop\6o\16ptogglemode\az,\ttabc\5\ftabdrop\n<C-t>\nopenc\6O\fpreview\22should_preview_cb\0\17border_chars\1\n\0\0\b┃\b┃\b━\b━\b┏\b┓\b┗\b┛\b█\1\0\3\17delay_syntax\3P\16win_vheight\3\f\15win_height\3\f\1\0\2\16auto_enable\2\23auto_resize_height\2\nsetup\bbqf\frequireY    hi BqfPreviewBorder guifg=#F2CDCD ctermfg=71\n    hi link BqfPreviewRange Search\n\bcmd\bvim\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-bqf",
    url = "git@github.com:kevinhwang91/nvim-bqf"
  },
  ["nvim-bufferline.lua"] = {
    config = { "\27LJ\2\n�\3\0\0\6\0\b\0\r6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\3\0004\4\3\0005\5\4\0>\5\1\4=\4\5\3=\3\a\2B\0\2\1K\0\1\0\foptions\1\0\0\foffsets\1\0\4\15text_align\vcenter\fpadding\3\1\ttext\18File Explorer\rfiletype\rNvimTree\1\0\14\28show_buffer_close_icons\2\22show_buffer_icons\2\24show_tab_indicators\2\vnumber\tnone\22max_prefix_length\3\r\20separator_style\tthin\18modified_icon\b✥\16diagnostics\rnvim_lsp\22buffer_close_icon\b\22left_trunc_marker\b\27always_show_bufferline\2\20max_name_length\3\14\23right_trunc_marker\b\rtab_size\3\20\nsetup\15bufferline\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-bufferline.lua",
    url = "git@github.com:akinsho/nvim-bufferline.lua"
  },
  ["nvim-cmp"] = {
    after = { "copilot.vim", "LuaSnip", "nvim-autopairs" },
    config = { "\27LJ\2\nF\0\1\a\0\3\0\b6\1\0\0009\1\1\0019\1\2\1\18\3\0\0+\4\2\0+\5\2\0+\6\2\0D\1\5\0\27nvim_replace_termcodes\bapi\bvim�\1\0\0\b\0\b\2!6\0\0\0006\2\1\0009\2\2\0029\2\3\2)\4\0\0B\2\2\0A\0\0\3\b\1\0\0X\2\20�6\2\1\0009\2\2\0029\2\4\2)\4\0\0\23\5\1\0\18\6\0\0+\a\2\0B\2\5\2:\2\1\2\18\4\2\0009\2\5\2\18\5\1\0\18\6\1\0B\2\4\2\18\4\2\0009\2\6\2'\5\a\0B\2\3\2\n\2\0\0X\2\2�+\2\1\0X\3\1�+\2\2\0L\2\2\0\a%s\nmatch\bsub\23nvim_buf_get_lines\24nvim_win_get_cursor\bapi\bvim\vunpack\0\2F\0\1\a\0\3\0\b6\1\0\0009\1\1\0019\1\2\1\18\3\0\0+\4\2\0+\5\2\0+\6\2\0D\1\5\0\27nvim_replace_termcodes\bapi\bvim�\1\0\0\6\0\b\2\0276\0\0\0009\0\1\0009\0\2\0'\2\3\0B\0\2\2\23\0\0\0\b\0\1\0X\1\17�6\1\0\0009\1\1\0019\1\4\1'\3\3\0B\1\2\2\18\3\1\0009\1\5\1\18\4\0\0\18\5\0\0B\1\4\2\18\3\1\0009\1\6\1'\4\a\0B\1\3\2X\2\3�+\1\1\0X\2\1�+\1\2\0L\1\2\0\a%s\nmatch\bsub\fgetline\6.\bcol\afn\bvim\2\0�\1\0\1\3\0\b\0\0264\1\t\0005\2\0\0>\0\2\2>\2\1\0015\2\1\0>\0\2\2>\2\2\0015\2\2\0>\0\2\2>\2\3\0015\2\3\0>\0\2\2>\2\4\0015\2\4\0>\0\2\2>\2\5\0015\2\5\0>\0\2\2>\2\6\0015\2\6\0>\0\2\2>\2\a\0015\2\a\0>\0\2\2>\2\b\1L\1\2\0\1\2\0\0\b│\1\2\0\0\b╰\1\2\0\0\b─\1\2\0\0\b╯\1\2\0\0\b│\1\2\0\0\b╮\1\2\0\0\b─\1\2\0\0\b╭\15\0\1\2\0\0\0\2+\1\1\0L\1\2\0�\2\0\1\a\3\16\00076\1\0\0009\1\1\0019\1\2\1B\1\1\2\6\1\3\0X\2\b�6\2\0\0009\2\4\0029\2\5\2\18\4\1\0'\5\6\0+\6\2\0B\2\4\1X\2(�-\2\0\0009\2\a\2B\2\1\2\15\0\2\0X\3\4�-\2\0\0009\2\b\2B\2\1\1X\2\31�6\2\t\0'\4\n\0B\2\2\0029\2\v\2B\2\1\2\15\0\2\0X\3\t�6\2\0\0009\2\1\0029\2\f\2-\4\1\0'\6\r\0B\4\2\2'\5\3\0B\2\3\1X\2\15�-\2\2\0B\2\1\2\15\0\2\0X\3\t�6\2\0\0009\2\1\0029\2\f\2-\4\1\0'\6\14\0B\4\2\2'\5\15\0B\2\3\1X\2\2�\18\2\0\0B\2\1\1K\0\1\0\6�\2�\3�\6n\n<Tab>!<Plug>luasnip-expand-or-jump\rfeedkeys\23expand_or_jumpable\fluasnip\frequire\21select_next_item\fvisible\6i\18nvim_feedkeys\bapi\5\19copilot#Accept\afn\bvim�\2\0\1\6\3\v\0%-\1\0\0009\1\0\1B\1\1\2\15\0\1\0X\2\4�-\1\0\0009\1\1\1B\1\1\1X\1\27�6\1\2\0'\3\3\0B\1\2\0029\1\4\1)\3��B\1\2\2\15\0\1\0X\2\t�6\1\5\0009\1\6\0019\1\a\1-\3\1\0'\5\b\0B\3\2\2'\4\t\0B\1\3\1X\1\n�-\1\2\0B\1\1\2\15\0\1\0X\2\4�-\1\0\0009\1\n\1B\1\1\1X\1\2�\18\1\0\0B\1\1\1K\0\1\0\6�\2�\1�\rcomplete\5\28<Plug>luasnip-jump-prev\rfeedkeys\afn\bvim\rjumpable\fluasnip\frequire\21select_prev_item\fvisible�\1\0\0\4\0\t\0\0276\0\0\0'\2\1\0B\0\2\0026\1\2\0009\1\3\0019\1\4\1B\1\1\2\a\1\5\0X\1\3�+\1\2\0L\1\2\0X\1\14�9\1\6\0'\3\a\0B\1\2\2\14\0\1\0X\1\5�9\1\6\0'\3\b\0B\1\2\2\19\1\1\0X\2\3�+\1\1\0X\2\1�+\1\2\0L\1\2\0K\0\1\0\fComment\fcomment\26in_treesitter_capture\6c\18nvim_get_mode\bapi\bvim\23cmp.config.context\frequire�\4\0\2\b\0\t\0\0155\2\0\0006\3\2\0009\3\3\3'\5\4\0009\6\1\0018\6\6\0029\a\1\1B\3\4\2=\3\1\0015\3\6\0009\4\a\0009\4\b\0048\3\4\3=\3\5\1L\1\2\0\tname\vsource\1\0\b\fluasnip\16[ LSnip]\nspell\17[  Spell]\ttmux\16[  Tmux]\rnvim_lsp\14[ LSP]\rnvim_lua\18[ NvimLua]\nemoji\16[ Emoji]\vbuffer\14[﬘ Buf]\tpath\r[~ Path]\tmenu\n%s %s\vformat\vstring\tkind\1\0\25\tText\b\nValue\b\rConstant\b\nField\b\18TypeParameter\b\16Constructor\b\14Interface\b\vMethod\b\nClass\bﴯ\tEnum\b\rProperty\bﰠ\rVariable\b\vModule\b\vStruct\b\rFunction\b\nEvent\b\tFile\b\15EnumMember\b\fSnippet\b\rOperator\b\fKeyword\b\tUnit\b\nColor\b\14Reference\b\vFolder\b�\1\0\1\a\1\t\0\0216\1\0\0009\1\1\0019\1\2\1B\1\1\2\6\1\3\0X\2\b�6\2\0\0009\2\4\0029\2\5\2\18\4\1\0'\5\6\0+\6\2\0B\2\4\1X\2\6�-\2\0\0009\2\a\0029\2\b\2B\2\1\2\18\4\0\0B\2\2\1K\0\1\0\6�\nabort\fmapping\6i\18nvim_feedkeys\bapi\5\19copilot#Accept\afn\bvim}\0\1\3\2\3\0\20-\1\0\0009\1\0\1B\1\1\2\15\0\1\0X\2\4�-\1\0\0009\1\1\1B\1\1\1X\1\n�-\1\1\0B\1\1\2\15\0\1\0X\2\4�-\1\0\0009\1\2\1B\1\1\1X\1\2�\18\1\0\0B\1\1\1K\0\1\0\6�\1�\rcomplete\21select_next_item\fvisibleR\0\1\3\1\2\0\f-\1\0\0009\1\0\1B\1\1\2\15\0\1\0X\2\4�-\1\0\0009\1\1\1B\1\1\1X\1\2�\18\1\0\0B\1\1\1K\0\1\0\6�\21select_prev_item\fvisible�\1\0\1\6\1\b\0\0206\1\0\0'\3\1\0B\1\2\0029\1\2\1)\3��B\1\2\2\15\0\1\0X\2\t�6\1\3\0009\1\4\0019\1\5\1-\3\0\0'\5\6\0B\3\2\2'\4\a\0B\1\3\1X\1\2�\18\1\0\0B\1\1\1K\0\1\0\0�\5\28<Plug>luasnip-jump-prev\rfeedkeys\afn\bvim\rjumpable\fluasnip\frequire�\1\0\1\6\1\b\0\0196\1\0\0'\3\1\0B\1\2\0029\1\2\1B\1\1\2\15\0\1\0X\2\t�6\1\3\0009\1\4\0019\1\5\1-\3\0\0'\5\6\0B\3\2\2'\4\a\0B\1\3\1X\1\2�\18\1\0\0B\1\1\1K\0\1\0\0�\5!<Plug>luasnip-expand-or-jump\rfeedkeys\afn\bvim\23expand_or_jumpable\fluasnip\frequireC\0\1\4\0\4\0\a6\1\0\0'\3\1\0B\1\2\0029\1\2\0019\3\3\0B\1\2\1K\0\1\0\tbody\15lsp_expand\fluasnip\frequire�\f\1\0\18\0i\0�\0016\0\0\0009\0\1\0'\2\2\0B\0\2\0013\0\3\0003\1\4\0003\2\5\0003\3\6\0003\4\a\0006\5\b\0'\a\t\0B\5\2\0023\6\v\0=\6\n\0056\6\b\0'\b\f\0B\6\2\0023\a\r\0003\b\14\0009\t\15\0065\v\18\0009\f\16\0069\f\17\f=\f\19\v5\f\23\0005\r\21\0\18\14\4\0'\16\20\0B\14\2\2=\14\22\r=\r\24\f5\r\26\0\18\14\4\0'\16\25\0B\14\2\2=\14\22\r=\r\27\f=\f\28\v3\f\29\0=\f\30\v5\f*\0004\r\t\0009\14\31\0069\14 \0149\14!\14>\14\1\r9\14\31\0069\14 \0149\14\"\14>\14\2\r9\14\31\0069\14 \0149\14#\14>\14\3\r6\14\b\0'\16$\0B\14\2\0029\14%\14>\14\4\r9\14\31\0069\14 \0149\14&\14>\14\5\r9\14\31\0069\14 \0149\14'\14>\14\6\r9\14\31\0069\14 \0149\14(\14>\14\a\r9\14\31\0069\14 \0149\14)\14>\14\b\r=\r+\f=\f,\v5\f.\0003\r-\0=\r/\f=\f0\v5\f3\0009\r1\0069\r2\rB\r\1\2=\r4\f9\r1\0069\r5\rB\r\1\2=\r6\f9\r1\0069\r7\r)\15��B\r\2\2=\r8\f9\r1\0069\r7\r)\15\4\0B\r\2\2=\r9\f9\r1\0069\r:\rB\r\1\2=\r;\f9\r1\0069\r:\rB\r\1\2=\r<\f9\r1\0069\r=\r5\15>\0B\r\2\2=\r?\f=\a@\f=\bA\f9\r1\0065\15C\0003\16B\0=\16D\0159\0161\0069\16E\16B\16\1\2=\16F\15B\r\2\2=\rG\f9\r1\0063\15H\0005\16I\0B\r\3\2=\rJ\f9\r1\0063\15K\0005\16L\0B\r\3\2=\rM\f3\rN\0=\rO\f3\rP\0=\rQ\f=\f1\v5\fS\0003\rR\0=\rT\f=\fU\v4\f\n\0005\rV\0>\r\1\f5\rW\0>\r\2\f5\rX\0>\r\3\f5\rY\0>\r\4\f5\rZ\0>\r\5\f5\r[\0>\r\6\f5\r\\\0>\r\a\f5\r]\0>\r\b\f5\r^\0>\r\t\f=\f_\vB\t\2\0019\t\15\0069\t`\t'\va\0005\fc\0009\r1\0069\rb\r9\r`\rB\r\1\2=\r1\f4\r\3\0005\14d\0>\14\1\r=\r_\fB\t\3\0019\t\15\0069\t`\t'\ve\0005\ff\0009\r1\0069\rb\r9\r`\rB\r\1\2=\r1\f9\r\31\0069\r_\r4\15\3\0005\16g\0>\16\1\0154\16\3\0005\17h\0>\17\1\16B\r\3\2=\r_\fB\t\3\0012\0\0�K\0\1\0\1\0\1\tname\fcmdline\1\0\1\tname\tpath\1\0\0\6:\1\0\1\tname\vbuffer\1\0\0\vpreset\6/\fcmdline\fsources\1\0\1\tname\nemoji\1\0\1\tname\nspell\1\0\1\tname\ttmux\1\0\1\tname\18latex_symbols\1\0\1\tname\vbuffer\1\0\1\tname\tpath\1\0\1\tname\fluasnip\1\0\1\tname\rnvim_lua\1\0\1\tname\rnvim_lsp\fsnippet\vexpand\1\0\0\0\n<C-l>\0\n<C-h>\0\n<C-k>\1\3\0\0\6i\6s\0\n<C-j>\1\3\0\0\6i\6s\0\n<C-e>\6c\nclose\6i\1\0\0\0\f<S-Tab>\n<Tab>\t<CR>\1\0\1\vselect\1\fconfirm\n<C-g>\n<C-c>\nabort\n<C-f>\n<C-d>\16scroll_docs\n<C-n>\21select_next_item\n<C-p>\1\0\0\21select_prev_item\fmapping\15formatting\vformat\1\0\0\0\fsorting\16comparators\1\0\0\norder\vlength\14sort_text\tkind\nunder\25cmp-under-comparator\nscore\nexact\voffset\fcompare\vconfig\fenabled\0\vwindow\18documentation\1\0\0\17CmpDocBorder\15completion\1\0\0\vborder\1\0\0\14CmpBorder\14preselect\1\0\0\tNone\18PreselectMode\nsetup\0\0\bcmp\0\18has_scrollbar\21cmp.utils.window\frequire\0\0\0\0\0!packadd cmp-under-comparator\bcmd\bvim\0" },
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
  ["nvim-gps"] = {
    after = { "lualine.nvim" },
    config = { "\27LJ\2\n�\1\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\14languages\1\0\b\6c\2\blua\2\bcpp\2\tjava\2\15javascript\2\trust\2\ago\2\vpython\2\nicons\1\0\1\14separator\b > \1\0\3\16method-name\t \15class-name\t \18function-name\t \nsetup\rnvim-gps\frequire\0" },
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-gps",
    url = "git@github.com:SmiteshP/nvim-gps"
  },
  ["nvim-lsp-installer"] = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-lsp-installer",
    url = "git@github.com:williamboman/nvim-lsp-installer"
  },
  ["nvim-lspconfig"] = {
    after = { "lspsaga.nvim", "lua-dev.nvim", "lsp_signature.nvim" },
    config = { "\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27modules.completion.lsp\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-lspconfig",
    url = "git@github.com:neovim/nvim-lspconfig"
  },
  ["nvim-repl"] = {
    commands = { "ReplToggle", "ReplSendLine", "ReplSendVisual" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-repl",
    url = "git@github.com:pappasam/nvim-repl"
  },
  ["nvim-spectre"] = {
    config = { "\27LJ\2\n�\15\0\0\a\0009\0C6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\5\0005\4\4\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\20\0035\4\21\0=\4\22\0035\4\23\0=\4\24\3=\3\25\0025\3#\0005\4\26\0005\5\27\0=\5\28\0045\5\30\0005\6\29\0=\6\31\0055\6 \0=\6!\5=\5\"\4=\4$\0035\4%\0005\5&\0=\5\28\0045\5(\0005\6'\0=\6\31\0055\6)\0=\6!\5=\5\"\4=\4*\3=\3+\0025\3-\0005\4,\0=\4.\0035\0040\0005\5/\0=\5\31\4=\4\"\3=\0031\0025\0034\0005\0042\0005\0053\0=\5\"\4=\0045\0035\0046\0=\0047\3=\0038\2B\0\2\1K\0\1\0\fdefault\freplace\1\0\1\bcmd\bsed\tfind\1\0\0\1\2\0\0\16ignore-case\1\0\1\bcmd\arg\19replace_engine\1\0\0\1\0\3\nvalue\18--ignore-case\tdesc\16ignore case\ticon\b[I]\bsed\1\0\0\1\0\1\bcmd\bsed\16find_engine\aag\1\0\3\ticon\b[H]\tdesc\16hidden file\nvalue\r--hidden\1\0\0\1\0\3\nvalue\a-i\tdesc\16ignore case\ticon\b[I]\1\3\0\0\14--vimgrep\a-s\1\0\1\bcmd\aag\arg\1\0\0\foptions\vhidden\1\0\3\ticon\b[H]\tdesc\16hidden file\nvalue\r--hidden\16ignore-case\1\0\0\1\0\3\nvalue\18--ignore-case\tdesc\16ignore case\ticon\b[I]\targs\1\6\0\0\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\1\0\1\bcmd\arg\fmapping\25toggle_ignore_hidden\1\0\3\bmap\ath\tdesc\25toggle search hidden\bcmd=<cmd>lua require('spectre').change_options('hidden')<CR>\23toggle_ignore_case\1\0\3\bmap\ati\tdesc\23toggle ignore case\bcmdB<cmd>lua require('spectre').change_options('ignore-case')<CR>\23toggle_live_update\1\0\3\bmap\atu\tdesc'update change when vim write file.\bcmd9<cmd>lua require('spectre').toggle_live_update()<CR>\21change_view_mode\1\0\3\bmap\14<leader>v\tdesc\28change result view mode\bcmd2<cmd>lua require('spectre').change_view()<CR>\16run_replace\1\0\3\bmap\14<leader>R\tdesc\16replace all\bcmd:<cmd>lua require('spectre.actions').run_replace()<CR>\21show_option_menu\1\0\3\bmap\14<leader>o\tdesc\16show option\bcmd3<cmd>lua require('spectre').show_options()<CR>\16replace_cmd\1\0\3\bmap\14<leader>c\tdesc\30input replace vim command\bcmd:<cmd>lua require('spectre.actions').replace_cmd()<CR>\15send_to_qf\1\0\3\bmap\14<leader>q\tdesc\30send all item to quickfix\bcmd9<cmd>lua require('spectre.actions').send_to_qf()<CR>\15enter_file\1\0\3\bmap\t<cr>\tdesc\22goto current file\bcmd;<cmd>lua require('spectre.actions').select_entry()<CR>\16toggle_line\1\0\0\1\0\3\bmap\add\tdesc\24toggle current item\bcmd2<cmd>lua require('spectre').toggle_line()<CR>\1\0\6\23is_open_target_win\2\20replace_vim_cmd\bcdo\19is_insert_mode\1\19color_devicons\2\ropen_cmd\tvnew\16live_update\2\nsetup\fspectre\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-spectre",
    url = "git@github.com:windwp/nvim-spectre"
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
    config = { "\27LJ\2\ny\0\1\2\0\6\1\0159\1\0\0\a\1\1\0X\1\3�)\1\15\0L\1\2\0X\1\b�9\1\0\0\a\1\2\0X\1\5�6\1\3\0009\1\4\0019\1\5\1\24\1\0\1L\1\2\0K\0\1\0\fcolumns\6o\bvim\rvertical\15horizontal\14direction��̙\19����\3�\2\1\0\4\0\n\0\0156\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0003\3\3\0=\3\5\0024\3\0\0=\3\6\0026\3\a\0009\3\b\0039\3\t\3=\3\t\2B\0\2\1K\0\1\0\nshell\6o\bvim\20shade_filetypes\tsize\1\0\t\20shade_terminals\1\19shading_factor\0061\20insert_mappings\2\17persist_size\2\14direction\rvertical\20start_in_insert\2\18close_on_exit\2\17open_mapping\n<C-t>\17hide_numbers\2\0\nsetup\15toggleterm\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-toggleterm.lua",
    url = "git@github.com:akinsho/nvim-toggleterm.lua"
  },
  ["nvim-tree.lua"] = {
    commands = { "NvimTreeToggle" },
    config = { "\27LJ\2\n�\f\0\0\b\0005\0=6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0005\4\a\0=\4\b\3=\3\t\0025\3\n\0004\4\0\0=\4\v\3=\3\f\0025\3\r\0004\4\0\0=\4\14\3=\3\15\0025\3\16\0005\4\17\0=\4\18\3=\3\19\0025\3\20\0=\3\21\0025\3\22\0005\4\23\0005\5\24\0005\6\25\0=\6\21\0055\6\26\0=\6\27\5=\5\28\4=\4\b\0035\4\29\0005\5\30\0=\5\b\4=\4\31\3=\3 \0025\3!\0=\3\"\0025\3#\0=\3$\0025\3%\0=\3&\0025\3'\0005\4(\0=\4)\0035\4*\0005\5+\0005\6-\0005\a,\0=\a.\0065\a/\0=\a0\6=\0061\5=\0052\4=\0043\3=\0034\2B\0\2\1K\0\1\0\factions\14open_file\18window_picker\fexclude\fbuftype\1\4\0\0\vnofile\rterminal\thelp\rfiletype\1\0\0\1\a\0\0\vnotify\vpacker\aqf\tdiff\rfugitive\18fugitiveblame\1\0\2\nchars)ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890\venable\2\1\0\2\17quit_on_open\1\18resize_window\1\15change_dir\1\0\2\vglobal\1\venable\2\1\0\1\25use_system_clipboard\2\ntrash\1\0\2\bcmd\brip\20require_confirm\2\23hijack_directories\1\0\2\14auto_open\2\venable\2\tview\1\0\5\tside\tleft\15signcolumn\byes\vheight\3\30\nwidth\3\30\19relativenumber\1\rrenderer\19indent_markers\1\0\3\vcorner\t└ \tnone\a  \tedge\t│ \1\0\1\venable\2\vglyphs\vfolder\1\0\b\15empty_open\b\topen\b\15arrow_open\5\17arrow_closed\5\nempty\b\17symlink_open\b\fsymlink\b\fdefault\b\1\0\a\fignored\b\frenamed\b\fdeleted\b\vstaged\b\14untracked\bﲉ\runmerged\bשׂ\runstaged\b\1\0\2\fsymlink\b\fdefault\b\1\0\2\fpadding\6 \18symlink_arrow\n  \1\0\1\25root_folder_modifier\a:e\bgit\1\0\3\vignore\2\venable\2\ftimeout\3�\3\ffilters\vcustom\1\2\0\0\14.DS_Store\1\0\1\rdotfiles\1\16system_open\targs\1\0\0\24update_focused_file\16ignore_list\1\0\2\venable\2\15update_cwd\2\16diagnostics\nicons\1\0\4\tinfo\b\thint\b\fwarning\b\nerror\b\1\0\1\venable\1\23ignore_ft_on_setup\1\0\r\23open_on_setup_file\1\15update_cwd\1\fsort_by\tname\25auto_reload_on_write\2\18disable_netrw\1\18hijack_cursor\2\20respect_buf_cwd\2'hijack_unnamed_buffer_when_opening\1\27ignore_buffer_on_setup\1\18open_on_setup\1\17hijack_netrw\2\16open_on_tab\1\23reload_on_bufenter\2\1\2\0\0\nalpha\nsetup\14nvim-tree\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/nvim-tree.lua",
    url = "git@github.com:kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    after = { "vim-matchup", "nvim-ts-hint-textobject", "nvim-ts-context-commentstring", "nvim-treesitter-context", "nvim-ts-autotag", "refactoring.nvim", "zen-mode.nvim", "nvim-treesitter-textobjects", "nvim-gps" },
    config = { "\27LJ\2\n�\r\0\0\f\0:\0Q6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\0016\0\4\0'\2\5\0B\0\2\0029\0\6\0005\2\b\0005\3\a\0=\3\t\0025\3\n\0005\4\v\0=\4\f\3=\3\r\0025\3\14\0=\3\15\0025\3\16\0=\3\17\0025\3\18\0=\3\19\0025\3\22\0005\4\20\0005\5\21\0=\5\f\4=\4\23\0035\4\24\0005\5\25\0=\5\26\0045\5\27\0=\5\28\4=\4\29\0035\4\30\0005\5\31\0=\5 \0045\5!\0=\5\"\0045\5#\0=\5$\0045\5%\0=\5&\4=\4'\0035\4(\0005\5)\0=\5*\4=\4+\3=\3,\2B\0\2\0016\0\4\0'\2-\0B\0\2\2+\1\2\0=\1.\0006\0\4\0'\2/\0B\0\2\0029\0000\0B\0\1\0026\0011\0\18\3\0\0B\1\2\4H\4\t�9\0062\0059\a2\0059\a3\a\18\t\a\0009\a4\a'\n5\0'\v6\0B\a\4\2=\a3\6F\4\3\3R\4�\1279\0017\0'\0029\0=\0028\1K\0\1\0\tocto\27filetype_to_parsername\rmarkdown\20git@github.com:\24https://github.com/\tgsub\burl\17install_info\npairs\23get_parser_configs\28nvim-treesitter.parsers\15prefer_git\28nvim-treesitter.install\16textobjects\16lsp_interop\25peek_definition_code\1\0\2\15<leader>sD\17@class.outer\15<leader>sd\20@function.outer\1\0\2\venable\2\vborder\tnone\tmove\22goto_previous_end\1\0\2\a[]\17@class.outer\a[M\20@function.outer\24goto_previous_start\1\0\2\a[[\17@class.outer\a[m\20@function.outer\18goto_next_end\1\0\2\a]M\20@function.outer\a][\17@class.outer\20goto_next_start\1\0\2\a]m\20@function.outer\a]]\17@class.outer\1\0\2\14set_jumps\2\venable\2\tswap\18swap_previous\1\0\1\14<leader>A\21@parameter.inner\14swap_next\1\0\1\14<leader>a\21@parameter.inner\1\0\1\venable\2\vselect\1\0\0\1\0\14\aii\16@call.inner\aic\23@conditional.inner\aai\16@call.outer\aal\16@loop.outer\aab\17@block.outer\aib\17@block.inner\ail\16@loop.inner\aas\21@statement.outer\aaC\17@class.outer\aaf\20@function.outer\aiC\17@class.inner\ais\21@statement.inner\aif\20@function.inner\aac\23@conditional.outer\1\0\2\venable\2\14lookahead\2\fmatchup\1\0\1\venable\2\26context_commentstring\1\0\2\19enable_autocmd\1\venable\2\14highlight\1\0\1\venable\2\26incremental_selection\fkeymaps\1\0\4\21node_incremental\bgrn\19init_selection\bgnn\22scope_incremental\bgrc\21node_decremental\bgrm\1\0\1\venable\2\21ensure_installed\1\0\1\17sync_install\1\1\20\0\0\tbash\6c\bcpp\blua\ago\ngomod\trust\15dockerfile\tjson\tyaml\nlatex\bnix\tmake\vpython\thtml\15javascript\15typescript\bvue\bcss\nsetup\28nvim-treesitter.configs\frequire,set foldexpr=nvim_treesitter#foldexpr()\24set foldmethod=expr\bcmd\bvim\0" },
    loaded = false,
    needs_bufread = false,
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
    config = { "\27LJ\2\n�\1\0\0\4\0\6\0\t6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\2B\0\2\1K\0\1\0\14filetypes\1\0\0\1\a\0\0\thtml\bxml\15javascript\20typescriptreact\20javascriptreact\bvue\nsetup\20nvim-ts-autotag\frequire\0" },
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
    after = { "dressing.nvim" },
    loaded = true,
    only_config = true
  },
  ["octo.nvim"] = {
    commands = { "Octo" },
    config = { "\27LJ\2\n�\20\0\0\5\0\21\0\0256\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\0025\3\t\0005\4\b\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\a\3=\3\20\2B\0\2\1K\0\1\0\rmappings\1\0\n\16focus_files\14<leader>e\15prev_entry\6k\22select_next_entry\a]q\18refresh_files\6R\22select_prev_entry\a[q\17toggle_files\14<leader>b\21close_review_tab\n<C-c>\18toggle_viewed\20<leader><space>\17select_entry\t<cr>\15next_entry\6j\16review_diff\1\0\n\21close_review_tab\n<C-c>\16focus_files\14<leader>e\18toggle_viewed\20<leader><space>\22select_next_entry\a]q\22select_prev_entry\a[q\16next_thread\a]t\17toggle_files\14<leader>b\16prev_thread\a[t\23add_review_comment\14<space>ca\26add_review_suggestion\14<space>sa\15submit_win\1\0\4\21close_review_tab\n<C-c>\19comment_review\n<C-m>\20request_changes\n<C-r>\19approve_review\n<C-a>\18review_thread\1\0\17\22select_prev_entry\a[q\15goto_issue\14<space>gi\16add_comment\14<space>ca\19delete_comment\14<space>cd\17next_comment\a]c\17prev_comment\a[c\19add_suggestion\14<space>sa\20react_thumbs_up\14<space>r+\15react_eyes\14<space>re\22select_next_entry\a]q\22react_thumbs_down\14<space>r-\17react_rocket\14<space>rr\17react_hooray\14<space>rp\21close_review_tab\n<C-c>\16react_laugh\14<space>rl\16react_heart\14<space>rh\19react_confused\14<space>rc\17pull_request\1\0\31\rcopy_url\n<C-y>\vreload\n<C-r>\17add_assignee\14<space>aa\15goto_issue\14<space>gi\20remove_assignee\14<space>ad\17create_label\14<space>lc\17prev_comment\a[c\16checkout_pr\14<space>po\16add_comment\14<space>ca\14add_label\14<space>la\19delete_comment\14<space>cd\rmerge_pr\14<space>pm\17next_comment\a]c\17remove_label\14<space>ld\17list_commits\14<space>pc\23list_changed_files\14<space>pf\20react_thumbs_up\14<space>r+\17show_pr_diff\14<space>pd\15react_eyes\14<space>re\17add_reviewer\14<space>va\22react_thumbs_down\14<space>r-\20remove_reviewer\14<space>vd\17react_rocket\14<space>rr\16close_issue\14<space>ic\17react_hooray\14<space>rp\17reopen_issue\14<space>io\16react_laugh\14<space>rl\16list_issues\14<space>il\16react_heart\14<space>rh\20open_in_browser\n<C-b>\19react_confused\14<space>rc\nissue\1\0\0\1\0\24\rcopy_url\n<C-y>\vreload\n<C-r>\17add_assignee\14<space>aa\20remove_assignee\14<space>ad\17create_label\14<space>lc\15goto_issue\14<space>gi\16add_comment\14<space>ca\14add_label\14<space>la\19delete_comment\14<space>cd\17next_comment\a]c\17remove_label\14<space>ld\17prev_comment\a[c\20react_thumbs_up\14<space>r+\15react_eyes\14<space>re\22react_thumbs_down\14<space>r-\17react_rocket\14<space>rr\16close_issue\14<space>ic\17react_hooray\14<space>rp\17reopen_issue\14<space>io\16react_laugh\14<space>rl\16list_issues\14<space>il\16react_heart\14<space>rh\20open_in_browser\n<C-b>\19react_confused\14<space>rc\15file_panel\1\0\2\tsize\3\n\14use_icons\2\19default_remote\1\0\b\30reaction_viewer_hint_icon\b\14user_icon\t \20timeline_marker\b\20timeline_indent\0062\27right_bubble_delimiter\b\26left_bubble_delimiter\b\26snippet_context_lines\3\4\20github_hostname\5\1\3\0\0\rupstream\vorigin\nsetup\tocto\frequire\0" },
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
    config = { "\27LJ\2\n�\1\0\0\4\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\4\0005\3\3\0=\3\5\0025\3\6\0=\3\a\2B\0\2\1K\0\1\0\27prompt_func_param_type\1\0\4\6c\2\ago\2\bcpp\2\tjava\2\28prompt_func_return_type\1\0\0\1\0\4\6c\2\ago\2\bcpp\2\tjava\2\nsetup\16refactoring\frequire\0" },
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/refactoring.nvim",
    url = "git@github.com:ThePrimeagen/refactoring.nvim"
  },
  ["rose-pine"] = {
    config = { "\27LJ\2\n;\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\14rose-pine\frequire\0" },
    loaded = true,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/start/rose-pine",
    url = "git@github.com:rose-pine/neovim"
  },
  ["rust-tools.nvim"] = {
    config = { "\27LJ\2\n�\5\0\0\5\0\27\0*6\0\0\0009\0\1\0'\2\2\0B\0\2\0015\0\21\0005\1\3\0005\2\4\0=\2\5\0015\2\6\0=\2\a\0015\2\b\0=\2\t\0015\2\18\0004\3\t\0005\4\n\0>\4\1\0035\4\v\0>\4\2\0035\4\f\0>\4\3\0035\4\r\0>\4\4\0035\4\14\0>\4\5\0035\4\15\0>\4\6\0035\4\16\0>\4\a\0035\4\17\0>\4\b\3=\3\19\2=\2\20\1=\1\22\0004\1\0\0=\1\23\0006\1\24\0'\3\25\0B\1\2\0029\1\26\1\18\3\0\0B\1\2\1K\0\1\0\nsetup\15rust-tools\frequire\vserver\ntools\1\0\0\18hover_actions\vborder\1\0\1\15auto_focus\1\1\3\0\0\b│\16FloatBorder\1\3\0\0\b╰\16FloatBorder\1\3\0\0\b─\16FloatBorder\1\3\0\0\b╯\16FloatBorder\1\3\0\0\b│\16FloatBorder\1\3\0\0\b╮\16FloatBorder\1\3\0\0\b─\16FloatBorder\1\3\0\0\b╭\16FloatBorder\16inlay_hints\1\0\t\27parameter_hints_prefix\b<- \16right_align\1\30only_current_line_autocmd\15CursorHold\22only_current_line\1\25show_parameter_hints\2\24right_align_padding\3\a\26max_len_align_padding\3\1\18max_len_align\1\23other_hints_prefix\t » \16debuggables\1\0\1\18use_telescope\2\14runnables\1\0\1\18use_telescope\2\1\0\2\23hover_with_actions\2\17autoSetHints\2\27packadd nvim-lspconfig\bcmd\bvim\0" },
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
    config = { "\27LJ\2\n�\v\0\0\5\0=\0A6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0024\3\0\0=\3\6\0025\3\b\0005\4\a\0=\4\t\0035\4\n\0=\4\v\0035\4\f\0=\4\r\0035\4\14\0=\4\15\0035\4\16\0=\4\17\0035\4\18\0=\4\19\0035\4\20\0=\4\21\0035\4\22\0=\4\23\0035\4\24\0=\4\25\0035\4\26\0=\4\27\0035\4\28\0=\4\29\0035\4\30\0=\4\31\0035\4 \0=\4!\0035\4\"\0=\4#\0035\4$\0=\4%\0035\4&\0=\4'\0035\4(\0=\4)\0035\4*\0=\4+\0035\4,\0=\4-\0035\4.\0=\4/\0035\0040\0=\0041\0035\0042\0=\0043\0035\0044\0=\0045\0035\0046\0=\0047\0035\0048\0=\0049\0035\4:\0=\4;\3=\3<\2B\0\2\1K\0\1\0\fsymbols\18TypeParameter\1\0\2\ticon\t𝙏\ahl\16TSParameter\rOperator\1\0\2\ticon\6+\ahl\15TSOperator\nEvent\1\0\2\ticon\t🗲\ahl\vTSType\vStruct\1\0\2\ticon\t𝓢\ahl\vTSType\15EnumMember\1\0\2\ticon\b\ahl\fTSField\tNull\1\0\2\ticon\tNULL\ahl\vTSType\bKey\1\0\2\ticon\t🔐\ahl\vTSType\vObject\1\0\2\ticon\b⦿\ahl\vTSType\nArray\1\0\2\ticon\b\ahl\15TSConstant\fBoolean\1\0\2\ticon\b⊨\ahl\14TSBoolean\vNumber\1\0\2\ticon\6#\ahl\rTSNumber\vString\1\0\2\ticon\t𝓐\ahl\rTSString\rConstant\1\0\2\ticon\b\ahl\15TSConstant\rVariable\1\0\2\ticon\b\ahl\15TSConstant\rFunction\1\0\2\ticon\b\ahl\15TSFunction\14Interface\1\0\2\ticon\bﰮ\ahl\vTSType\tEnum\1\0\2\ticon\bℰ\ahl\vTSType\16Constructor\1\0\2\ticon\b\ahl\18TSConstructor\nField\1\0\2\ticon\b\ahl\fTSField\rProperty\1\0\2\ticon\b\ahl\rTSMethod\vMethod\1\0\2\ticon\aƒ\ahl\rTSMethod\nClass\1\0\2\ticon\t𝓒\ahl\vTSType\fPackage\1\0\2\ticon\b\ahl\16TSNamespace\14Namespace\1\0\2\ticon\b\ahl\16TSNamespace\vModule\1\0\2\ticon\b\ahl\16TSNamespace\tFile\1\0\0\1\0\2\ticon\b\ahl\nTSURI\18lsp_blacklist\fkeymaps\1\0\6\17code_actions\6a\nclose\n<Esc>\18rename_symbol\6r\17hover_symbol\14<C-space>\19focus_location\6o\18goto_location\t<Cr>\1\0\t\24show_symbol_details\2\26show_relative_numbers\2\17show_numbers\2\17auto_preview\2\16show_guides\2\27highlight_hovered_item\2\rposition\nright\nwidth\3\30\25preview_bg_highlight\nPmenu\nsetup\20symbols-outline\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/symbols-outline.nvim",
    url = "git@github.com:simrat39/symbols-outline.nvim"
  },
  ["telekasten.nvim"] = {
    after = { "calendar-vim" },
    config = { "\27LJ\2\n�\a\0\0\t\0\25\0A6\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\3\0009\0\4\0006\1\3\0009\1\5\1'\2\6\0&\0\2\0006\1\a\0'\3\b\0B\1\2\0029\1\t\0015\3\n\0=\0\v\3\18\4\0\0006\5\3\0009\5\5\5'\6\f\0&\4\6\4=\4\r\3\18\4\0\0006\5\3\0009\5\5\5'\6\14\0&\4\6\4=\4\15\3\18\4\0\0006\5\3\0009\5\5\5'\6\16\0&\4\6\4=\4\16\0035\4\17\0=\4\18\3\18\4\0\0006\5\3\0009\5\5\5'\6\16\0006\a\3\0009\a\5\a'\b\19\0&\4\b\4=\4\20\3\18\4\0\0006\5\3\0009\5\5\5'\6\16\0006\a\3\0009\a\5\a'\b\21\0&\4\b\4=\4\22\3\18\4\0\0006\5\3\0009\5\5\5'\6\16\0006\a\3\0009\a\5\a'\b\23\0&\4\b\4=\4\24\3B\1\2\1K\0\1\0\24template_new_weekly\14weekly.md\23template_new_daily\rdaily.md\22template_new_note\16new_note.md\18calendar_opts\1\0\3\18calendar_mark\rleft-fit\20calendar_monday\3\1\vweeknm\3\4\14templates\rweeklies\vweekly\fdailies\ndaily\thome\1\0\18\21subdirs_in_links\2\22template_handling\nsmart\14extension\b.md\23plug_into_calendar\2 weeklies_create_nonexisting\2\31dailies_create_nonexisting\2\31follow_creates_nonexisting\2\22new_note_location\nsmart\17image_subdir\vimages\24rename_update_links\2\22auto_set_filetype\2\22take_over_my_home\2\20show_tags_theme\bivy\26command_palette_theme\bivy\17tag_notation\t#tag\27insert_after_inserting\2\24close_after_yanking\1\21image_link_style\rmarkdown\nsetup\15telekasten\frequire\17zettelkasten\rpath_sep\rvim_path\20__editor_global\27 packadd calendar-vim \bcmd\bvim\0" },
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
    after = { "telescope-file-browser.nvim", "telescope-project.nvim" },
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
      ["telescope-fzf-native.nvim"] = true
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
  ["telescope.nvim"] = {
    after = { "telescope-ui-select.nvim", "telescope-fzf-native.nvim", "telescope-emoji.nvim", "cheatsheet.nvim", "octo.nvim" },
    commands = { "Telescope" },
    config = { "\27LJ\2\n/\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\16:normal! zx\bcmd\bvimM\1\1\6\1\5\0\v-\1\0\0009\1\0\1\18\3\1\0009\1\1\0015\4\3\0003\5\2\0=\5\4\4B\1\3\1+\1\2\0002\0\0�L\1\2\0\0�\tpost\1\0\0\0\fenhance\vselect<\0\1\a\0\5\0\b5\1\3\0\18\4\0\0009\2\0\0'\5\1\0'\6\2\0B\2\4\2=\2\4\1L\1\2\0\vprompt\1\0\0\a.*\a%s\tgsub/\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\16:normal! zx\bcmd\bvimM\1\1\6\1\5\0\v-\1\0\0009\1\0\1\18\3\1\0009\1\1\0015\4\3\0003\5\2\0=\5\4\4B\1\3\1+\1\2\0002\0\0�L\1\2\0\0�\tpost\1\0\0\0\fenhance\vselect�\20\1\0\v\0h\1�\0016\0\0\0009\0\1\0'\2\2\0B\0\2\0016\0\0\0009\0\1\0'\2\3\0B\0\2\0016\0\0\0009\0\1\0'\2\4\0B\0\2\0016\0\0\0009\0\1\0'\2\5\0B\0\2\0016\0\0\0009\0\1\0'\2\6\0B\0\2\0016\0\0\0009\0\1\0'\2\a\0B\0\2\0016\0\0\0009\0\1\0'\2\b\0B\0\2\0016\0\t\0'\2\n\0B\0\2\0026\1\v\0009\1\f\0015\2\r\0003\3\14\0=\3\15\0026\3\t\0'\5\16\0B\3\2\0029\3\17\0039\3\18\0039\3\19\0035\0047\0005\5\20\0005\6\21\0=\6\22\0055\6\29\0005\a\24\0005\b\23\0=\b\25\a6\b\t\0'\n\26\0B\b\2\0029\b\27\b=\b\28\a=\a\30\6=\6\31\0055\6!\0005\a \0=\a\"\0065\a#\0=\a$\6=\6%\0055\6&\0=\6'\0056\6\t\0'\b(\0B\6\2\0029\6)\0069\6*\6=\6+\0056\6\t\0'\b(\0B\6\2\0029\6,\0069\6*\6=\6-\0056\6\t\0'\b(\0B\6\2\0029\6.\0069\6*\6=\6/\0056\6\t\0'\b0\0B\6\2\0029\0061\6=\0062\0056\6\t\0'\b(\0B\6\2\0029\0063\6=\0063\0055\0064\0=\0065\0054\6\0\0=\0066\5=\0058\0045\5;\0004\6\3\0006\a\t\0'\t9\0B\a\2\0029\a:\a4\t\0\0B\a\2\0?\a\0\0=\6<\0055\6=\0=\1\f\0065\aE\0005\b?\0009\t>\3=\t@\b9\tA\3=\tB\b9\tC\3=\tD\b=\b\30\a4\b\0\0=\bF\a=\a\31\6=\6\18\0055\6G\0=\6H\0055\6I\0005\aJ\0=\aK\6=\6L\5=\5\17\0045\5M\0=\2N\5=\2O\5=\2P\5=\2Q\0055\6R\0=\1\f\0063\aS\0=\aT\0063\aU\0=\a\15\6=\6V\5=\2W\0055\6X\0=\1\f\6=\6Y\0055\6Z\0=\1\f\6=\6[\0055\6\\\0005\a]\0=\a%\6=\6^\0055\6_\0=\6`\5=\5a\0046\5b\0=\4c\0056\5\t\0'\a\16\0B\5\2\0029\5d\5\18\a\4\0B\5\2\0016\5\t\0'\a\16\0B\5\2\0029\5e\5'\aH\0B\5\2\0016\5\t\0'\a\16\0B\5\2\0029\5e\5'\af\0B\5\2\0016\5\t\0'\a\16\0B\5\2\0029\5e\5'\aL\0B\5\2\0016\5\t\0'\a\16\0B\5\2\0029\5e\5'\a<\0B\5\2\0016\5\t\0'\a\16\0B\5\2\0029\5e\5'\a\18\0B\5\2\0016\5\t\0'\a\16\0B\5\2\0029\5e\5'\ag\0B\5\2\0012\0\0�K\0\1\0\nemoji\fproject\19load_extension\nsetup\21telescope_config\a_G\fpickers\21lsp_code_actions\1\0\2\ntheme\vcursor\17initial_mode\vnormal\19lsp_references\1\0\2\nwidth\4����\t����\3\vheight\4����\t����\3\1\0\2\ntheme\vcursor\17initial_mode\vnormal\16diagnostics\1\0\1\17initial_mode\vnormal\25lsp_document_symbols\1\0\0\roldfiles\14live_grep\0\23on_input_filter_cb\0\1\0\0\16grep_string\14git_files\15find_files\fbuffers\1\0\0\rfrecency\20ignore_patterns\1\3\0\0\f*.git/*\f*/tmp/*\1\0\2\16show_scores\2\19show_unindexed\2\bfzf\1\0\4\nfuzzy\2\28override_generic_sorter\2\25override_file_sorter\2\14case_mode\15smart_case\6n\1\0\0\n<C-c>\vcreate\n<C-e>\vrename\n<C-h>\1\0\0\20goto_parent_dir\1\0\0\14ui-select\1\0\0\17get_dropdown\21telescope.themes\rdefaults\1\0\0\vborder\17path_display\1\2\0\0\nsmart\27buffer_previewer_maker\19generic_sorter\29get_generic_fuzzy_sorter\22telescope.sorters\21qflist_previewer\22vim_buffer_qflist\19grep_previewer\23vim_buffer_vimgrep\19file_previewer\bnew\19vim_buffer_cat\25telescope.previewers\25file_ignore_patterns\1\5\0\0\24packer_compiled.lua\20static_content/\18node_modules/\n.git/\18layout_config\rvertical\1\0\1\vmirror\1\15horizontal\1\0\3\19preview_cutoff\3x\vheight\4����\t����\3\nwidth\4����\3����\3\1\0\3\18results_width\4����\t����\3\20prompt_position\btop\18preview_width\4����\t����\3\rmappings\6i\1\0\0\n<Esc>\nclose\22telescope.actions\n<C-a>\1\0\0\1\2\1\0\f<esc>0i\ttype\fcommand\22vimgrep_arguments\1\b\0\0\arg\18--color=never\17--no-heading\20--with-filename\18--line-number\r--column\17--smart-case\1\0\v\20layout_strategy\15horizontal\rwinblend\3\0\23selection_strategy\nreset\19color_devicons\2\21sorting_strategy\14ascending\18results_title\1\ruse_less\2\20scroll_strategy\nlimit\18prompt_prefix\n🔭 \20selection_caret\b» \18initial_model\vinsert\factions\17file_browser\15extensions\14telescope\20attach_mappings\0\1\0\1\vhidden\2\ntheme\20__editor_config\26telescope.actions.set\frequire%packadd telescope-ui-select.nvim!packadd telescope-emoji.nvim$packadd telescope-frecency.nvim#packadd telescope-project.nvim(packadd telescope-file-browser.nvim&packadd telescope-fzf-native.nvim\23packadd sqlite.lua\bcmd\bvim\3����\4\0" },
    loaded = false,
    needs_bufread = true,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/telescope.nvim",
    url = "git@github.com:nvim-telescope/telescope.nvim"
  },
  ["trouble.nvim"] = {
    commands = { "Trouble", "TroubleToggle", "TroubleRefresh" },
    config = { "\27LJ\2\n�\5\0\0\5\0\26\0\0296\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0005\4\5\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\v\0=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\0035\4\17\0=\4\18\0035\4\19\0=\4\20\3=\3\21\0025\3\22\0=\3\23\0025\3\24\0=\3\25\2B\0\2\1K\0\1\0\nsigns\1\0\5\fwarning\b\nother\b﫠\nerror\b\16information\b\thint\b\14auto_jump\1\2\0\0\20lsp_definitions\16action_keys\16toggle_fold\1\3\0\0\azA\aza\15open_folds\1\3\0\0\azR\azr\16close_folds\1\3\0\0\azM\azm\15jump_close\1\2\0\0\6o\ropen_tab\1\2\0\0\n<c-t>\16open_vsplit\1\2\0\0\n<c-v>\15open_split\1\2\0\0\n<c-x>\tjump\1\3\0\0\t<cr>\n<tab>\1\0\t\fpreview\6p\nclose\6q\nhover\6K\tnext\6j\frefresh\6r\19toggle_preview\6P\16toggle_mode\6m\rprevious\6k\vcancel\n<esc>\1\0\r\rposition\vbottom\16fold_closed\b\14fold_open\b\nicons\2\14auto_open\1\17auto_preview\2\tmode\25document_diagnostics\14auto_fold\1\17indent_lines\2\vheight\3\n\nwidth\0032\15auto_close\2\29use_lsp_diagnostic_signs\1\nsetup\ftrouble\frequire\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/trouble.nvim",
    url = "git@github.com:folke/trouble.nvim"
  },
  ["twilight.nvim"] = {
    config = { "\27LJ\2\n�\1\0\0\6\0\f\0\0176\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\3\0005\3\6\0005\4\3\0005\5\4\0=\5\5\4=\4\a\0035\4\b\0=\4\t\0035\4\n\0=\4\v\3>\3\1\2B\0\2\1K\0\1\0\fexclude\1\2\0\0\n.git*\vexpand\1\5\0\0\rfunction\vmethod\ntable\17if_statement\fdimming\1\0\2\15treesitter\2\fcontext\0032\ncolor\1\3\0\0\vNormal\f#ffffff\1\0\2\nalpha\4\0����\3\rinactive\2\nsetup\rtwilight\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/twilight.nvim",
    url = "git@github.com:folke/twilight.nvim"
  },
  undotree = {
    commands = { "UndotreeToggle" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/undotree",
    url = "git@github.com:mbbill/undotree"
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
  ["vim-illuminate"] = {
    config = { "\27LJ\2\n�\1\0\0\2\0\5\0\t6\0\0\0009\0\1\0)\1\0\0=\1\2\0006\0\0\0009\0\1\0005\1\4\0=\1\3\0K\0\1\0\1\f\0\0\thelp\14dashboard\nalpha\vpacker\tnorg\rDoomInfo\rNvimTree\fOutline\15toggleterm\fTrouble\rquickfix\27Illuminate_ftblacklist$Illuminate_highlightUnderCursor\6g\bvim\0" },
    loaded = false,
    needs_bufread = false,
    only_cond = false,
    path = "/Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-illuminate",
    url = "git@github.com:RRethy/vim-illuminate"
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
  ["wilder.nvim"] = {
    after = { "fzy-lua-native" },
    config = { "\27LJ\2\nj\0\2\6\0\5\0\r6\2\0\0009\2\1\2\18\4\1\0'\5\2\0B\2\3\2\n\2\0\0X\2\3�5\2\3\0L\2\2\0X\2\2�5\2\4\0L\2\2\0K\0\1\0\1\3\0\0\vfdfind\b-tf\1\4\0\0\vfdfind\b-tf\a-H\6.\tfind\vstring \0\2\3\0\1\0\6\6\1\0\0X\2\2�+\2\1\0X\3\1�+\2\2\0L\2\2\0\5�\t\1\0\17\0:\3h6\0\0\0'\2\1\0B\0\2\0029\1\2\0005\3\4\0005\4\3\0=\4\5\3B\1\2\0019\1\6\0'\3\a\0004\4\3\0009\5\b\0009\a\t\0005\t\v\0003\n\n\0=\n\f\t5\n\r\0=\n\14\tB\a\2\0029\b\15\0005\n\21\0009\v\16\0005\r\17\0009\14\18\0005\16\19\0B\14\2\2=\14\20\rB\v\2\2=\v\a\nB\b\2\0024\t\3\0009\n\22\0003\f\23\0B\n\2\2>\n\1\t9\n\24\0B\n\1\0?\n\0\0009\n\16\0005\f\26\0009\r\18\0005\15\25\0B\r\2\2=\r\20\fB\n\2\0A\5\3\0?\5\1\0B\1\3\0014\1\3\0009\2\27\0B\2\1\2>\2\1\0019\2\28\0B\2\1\0?\2\0\0009\2\29\0009\4\30\0005\6\31\0009\a \0B\a\1\2=\a!\6=\1\"\0065\a#\0009\b$\0B\b\1\2>\b\2\a9\b%\0005\n&\0005\v'\0=\v(\nB\b\2\0?\b\2\0=\a)\0065\a*\0009\b+\0B\b\1\0?\b\0\0=\a,\6B\4\2\0A\2\0\0029\3-\0005\5.\0=\1/\0055\0060\0009\a1\0B\a\1\2>\a\2\6=\6)\0055\0062\0009\a3\0B\a\1\0?\a\0\0=\6,\5B\3\2\0029\4\6\0'\0064\0009\a5\0005\t6\0=\0027\t=\0038\t=\0039\tB\a\2\0A\4\1\1K\0\1\0\15substitute\6/\6:\1\0\0\17renderer_mux\rrenderer\19wildmenu_index\1\2\0\0\6 \21wildmenu_spinner\1\4\0\0\6 \0\6 \16highlighter\1\0\1\14separator\t · \22wildmenu_renderer\nright\24popupmenu_scrollbar\1\2\0\0\6 \tleft\nicons\1\0\3\6a\b\6h\b\6+\b\1\0\1\nflags\n a + \27popupmenu_buffer_flags\23popupmenu_devicons\1\2\0\0\6 \15highligher\18empty_message)popupmenu_empty_message_with_spinner\1\0\1\vborder\frounded\27popupmenu_border_theme\23popupmenu_renderer\24lua_fzy_highlighter\22pcre2_highlighter\1\0\0\1\0\1\22start_at_boundary\3\0\fhistory\0\ncheck\1\0\0\fpattern\1\0\1\22start_at_boundary\3\0\25python_fuzzy_pattern\1\0\1\23skip_cmdtype_check\3\1\27python_search_pipeline\24substitute_pipeline\16dir_command\1\3\0\0\afd\b-td\17file_command\1\0\0\0 python_file_finder_pipeline\vbranch\rpipeline\15set_option\nmodes\1\0\0\1\3\0\0\6/\6?\nsetup\vwilder\frequire\5����\4\3����\4\a����\4\0" },
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
  ["^octo"] = "octo.nvim",
  ["^refactoring"] = "refactoring.nvim",
  ["^spectre"] = "nvim-spectre",
  ["^telekasten"] = "telekasten.nvim"
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
try_loadstring("\27LJ\2\n�\1\0\0\2\0\b\0\0176\0\0\0009\0\1\0+\1\2\0=\1\2\0006\0\0\0009\0\1\0+\1\2\0=\1\3\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0006\0\0\0009\0\1\0005\1\a\0=\1\6\0K\0\1\0\1\0\1\20TelescopePrompt\1\22copilot_filetypes\5\25copilot_tab_fallback\26copilot_assume_mapped\23copilot_no_tab_map\6g\bvim\0", "setup", "copilot.vim")
time([[Setup for copilot.vim]], false)
-- Config for: rose-pine
time([[Config for rose-pine]], true)
try_loadstring("\27LJ\2\n;\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\14rose-pine\frequire\0", "config", "rose-pine")
time([[Config for rose-pine]], false)
-- Config for: nvim-web-devicons
time([[Config for nvim-web-devicons]], true)
try_loadstring("\27LJ\2\n�\v\0\0\a\0M\0}6\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\0029\0\3\0006\1\0\0'\3\4\0B\1\2\0029\1\5\0015\3K\0005\4\a\0005\5\6\0=\5\b\0045\5\t\0009\6\n\0=\6\v\5=\5\f\0045\5\r\0009\6\n\0=\6\v\5=\5\14\0045\5\15\0009\6\16\0=\6\v\5=\5\17\0045\5\18\0009\6\16\0=\6\v\5=\5\19\0045\5\20\0009\6\21\0=\6\v\5=\5\22\0045\5\23\0009\6\24\0=\6\v\5=\5\25\0045\5\26\0009\6\24\0=\6\v\5=\5\27\0045\5\28\0009\6\29\0=\6\v\5=\5\30\0045\5\31\0009\6 \0=\6\v\5=\5!\0045\5\"\0009\6#\0=\6\v\5=\5$\0045\5%\0009\6\n\0=\6\v\5=\5&\0045\5'\0009\6(\0=\6\v\5=\5)\0045\5*\0009\6(\0=\6\v\5=\5+\0045\5,\0009\6(\0=\6\v\5=\5-\0045\5.\0009\6\24\0=\6\v\5=\5/\0045\0050\0009\6\16\0=\6\v\5=\0051\0045\0052\0009\6#\0=\6\v\5=\0053\0045\0054\0009\6\n\0=\6\v\5=\0055\0045\0056\0009\0067\0=\6\v\5=\0058\0045\0059\0009\6(\0=\6\v\5=\5:\0045\5;\0009\6<\0=\6\v\5=\5=\0045\5>\0009\6 \0=\6\v\5=\5?\0045\5@\0009\6A\0=\6\v\5=\5B\0045\5C\0009\6(\0=\6\v\5=\5D\0045\5E\0009\6(\0=\6\v\5=\5F\0045\5G\0009\6\29\0=\6\v\5=\5H\0045\5I\0009\6\29\0=\6\v\5=\5J\4=\4L\3B\1\2\1K\0\1\0\roverride\1\0\1\fdefault\2\bzip\1\0\2\tname\bzip\ticon\b\axz\1\0\2\tname\axz\ticon\b\nwoff2\1\0\2\tname\23WebOpenFontFormat2\ticon\b\twoff\1\0\2\tname\22WebOpenFontFormat\ticon\b\bvue\18vibrant_green\1\0\2\tname\bvue\ticon\b﵂\brpm\1\0\2\tname\brpm\ticon\b\arb\tpink\1\0\2\tname\arb\ticon\b\bttf\1\0\2\tname\17TrueTypeFont\ticon\b\ats\tteal\1\0\2\tname\ats\ticon\bﯤ\ttoml\1\0\2\tname\ttoml\ticon\b\15robots.txt\1\0\2\tname\vrobots\ticon\bﮧ\apy\1\0\2\tname\apy\ticon\b\bpng\1\0\2\tname\bpng\ticon\b\bout\1\0\2\tname\bout\ticon\b\bmp4\1\0\2\tname\bmp4\ticon\b\bmp3\nwhite\1\0\2\tname\bmp3\ticon\b\blua\1\0\2\tname\blua\ticon\b\tlock\bred\1\0\2\tname\tlock\ticon\b\akt\vorange\1\0\2\tname\akt\ticon\t󱈙\ajs\bsun\1\0\2\tname\ajs\ticon\b\bjpg\1\0\2\tname\bjpg\ticon\b\tjpeg\16dark_purple\1\0\2\tname\tjpeg\ticon\b\thtml\14baby_pink\1\0\2\tname\thtml\ticon\b\15Dockerfile\1\0\2\tname\15Dockerfile\ticon\b\bdeb\tcyan\1\0\2\tname\bdeb\ticon\b\bcss\1\0\2\tname\bcss\ticon\b\6c\ncolor\tblue\1\0\2\tname\6c\ticon\b\bzsh\1\0\0\1\0\4\tname\bZsh\16cterm_color\a65\ncolor\f#428850\ticon\b\nsetup\22nvim-web-devicons\fbase_30\bget\16core.colors\frequire\0", "config", "nvim-web-devicons")
time([[Config for nvim-web-devicons]], false)
-- Config for: catppuccin
time([[Config for catppuccin]], true)
try_loadstring("\27LJ\2\n�\5\0\0\6\0\18\0\0216\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\3\0005\3\4\0=\3\5\0025\3\6\0005\4\a\0005\5\b\0=\5\t\0045\5\n\0=\5\v\4=\4\f\0035\4\r\0=\4\14\0035\4\15\0=\4\16\3=\3\17\2B\0\2\1K\0\1\0\17integrations\21indent_blankline\1\0\2\26colored_indent_levels\1\fenabled\2\rnvimtree\1\0\3\14show_root\2\22transparent_panel\1\fenabled\2\15native_lsp\15underlines\1\0\4\16information\14underline\verrors\14underline\nhints\14underline\rwarnings\14underline\17virtual_text\1\0\4\16information\vitalic\verrors\vitalic\nhints\vitalic\rwarnings\vitalic\1\0\1\fenabled\2\1\0\21\14dashboard\2\vneogit\1\14vim_sneak\1\tfern\1\vbarbar\1\14which_key\2\14telescope\2\15treesitter\2\rmarkdown\2\15lightspeed\1\rgitsigns\2\vnotify\2\15bufferline\2\bcmp\2\15ts_rainbow\2\bhop\1\15telekasten\2\20symbols_outline\2\16lsp_trouble\2\rlsp_saga\2\14gitgutter\2\vstyles\1\0\4\17conditionals\vitalic\nloops\vitalic\14functions\vitalic\rcomments\vitalic\1\0\2\16term_colors\2\27transparent_background\1\nsetup\15catppuccin\frequire\0", "config", "catppuccin")
time([[Config for catppuccin]], false)
-- Config for: filetype.nvim
time([[Config for filetype.nvim]], true)
try_loadstring("\27LJ\2\n:\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\rfiletype\frequire\0", "config", "filetype.nvim")
time([[Config for filetype.nvim]], false)
-- Conditional loads
time([[Conditional loading of nvim-tmux-navigation]], true)
  require("packer.load")({"nvim-tmux-navigation"}, {}, _G.packer_plugins)
time([[Conditional loading of nvim-tmux-navigation]], false)
-- Load plugins in order defined by `after`
time([[Sequenced loading]], true)
vim.cmd [[ packadd dressing.nvim ]]
time([[Sequenced loading]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GenTocGFM lua require("packer.load")({'vim-markdown-toc'}, { cmd = "GenTocGFM", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TroubleRefresh lua require("packer.load")({'trouble.nvim'}, { cmd = "TroubleRefresh", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SymbolsOutline lua require("packer.load")({'symbols-outline.nvim'}, { cmd = "SymbolsOutline", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Telescope lua require("packer.load")({'telescope.nvim'}, { cmd = "Telescope", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Ggrep lua require("packer.load")({'vim-fugitive'}, { cmd = "Ggrep", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file BqfEnable lua require("packer.load")({'nvim-bqf'}, { cmd = "BqfEnable", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file BqfAutoToggle lua require("packer.load")({'nvim-bqf'}, { cmd = "BqfAutoToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file EasyAlign lua require("packer.load")({'vim-easy-align'}, { cmd = "EasyAlign", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TroubleToggle lua require("packer.load")({'trouble.nvim'}, { cmd = "TroubleToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Dispatch lua require("packer.load")({'vim-dispatch'}, { cmd = "Dispatch", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file StartupTime lua require("packer.load")({'vim-startuptime'}, { cmd = "StartupTime", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file G lua require("packer.load")({'vim-fugitive'}, { cmd = "G", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Octo lua require("packer.load")({'octo.nvim'}, { cmd = "Octo", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file ReplToggle lua require("packer.load")({'nvim-repl'}, { cmd = "ReplToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file NvimTreeToggle lua require("packer.load")({'nvim-tree.lua'}, { cmd = "NvimTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file UndotreeToggle lua require("packer.load")({'undotree'}, { cmd = "UndotreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file ReplSendLine lua require("packer.load")({'nvim-repl'}, { cmd = "ReplSendLine", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file ReplSendVisual lua require("packer.load")({'nvim-repl'}, { cmd = "ReplSendVisual", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Trouble lua require("packer.load")({'trouble.nvim'}, { cmd = "Trouble", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GBrowse lua require("packer.load")({'vim-fugitive'}, { cmd = "GBrowse", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Git lua require("packer.load")({'vim-fugitive'}, { cmd = "Git", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SymbolsOutlineOpen lua require("packer.load")({'symbols-outline.nvim'}, { cmd = "SymbolsOutlineOpen", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file JupyterExecute lua require("packer.load")({'jupyter_ascending.vim'}, { cmd = "JupyterExecute", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file JupyterExecuteAll lua require("packer.load")({'jupyter_ascending.vim'}, { cmd = "JupyterExecuteAll", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args>, mods = "<mods>" }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType html ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "html" }, _G.packer_plugins)]]
vim.cmd [[au FileType ipynb ++once lua require("packer.load")({'jupyter_ascending.vim'}, { ft = "ipynb" }, _G.packer_plugins)]]
vim.cmd [[au FileType md ++once lua require("packer.load")({'vim-markdown-toc'}, { ft = "md" }, _G.packer_plugins)]]
vim.cmd [[au FileType tex ++once lua require("packer.load")({'vimtex'}, { ft = "tex" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'markdown-preview.nvim'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType qf ++once lua require("packer.load")({'nvim-bqf'}, { ft = "qf" }, _G.packer_plugins)]]
vim.cmd [[au FileType xml ++once lua require("packer.load")({'nvim-ts-autotag'}, { ft = "xml" }, _G.packer_plugins)]]
vim.cmd [[au FileType latex ++once lua require("packer.load")({'cmp-latex-symbols'}, { ft = "latex" }, _G.packer_plugins)]]
vim.cmd [[au FileType rust ++once lua require("packer.load")({'rust-tools.nvim'}, { ft = "rust" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au BufNewFile * ++once lua require("packer.load")({'gitsigns.nvim'}, { event = "BufNewFile *" }, _G.packer_plugins)]]
vim.cmd [[au InsertEnter * ++once lua require("packer.load")({'nvim-cmp', 'friendly-snippets'}, { event = "InsertEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufWinEnter * ++once lua require("packer.load")({'alpha-nvim'}, { event = "BufWinEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufEnter * ++once lua require("packer.load")({'which-key.nvim'}, { event = "BufEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufReadPre * ++once lua require("packer.load")({'nvim-lspconfig'}, { event = "BufReadPre *" }, _G.packer_plugins)]]
vim.cmd [[au CmdlineEnter * ++once lua require("packer.load")({'wilder.nvim'}, { event = "CmdlineEnter *" }, _G.packer_plugins)]]
vim.cmd [[au BufRead * ++once lua require("packer.load")({'nvim-colorizer.lua', 'indent-blankline.nvim', 'vim-illuminate', 'gitsigns.nvim', 'nvim-treesitter', 'fidget.nvim', 'nvim-toggleterm.lua', 'nvim-bufferline.lua'}, { event = "BufRead *" }, _G.packer_plugins)]]
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
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc/ftdetect/markdown.vim]], true)
vim.cmd [[source /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc/ftdetect/markdown.vim]]
time([[Sourcing ftdetect script at: /Users/aarnphm/.local/share/nvim/site/pack/packer/opt/vim-markdown-toc/ftdetect/markdown.vim]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
