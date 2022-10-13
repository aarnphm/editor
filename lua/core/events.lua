local vim, api = vim, vim.api
local M = {}

_G.set_tmux_keymaps = function()
  local opts = { noremap = true, silent = true }
  if api.nvim_eval('exists("$TMUX")') ~= 0 then
    api.nvim_set_keymap("n", "<C-h>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateLeft()<cr>", opts)
    api.nvim_set_keymap("n", "<C-j>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateDown()<cr>", opts)
    api.nvim_set_keymap("n", "<C-k>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateUp()<cr>", opts)
    api.nvim_set_keymap("n", "<C-l>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateRight()<cr>", opts)
    api.nvim_set_keymap("n", "<C-\\>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateLastActive()<cr>", opts)
    api.nvim_set_keymap("n", "<C-Space>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateNext()<cr>", opts)
  end
end

_G.set_terminal_keymaps = function()
  local opts = { noremap = true }
  api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
  api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
  api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
  api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
  api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
  api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

_G.setup_octo_autocomplete = function()
  local opts = { noremap = true, silent = true }
  api.nvim_buf_set_keymap(0, "i", "@", "@<C-x><C-o>", opts)
  api.nvim_buf_set_keymap(0, "i", "#", "#<C-x><C-o>", opts)
end

local autocmd = api.nvim_create_autocmd

-- Disable statusline in dashboard
autocmd("FileType", {
  pattern = "alpha",
  callback = function()
    vim.opt.laststatus = 0
    vim.opt.showtabline = 0
  end,
})

autocmd("BufUnload", {
  buffer = 0,
  callback = function()
    vim.opt.laststatus = 3
    vim.opt.showtabline = 2
  end,
})

local nvim_create_augroups = function(definitions)
  for group_name, definition in pairs(definitions) do
    api.nvim_command("augroup " .. group_name)
    api.nvim_command("autocmd!")
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten({ "autocmd", def }), " ")
      api.nvim_command(command)
    end
    api.nvim_command("augroup END")
  end
end

M.setup = function()
  local definitions = {
    packer = {},
    terms = {
      { "TermOpen", "term://*", "lua set_terminal_keymaps()" },
    },
    bufs = {
      {
        "BufEnter,WinEnter",
        "*",
        "lua set_tmux_keymaps()",
      },
      {
        "BufEnter,WinEnter",
        "*",
        'lua require("core.utils").hide_statusline()',
      },
      {
        "BufWritePost",
        [[$VIM_PATH/{*.vim,*.yaml,vimrc} nested source $MYVIMRC | redraw]],
      },
      -- Reload Vim script automatically if setlocal autoread
      {
        "BufWritePost,FileWritePost",
        "*.vim",
        [[nested if &l:autoread > 0 | source <afile> | echo 'source ' . bufname('%') | endif]],
      },
      { "BufWritePre", "/tmp/*", "setlocal noundofile" },
      { "BufWritePre", "COMMIT_EDITMSG", "setlocal noundofile" },
      { "BufWritePre", "MERGE_MSG", "setlocal noundofile" },
      { "BufWritePre", "*.tmp", "setlocal noundofile" },
      { "BufWritePre", "*.bak", "setlocal noundofile" },
      -- auto change directory
      { "BufEnter", "*", "silent! lcd %:p:h" },
      -- auto place to last edit
      {
        "BufReadPost",
        "*",
        [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif]],
      },
      {
        "BufEnter",
        "*",
        [[if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif]],
      },
      {
        "WinEnter",
        "*",
        [[if winnr('$') == 1 && &buftype == "quickfix" | q | endif]],
      },
    },
    wins = {
      -- Highlight current line only on focused window
      {
        "WinEnter,BufEnter,InsertLeave",
        "*",
        [[if ! &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal cursorline | endif]],
      },
      {
        "WinLeave,BufLeave,InsertEnter",
        "*",
        [[if &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal nocursorline | endif]],
      },
      -- Force write shada on leaving nvim
      {
        "VimLeave",
        "*",
        [[if has('nvim') | wshada! | else | wviminfo! | endif]],
      },
      -- Check if file changed when its window is focus, more eager than 'autoread'
      { "FocusGained", "* checktime" },
      -- Equalize window dimensions when resizing vim window
      { "VimResized", "*", [[tabdo wincmd =]] },
    },
    ft = {
      { "FileType", "alpha", "set showtabline=0" },
      { "FileType", "markdown", "set wrap" },
      { "FileType", "make", "set noexpandtab shiftwidth=8 softtabstop=0" },
      { "FileType", "dap-repl", "lua require('dap.ext.autocompl').attach()" },
      {
        "FileType",
        "*",
        [[setlocal formatoptions-=cro]],
      },
      {
        "FileType",
        "c,cpp",
        "nnoremap <leader>h :ClangdSwitchSourceHeaderVSplit<CR>",
      },
      -- Google tab style
      { "BufNewFile,BufRead", "BUILD*", "setf bzl" },
      { "BufNewFile,BufRead", "WORKSPACE", "setf bzl" },
      { "BufNewFile,BufRead", "*.toml", "setf toml" },
      { "BufNewFile,BufRead", "*.proto", "setf proto" },
      { "BufNewFile,BufRead", "Bentfile", "setf dockerfile.yaml" },
      { "BufNewFile,BufRead", "Dockerfile-*", "setf dockerfile" },
      { "BufNewFile,BufRead", "Dockerfile.{tpl,template,tmpl}", "setf dockerfile" },
      { "BufNewFile,BufRead", "*.{Dockerfile,dockerfile}", "setf dockerfile" },
      { "BufNewFile,BufRead", "FRAMEWORK_TEMPLATE_PY", "setf python" },
      { "FileType", "make", "set noexpandtab shiftwidth=4 softtabstop=0" },
      { "FileType", "lua", "set noexpandtab shiftwidth=2 tabstop=2" },
      { "FileType", "nix", "set noexpandtab shiftwidth=2 tabstop=2" },
      { "FileType", "c,cpp", "set expandtab tabstop=2 shiftwidth=2" },
      { "FileType", "octo", "lua setup_octo_autocomplete()" },
    },
    yank = {
      {
        "TextYankPost",
        "*",
        [[silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=300})]],
      },
    },
  }

  nvim_create_augroups(definitions)
end

M.setup()

return M
