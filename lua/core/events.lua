local api, create_autocmd = vim.api, vim.api.nvim_create_autocmd
local create_augroup = vim.api.nvim_create_augroup

-- Disable statusline in dashboard
create_autocmd("FileType", {
  pattern = "alpha",
  callback = function()
    vim.opt.laststatus = 0
    vim.opt.showtabline = 0
  end,
})
create_autocmd("BufUnload", {
  buffer = 0,
  callback = function()
    vim.opt.laststatus = 3
    vim.opt.showtabline = 2
  end,
})

-- auto close NvimTree
create_autocmd("BufEnter", {
  group = api.nvim_create_augroup("NvimTreeClose", { clear = true }),
  pattern = "NvimTree_*",
  callback = function()
    local layout = api.nvim_call_function("winlayout", {})
    if
      layout[1] == "leaf"
      and api.nvim_buf_get_option(api.nvim_win_get_buf(layout[2]), "filetype") == "NvimTree"
      and layout[3] == nil
    then
      vim.cmd("confirm quit")
    end
  end,
})

-- Make <esc> and kk in terminal mode behave like in normal mode
create_autocmd("TermOpen", {
  group = create_augroup("term", { clear = true }),
  pattern = "term://*",
  callback = function(_)
    api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], { noremap = true })
    api.nvim_buf_set_keymap(0, "t", "kk", [[<C-\><C-n>]], { noremap = true })
    api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], { noremap = true })
    api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], { noremap = true })
    api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], { noremap = true })
    api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], { noremap = true })
  end,
})

local bufs_id = create_augroup("bufs", { clear = true })
-- Hide statusline in certain buffers
create_autocmd("BufEnter,WinEnter", {
  group = bufs_id,
  pattern = "*",
  callback = function(_)
    local shown = {}
    local hidden = {
      "help",
      "NvimTree",
      "terminal",
      "Scratch",
      "quickfix",
      "Trouble",
    }

    local buftype = api.nvim_buf_get_option(0, "ft")

    -- shown table from config has the highest priority
    if vim.tbl_contains(shown, buftype) then
      api.nvim_set_option("laststatus", 3)
      return
    end

    if vim.tbl_contains(hidden, buftype) then
      api.nvim_set_option("laststatus", 0)
      return
    end

    api.nvim_set_option("laststatus", 3)
  end,
})
-- source vimrc on save
create_autocmd("BufWritePost", {
  group = bufs_id,
  pattern = "$VIM_PATH/{*.vim,*.yaml,vimrc}",
  command = "source $MYVIMRC | redraw",
  nested = true,
})
-- Reload Vim script automatically if setlocal autoread
create_autocmd("BufWritePost,FileWritePost", {
  group = bufs_id,
  pattern = "*.vim",
  callback = function(_)
    api.nvim_command([[nested if &l:autoread > 0 | source <afile> | echo 'source ' . bufname('%') | endif]])
  end,
})
-- Set noundofile for temporary files
create_autocmd("BufWritePre", {
  group = bufs_id,
  pattern = "/tmp/*",
  callback = function(_)
    api.nvim_command("setlocal noundofile")
  end,
})
create_autocmd("BufWritePre", {
  group = bufs_id,
  pattern = "*.tmp",
  callback = function(_)
    api.nvim_command("setlocal noundofile")
  end,
})
create_autocmd("BufWritePre", {
  group = bufs_id,
  pattern = "*.bak",
  callback = function(_)
    api.nvim_command("setlocal noundofile")
  end,
})
-- auto change directory
create_autocmd("BufEnter", {
  group = bufs_id,
  pattern = "*",
  callback = function(_)
    api.nvim_command("silent! lcd %:p:h")
  end,
})
-- auto place to last edit
create_autocmd("BufReadPost", {
  group = bufs_id,
  pattern = "*",
  callback = function(_)
    api.nvim_command([[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif]])
  end,
})

