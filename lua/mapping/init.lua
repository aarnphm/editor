local nvim_load_mapping = require("mapping.bind").nvim_load_mapping
local map_cr = require("mapping.bind").map_cr
local map_cu = require("mapping.bind").map_cu
local map_cmd = require("mapping.bind").map_cmd

require("mapping.config")

local M = {}

function M.setup_mapping()
  -- default map
  local def_map = {
    -- Vim map
    ["n|<C-x>"] = map_cr("lua require('bufdelete').delete_buffer()"):with_noremap():with_silent(),
    ["n|<C-s>"] = map_cu("write"):with_noremap(),
    ["n|Y"] = map_cmd("y$"),
    ["n|D"] = map_cmd("d$"),
    ["n|;"] = map_cmd(":"):with_noremap(),
    ["n|<leader>vs"] = map_cmd(':vsplit <C-r>=expand("%:p:h")<cr>/'):with_noremap(),
    ["n|<leader>s"] = map_cmd(':split <C-r>=expand("%:p:h")<cr>/'):with_noremap(),
    ["n|<leader>te"] = map_cmd(':tabedit <C-r>=expand("%:p:h")<cr>/'):with_noremap(),
    ["n|<leader>["] = map_cr("vertical resize -5"):with_silent(),
    ["n|<leader>]"] = map_cr("vertical resize +5"):with_silent(),
    ["n|<leader>-"] = map_cr("resize -2"):with_silent(),
    ["n|<leader>="] = map_cr("resize +2"):with_silent(),
    ["n|<leader>o"] = map_cr("setlocal spell! spelllang=en_us"),
    ["n|<leader>I"] = map_cmd(":set list!<cr>"):with_noremap(),
    ["n|\\"] = map_cmd(":let @/=''<CR>:noh<CR>"):with_noremap(),
    ["n|<leader>p"] = map_cmd(":%s///g<CR>"):with_noremap():with_silent(),
    ["n|<leader>i"] = map_cmd("gg=G<CR>"):with_noremap():with_silent(),
    ["n|<leader>l"] = map_cmd(":set list! list?<CR>"):with_noremap(),
    ["n|<leader>t"] = map_cmd(":%s/\\s\\+$//e<CR>"):with_noremap(),
    -- Insert
    ["i|jj"] = map_cmd("<Esc>"):with_noremap(),
    ["i|<C-u>"] = map_cmd("<C-G>u<C-U>"):with_noremap(),
    -- command line
    ["c|<C-t>"] = map_cmd([[<C-R>=expand("%:p:h") . "/" <CR>]]):with_noremap(),
    ["c|W!!"] = map_cmd("execute 'silent! write !sudo tee % >/dev/null' <bar> edit!"),
    -- Visual
    ["v|J"] = map_cmd(":m '>+1<cr>gv=gv"),
    ["v|K"] = map_cmd(":m '<-2<cr>gv=gv"),
    ["v|<"] = map_cmd("<gv"),
    ["v|>"] = map_cmd(">gv"),
  }

  local plug_map = {
    -- reload and edit config
    ["n|<LocalLeader>rl"] = map_cu("lua require('core.utils').reload()"):with_noremap():with_silent(),
    ["n|<LocalLeader>er"] = map_cu("lua require('core.utils').edit_root()"):with_noremap():with_silent(),
    ["n|<LocalLeader>ec"] = map_cu(":e ~/.editor.lua"):with_noremap():with_silent(),
    -- jupyter_ascending
    ["n|<LocalLeader><LocalLeader>x"] = map_cr(":call jupyter_ascending#execute()<CR>"),
    ["n|<LocalLeader><LocalLeader>X"] = map_cr(":call jupyter_ascending#execute_all()<CR>"),
    -- Bufferline
    ["n|<LocalLeader>j"] = map_cr("BufferLineCycleNext"):with_noremap():with_silent(),
    ["n|<LocalLeader>k"] = map_cr("BufferLineCyclePrev"):with_noremap():with_silent(),
    ["n|<LocalLeader>bp"] = map_cr("BufferLinePick"):with_noremap():with_silent(),
    ["n|<LocalLeader>bc"] = map_cr("BufferLinePickClose"):with_noremap():with_silent(),
    ["n|<LocalLeader>be"] = map_cr("BufferLineSortByExtension"):with_noremap(),
    ["n|<LocalLeader>bd"] = map_cr("BufferLineSortByDirectory"):with_noremap(),
    ["n|<C-1>"] = map_cr("BufferLineGoToBuffer 1"):with_noremap():with_silent(),
    ["n|<C-2>"] = map_cr("BufferLineGoToBuffer 2"):with_noremap():with_silent(),
    ["n|<C-3>"] = map_cr("BufferLineGoToBuffer 3"):with_noremap():with_silent(),
    ["n|<C-4>"] = map_cr("BufferLineGoToBuffer 4"):with_noremap():with_silent(),
    ["n|<C-5>"] = map_cr("BufferLineGoToBuffer 5"):with_noremap():with_silent(),
    ["n|<C-6>"] = map_cr("BufferLineGoToBuffer 6"):with_noremap():with_silent(),
    ["n|<C-7>"] = map_cr("BufferLineGoToBuffer 7"):with_noremap():with_silent(),
    ["n|<C-8>"] = map_cr("BufferLineGoToBuffer 8"):with_noremap():with_silent(),
    ["n|<C-9>"] = map_cr("BufferLineGoToBuffer 9"):with_noremap():with_silent(),
    -- Packer
    ["n|<LocalLeader>ps"] = map_cu("lua require('core.pack').sync()"):with_silent():with_noremap():with_nowait(),
    ["n|<LocalLeader>pS"] = map_cu("lua require('core.pack').status()"):with_silent():with_noremap():with_nowait(),
    ["n|<LocalLeader>pu"] = map_cu("lua require('core.pack').update()"):with_silent():with_noremap():with_nowait(),
    ["n|<LocalLeader>pc"] = map_cu("lua require('core.pack').compile()"):with_silent():with_noremap():with_nowait(),
    ["n|<LocalLeader>pC"] = map_cu("lua require('core.pack').clean()"):with_silent():with_noremap():with_nowait(),
    -- Lsp mapp work when insertenter and lsp start
    ["n|<leader>li"] = map_cr("LspInfo"):with_noremap():with_silent():with_nowait(),
    ["n|<leader>lr"] = map_cr("LspRestart"):with_noremap():with_silent():with_nowait(),
    ["n|g["] = map_cr("Lspsaga diagnostic_jump_next"):with_noremap():with_silent(),
    ["n|g]"] = map_cr("Lspsaga diagnostic_jump_prev"):with_noremap():with_silent(),
    ["n|gs"] = map_cr("Lspsaga signature_help"):with_noremap():with_silent(),
    ["n|gr"] = map_cr("Lspsaga rename"):with_noremap():with_silent(),
    ["n|K"] = map_cr("Lspsaga hover_doc"):with_noremap():with_silent(),
    ["n|<C-Up>"] = map_cr("lua require('lspsaga.action').smart_scroll_with_saga(-1)"):with_noremap():with_silent(),
    ["n|<C-Down>"] = map_cr("lua require('lspsaga.action').smart_scroll_with_saga(1)"):with_noremap():with_silent(),
    ["n|<leader>ca"] = map_cr("Lspsaga code_action"):with_noremap():with_silent(),
    ["v|<leader>ca"] = map_cu("Lspsaga range_code_action"):with_noremap():with_silent(),
    ["n|gd"] = map_cr("Lspsaga preview_definition"):with_noremap():with_silent(),
    ["n|gD"] = map_cr("lua vim.lsp.buf.definition()"):with_noremap():with_silent(),
    ["n|gh"] = map_cr("lua vim.lsp.buf.references()"):with_noremap():with_silent(),
    ["n|<F5>"] = map_cu("lua require('core.utils').gitui()"):with_noremap():with_silent(),
    ["n|<F6>"] = map_cu("lua require('core.utils').create_float_term()"):with_noremap():with_silent(),
    ["n|<Leader>G"] = map_cu("Git"):with_noremap():with_silent(),
    ["n|gps"] = map_cr("G push"):with_noremap():with_silent(),
    ["n|gpl"] = map_cr("G pull"):with_noremap():with_silent(),
    -- Plugin nvim-tree
    ["n|<C-n>"] = map_cr("NvimTreeToggle"):with_noremap():with_silent(),
    ["n|<Leader>nf"] = map_cr("NvimTreeFindFile"):with_noremap():with_silent(),
    ["n|<Leader>nr"] = map_cr("NvimTreeRefresh"):with_noremap():with_silent(),
    -- Plugin trouble
    ["n|gt"] = map_cr("TroubleToggle"):with_noremap():with_silent(),
    ["n|gR"] = map_cr("TroubleToggle lsp_references"):with_noremap():with_silent(),
    ["n|<leader>cd"] = map_cr("TroubleToggle lsp_document_diagnostics"):with_noremap():with_silent(),
    ["n|<leader>cw"] = map_cr("TroubleToggle lsp_workspace_diagnostics"):with_noremap():with_silent(),
    ["n|<leader>cq"] = map_cr("TroubleToggle quickfix"):with_noremap():with_silent(),
    ["n|<leader>cl"] = map_cr("TroubleToggle loclist"):with_noremap():with_silent(),
    -- Plugin Telescope
    ["n|<Leader>fr"] = map_cu("lua require('telescope').extensions.frecency.frecency{}"):with_noremap():with_silent(),
    ["n|<Leader>fe"] = map_cu("DashboardFindHistory"):with_noremap():with_silent(),
    ["n|<Leader>ff"] = map_cu("DashboardFindFile"):with_noremap():with_silent(),
    ["n|<Leader>fw"] = map_cu("DashboardFindWord"):with_noremap():with_silent(),
    ["n|<Leader>fn"] = map_cu("DashboardNewFile"):with_noremap():with_silent(),
    ["n|<Leader>fb"] = map_cu("Telescope file_browser"):with_noremap():with_silent(),
    ["n|<Leader>fg"] = map_cu("Telescope git_files"):with_noremap():with_silent(),
    ["n|<Leader>ft"] = map_cu("Telescope live_grep"):with_noremap():with_silent(),
    ["n|<LocalLeader>km"] = map_cu("Telescope keymaps"):with_noremap():with_silent(),
    -- Plugin spectre
    ["n|<S-F6>"] = map_cr("lua require('spectre').open()"):with_noremap():with_silent(),
    ["n|<Leader>sw"] = map_cr("lua require('spectre').open_visual({select_word=true})"):with_noremap():with_silent(),
    ["n|<Leader>s"] = map_cr("lua require('spectre').open_visual()"):with_noremap():with_silent(),
    ["n|<Leader>sp"] = map_cr("lua require('spectre').open_file_search()"):with_noremap():with_silent(),
    -- Plugin EasyAlign
    ["n|ga"] = map_cmd("v:lua.enhance_align('nga')"):with_expr(),
    ["x|ga"] = map_cmd("v:lua.enhance_align('xga')"):with_expr(),
    -- Plugin SymbolsOutline
    ["n|so"] = map_cr("SymbolsOutlineOpen"):with_noremap():with_silent(),
    ["n|sc"] = map_cr("SymbolsOutlineClose"):with_noremap():with_silent(),
    -- Plugin MarkdownPreview
    ["n|<F12>"] = map_cr("MarkdownPreviewToggle"):with_noremap():with_silent(),
    -- Plugin zen-mode
    ["n|zm"] = map_cu('lua require("zen-mode").toggle({window = { width = .85 }})'):with_noremap():with_silent(),
    -- Plugin dap
    ["n|<F7>"] = map_cr("lua require('dap').continue()"):with_noremap():with_silent(),
    ["n|<leader>dr"] = map_cr("lua require('dap').continue()"):with_noremap():with_silent(),
    ["n|<leader>dd"] = map_cr("lua require('dap').terminate() require('dapui').close()"):with_noremap():with_silent(),
    ["n|<leader>db"] = map_cr("lua require('dap').toggle_breakpoint()"):with_noremap():with_silent(),
    ["n|<leader>dB"] = map_cr("lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))")
      :with_noremap()
      :with_silent(),
    ["n|<leader>dbl"] = map_cr("lua require('dap').list_breakpoints()"):with_noremap():with_silent(),
    ["n|<leader>drc"] = map_cr("lua require('dap').run_to_cursor()"):with_noremap():with_silent(),
    ["n|<leader>drl"] = map_cr("lua require('dap').run_last()"):with_noremap():with_silent(),
    ["n|<F9>"] = map_cr("lua require('dap').step_over()"):with_noremap():with_silent(),
    ["n|<leader>dv"] = map_cr("lua require('dap').step_over()"):with_noremap():with_silent(),
    ["n|<F10>"] = map_cr("lua require('dap').step_into()"):with_noremap():with_silent(),
    ["n|<leader>di"] = map_cr("lua require('dap').step_into()"):with_noremap():with_silent(),
    ["n|<F11>"] = map_cr("lua require('dap').step_out()"):with_noremap():with_silent(),
    ["n|<leader>do"] = map_cr("lua require('dap').step_out()"):with_noremap():with_silent(),
    ["n|<leader>dl"] = map_cr("lua require('dap').repl.open()"):with_noremap():with_silent(),
    -- Plugins telekasten
    ["n|<leader>zf"] = map_cr("lua require('telekasten').find_notes()"):with_noremap():with_silent(),
    ["n|<leader>zd"] = map_cr("lua require('telekasten').find_daily_notes()"):with_noremap():with_silent(),
    ["n|<leader>zg"] = map_cr("lua require('telekasten').search_notes()"):with_noremap():with_silent(),
    ["n|<leader>zz"] = map_cr("lua require('telekasten').follow_link()"):with_noremap():with_silent(),
    ["n|<leader>zT"] = map_cr("lua require('telekasten').goto_today()"):with_noremap():with_silent(),
    ["n|<leader>zW"] = map_cr("lua require('telekasten').goto_thisweek()"):with_noremap():with_silent(),
    ["n|<leader>zw"] = map_cr("lua require('telekasten').find_weekly_notes()"):with_noremap():with_silent(),
    ["n|<leader>zn"] = map_cr("lua require('telekasten').new_note()"):with_noremap():with_silent(),
    ["n|<leader>zN"] = map_cr("lua require('telekasten').new_templated_note()"):with_noremap():with_silent(),
    ["n|<leader>zy"] = map_cr("lua require('telekasten').yank_notelink()"):with_noremap():with_silent(),
    ["n|<leader>zc"] = map_cr("lua require('telekasten').show_calendar()"):with_noremap():with_silent(),
    ["n|<leader>zC"] = map_cr("CalendarT"):with_noremap():with_silent(),
    ["n|<leader>zi"] = map_cr("lua require('telekasten').paste_img_and_link()"):with_noremap():with_silent(),
    ["n|<leader>zt"] = map_cr("lua require('telekasten').toggle_todo()"):with_noremap():with_silent(),
    ["n|<leader>zb"] = map_cr("lua require('telekasten').show_backlinks()"):with_noremap():with_silent(),
    ["n|<leader>zF"] = map_cr("lua require('telekasten').find_friends()"):with_noremap():with_silent(),
    ["n|<leader>zI"] = map_cr("lua require('telekasten').insert_img_link({ i=true })"):with_noremap():with_silent(),
    ["n|<leader>zpi"] = map_cr("lua require('telekasten').preview_img()"):with_noremap():with_silent(),
    ["n|<leader>zm"] = map_cr("lua require('telekasten').browse_media()"):with_noremap():with_silent(),
    ["n|<leader>za"] = map_cr("lua require('telekasten').show_tags()"):with_noremap():with_silent(),
    ["n|<leader>zr"] = map_cr("lua require('telekasten').rename_note()"):with_noremap():with_silent(),
    ["n|<leader>zp"] = map_cr("lua require('telekasten').panel()"):with_noremap():with_silent(),
    ["n|<leader>#"] = map_cr("lua require('telekasten').show_tags()"):with_noremap():with_silent(),
    -- interactive
    ["i|<leader>["] = map_cr("lua require('telekasten').insert_link({ i=true })"):with_noremap():with_silent(),
    ["i|<leader>#"] = map_cr("lua require('telekasten').show_tags({i = true})"):with_noremap():with_silent(),
    ["i|<leader>zt"] = map_cr("lua require('telekasten').toggle_todo({ i=true })"):with_noremap():with_silent(),
  }

  nvim_load_mapping(def_map)
  nvim_load_mapping(plug_map)
end

return M
