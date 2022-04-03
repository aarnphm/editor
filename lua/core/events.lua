local vim = vim
local api = vim.api
local M = {}

_G.set_tmux_keymaps = function()
  local opts = { noremap = true, silent = true }
  if vim.api.nvim_eval('exists("$TMUX")') ~= 0 then
    vim.api.nvim_set_keymap("n", "<C-h>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateLeft()<cr>", opts)
    vim.api.nvim_set_keymap("n", "<C-j>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateDown()<cr>", opts)
    vim.api.nvim_set_keymap("n", "<C-k>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateUp()<cr>", opts)
    vim.api.nvim_set_keymap("n", "<C-l>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateRight()<cr>", opts)
    vim.api.nvim_set_keymap("n", "<C-\\>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateLastActive()<cr>", opts)
    vim.api.nvim_set_keymap("n", "<C-Space>", ":lua require'nvim-tmux-navigation'.NvimTmuxNavigateNext()<cr>", opts)
  end
end

_G.set_terminal_keymaps = function()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

_G.set_neuron_keymaps = function()
  vim.cmd([[packadd neuron]])
  local neuron = require("neuron")

  local map_buf = function(key, rhs)
    local lhs = string.format("%s%s", neuron.config.leader, key)
    api.nvim_buf_set_keymap(0, "n", lhs, rhs, { noremap = true, silent = true })
  end

  api.nvim_buf_set_keymap(0, "n", "<CR>", ":lua require'neuron'.enter_link()<CR>", { noremap = true, silent = true })
  map_buf("<CR>", "<cmd>lua require'neuron'.enter_link()<CR>")

  map_buf("n", "<cmd>lua require'neuron.cmd'.new_edit(require'neuron'.config.neuron_dir)<CR>")

  map_buf("z", "<cmd>lua require'neuron.telescope'.find_zettels()<CR>")
  map_buf("Z", "<cmd>lua require'neuron.telescope'.find_zettels {insert = true}<CR>")

  map_buf("b", "<cmd>lua require'neuron.telescope'.find_backlinks()<CR>")
  map_buf("B", "<cmd>lua require'neuron.telescope'.find_backlinks {insert = true}<CR>")

  map_buf("t", "<cmd>lua require'neuron.telescope'.find_tags()<CR>")

  map_buf("s", [[<cmd>lua require'neuron'.rib {address = "127.0.0.1:8200", verbose = true}<CR>]])

  map_buf("]", "<cmd>lua require'neuron'.goto_next_extmark()<CR>")
  map_buf("[", "<cmd>lua require'neuron'.goto_prev_extmark()<CR>")
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
      { "BufRead", string.format("%s/*.md", __editor_global.zettel_home), "lua set_neuron_keymaps()" },
      {
        "BufEnter,WinEnter",
        "*",
        "lua set_tmux_keymaps()",
      },
      {
        "BufEnter,BufRead,BufWinEnter,FileType,WinEnter",
        "*",
        'lua require("core.utils").hide_statusline()',
      },
      { "BufWritePost", "*.lua", "lua require'plugins' require('packer').compile()" },
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
    },
    yank = {
      {
        "TextYankPost",
        "*",
        [[silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=300})]],
      },
    },
  }

  M.nvim_create_augroups(definitions)
end

return M
