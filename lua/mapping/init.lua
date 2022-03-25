local nvim_load_mapping = _G.__lazy.require_on_exported_call("mapping.bind").nvim_load_mapping
local map_cr = _G.__lazy.require_on_exported_call("mapping.bind").map_cr
local map_cu = _G.__lazy.require_on_exported_call("mapping.bind").map_cu
local map_cmd = _G.__lazy.require_on_exported_call("mapping.bind").map_cmd

require("mapping.config")

local M = {}

function M.setup_mapping()
  -- default map
  local def_map = {
    -- Vim map
    ["n|<C-x>k"] = map_cr("bdelete"):with_noremap():with_silent(),
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
    ["n|<Leader>rl"] = map_cu("lua require('core.utils').reload()"):with_noremap():with_silent(),
    ["n|<Leader>er"] = map_cu("lua require('core.utils').edit_root()"):with_noremap():with_silent(),
    ["n|<Leader>ec"] = map_cu(":e ~/.editor.lua"):with_noremap():with_silent(),
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
    ["n|1gt"] = map_cr("BufferLineGoToBuffer 1"):with_noremap():with_silent(),
    ["n|2gt"] = map_cr("BufferLineGoToBuffer 2"):with_noremap():with_silent(),
    ["n|3gt"] = map_cr("BufferLineGoToBuffer 3"):with_noremap():with_silent(),
    ["n|4gt"] = map_cr("BufferLineGoToBuffer 4"):with_noremap():with_silent(),
    ["n|5gt"] = map_cr("BufferLineGoToBuffer 5"):with_noremap():with_silent(),
    ["n|6gt"] = map_cr("BufferLineGoToBuffer 6"):with_noremap():with_silent(),
    ["n|7gt"] = map_cr("BufferLineGoToBuffer 7"):with_noremap():with_silent(),
    ["n|8gt"] = map_cr("BufferLineGoToBuffer 8"):with_noremap():with_silent(),
    ["n|9gt"] = map_cr("BufferLineGoToBuffer 9"):with_noremap():with_silent(),
    -- minimap
    ["n|mm"] = map_cr("MinimapToggle"):with_noremap():with_silent(),
    ["n|mr"] = map_cr("MinimapRefresh"):with_noremap():with_silent(),
    -- Packer
    ["n|<Space>ps"] = map_cr("PackerSync"):with_silent():with_noremap():with_nowait(),
    ["n|<Space>pu"] = map_cr("PackerUpdate"):with_silent():with_noremap():with_nowait(),
    ["n|<Space>pi"] = map_cr("PackerInstall"):with_silent():with_noremap():with_nowait(),
    ["n|<Space>pc"] = map_cr("PackerCompile"):with_silent():with_noremap():with_nowait(),
    ["n|<Space>pcc"] = map_cr("PackerClean"):with_silent():with_noremap():with_nowait(),
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
    ["n|ft"] = map_cu('lua require("FTerm").toggle()'):with_noremap():with_silent(),
    ["t|ft"] = map_cu([[<C-\><C-n><CMD>lua require("FTerm").toggle()]]):with_noremap():with_silent(),
    ["t|fc"] = map_cu([[<C-\><C-n><CMD>lua require("FTerm").exit()]]):with_noremap():with_silent(),
    ["n|<F5>"] = map_cu("lua require('core.utils').gitui()"):with_noremap():with_silent(),
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
    ["n|<Leader>fp"] = map_cu("lua require('telescope').extensions.project.project{}"):with_noremap():with_silent(),
    ["n|<Leader>fr"] = map_cu("lua require('telescope').extensions.frecency.frecency{}"):with_noremap():with_silent(),
    ["n|<Leader>fe"] = map_cu("DashboardFindHistory"):with_noremap():with_silent(),
    ["n|<Leader>ff"] = map_cu("DashboardFindFile"):with_noremap():with_silent(),
    ["n|<Leader>sc"] = map_cu("DashboardChangeColorscheme"):with_noremap():with_silent(),
    ["n|<Leader>fw"] = map_cu("DashboardFindWord"):with_noremap():with_silent(),
    ["n|<Leader>fn"] = map_cu("DashboardNewFile"):with_noremap():with_silent(),
    ["n|<Leader>fb"] = map_cu("Telescope file_browser"):with_noremap():with_silent(),
    ["n|<Leader>fg"] = map_cu("Telescope git_files"):with_noremap():with_silent(),
    ["n|<Leader>ft"] = map_cu("Telescope live_grep"):with_noremap():with_silent(),
    ["n|<Leader>fz"] = map_cu("Telescope zoxide list"):with_noremap():with_silent(),
    ["n|<Leader>km"] = map_cu("Telescope keymaps"):with_noremap():with_silent(),
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
    ["n|<F6>"] = map_cr("lua require('dap').continue()"):with_noremap():with_silent(),
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
  }

  nvim_load_mapping(def_map)
  nvim_load_mapping(plug_map)
end

return M