local wins_id = create_augroup("wins", { clear = true })
-- Highlight current line only on focused window
create_autocmd("WinEnter,BufEnter,InsertLeave", {
  group = wins_id,
  pattern = "*",
  callback = function(_)
    api.nvim_command(
      [[if ! &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal cursorline | endif]]
    )
  end,
})
-- Disable cursorline on unfocused windows
create_autocmd("WinLeave,BufLeave,InsertEnter", {
  group = wins_id,
  pattern = "*",
  callback = function(_)
    api.nvim_command(
      [[if &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal nocursorline | endif]]
    )
  end,
})
-- Force write shada on leaving nvim
create_autocmd("VimLeave", {
  group = wins_id,
  pattern = "*",
  callback = function(_)
    api.nvim_command([[if has('nvim') | wshada! | else | wviminfo! | endif]])
  end,
})
-- Check if file changed when its window is focus, more eager than 'autoread'
create_autocmd("FocusGained", {
  group = wins_id,
  pattern = "*",
  callback = function(_)
    api.nvim_command([[checktime]])
  end,
})
-- Equalize window dimensions when resizing vim window
create_autocmd("VimResized", {
  group = wins_id,
  pattern = "*",
  callback = function(_)
    api.nvim_command([[tabdo wincmd =]])
  end,
})

local ft_id = create_augroup("ft", { clear = true })
-- set local to all filetypes to have formatoptions-=cro
create_autocmd("FileType", {
  group = ft_id,
  pattern = "*",
  callback = function(_)
    api.nvim_command([[setlocal formatoptions-=cro]])
  end,
})
create_autocmd("FileType", {
  group = ft_id,
  pattern = "alpha",
  callback = function(_)
    api.nvim_command("set showtabline=0")
  end,
})
create_autocmd("FileType", {
  group = ft_id,
  pattern = "markdown",
  callback = function(_)
    api.nvim_command("set wrap")
  end,
})
create_autocmd("FileType", {
  group = ft_id,
  pattern = "make",
  callback = function(_)
    api.nvim_command("set noexpandtab shiftwidth=8 softtabstop=0")
  end,
})
create_autocmd("FileType", {
  group = ft_id,
  pattern = "dap-repl",
  callback = function(_)
    api.nvim_command("lua require('dap.ext.autocompl').attach()")
  end,
})
-- Google tab style for C/C++
create_autocmd("FileType", {
  group = ft_id,
  pattern = "c,cpp",
  callback = function(_)
    api.nvim_command("nnoremap <leader>h :ClangdSwitchSourceHeaderVSplit<CR>")
  end,
})
-- set filetype for bazel files
create_autocmd("BufNewFile,BufRead", {
  group = ft_id,
  pattern = "*.bazel",
  callback = function(_)
    api.nvim_command("setf bzl")
  end,
})
create_autocmd("BufNewFile,BufRead", {
  group = ft_id,
  pattern = "WORKSPACE",
  callback = function(_)
    api.nvim_command("setf bzl")
  end,
})
-- set filetype for proto files
create_autocmd("BufNewFile,BufRead", {
  group = ft_id,
  pattern = "*.proto",
  callback = function(_)
    api.nvim_command("setf proto")
  end,
})
-- set filetype for docker files
create_autocmd("BufNewFile,BufRead", {
  group = ft_id,
  pattern = "Dockerfile-*",
  callback = function(_)
    api.nvim_command("setf dockerfile")
  end,
})
create_autocmd("BufNewFile,BufRead", {
  group = ft_id,
  pattern = "Dockerfile.{tpl,template,tmpl}",
  callback = function(_)
    api.nvim_command("setf dockerfile")
  end,
})
create_autocmd("BufNewFile,BufRead", {
  group = ft_id,
  pattern = "*.{Dockerfile,dockerfile}",
  callback = function(_)
    api.nvim_command("setf dockerfile")
  end,
})
-- set make to noexpandtab, shiftwidth=8, softtabstop=0
create_autocmd("FileType", {
  group = ft_id,
  pattern = "make",
  callback = function(_)
    api.nvim_command("set noexpandtab shiftwidth=8 softtabstop=0")
  end,
})

local yank_id = create_augroup("yank", { clear = true })
-- Highlight on yank
create_autocmd("TextYankPost", {
  group = yank_id,
  pattern = "*",
  callback = function(_)
    api.nvim_command([[silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=300})]])
  end,
})
