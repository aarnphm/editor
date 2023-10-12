local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- NOTE: normal mode
map("n", "<S-Tab>", "<cmd>normal za<cr>", { desc = "edit: Toggle code fold" })
map("n", "Y", "y$", { desc = "edit: Yank text to EOL" })
map("n", "D", "d$", { desc = "edit: Delete text to EOL" })
map("n", "J", "mzJ`z", { desc = "edit: Join next line" })
map("n", "\\", ":let @/=''<CR>:noh<CR>", { silent = true, desc = "window: Clean highlight" })
map("n", ";", ":", { silent = false, desc = "command: Enter command mode" })
map("n", ";;", ";", { silent = false, desc = "normal: Enter Ex mode" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "edit: Move this line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "edit: Move this line up" })
map("v", "<", "<gv", { desc = "edit: Decrease indent" })
map("v", ">", ">gv", { desc = "edit: Increase indent" })
map("c", "W!!", "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!", { desc = "edit: Save file using sudo" })
map("n", "<C-h>", "<C-w>h", { desc = "window: Focus left" })
map("n", "<C-l>", "<C-w>l", { desc = "window: Focus right" })
map("n", "<C-j>", "<C-w>j", { desc = "window: Focus down" })
map("n", "<C-k>", "<C-w>k", { desc = "window: Focus up" })
map("n", "<LocalLeader>|", "<C-w>|", { desc = "window: Maxout width" })
map("n", "<LocalLeader>-", "<C-w>_", { desc = "window: Maxout width" })
map("n", "<LocalLeader>=", "<C-w>=", { desc = "window: Equal size" })
map("n", "<Leader>qq", "<cmd>wqa<cr>", { desc = "editor: write quit all" })
map("n", "<Leader>.", "<cmd>bnext<cr>", { desc = "buffer: next" })
map("n", "<Leader>,", "<cmd>bprevious<cr>", { desc = "buffer: previous" })
map("n", "<Leader>q", "<cmd>copen<cr>", { desc = "quickfix: Open quickfix" })
map("n", "<Leader>l", "<cmd>lopen<cr>", { desc = "quickfix: Open location list" })
map("n", "<Leader>n", "<cmd>enew<cr>", { desc = "buffer: new" })
map("n", "<LocalLeader>sw", "<C-w>r", { desc = "window: swap position" })
map("n", "<LocalLeader>vs", "<C-w>v", { desc = "edit: split window vertically" })
map("n", "<LocalLeader>hs", "<C-w>s", { desc = "edit: split window horizontally" })
map("n", "<LocalLeader>cd", ":lcd %:p:h<cr>", { desc = "misc: change directory to current file buffer" })
map("n", "<LocalLeader>l", "<cmd>set list! list?<cr>", { silent = false, desc = "misc: toggle invisible characters" })
map(
  "n",
  "<LocalLeader>]",
  string.format("<cmd>vertical resize -%s<cr>", 10),
  { noremap = false, desc = "windows: resize right 10px" }
)
map(
  "n",
  "<LocalLeader>[",
  string.format("<cmd>vertical resize +%s<cr>", 10),
  { noremap = false, desc = "windows: resize left 10px" }
)
map(
  "n",
  "<LocalLeader>-",
  string.format("<cmd>resize -%s<cr>", 10),
  { noremap = false, desc = "windows: resize down 10px" }
)
map(
  "n",
  "<LocalLeader>+",
  string.format("<cmd>resize +%s<cr>", 10),
  { noremap = false, desc = "windows: resize up 10px" }
)
map("n", "<LocalLeader>p", "<cmd>Lazy<cr>", { desc = "package: show manager" })