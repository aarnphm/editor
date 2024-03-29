local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function() go { severity = severity } end
end

map("n", "<leader>d", vim.diagnostic.open_float, { desc = "lsp: show line diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "lsp: Next diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "lsp: Prev diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "lsp: Next error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "lsp: Prev error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "lsp: Next warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "lsp: Prev warning" })
map({ "n", "v" }, "<leader><leader>f", function() Util.format { force = true } end, { desc = "style: format buffer" })
map("i", "jj", "<Esc>", { desc = "normal: escape" })
map("i", "jk", "<Esc>", { desc = "normal: escape" })

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
map("n", "<C-h>", "<C-w>h", { desc = "window: Focus left", silent = true, noremap = true })
map("n", "<C-l>", "<C-w>l", { desc = "window: Focus right", silent = true, noremap = true })
map("n", "<C-j>", "<C-w>j", { desc = "window: Focus down", silent = true, noremap = true })
map("n", "<C-k>", "<C-w>k", { desc = "window: Focus up", silent = true, noremap = true })
map("t", "<C-w>h", "<cmd>wincmd h<CR>", { desc = "window: Focus left", silent = true, noremap = true })
map("t", "<C-w>l", "<cmd>wincmd l<CR>", { desc = "window: Focus right", silent = true, noremap = true })
map("t", "<C-w>j", "<cmd>wincmd j<CR>", { desc = "window: Focus down", silent = true, noremap = true })
map("t", "<C-w>k", "<cmd>wincmd k<CR>", { desc = "window: Focus up", silent = true, noremap = true })
map("n", "<LocalLeader>|", "<C-w>|", { desc = "window: Maxout width" })
map("n", "<LocalLeader>-", "<C-w>_", { desc = "window: Maxout width" })
map("n", "<LocalLeader>=", "<C-w>=", { desc = "window: Equal size" })
map("n", "<Leader>qq", "<cmd>wqa<cr>", { desc = "editor: write quit all" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "buffer: next" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "buffer: previous" })
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

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

map("n", "<LocalLeader>p", "<cmd>Lazy<cr>", { desc = "package: show manager" })

map("n", "<leader>qf", "<cmd>copen<cr>", { desc = "quickfix: open" })
map("n", "<leader>lf", "<cmd>lopen<cr>", { desc = "locationfix: open" })
