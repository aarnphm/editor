local k = require("keybind")
-- a local reference for ToggleTerm
local _lazygit = nil

local mapping = {
  -- Insert
  ["i|<C-u>"] = k.map_cmd("<C-G>u<C-U>"):with_noremap(),
  -- command line
  ["c|<C-t>"] = k.map_cmd([[<C-R>=expand("%:p:h") . "/" <CR>]]):with_noremap(),
  ["c|W!!"] = k.map_cmd("execute 'silent! write !sudo tee % >/dev/null' <bar> edit!"),
  -- Visual
  ["v|J"] = k.map_cmd(":m '>+1<CR>gv=gv"),
  ["v|K"] = k.map_cmd(":m '<-2<CR>gv=gv"),
  ["v|<"] = k.map_cmd("<gv"),
  ["v|>"] = k.map_cmd(">gv"),
  ["n|<C-s>"] = k.map_cu("write"):with_noremap(),
  -- yank to end of line
  ["n|Y"] = k.map_cmd("y$"),
  ["n|D"] = k.map_cmd("d$"),
  -- remap command key to ;
  ["n|;"] = k.map_cmd(":"):with_noremap(),
  ["n|<C-h>"] = k.map_cmd("<C-w>h"):with_noremap(),
  ["n|<C-l>"] = k.map_cmd("<C-w>l"):with_noremap(),
  ["n|<C-j>"] = k.map_cmd("<C-w>j"):with_noremap(),
  ["n|<C-k>"] = k.map_cmd("<C-w>k"):with_noremap(),
  ["n|\\"] = k.map_cmd(":let @/=''<CR>:noh<CR>"):with_noremap(),
  ["n|<LocalLeader>]"] = k.map_cr("vertical resize -10"):with_silent(),
  ["n|<LocalLeader>["] = k.map_cr("vertical resize +10"):with_silent(),
  ["n|<LocalLeader>-"] = k.map_cr("resize -5"):with_silent(),
  ["n|<LocalLeader>="] = k.map_cr("resize +5"):with_silent(),
  ["n|<LocalLeader>lcd"] = k.map_cmd(":lcd %:p:h<CR>"):with_noremap(),
  ["n|<LocalLeader>vs"] = k.map_cu("vsplit"):with_defaults(),
  ["n|<LocalLeader>hs"] = k.map_cu("split"):with_defaults(),
  ["n|<Leader>o"] = k.map_cr("setlocal spell! spelllang=en_us"),
  ["n|<Leader>I"] = k.map_cmd(":set list!<CR>"):with_noremap(),
  ["n|<Leader>p"] = k.map_cmd(":%s///g<CR>"):with_defaults(),
  ["n|<Leader>i"] = k.map_cmd("gg=G<CR>"):with_defaults(),
  ["n|<Leader>l"] = k.map_cmd(":set list! list?<CR>"):with_noremap(),
  ["n|<Leader>t"] = k.map_cmd(":%s/\\s\\+$//e<CR>"):with_noremap(),

  -- Start mapping for plugins
  ["n|ft"] = k.map_cr("FormatToggle"):with_defaults(),
  -- jupyter_ascending
  ["n|<LocalLeader><LocalLeader>x"] = k.map_cr(":call jupyter_ascending#execute()<CR>")
    :with_desc("jupyter_ascending: Execute notebook shell"),
  ["n|<LocalLeader><LocalLeader>X"] = k.map_cr(":call jupyter_ascending#execute_all()<CR>")
    :with_desc("jupyter_ascending: Exceute all notebook shells"),
  -- ojroques/nvim-bufdel
  ["n|<C-x>"] = k.map_cr("BufDel"):with_defaults():with_desc("bufdel: Delete current buffer"),
  -- Bufferline
  ["n|<Space>bp"] = k.map_cr("BufferLinePick"):with_defaults(),
  ["n|<Space>bc"] = k.map_cr("BufferLinePickClose"):with_defaults(),
  ["n|<Space>be"] = k.map_cr("BufferLineSortByExtension"):with_noremap(),
  ["n|<Space>bd"] = k.map_cr("BufferLineSortByDirectory"):with_noremap(),
  ["n|<Space>."] = k.map_cr("BufferLineCycleNext"):with_defaults():with_desc("buffer: Cycle to next buffer"),
  ["n|<Space>n"] = k.map_cr("BufferLineCyclePrev"):with_defaults():with_desc("buffer: Cycle to previous buffer"),
  -- Lazy
  ["n|<Space>ps"] = k.map_cr("Lazy sync"):with_defaults(),
  ["n|<Space>pc"] = k.map_cr("Lazy clean"):with_defaults(),
  ["n|<Space>pu"] = k.map_cr("Lazy update"):with_defaults(),
  ["n|<Space>pcc"] = k.map_cr("Lazy check"):with_defaults(),
  ["n|<Space>ph"] = k.map_cr("Lazy home"):with_defaults(),
  -- Copilot
  ["n|<LocalLeader>cp"] = k.map_cr("Copilot panel"):with_defaults():with_nowait(),
  -- Lsp mapping (lspsaga, nvim-lspconfig, nvim-lsp, mason-lspconfig)
  ["n|<LocalLeader>li"] = k.map_cr("LspInfo"):with_defaults():with_nowait(),
  ["n|<LocalLeader>lr"] = k.map_cr("LspRestart"):with_defaults():with_nowait(),
  ["n|g["] = k.map_cr("Lspsaga diagnostic_jump_next"):with_defaults(),
  ["n|g]"] = k.map_cr("Lspsaga diagnostic_jump_prev"):with_defaults(),
  ["n|gs"] = k.map_callback(vim.lsp.buf.signature_help):with_defaults():with_desc("lsp: Signature help"),
  ["n|gr"] = k.map_cr("Lspsaga rename"):with_defaults(),
  ["n|K"] = k.map_cr("Lspsaga hover_doc"):with_defaults(),
  ["n|go"] = k.map_cr("Lspsaga outline"):with_defaults(),
  ["n|ga"] = k.map_cr("Lspsaga code_action"):with_defaults(),
  ["v|ga"] = k.map_cu("Lspsaga code_action"):with_defaults(),
  ["n|gd"] = k.map_cr("Lspsaga peek_definition"):with_defaults(),
  ["n|gD"] = k.map_cr("Lspsaga goto_definition"):with_defaults(),
  ["n|gh"] = k.map_cr("Lspsaga lsp_finder"):with_defaults(),
  ["n|<LocalLeader>sl"] = k.map_cr("Lspsaga show_line_diagnostics"):with_defaults(),
  ["n|<LocalLeader>sc"] = k.map_cr("Lspsaga show_cursor_diagnostics"):with_defaults(),
  ["n|<LocalLeader>ci"] = k.map_cr("Lspsaga incoming_calls"):with_noremap():with_silent(),
  ["n|<LocalLeader>co"] = k.map_cr("Lspsaga outgoing_calls"):with_noremap():with_silent(),
  -- toggleterm
  ["n|<C-\\>"] = k.map_cr([[execute v:count . "ToggleTerm direction=horizontal"]]):with_defaults(),
  ["i|<C-\\>"] = k.map_cmd("<Esc><Cmd>ToggleTerm direction=horizontal<CR>"):with_defaults(),
  ["t|<C-\\>"] = k.map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_defaults(),
  ["n|<C-w>t"] = k.map_cr([[execute v:count . "ToggleTerm direction=vertical"]]):with_defaults(),
  ["i|<C-w>t"] = k.map_cmd("<Esc><Cmd>ToggleTerm direction=vertical<CR>"):with_defaults(),
  ["t|<C-w>t"] = k.map_cmd("<Esc><Cmd>ToggleTerm<CR>"):with_defaults(),
  ["n|slg"] = k.map_callback(function()
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
  -- tpope/vim-fugitive
  ["n|<LocalLeader>G"] = k.map_cr("G"):with_defaults(),
  ["n|<LocalLeader>gaa"] = k.map_cr("G add ."):with_defaults(),
  ["n|<LocalLeader>gcm"] = k.map_cr("G commit"):with_defaults(),
  ["n|<LocalLeader>gps"] = k.map_cr("G push"):with_defaults(),
  ["n|<LocalLeader>gpl"] = k.map_cr("G pull"):with_defaults(),
  -- nvim-tree
  ["n|<C-n>"] = k.map_cr("NvimTreeToggle"):with_defaults(),
  ["n|<Leader>nf"] = k.map_cr("NvimTreeFindFile"):with_defaults(),
  ["n|<Leader>nr"] = k.map_cr("NvimTreeRefresh"):with_defaults(),
  -- octo
  ["n|<LocalLeader>ocpr"] = k.map_cr("Octo pr list"):with_noremap(),
  -- trouble
  ["n|gt"] = k.map_cr("TroubleToggle"):with_defaults(),
  ["n|<LocalLeader>tr"] = k.map_cr("TroubleToggle lsp_references"):with_defaults(),
  ["n|<LocalLeader>td"] = k.map_cr("TroubleToggle document_diagnostics"):with_defaults(),
  ["n|<LocalLeader>tw"] = k.map_cr("TroubleToggle workspace_diagnostics"):with_defaults(),
  ["n|<LocalLeader>tq"] = k.map_cr("TroubleToggle quickfix"):with_defaults(),
  ["n|<LocalLeader>tl"] = k.map_cr("TroubleToggle loclist"):with_defaults(),
  -- Telescope
  ["n|fo"] = k.map_cu("Telescope oldfiles"):with_defaults(),
  ["n|fr"] = k.map_cu("Telescope frecency"):with_defaults(),
  ["n|fb"] = k.map_cu("Telescope buffers"):with_defaults(),
  ["n|ff"] = k.map_cu("Telescope find_files"):with_defaults(),
  ["n|fz"] = k.map_cu("Telescope zoxide list"):with_defaults(),
  ["n|fw"] = k.map_cu("Telescope live_grep"):with_defaults(),
  ["n|<LocalLeader>ff"] = k.map_cu("Telescope git_files"):with_defaults(),
  ["n|fp"] = k.map_callback(function()
    require("telescope").extensions.projects.projects({})
  end):with_defaults(),
  ["n|<LocalLeader>fw"] = k.map_callback(function()
    require("telescope").extensions.live_grep_args.live_grep_args({})
  end):with_defaults(),
  ["n|<LocalLeader>fu"] = k.map_callback(function()
    require("telescope").extensions.undo.undo()
  end):with_defaults(),
  ["n|<LocalLeader>fn"] = k.map_cu("enew"):with_defaults(),
  -- cheatsheet
  ["n|<LocalLeader>km"] = k.map_cr("Cheatsheet"):with_defaults(),
  -- Plugin SnipRun
  ["v|<Leader>r"] = k.map_cr("SnipRun"):with_defaults(),
  ["n|<Leader>r"] = k.map_cu([[%SnipRun]]):with_defaults(),
  -- spectre
  ["n|<Leader>s"] = k.map_callback(function()
    require("spectre").open_visual()
  end):with_defaults(),
  ["n|<Leader>so"] = k.map_callback(function()
    require("spectre").open()
  end):with_defaults(),
  ["n|<Leader>sw"] = k.map_callback(function()
    require("spectre").open_visual({ select_word = true })
  end):with_defaults(),
  ["n|<Leader>sp"] = k.map_callback(function()
    require("spectre").open_file_search({ select_word = true })
  end):with_defaults(),
  -- Hop
  ["n|<LocalLeader>w"] = k.map_cu("HopWord"):with_noremap(),
  ["n|<LocalLeader>j"] = k.map_cu("HopLine"):with_noremap(),
  ["n|<LocalLeader>k"] = k.map_cu("HopLine"):with_noremap(),
  ["n|<LocalLeader>c"] = k.map_cu("HopChar1"):with_noremap(),
  ["n|<LocalLeader>cc"] = k.map_cu("HopChar2"):with_noremap(),
  -- EasyAlign
  ["n|gea"] = k.map_callback(function()
    return vim.api.nvim_replace_termcodes("<Plug>(EasyAlign)", true, true, true)
  end):with_expr(),
  ["x|gea"] = k.map_callback(function()
    return vim.api.nvim_replace_termcodes("<Plug>(EasyAlign)", true, true, true)
  end):with_expr(),
  -- MarkdownPreview
  ["n|mpt"] = k.map_cr("MarkdownPreviewToggle"):with_defaults(),
  -- zen-mode
  ["n|zm"] = k.map_callback(function()
    require("zen-mode").toggle({ window = { width = 0.75 } })
  end):with_defaults(),
  -- refactoring
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
  -- dap
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
  ["n|<LocalLeader>db"] = k.map_callback(function()
    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end):with_defaults(),
  ["n|<LocalLeader>dc"] = k.map_callback(function()
    require("dap").run_to_cursor()
  end):with_defaults(),
  ["n|<LocalLeader>dl"] = k.map_callback(function()
    require("dap").run_last()
  end):with_defaults(),
  ["n|<LocalLeader>do"] = k.map_callback(function()
    require("dap").repl.open()
  end):with_defaults(),
  -- Legendary
  ["n|<C-p>"] = k.map_cr("Legendary"):with_defaults():with_desc("utils: Show keymap legends"),
  -- Diffview
  ["n|<LocalLeader>D"] = k.map_cr("DiffviewOpen"):with_defaults():with_desc("git: Show diff view"),
  ["n|<LocalLeader><LocalLeader>D"] = k.map_cr("DiffviewClose"):with_defaults():with_desc("git: Close diff view"),
}

k.nvim_load_mapping(mapping)
