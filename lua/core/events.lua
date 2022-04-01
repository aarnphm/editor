local vim = vim
local M = {}

function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

function M.nvim_create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    vim.api.nvim_command("augroup " .. group_name)
    vim.api.nvim_command("autocmd!")
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten({ "autocmd", def }), " ")
      vim.api.nvim_command(command)
    end
    vim.api.nvim_command("augroup END")
  end
end

function M.setup_autocmds()
  local definitions = {
    terms = {
      { "TermOpen", "term://*", "lua set_terminal_keymaps()" },
    },
    bufs = {
      { "BufWritePre", "COMMIT_EDITMSG", "setlocal noundofile" },
      { "BufWritePre", "MERGE_MSG", "setlocal noundofile" },
      { "BufWritePre", "*.tmp", "setlocal noundofile" },
      { "BufWritePre", "*.bak", "setlocal noundofile" },
      {
        "BufEnter,BufRead,BufWinEnter,FileType,WinEnter",
        "*",
        'lua require("core.utils").hide_statusline()',
      },
      { "WinEnter", "*", "lua require('core.utils').install_treesitter()" },
      { "BufWritePost", "*.lua", "lua require('core.pack').compile()" },
      {
        "BufReadPost",
        "*",
        [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif]],
      },
      {
        "BufEnter",
        "*",
        [[++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif]],
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
      { "BufNewFile,BufRead", "*.toml", "setf toml" },
      { "BufNewFile,BufRead", "Dockerfile-*", "setf dockerfile" },
      { "BufNewFile,BufRead", "*.{Dockerfile,dockerfile}", "setf dockerfile" },
      { "FileType", "make", "set noexpandtab shiftwidth=4 softtabstop=0" },
      { "FileType", "lua", "set noexpandtab shiftwidth=2 tabstop=2" },
      { "FileType", "nix", "set noexpandtab shiftwidth=2 tabstop=2" },
      { "FileType", "c,cpp", "set expandtab tabstop=2 shiftwidth=2" },
      { "FileType", "dap-repl", "lua require('dap.ext.autocompl').attach()" },
    },
    yank = {
      {
        "TextYankPost",
        "*",
        [[silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=300})]],
      },
    },
  }

  vim.cmd([[
  autocmd FileType dashboard set showtabline=0 laststatus=0
  autocmd WinLeave <buffer> set showtabline=2 laststatus=2
  ]])

  M.nvim_create_augroups(definitions)
end

return M
