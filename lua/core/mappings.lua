local k = require("keybind")

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

_G.enhance_ft_move = function(key)
  local map = {
    f = "<Plug>(eft-f)",
    F = "<Plug>(eft-F)",
    t = "<Plug>(eft-t)",
    T = "<Plug>(eft-T)",
    [";"] = "<Plug>(eft-repeat)",
  }
  return t(map[key])
end

_G.enhance_align = function(key)
  local map = { ["nga"] = "<Plug>(EasyAlign)", ["xga"] = "<Plug>(EasyAlign)" }
  return t(map[key])
end

local create_term = function(config)
  local ft = require("toggleterm.terminal").Terminal:new(config)
  ft:toggle()
end

_G.create_float_term = function()
  local config = {
    hidden = true,
    direction = "float",
    float_opts = {
      border = "double",
    },
    on_open = function(term)
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  }
  create_term(config)
end

_G.gitroot_project_files = function()
  local load_telescope = require("modules.editor.config").telescope
  load_telescope()
  local opts = {} -- define here if you want to define something
  vim.fn.system("git rev-parse --is-inside-work-tree")
  if vim.v.shell_error == 0 then
    require("telescope.builtin").git_files(opts)
  else
    require("telescope.builtin").find_files(opts)
  end
end

_G.gitroot_live_grep = function()
  local load_telescope = require("modules.editor.config").telescope
  load_telescope()
  local opts = { cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] }
  require("telescope.builtin").live_grep(opts)
end

_G.create_gitui = function()
  local config = {
    cmd = "gitui",
    hidden = true,
    direction = "float",
    float_opts = {
      border = "double",
    },
    on_open = function(term)
      vim.api.nvim_command([[startinsert!]])
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  }
  create_term(config)
end

-- default map
local def_map = {
  -- Vim map
  ["n|<C-x>"] = k.map_cr("lua require('bufdelete').delete_buffer()"):with_noremap():with_silent(),
  ["n|<Space>x"] = k.map_cr("lua require('bufdelete').delete_buffer()"):with_noremap():with_silent(),
  ["n|<C-s>"] = k.map_cu("write"):with_noremap(),
  ["n|Y"] = k.map_cmd("y$"),
  ["n|D"] = k.map_cmd("d$"),
  ["n|;"] = k.map_cmd(":"):with_noremap(),
  ["n|<C-h>"] = k.map_cmd("<C-w>h"):with_noremap(),
  ["n|<C-l>"] = k.map_cmd("<C-w>l"):with_noremap(),
  ["n|<C-j>"] = k.map_cmd("<C-w>j"):with_noremap(),
  ["n|<C-k>"] = k.map_cmd("<C-w>k"):with_noremap(),
  ["n|<LocalLeader>vs"] = k.map_cu("vsplit"):with_noremap():with_silent(),
  ["n|<LocalLeader>hs"] = k.map_cu("split"):with_noremap():with_silent(),
  ["n|<leader>vs"] = k.map_cmd(':vsplit <C-r>=expand("%:p:h")<cr>/'):with_noremap(),
  ["n|<leader>hs"] = k.map_cmd(':split <C-r>=expand("%:p:h")<cr>/'):with_noremap(),
  ["n|<leader>te"] = k.map_cmd(':tabedit <C-r>=expand("%:p:h")<cr>/'):with_noremap(),
  ["n|<LocalLeader>]"] = k.map_cr("vertical resize -10"):with_silent(),
  ["n|<LocalLeader>["] = k.map_cr("vertical resize +10"):with_silent(),
  ["n|<LocalLeader>-"] = k.map_cr("resize -4"):with_silent(),
  ["n|<LocalLeader>="] = k.map_cr("resize +4"):with_silent(),
  ["n|<leader>o"] = k.map_cr("setlocal spell! spelllang=en_us"),
  ["n|<leader>I"] = k.map_cmd(":set list!<cr>"):with_noremap(),
  ["n|\\"] = k.map_cmd(":let @/=''<CR>:noh<CR>"):with_noremap(),
  ["n|<leader>p"] = k.map_cmd(":%s///g<CR>"):with_noremap():with_silent(),
  ["n|<leader>i"] = k.map_cmd("gg=G<CR>"):with_noremap():with_silent(),
  ["n|<leader>l"] = k.map_cmd(":set list! list?<CR>"):with_noremap(),
  ["n|<leader>t"] = k.map_cmd(":%s/\\s\\+$//e<CR>"):with_noremap(),
  ["n|<LocalLeader>lcd"] = k.map_cmd(":lcd %:p:h<CR>"):with_noremap(),
  -- Insert
  ["i|jj"] = k.map_cmd("<Esc>"):with_noremap(),
  ["i|<C-u>"] = k.map_cmd("<C-G>u<C-U>"):with_noremap(),
  -- command line
  ["c|<C-t>"] = k.map_cmd([[<C-R>=expand("%:p:h") . "/" <CR>]]):with_noremap(),
  ["c|W!!"] = k.map_cmd("execute 'silent! write !sudo tee % >/dev/null' <bar> edit!"),
  -- Visual
  ["v|J"] = k.map_cmd(":m '>+1<cr>gv=gv"),
  ["v|K"] = k.map_cmd(":m '<-2<cr>gv=gv"),
  ["v|<"] = k.map_cmd("<gv"),
  ["v|>"] = k.map_cmd(">gv"),
}

