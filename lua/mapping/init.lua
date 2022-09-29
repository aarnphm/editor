local nvim_load_mapping = require("mapping.bind").nvim_load_mapping
local map_cr = require("mapping.bind").map_cr
local map_cu = require("mapping.bind").map_cu
local map_cmd = require("mapping.bind").map_cmd

require("mapping.config")

local M = {}

M.setup = function()
  -- default map
  local def_map = {
    -- Vim map
    ["n|<C-x>"] = map_cr("lua require('bufdelete').delete_buffer()"):with_noremap():with_silent(),
    ["n|<Space>x"] = map_cr("lua require('bufdelete').delete_buffer()"):with_noremap():with_silent(),
    ["n|<C-s>"] = map_cu("write"):with_noremap(),
    ["n|Y"] = map_cmd("y$"),
    ["n|D"] = map_cmd("d$"),
    ["n|;"] = map_cmd(":"):with_noremap(),
    ["n|<C-h>"] = map_cmd("<C-w>h"):with_noremap(),
    ["n|<C-l>"] = map_cmd("<C-w>l"):with_noremap(),
    ["n|<C-j>"] = map_cmd("<C-w>j"):with_noremap(),
    ["n|<C-k>"] = map_cmd("<C-w>k"):with_noremap(),
    ["n|vs"] = map_cu("vsplit"):with_noremap():with_silent(),
    ["n|<leader>vs"] = map_cmd(':vsplit <C-r>=expand("%:p:h")<cr>/'):with_noremap(),
    ["n|<leader>s"] = map_cmd(':split <C-r>=expand("%:p:h")<cr>/'):with_noremap(),
    ["n|<leader>te"] = map_cmd(':tabedit <C-r>=expand("%:p:h")<cr>/'):with_noremap(),
    ["n|<LocalLeader>]"] = map_cr("vertical resize -5"):with_silent(),
    ["n|<LocalLeader>["] = map_cr("vertical resize +5"):with_silent(),
    ["n|<LocalLeader>-"] = map_cr("resize -2"):with_silent(),
    ["n|<LocalLeader>="] = map_cr("resize +2"):with_silent(),
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
    ["n|ft"] = map_cr("FormatToggle"):with_noremap():with_silent(),
    -- reload and edit config
    ["n|<LocalLeader>rl"] = map_cu("lua require'plugins' require('packer').sync()"):with_noremap():with_silent(),
    -- jupyter_ascending
    ["n|<LocalLeader><LocalLeader>x"] = map_cr(":call jupyter_ascending#execute()<CR>"),
    ["n|<LocalLeader><LocalLeader>X"] = map_cr(":call jupyter_ascending#execute_all()<CR>"),
    -- Bufferline
    ["n|<Space>l"] = map_cr("BufferLineCycleNext"):with_noremap():with_silent(),
    ["n|<Space>h"] = map_cr("BufferLineCyclePrev"):with_noremap():with_silent(),
    ["n|<Space>bp"] = map_cr("BufferLinePick"):with_noremap():with_silent(),
    ["n|<Space>bc"] = map_cr("BufferLinePickClose"):with_noremap():with_silent(),
    ["n|<LocalLeader>be"] = map_cr("BufferLineSortByExtension"):with_noremap(),
    ["n|<LocalLeader>bd"] = map_cr("BufferLineSortByDirectory"):with_noremap(),
    ["n|1gt"] = map_cr("BufferLineGoToBuffer 1"):with_noremap():with_silent(),
    ["n|2gt"] = map_cr("BufferLineGoToBuffer 2"):with_noremap():with_silent(),
    ["n|3gt"] = map_cr("BufferLineGoToBuffer 3"):with_noremap():with_silent(),
    ["n|4gt"] = map_cr("BufferLineGoToBuffer 4"):with_noremap():with_silent(),
    ["n|5gt"] = map_cr("BufferLineGoToBuffer 5"):with_noremap():with_silent(),
    ["n|6gt"] = map_cr("BufferLineGoToBuffer 6"):with_noremap():with_silent(),
    ["n|7gt"] = map_cr("BufferLineGoToBuffer 7"):with_noremap():with_silent(),
    ["n|8gt"] = map_cr("BufferLineGoToBuffer 8"):with_noremap():with_silent(),
    ["n|9gt"] = map_cr("BufferLineGoToBuffer 9"):with_noremap():with_silent(),
    -- Packer
    ["n|<Space>ps"] = map_cu("lua require'plugins' require('packer').sync()"):with_noremap(),
    ["n|<Space>pS"] = map_cu("lua require'plugins' require('packer').status()"):with_noremap(),
    ["n|<Space>pu"] = map_cu("lua require'plugins' require('packer').update()"):with_noremap(),
    ["n|<Space>pc"] = map_cu("lua require'plugins' require('packer').compile()"):with_noremap(),
    ["n|<Space>pC"] = map_cu("lua require'plugins' require('packer').clean()"):with_noremap(),
    -- Lsp map work when insertenter and lsp start
    ["n|<leader>li"] = map_cr("LspInfo"):with_noremap():with_silent():with_nowait(),
    ["n|<LocalLeader>lr"] = map_cr("LspRestart"):with_noremap():with_silent():with_nowait(),
    ["n|g["] = map_cr("Lspsaga diagnostic_jump_next"):with_noremap():with_silent(),
    ["n|g]"] = map_cr("Lspsaga diagnostic_jump_prev"):with_noremap():with_silent(),
    ["n|gs"] = map_cr("Lspsaga signature_help"):with_noremap():with_silent(),
    ["n|gr"] = map_cr("Lspsaga rename"):with_noremap():with_silent(),
    ["n|K"] = map_cr("Lspsaga hover_doc"):with_noremap():with_silent(),
    ["n|so"] = map_cr("LSoutlineToggle"):with_noremap():with_silent(),
    ["n|<LocalLeader>ca"] = map_cr("Lspsaga code_action"):with_noremap():with_silent(),
    ["v|<LocalLeader>ca"] = map_cu("Lspsaga code_action"):with_noremap():with_silent(),
    ["n|gd"] = map_cr("Lspsaga peek_definition"):with_noremap():with_silent(),
    ["n|<LocalLeader>cd"] = map_cr("Lspsaga show_line_diagnostics"):with_noremap():with_silent(),
    ["n|<Leader>cd"] = map_cr("Lspsaga show_cursor_diagnostics"):with_noremap():with_silent(),
    ["n|gD"] = map_cr("lua vim.lsp.buf.definition()"):with_noremap():with_silent(),
    ["n|gh"] = map_cr("Lspsaga lsp_finder"):with_noremap():with_silent(),
    ["n|<F5>"] = map_cu("lua require('core.utils').gitui()"):with_noremap():with_silent(),
    ["n|<F6>"] = map_cu("lua require('core.utils').create_float_term()"):with_noremap():with_silent(),
    ["n|<LocalLeader>G"] = map_cu("Git"):with_noremap():with_silent(),
    ["n|gps"] = map_cr("G push"):with_noremap():with_silent(),
    ["n|gpl"] = map_cr("G pull"):with_noremap():with_silent(),
    -- Plugin nvim-tree
    ["n|<C-n>"] = map_cr("NvimTreeToggle"):with_noremap():with_silent(),
    ["n|<LocalLeader>nf"] = map_cr("NvimTreeFindFile"):with_noremap():with_silent(),
    ["n|<Leader>nr"] = map_cr("NvimTreeRefresh"):with_noremap():with_silent(),
    -- Plugin octo
    ["n|<LocalLeader>oc"] = map_cr("Octo"):with_noremap(),
    -- Copilot
    ["n|<LocalLeader>cp"] = map_cr("Copilot setup"):with_noremap(),
    -- Plugin trouble
    ["n|gt"] = map_cr("TroubleToggle"):with_noremap():with_silent(),
    ["n|gR"] = map_cr("TroubleToggle lsp_references"):with_noremap():with_silent(),
    ["n|<LocalLeader>dd"] = map_cr("TroubleToggle document_diagnostics"):with_noremap():with_silent(),
    ["n|<LocalLeader>wd"] = map_cr("TroubleToggle workspace_diagnostics"):with_noremap():with_silent(),
    ["n|<LocalLeader>qf"] = map_cr("TroubleToggle quickfix"):with_noremap():with_silent(),
    ["n|<LocalLeader>ll"] = map_cr("TroubleToggle loclist"):with_noremap():with_silent(),
    -- Plugin vim-eft
    ["n|f"] = map_cmd("v:lua.enhance_ft_move('f')"):with_expr(),
    ["n|F"] = map_cmd("v:lua.enhance_ft_move('F')"):with_expr(),
    ["n|t"] = map_cmd("v:lua.enhance_ft_move('t')"):with_expr(),
    ["n|T"] = map_cmd("v:lua.enhance_ft_move('T')"):with_expr(),
    -- Plugin Telescope
    ["n|fo"] = map_cmd("<cmd> Telescope oldfiles<CR>"):with_noremap():with_silent(),
    ["n|fr"] = map_cmd("<cmd> Telescope frecency<CR>"):with_noremap():with_silent(),
    ["n|ff"] = map_cmd("<cmd> Telescope find_files<CR>"):with_noremap():with_silent(),
    ["n|<LocalLeader>ff"] = map_cr("<cmd> Telescope git_files<CR>"):with_noremap():with_silent(),
    ["n|fw"] = map_cmd("<cmd> Telescope live_grep <CR>"):with_noremap():with_silent(),
    ["n|<LocalLeader>fw"] = map_cr(
      "lua require('core.utils').exec_telescope('telescope.builtin.__files', 'live_grep')"
    )
      :with_noremap()
      :with_silent(),
    ["n|<LocalLeader>fn"] = map_cu("enew"):with_noremap():with_silent(),
    ["n|<LocalLeader>fb"] = map_cmd("<cmd> Telescope file_browser <CR>"):with_noremap():with_silent(),
    ["n|<LocalLeader>km"] = map_cmd("<cmd> Telescope keymaps <CR>"):with_noremap():with_silent(),
    -- Plugin spectre
    ["n|<S-F6>"] = map_cr("lua require('spectre').open()"):with_noremap():with_silent(),
    ["n|<Leader>sw"] = map_cr("lua require('spectre').open_visual({select_word=true})"):with_noremap():with_silent(),
    ["n|<Leader>s"] = map_cr("lua require('spectre').open_visual()"):with_noremap():with_silent(),
    ["n|<Leader>sp"] = map_cr("lua require('spectre').open_file_search({select_word=true})")
      :with_noremap()
      :with_silent(),
    -- Plugin Hop
    ["n|<LocalLeader>w"] = map_cu("HopWord"):with_noremap(),
    ["n|<LocalLeader>j"] = map_cu("HopLine"):with_noremap(),
    ["n|<LocalLeader>k"] = map_cu("HopLine"):with_noremap(),
    ["n|<LocalLeader>c"] = map_cu("HopChar1"):with_noremap(),
    ["n|<LocalLeader>cc"] = map_cu("HopChar2"):with_noremap(),
    -- Plugin EasyAlign
    ["n|ga"] = map_cmd("v:lua.enhance_align('nga')"):with_expr(),
    ["x|ga"] = map_cmd("v:lua.enhance_align('xga')"):with_expr(),
    -- Plugin MarkdownPreview
    ["n|mpt"] = map_cr("MarkdownPreviewToggle"):with_noremap():with_silent(),
    -- Plugin zen-mode
    ["n|zm"] = map_cu('lua require("zen-mode").toggle({window = { width = .85 }})'):with_noremap():with_silent(),
    -- refactoring
    ["v|<LocalLeader>re"] = map_cr("lua require('refactoring').refactor('Extract Function')")
      :with_noremap()
      :with_silent(),
    ["v|<LocalLeader>rf"] = map_cr("lua require('refactoring').refactor('Extract Function To File')")
      :with_noremap()
      :with_silent(),
    ["v|<LocalLeader>rv"] = map_cr("lua require('refactoring').refactor('Extract Variable')")
      :with_noremap()
      :with_silent(),
    ["v|<LocalLeader>ri"] = map_cr("lua require('refactoring').refactor('Inline Variable')")
      :with_noremap()
      :with_silent(),
    ["n|<LocalLeader>rb"] = map_cr("lua require('refactoring').refactor('Extract Block')"):with_noremap():with_silent(),
    ["n|<LocalLeader>rbf"] = map_cr("lua require('refactoring').refactor('Extract Block To File')")
      :with_noremap()
      :with_silent(),
    ["n|<LocalLeader>ri"] = map_cr("lua require('refactoring').refactor('Inline Variable')")
      :with_noremap()
      :with_silent(),
  }

  nvim_load_mapping(def_map)
  nvim_load_mapping(plug_map)
end

return M
