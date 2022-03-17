local bind = require("core.keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
require("core.keymap.config")

local plug_map = {
  -- jupyter_ascending
  ["n|<Space><Space>x"] = map_cr(":call jupyter_ascending#execute()<CR>"),
  ["n|<Space><Space>X"] = map_cr(":call jupyter_ascending#execute_all()<CR>"),
  -- Bufferline
  ["n|<Space>bp"] = map_cr("BufferLinePick"):with_noremap():with_silent(),
  ["n|<Space>bc"] = map_cr("BufferLinePickClose"):with_noremap():with_silent(),
  ["n|<A-j>"] = map_cr("BufferLineCycleNext"):with_noremap():with_silent(),
  ["n|<A-k>"] = map_cr("BufferLineCyclePrev"):with_noremap():with_silent(),
  ["n|<leader>be"] = map_cr("BufferLineSortByExtension"):with_noremap(),
  ["n|<leader>bd"] = map_cr("BufferLineSortByDirectory"):with_noremap(),
  ["n|<A-1>"] = map_cr("BufferLineGoToBuffer 1"):with_noremap():with_silent(),
  ["n|1gt"] = map_cr("BufferLineGoToBuffer 1"):with_noremap():with_silent(),
  ["n|<A-2>"] = map_cr("BufferLineGoToBuffer 2"):with_noremap():with_silent(),
  ["n|2gt"] = map_cr("BufferLineGoToBuffer 2"):with_noremap():with_silent(),
  ["n|<A-3>"] = map_cr("BufferLineGoToBuffer 3"):with_noremap():with_silent(),
  ["n|3gt"] = map_cr("BufferLineGoToBuffer 3"):with_noremap():with_silent(),
  ["n|<A-4>"] = map_cr("BufferLineGoToBuffer 4"):with_noremap():with_silent(),
  ["n|4gt"] = map_cr("BufferLineGoToBuffer 4"):with_noremap():with_silent(),
  ["n|<A-5>"] = map_cr("BufferLineGoToBuffer 5"):with_noremap():with_silent(),
  ["n|5gt"] = map_cr("BufferLineGoToBuffer 5"):with_noremap():with_silent(),
  ["n|<A-6>"] = map_cr("BufferLineGoToBuffer 6"):with_noremap():with_silent(),
  ["n|6gt"] = map_cr("BufferLineGoToBuffer 6"):with_noremap():with_silent(),
  ["n|<A-7>"] = map_cr("BufferLineGoToBuffer 7"):with_noremap():with_silent(),
  ["n|7gt"] = map_cr("BufferLineGoToBuffer 7"):with_noremap():with_silent(),
  ["n|<A-8>"] = map_cr("BufferLineGoToBuffer 8"):with_noremap():with_silent(),
  ["n|8gt"] = map_cr("BufferLineGoToBuffer 8"):with_noremap():with_silent(),
  ["n|<A-9>"] = map_cr("BufferLineGoToBuffer 9"):with_noremap():with_silent(),
  ["n|9gt"] = map_cr("BufferLineGoToBuffer 9"):with_noremap():with_silent(),
  -- Packer
  ["n|<leader>ps"] = map_cr("PackerSync"):with_silent():with_noremap():with_nowait(),
  ["n|<leader>pu"] = map_cr("PackerUpdate"):with_silent():with_noremap():with_nowait(),
  ["n|<leader>pi"] = map_cr("PackerInstall"):with_silent():with_noremap():with_nowait(),
  ["n|<leader>pc"] = map_cr("PackerClean"):with_silent():with_noremap():with_nowait(),
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
  ["n|<A-d>"] = map_cu('lua require("FTerm").toggle()'):with_noremap():with_silent(),
  ["t|<A-d>"] = map_cu([[<C-\><C-n><CMD>lua require("FTerm").toggle()]]):with_noremap():with_silent(),
  ["t|<A-S-d>"] = map_cu([[<C-\><C-n><CMD>lua require("FTerm").exit()]]):with_noremap():with_silent(),
  ["n|<Leader>gu"] = map_cu("lua require('FTerm').run('gitui')"):with_noremap():with_silent(),
  ["n|<Leader>G"] = map_cu("Git"):with_noremap():with_silent(),
  ["n|gps"] = map_cr("G push"):with_noremap():with_silent(),
  ["n|gpl"] = map_cr("G pull"):with_noremap():with_silent(),
  -- Plugin nvim-tree
  ["n|<C-n>"] = map_cr("NvimTreeToggle"):with_noremap():with_silent(),
  ["n|<Leader>nf"] = map_cr("NvimTreeFindFile"):with_noremap():with_silent(),
  ["n|<Leader>nr"] = map_cr("NvimTreeRefresh"):with_noremap():with_silent(),
  -- Plugin Telescope
  ["n|<Leader>fp"] = map_cu("lua require('telescope').extensions.project.project{}"):with_noremap():with_silent(),
  ["n|<Leader>fr"] = map_cu("lua require('telescope').extensions.frecency.frecency{}"):with_noremap():with_silent(),
  ["n|<Leader>fe"] = map_cu("DashboardFindHistory"):with_noremap():with_silent(),
  ["n|<Leader>ff"] = map_cu("DashboardFindFile"):with_noremap():with_silent(),
  ["n|<Leader>sc"] = map_cu("DashboardChangeColorscheme"):with_noremap():with_silent(),
  ["n|<Leader>fw"] = map_cu("DashboardFindWord"):with_noremap():with_silent(),
  ["n|<Leader>fn"] = map_cu("DashboardNewFile"):with_noremap():with_silent(),
  ["n|<Leader>fb"] = map_cu("Telescope file_browser"):with_noremap():with_silent(),
  ["n|<Leader>fg"] = map_cu("Telescope git_files"):with_noremap():with_silent(),
  ["n|<Leader>fz"] = map_cu("Telescope zoxide list"):with_noremap():with_silent(),
  -- Plugin EasyAlign
  ["n|ga"] = map_cmd("v:lua.enhance_align('nga')"):with_expr(),
  ["x|ga"] = map_cmd("v:lua.enhance_align('xga')"):with_expr(),
  -- Plugin SymbolsOutline
  ["n|so"] = map_cr("SymbolsOutlineOpen"):with_noremap():with_silent(),
  ["n|sc"] = map_cr("SymbolsOutlineClose"):with_noremap():with_silent(),
  -- Plugin split-term
  ["n|<F5>"] = map_cr("VTerm"):with_noremap():with_silent(),
  ["n|<C-w>t"] = map_cr("VTerm"):with_noremap():with_silent(),
  -- Plugin MarkdownPreview
  ["n|<F12>"] = map_cr("MarkdownPreviewToggle"):with_noremap():with_silent(),
  -- Plugin go.nvim
  ["n|<Leader>gof"] = map_cr('require("go.format").goimport()'):with_noremap():with_silent(),
}

bind.nvim_load_mapping(plug_map)
