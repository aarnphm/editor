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
  local definitions = {
    bufs = {
      { "BufWritePre", "/tmp/*", "setlocal noundofile" },
      { "BufWritePre", "COMMIT_EDITMSG", "setlocal noundofile" },
      { "BufWritePre", "MERGE_MSG", "setlocal noundofile" },
      { "BufWritePre", "*.tmp", "setlocal noundofile" },
      { "BufWritePre", "*.bak", "setlocal noundofile" },
      {
        "BufEnter,BufRead,BufWinEnter,FileType,WinEnter",
        "*",
        'lua require("core.utils").hide_statusline()',
      },
      { "BufNewFile,BufRead", "*.toml", "setf toml" },
      { "BufNewFile,BufRead", "Dockerfile-*", "setf dockerfile" },
      { "BufNewFile,BufRead", "*.{Dockerfile,dockerfile}", "setf dockerfile" },
    },
    ft = {
      { "FileType", "make", "set noexpandtab shiftwidth=4 softtabstop=0" },
      { "FileType", "lua", "set noexpandtab shiftwidth=2 tabstop=2" },
      { "FileType", "nix", "set noexpandtab shiftwidth=2 tabstop=2" },
      { "FileType", "c,cpp", "set expandtab tabstop=2 shiftwidth=2" },
      { "FileType", "dap-repl", "lua require('dap.ext.autocompl').attach()" },
      {
        "FileType",
        "dashboard",
        "set showtabline=0 | autocmd WinLeave <buffer> set showtabline=2",
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
