local k = require("keybind")

-- a local reference for ToggleTerm
local _lazygit = nil

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

-- default map
local def_map = {
  ["n|<C-s>"] = k.map_cu("write"):with_noremap(),
  ["n|Y"] = k.map_cmd("y$"),
  ["n|D"] = k.map_cmd("d$"),
  ["n|;"] = k.map_cmd(":"):with_noremap(),
  ["n|<C-h>"] = k.map_cmd("<C-w>h"):with_noremap(),
  ["n|<C-l>"] = k.map_cmd("<C-w>l"):with_noremap(),
  ["n|<C-j>"] = k.map_cmd("<C-w>j"):with_noremap(),
  ["n|<C-k>"] = k.map_cmd("<C-w>k"):with_noremap(),
  ["n|<LocalLeader>vs"] = k.map_cu("vsplit"):with_defaults(),
  ["n|<LocalLeader>hs"] = k.map_cu("split"):with_defaults(),
  ["n|<leader>vs"] = k.map_cr('vsplit <C-r>=expand("%:p:h")'):with_noremap(),
  ["n|<leader>hs"] = k.map_cr('split <C-r>=expand("%:p:h")'):with_noremap(),
  ["n|<leader>te"] = k.map_cr('tabedit <C-r>=expand("%:p:h")'):with_noremap(),
  ["n|<LocalLeader>]"] = k.map_cr("vertical resize -10"):with_silent(),
  ["n|<LocalLeader>["] = k.map_cr("vertical resize +10"):with_silent(),
  ["n|<LocalLeader>-"] = k.map_cr("resize -4"):with_silent(),
  ["n|<LocalLeader>="] = k.map_cr("resize +4"):with_silent(),
  ["n|<leader>o"] = k.map_cr("setlocal spell! spelllang=en_us"),
  ["n|<leader>I"] = k.map_cmd(":set list!<CR>"):with_noremap(),
  ["n|\\"] = k.map_cmd(":let @/=''<CR>:noh<CR>"):with_noremap(),
  ["n|<leader>p"] = k.map_cmd(":%s///g<CR>"):with_defaults(),
  ["n|<leader>i"] = k.map_cmd("gg=G<CR>"):with_defaults(),
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
  ["v|J"] = k.map_cmd(":m '>+1<CR>gv=gv"),
  ["v|K"] = k.map_cmd(":m '<-2<CR>gv=gv"),
  ["v|<"] = k.map_cmd("<gv"),
  ["v|>"] = k.map_cmd(">gv"),
}

