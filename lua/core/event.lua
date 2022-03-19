local vim = vim
local autocmd = {}

function autocmd.nvim_create_augroups(definitions)
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

function autocmd.load_autocmds()
  -- remove statusline when entering into some buffer
  vim.cmd([[ autocmd BufEnter,BufRead,BufWinEnter,FileType,WinEnter * lua require("core.utils").hide_statusline() ]])

  local definitions = {
    packer = {
      { "BufWritePost", "*.lua", "lua require('core.pack').auto_compile()" },
    },
    bufs = {
      -- Reload vim config automatically
      {
        "BufWritePost",
        [[$VIM_PATH/{*.vim,*.yaml,vimrc} nested source $MYVIMRC | redraw]],
      }, -- Reload Vim script automatically if setlocal autoread
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
      {
        "BufWritePre",
        "*.go",
        "silent! lua require('go.format').gofmt()",
      },
      { "BufEnter", "*", "silent! lcd %:p:h" }, -- auto place to last edit
      {
        "BufReadPost",
        "*",
        [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif]],
      },
    },
    wins = {
      {
        "WinEnter,BufEnter,InsertLeave",
        "*",
        [[if ! &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal cursorline | endif]],
      },
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
      { "BufNewFile,BufRead", "*.toml", " setf toml" },
      { "BufNewFile,BufRead", "Dockerfile-*", " setf dockerfile" },
      { "BufNewFile,BufRead", "*.{Dockerfile,dockerfile}", " setf dockerfile" },
      { "BufNewFile,BufRead", "*-{Dockerfile,dockerfile}.j2", " setf dockerfile" },
      { "BufNewFile,BufRead", "*.j2", " setf html" },
      { "FileType", "make", "set noexpandtab shiftwidth=4 softtabstop=0" },
      { "FileType", "lua", "set noexpandtab shiftwidth=2 tabstop=2" },
      { "FileType", "c,cpp", "set expandtab tabstop=2 shiftwidth=2" },
      { "FileType", "dap-repl", "lua require('dap.ext.autocompl').attach()" },
      {
        "FileType",
        "dashboard",
        "set showtabline=0 | autocmd WinLeave <buffer> set showtabline=2",
      },
      {
        "FileType",
        "*",
        [[setlocal formatoptions-=c formatoptions-=r formatoptions-=o]],
      },
    },
    yank = {
      {
        "TextYankPost",
        "*",
        [[silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=300})]],
      },
    },
  }

  autocmd.nvim_create_augroups(definitions)
end

autocmd.load_autocmds()