local plug_map = {
  ["n|ft"] = k.map_cr("FormatToggle"):with_noremap():with_silent(),
  -- jupyter_ascending
  ["n|<LocalLeader><LocalLeader>x"] = k.map_cr(":call jupyter_ascending#execute()<CR>"),
  ["n|<LocalLeader><LocalLeader>X"] = k.map_cr(":call jupyter_ascending#execute_all()<CR>"),
  -- Bufferline
  ["n|<Space>l"] = k.map_cr("BufferLineCycleNext"):with_noremap():with_silent(),
  ["n|<Space>h"] = k.map_cr("BufferLineCyclePrev"):with_noremap():with_silent(),
  ["n|<Space>bp"] = k.map_cr("BufferLinePick"):with_noremap():with_silent(),
  ["n|<Space>bc"] = k.map_cr("BufferLinePickClose"):with_noremap():with_silent(),
  ["n|<LocalLeader>be"] = k.map_cr("BufferLineSortByExtension"):with_noremap(),
  ["n|<LocalLeader>bd"] = k.map_cr("BufferLineSortByDirectory"):with_noremap(),
  ["n|1gt"] = k.map_cr("BufferLineGoToBuffer 1"):with_noremap():with_silent(),
  ["n|2gt"] = k.map_cr("BufferLineGoToBuffer 2"):with_noremap():with_silent(),
  ["n|3gt"] = k.map_cr("BufferLineGoToBuffer 3"):with_noremap():with_silent(),
  ["n|4gt"] = k.map_cr("BufferLineGoToBuffer 4"):with_noremap():with_silent(),
  ["n|5gt"] = k.map_cr("BufferLineGoToBuffer 5"):with_noremap():with_silent(),
  ["n|6gt"] = k.map_cr("BufferLineGoToBuffer 6"):with_noremap():with_silent(),
  ["n|7gt"] = k.map_cr("BufferLineGoToBuffer 7"):with_noremap():with_silent(),
  ["n|8gt"] = k.map_cr("BufferLineGoToBuffer 8"):with_noremap():with_silent(),
  ["n|9gt"] = k.map_cr("BufferLineGoToBuffer 9"):with_noremap():with_silent(),
  -- Lazy
  ["n|<Space>ls"] = k.map_cr("Lazy sync"):with_noremap():with_silent(),
  ["n|<Space>lc"] = k.map_cr("Lazy clean"):with_noremap():with_silent(),
  ["n|<Space>lu"] = k.map_cr("Lazy update"):with_noremap():with_silent(),
  ["n|<Space>lcc"] = k.map_cr("Lazy check"):with_noremap():with_silent(),
  ["n|<Space>lh"] = k.map_cr("Lazy home"):with_noremap():with_silent(),
  -- Gitsigns
  ["n|<Space>wd"] = k.map_cr("Gitsigns toggle_word_diff"):with_noremap():with_silent(),
  ["n|<Space>ld"] = k.map_cr("Gitsigns toggle_deleted"):with_noremap():with_silent(),
  -- Copilot
  ["n|<LocalLeader>cp"] = k.map_cr("Copilot panel"):with_noremap():with_silent():with_nowait(),
  -- Lsp map work when insertenter and lsp start
  ["n|<LocalLeader>li"] = k.map_cr("LspInfo"):with_noremap():with_silent():with_nowait(),
  ["n|<LocalLeader>lr"] = k.map_cr("LspRestart"):with_noremap():with_silent():with_nowait(),
  ["n|g["] = k.map_cr("Lspsaga diagnostic_jump_next"):with_noremap():with_silent(),
  ["n|g]"] = k.map_cr("Lspsaga diagnostic_jump_prev"):with_noremap():with_silent(),
  ["n|gs"] = k.map_cr("lua vim.lsp.buf.signature_help()"):with_noremap():with_silent(),
  ["n|gr"] = k.map_cr("Lspsaga rename"):with_noremap():with_silent(),
  ["n|K"] = k.map_cr("Lspsaga hover_doc"):with_noremap():with_silent(),
  ["n|go"] = k.map_cr("Lspsaga outline"):with_noremap():with_silent(),
  ["n|<LocalLeader>ca"] = k.map_cr("Lspsaga code_action"):with_noremap():with_silent(),
  ["v|<LocalLeader>ca"] = k.map_cu("Lspsaga code_action"):with_noremap():with_silent(),
  ["n|gd"] = k.map_cr("Lspsaga peek_definition"):with_noremap():with_silent(),
  ["n|<LocalLeader>cd"] = k.map_cr("Lspsaga show_line_diagnostics"):with_noremap():with_silent(),
  ["n|<Leader>cd"] = k.map_cr("Lspsaga show_cursor_diagnostics"):with_noremap():with_silent(),
  ["n|gD"] = k.map_cr("Lspsaga goto_definition"):with_noremap():with_silent(),
  ["n|gh"] = k.map_cr("Lspsaga lsp_finder"):with_noremap():with_silent(),
  -- Plugin toggleterm
  ["n|<C-\\>"] = k.map_cr([[execute v:count . "ToggleTerm direction=horizontal"]]):with_noremap():with_silent(),
  ["i|<C-\\>"] = k.map_cmd("<Esc><Cmd>ToggleTerm direction=horizontal<CR>"):with_noremap():with_silent(),
  ["t|<C-\\>"] = k.map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_noremap():with_silent(),
  ["n|<C-w>t"] = k.map_cr([[execute v:count . "ToggleTerm direction=vertical"]]):with_noremap():with_silent(),
  ["i|<C-w>t"] = k.map_cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>"):with_noremap():with_silent(),
  ["t|<C-w>t"] = k.map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_noremap():with_silent(),
  ["n|<F7>"] = k.map_cu("lua create_gitui()"):with_noremap():with_silent(),
  ["n|<F8>"] = k.map_cu("lua create_float_term()"):with_noremap():with_silent(),
  ["n|<LocalLeader>g"] = k.map_cu("Git"):with_noremap():with_silent(),
  ["n|gps"] = k.map_cr("G push"):with_noremap():with_silent(),
  ["n|gpl"] = k.map_cr("G pull"):with_noremap():with_silent(),
  -- Plugin nvim-tree
  ["n|<C-n>"] = k.map_cr("NvimTreeToggle"):with_noremap():with_silent(),
  ["n|<LocalLeader>nf"] = k.map_cr("NvimTreeFindFile"):with_noremap():with_silent(),
  ["n|<Leader>nr"] = k.map_cr("NvimTreeRefresh"):with_noremap():with_silent(),
  -- Plugin octo
  ["n|<LocalLeader>ocpr"] = k.map_cr("Octo pr list"):with_noremap(),
  -- Plugin trouble
  ["n|gt"] = k.map_cr("TroubleToggle"):with_noremap():with_silent(),
  ["n|gR"] = k.map_cr("TroubleToggle lsp_references"):with_noremap():with_silent(),
  ["n|<LocalLeader>dd"] = k.map_cr("TroubleToggle document_diagnostics"):with_noremap():with_silent(),
  ["n|<LocalLeader>wd"] = k.map_cr("TroubleToggle workspace_diagnostics"):with_noremap():with_silent(),
  ["n|<LocalLeader>qf"] = k.map_cr("TroubleToggle quickfix"):with_noremap():with_silent(),
  ["n|<LocalLeader>ll"] = k.map_cr("TroubleToggle loclist"):with_noremap():with_silent(),
  -- Plugin vim-eft
  ["n|f"] = k.map_cmd("v:lua.enhance_ft_move('f')"):with_expr(),
  ["n|F"] = k.map_cmd("v:lua.enhance_ft_move('F')"):with_expr(),
  ["n|t"] = k.map_cmd("v:lua.enhance_ft_move('t')"):with_expr(),
  ["n|T"] = k.map_cmd("v:lua.enhance_ft_move('T')"):with_expr(),
  -- Plugin Telescope
  ["n|fo"] = k.map_cmd("<cmd> Telescope oldfiles<CR>"):with_noremap():with_silent(),
  ["n|fr"] = k.map_cmd("<cmd> Telescope frecency<CR>"):with_noremap():with_silent(),
  ["n|ff"] = k.map_cmd("<cmd> Telescope find_files<CR>"):with_noremap():with_silent(),
  ["n|fb"] = k.map_cmd("<cmd> Telescope buffers<CR>"):with_noremap():with_silent(),
  ["n|<LocalLeader>ff"] = k.map_cu("lua gitroot_project_files()"):with_noremap():with_silent(),
  ["n|fw"] = k.map_cmd("<cmd> Telescope live_grep <CR>"):with_noremap():with_silent(),
  ["n|<LocalLeader>fw"] = k.map_cu("lua gitroot_live_grep()"):with_noremap():with_silent(),
  ["n|<LocalLeader>fn"] = k.map_cu("enew"):with_noremap():with_silent(),
  ["n|<LocalLeader>km"] = k.map_cmd("<cmd> Telescope keymaps<CR>"):with_noremap():with_silent(),
  -- Plugin spectre
  ["n|<S-F6>"] = k.map_cr("lua require('spectre').open()"):with_noremap():with_silent(),
  ["n|<Leader>sw"] = k.map_cr("lua require('spectre').open_visual({select_word=true})"):with_noremap():with_silent(),
  ["n|<Leader>s"] = k.map_cr("lua require('spectre').open_visual()"):with_noremap():with_silent(),
  ["n|<Leader>sp"] = k.map_cr("lua require('spectre').open_file_search({select_word=true})")
    :with_noremap()
    :with_silent(),
  -- Plugin Hop
  ["n|<LocalLeader>w"] = k.map_cu("HopWord"):with_noremap(),
  ["n|<LocalLeader>j"] = k.map_cu("HopLine"):with_noremap(),
  ["n|<LocalLeader>k"] = k.map_cu("HopLine"):with_noremap(),
  ["n|<LocalLeader>c"] = k.map_cu("HopChar1"):with_noremap(),
  ["n|<LocalLeader>cc"] = k.map_cu("HopChar2"):with_noremap(),
  -- Plugin EasyAlign
  ["n|ga"] = k.map_cmd("v:lua.enhance_align('nga')"):with_expr(),
  ["x|ga"] = k.map_cmd("v:lua.enhance_align('xga')"):with_expr(),
  -- Plugin MarkdownPreview
  ["n|mpt"] = k.map_cr("MarkdownPreviewToggle"):with_noremap():with_silent(),
  -- Plugin zen-mode
  ["n|zm"] = k.map_cu('lua require("zen-mode").toggle({window = { width = .65 }})'):with_noremap():with_silent(),
  -- refactoring
  ["v|<LocalLeader>re"] = k.map_cr("lua require('refactoring').refactor('Extract Function')")
    :with_noremap()
    :with_silent(),
  ["v|<LocalLeader>rf"] = k.map_cr("lua require('refactoring').refactor('Extract Function To File')")
    :with_noremap()
    :with_silent(),
  ["v|<LocalLeader>rv"] = k.map_cr("lua require('refactoring').refactor('Extract Variable')")
    :with_noremap()
    :with_silent(),
  ["v|<LocalLeader>ri"] = k.map_cr("lua require('refactoring').refactor('Inline Variable')")
    :with_noremap()
    :with_silent(),
  ["n|<LocalLeader>rb"] = k.map_cr("lua require('refactoring').refactor('Extract Block')"):with_noremap():with_silent(),
  ["n|<LocalLeader>rbf"] = k.map_cr("lua require('refactoring').refactor('Extract Block To File')")
    :with_noremap()
    :with_silent(),
  ["n|<LocalLeader>ri"] = k.map_cr("lua require('refactoring').refactor('Inline Variable')")
    :with_noremap()
    :with_silent(),
}

k.nvim_load_mapping(def_map)
k.nvim_load_mapping(plug_map)