local plug_map = {
  ["n|ft"] = k.map_cr("FormatToggle"):with_defaults(),
  -- jupyter_ascending
  ["n|<LocalLeader><LocalLeader>x"] = k.map_cr(":call jupyter_ascending#execute()<CR>"),
  ["n|<LocalLeader><LocalLeader>X"] = k.map_cr(":call jupyter_ascending#execute_all()<CR>"),
  -- ojroques/nvim-bufdel
  ["n|<C-x>"] = k.map_cr("BufDel"):with_defaults(),
  ["n|<Space>x"] = k.map_cr("BufDel"):with_defaults(),
  -- Bufferline
  ["n|<Space>l"] = k.map_cr("BufferLineCycleNext"):with_defaults(),
  ["n|<Space>h"] = k.map_cr("BufferLineCyclePrev"):with_defaults(),
  ["n|<Space>bp"] = k.map_cr("BufferLinePick"):with_defaults(),
  ["n|<Space>bc"] = k.map_cr("BufferLinePickClose"):with_defaults(),
  ["n|<Space>be"] = k.map_cr("BufferLineSortByExtension"):with_noremap(),
  ["n|<Space>bd"] = k.map_cr("BufferLineSortByDirectory"):with_noremap(),
  -- Lazy
  ["n|<Space>ls"] = k.map_cr("Lazy sync"):with_defaults(),
  ["n|<Space>lc"] = k.map_cr("Lazy clean"):with_defaults(),
  ["n|<Space>lu"] = k.map_cr("Lazy update"):with_defaults(),
  ["n|<Space>lcc"] = k.map_cr("Lazy check"):with_defaults(),
  ["n|<Space>lh"] = k.map_cr("Lazy home"):with_defaults(),
  -- Gitsigns
  ["n|<Space>wd"] = k.map_cr("Gitsigns toggle_word_diff"):with_defaults(),
  ["n|<Space>ld"] = k.map_cr("Gitsigns toggle_deleted"):with_defaults(),
  -- Copilot
  ["n|<LocalLeader>cp"] = k.map_cr("Copilot panel"):with_defaults():with_nowait(),
  -- Lsp map work when insertenter and lsp start
  ["n|<LocalLeader>li"] = k.map_cr("LspInfo"):with_defaults():with_nowait(),
  ["n|<LocalLeader>lr"] = k.map_cr("LspRestart"):with_defaults():with_nowait(),
  ["n|g["] = k.map_cr("Lspsaga diagnostic_jump_next"):with_defaults(),
  ["n|g]"] = k.map_cr("Lspsaga diagnostic_jump_prev"):with_defaults(),
  ["n|gs"] = k.map_callback(function()
    vim.lsp.buf.signature_help()
  end):with_defaults(),
  ["n|gr"] = k.map_cr("Lspsaga rename"):with_defaults(),
  ["n|K"] = k.map_cr("Lspsaga hover_doc"):with_defaults(),
  ["n|go"] = k.map_cr("Lspsaga outline"):with_defaults(),
  ["n|<LocalLeader>ca"] = k.map_cr("Lspsaga code_action"):with_defaults(),
  ["v|<LocalLeader>ca"] = k.map_cu("Lspsaga code_action"):with_defaults(),
  ["n|gd"] = k.map_cr("Lspsaga peek_definition"):with_defaults(),
  ["n|<LocalLeader>cd"] = k.map_cr("Lspsaga show_line_diagnostics"):with_defaults(),
  ["n|<Leader>cd"] = k.map_cr("Lspsaga show_cursor_diagnostics"):with_defaults(),
  ["n|gD"] = k.map_cr("Lspsaga goto_definition"):with_defaults(),
  ["n|gh"] = k.map_cr("Lspsaga lsp_finder"):with_defaults(),
  -- Plugin toggleterm
  ["n|<C-\\>"] = k.map_cr([[execute v:count . "ToggleTerm direction=horizontal"]]):with_defaults(),
  ["i|<C-\\>"] = k.map_cmd("<Esc><Cmd>ToggleTerm direction=horizontal<CR>"):with_defaults(),
  ["t|<C-\\>"] = k.map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_defaults(),
  ["n|<C-w>t"] = k.map_cr([[execute v:count . "ToggleTerm direction=vertical"]]):with_defaults(),
  ["i|<C-w>t"] = k.map_cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>"):with_defaults(),
  ["t|<C-w>t"] = k.map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_defaults(),
  ["n|<S-F7>"] = k.map_callback(function()
    if not _lazygit then
      local config = {
        cmd = require("utils").get_binary_path("lazygit"),
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
      _lazygit = require("toggleterm.terminal").Terminal:new(config)
    end
    _lazygit:toggle()
  end):with_defaults(),
  ["n|<LocalLeader>gg"] = k.map_cu("Git"):with_defaults(),
  -- Plugin tpope/vim-fugitive
  ["n|<LocalLeader>gaa"] = k.map_cr("G add ."):with_defaults(),
  ["n|<LocalLeader>gcm"] = k.map_cr("G commit"):with_defaults(),
  ["n|<LocalLeader>gps"] = k.map_cr("G push"):with_defaults(),
  ["n|<LocalLeader>gpl"] = k.map_cr("G pull"):with_defaults(),
  -- Plugin nvim-tree
  ["n|<C-n>"] = k.map_cr("NvimTreeToggle"):with_defaults(),
  ["n|<LocalLeader>nf"] = k.map_cr("NvimTreeFindFile"):with_defaults(),
  ["n|<Leader>nr"] = k.map_cr("NvimTreeRefresh"):with_defaults(),
  -- Plugin octo
  ["n|<LocalLeader>ocpr"] = k.map_cr("Octo pr list"):with_noremap(),
  -- Plugin trouble
  ["n|gt"] = k.map_cr("TroubleToggle"):with_defaults(),
  ["n|gR"] = k.map_cr("TroubleToggle lsp_references"):with_defaults(),
  ["n|<LocalLeader>dd"] = k.map_cr("TroubleToggle document_diagnostics"):with_defaults(),
  ["n|<LocalLeader>wd"] = k.map_cr("TroubleToggle workspace_diagnostics"):with_defaults(),
  ["n|<LocalLeader>qf"] = k.map_cr("TroubleToggle quickfix"):with_defaults(),
  ["n|<LocalLeader>ll"] = k.map_cr("TroubleToggle loclist"):with_defaults(),
  -- Plugin Telescope
  ["n|fo"] = k.map_cmd("<cmd> Telescope oldfiles<CR>"):with_defaults(),
  ["n|fr"] = k.map_cmd("<cmd> Telescope frecency<CR>"):with_defaults(),
  ["n|fb"] = k.map_cmd("<cmd> Telescope buffers<CR>"):with_defaults(),
  ["n|ff"] = k.map_cmd("<cmd> Telescope find_files<CR>"):with_defaults(),
  ["n|fkm"] = k.map_cr("<cmd> Telescope keymaps<CR>"):with_defaults(),
  ["n|fp"] = k.map_callback(function()
    require("telescope").extensions.projects.projects({})
  end):with_defaults(),
  ["n|<LocalLeader>ff"] = k.map_callback(function()
    require("modules.configs.editor.nvim-telescope")()
    local opts = { -- define here if you want to pass options to git_files or find_files
      git_files = {},
      find_files = {},
    }
    vim.fn.system("git rev-parse --is-inside-work-tree")
    if vim.v.shell_error == 0 then
      require("telescope.builtin").git_files(opts.git_files)
    else
      require("telescope.builtin").find_files(opts.find_files)
    end
  end):with_defaults(),
  ["n|fw"] = k.map_cmd("<cmd> Telescope live_grep <CR>"):with_defaults(),
  ["n|<LocalLeader>fw"] = k.map_callback(function()
    require("telescope").extensions.live_grep_args.live_grep_args({})
  end):with_defaults(),
  ["n|<LocalLeader>fu"] = k.map_callback(function()
    require("telescope").extensions.undo.undo()
  end):with_defaults(),
  ["n|<LocalLeader>fn"] = k.map_cu("enew"):with_defaults(),
  -- Plugin cheatsheet
  ["n|<LocalLeader>km"] = k.map_cr("Cheatsheet"):with_defaults(),
  -- Plugin spectre
  ["n|<Leader>so"] = k.map_callback(function()
    require("spectre").open()
  end):with_defaults(),
  ["n|<Leader>s"] = k.map_callback(function()
    require("spectre").open_visual()
  end):with_defaults(),
  ["n|<Leader>sw"] = k.map_callback(function()
    require("spectre").open_visual({ select_word = true })
  end):with_defaults(),
  ["n|<Leader>sp"] = k.map_callback(function()
    require("spectre").open_file_search({ select_word = true })
  end):with_defaults(),
  -- Plugin Hop
  ["n|<LocalLeader>w"] = k.map_cu("HopWord"):with_noremap(),
  ["n|<LocalLeader>j"] = k.map_cu("HopLine"):with_noremap(),
  ["n|<LocalLeader>k"] = k.map_cu("HopLine"):with_noremap(),
  ["n|<LocalLeader>c"] = k.map_cu("HopChar1"):with_noremap(),
  ["n|<LocalLeader>cc"] = k.map_cu("HopChar2"):with_noremap(),
  -- Plugin EasyAlign
  ["n|ga"] = k.map_cmd("v:lua.enhance_align('nga')"):with_expr(),
  ["x|ga"] = k.map_cmd("v:lua.enhance_align('xga')"):with_expr(),
  -- Plugin vim-eft
  ["n|f"] = k.map_cmd("v:lua.enhance_ft_move('f')"):with_expr(),
  ["n|F"] = k.map_cmd("v:lua.enhance_ft_move('F')"):with_expr(),
  ["n|t"] = k.map_cmd("v:lua.enhance_ft_move('t')"):with_expr(),
  ["n|T"] = k.map_cmd("v:lua.enhance_ft_move('T')"):with_expr(),
  -- Plugin MarkdownPreview
  ["n|mpt"] = k.map_cr("MarkdownPreviewToggle"):with_defaults(),
  -- Plugin zen-mode
  ["n|zm"] = k.map_callback(function()
    require("zen-mode").toggle({ window = { width = 0.75 } })
  end):with_defaults(),
  -- Plugin refactoring
  ["v|<LocalLeader>re"] = k.map_callback(function()
    require("refactoring").refactor("Extract Function")
  end):with_defaults(),
  ["v|<LocalLeader>rf"] = k.map_callback(function()
    require("refactoring").refactor("Extract Function To File")
  end):with_defaults(),
  ["v|<LocalLeader>rv"] = k.map_callback(function()
    require("refactoring").refactor("Extract Variable")
  end):with_defaults(),
  ["v|<LocalLeader>ri"] = k.map_callback(function()
    require("refactoring").refactor("Inline Variable")
  end):with_defaults(),
  ["n|<LocalLeader>rb"] = k.map_callback(function()
    require("refactoring").refactor("Extract Block")
  end):with_defaults(),
  ["n|<LocalLeader>rbf"] = k.map_callback(function()
    require("refactoring").refactor("Extract Block To File")
  end):with_defaults(),
  ["n|<LocalLeader>ri"] = k.map_callback(function()
    require("refactoring").refactor("Inline Variable")
  end):with_defaults(),
  -- Plugin dap
  ["n|<F6>"] = k.map_callback(function()
    require("dap").continue()
  end):with_defaults(),
  ["n|<F7>"] = k.map_callback(function()
    require("dap").terminate()
    require("dapui").close()
  end):with_defaults(),
  ["n|<F8>"] = k.map_callback(function()
    require("dap").toggle_breakpoint()
  end):with_defaults(),
  ["n|<F9>"] = k.map_callback(function()
    require("dap").step_into()
  end):with_defaults(),
  ["n|<F10>"] = k.map_callback(function()
    require("dap").step_out()
  end):with_defaults(),
  ["n|<F11>"] = k.map_callback(function()
    require("dap").step_over()
  end):with_defaults(),
  ["n|<leader>db"] = k.map_callback(function()
    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end):with_defaults(),
  ["n|<leader>dc"] = k.map_callback(function()
    require("dap").run_to_cursor()
  end):with_defaults(),
  ["n|<leader>dl"] = k.map_callback(function()
    require("dap").run_last()
  end):with_defaults(),
  ["n|<leader>do"] = k.map_callback(function()
    require("dap").repl.open()
  end):with_defaults(),
  ["o|m"] = k.map_callback(function()
    require("tsht").nodes()
  end):with_silent(),
  -- Plugin Legendary
  ["n|<C-p>"] = k.map_cr("Legendary"):with_defaults(),
}

k.nvim_load_mapping(def_map)
k.nvim_load_mapping(plug_map)
