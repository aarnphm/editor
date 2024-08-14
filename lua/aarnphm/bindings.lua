local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Easily hit escape in terminal mode.
-- Open a terminal at the bottom of the screen with a fixed height.
local function get_fzf_args()
  return vim.api.nvim_get_option_value("background", {}) == "light"
      and "--color=fg:#797593,bg:#faf4ed,hl:#d7827e --color=fg+:#575279,bg+:#f2e9e1,hl+:#d7827e --color=border:#dfdad9,header:#286983,gutter:#faf4ed --color=spinner:#ea9d34,info:#56949f --color=pointer:#907aa9,marker:#b4637a,prompt:#797593"
    or "--color=fg:#908caa,bg:#191724,hl:#ebbcba --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba --color=border:#403d52,header:#31748f,gutter:#191724 --color=spinner:#f6c177,info:#9ccfd8 --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"
end
map(
  "n",
  "<C-p>",
  function()
    Util.terminal(nil, {
      cwd = Util.root(),
      env = { FZF_DEFAULT_OPTS = get_fzf_args() },
    })
  end,
  { desc = "terminal: open (root)" }
)
map(
  "n",
  "<C-S-p>",
  function()
    Util.terminal(nil, {
      cwd = Util.root(),
      env = { FZF_DEFAULT_OPTS = get_fzf_args() },
    })
  end,
  { desc = "terminal: open (root)" }
)
map(
  "n",
  "<M-[>",
  function() Util.terminal(nil, { env = { FZF_DEFAULT_OPTS = get_fzf_args() } }) end,
  { desc = "terminal: open (root)" }
)
map(
  "n",
  "<M-]>",
  function()
    Util.terminal(
      { "npx", "quartz", "build", "--bundleInfo", "--concurrency", "4", "--serve", "--verbose" },
      { cwd = Util.root(), env = { FZF_DEFAULT_OPTS = get_fzf_args() }, interactive = true, esc_esc = true }
    )
  end,
  { desc = "terminal: serve quartz" }
)
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "terminal: enter normal mode" })
map("t", "<C-w>h", "<cmd>wincmd h<cr>", { desc = "terminal: go to left window" })
map("t", "<C-w>j", "<cmd>wincmd j<cr>", { desc = "terminal: go to lower window" })
map("t", "<C-w>k", "<cmd>wincmd k<cr>", { desc = "terminal: go to upper window" })
map("t", "<C-w>l", "<cmd>wincmd l<cr>", { desc = "terminal: go to right window" })
map("t", "<C-S-p>", "<cmd>close<cr>", { desc = "terminal: hide" })
map("t", "<C-p>", "<cmd>close<cr>", { desc = "terminal: hide" })
map("t", "<M-[>", "<cmd>close<cr>", { desc = "terminal: hide" })
map("t", "<M-]>", "<cmd>close<cr>", { desc = "terminal: hide" })
map("i", "jj", "<Esc>", { desc = "normal: escape" })
map("i", "jk", "<Esc>", { desc = "normal: escape" })

-- NOTE: normal mode
map("n", "<leader><leader>a", "<CMD>normal za<CR>", { desc = "edit: Toggle code fold" })
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
map("n", "<LocalLeader>|", "<C-w>|", { desc = "window: Maxout width" })
map("n", "<LocalLeader>-", "<C-w>_", { desc = "window: Maxout width" })
map("n", "<LocalLeader>=", "<C-w>=", { desc = "window: Equal size" })
map("n", "<Leader>qq", "<cmd>wqa<cr>", { desc = "editor: write quit all" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "buffer: next" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "buffer: previous" })
map("n", "<Leader>`", "<cmd>e #<cr>", { desc = "buffer: switch to other buffer" })
map("n", "<C-x>", function(buf) Util.ui.bufremove(buf) end, { desc = "buffer: delete" })
map("n", "<C-q>", "<cmd>:bd<cr>", { desc = "buffer: delete" })
map("n", "<Leader>n", "<cmd>enew<cr>", { desc = "buffer: new" })
map("n", "<LocalLeader>sw", "<C-w>r", { desc = "window: swap position" })
map("n", "<LocalLeader>vs", "<C-w>v", { desc = "edit: split window vertically" })
map("n", "<LocalLeader>hs", "<C-w>s", { desc = "edit: split window horizontally" })
map("n", "<LocalLeader>cd", ":lcd %:p:h<cr>", { desc = "misc: change directory to current file buffer" })
map("n", "<LocalLeader>l", "<cmd>set list! list?<cr>", { silent = false, desc = "misc: toggle invisible characters" })
map("n", "<LocalLeader>]", "<cmd>vertical resize -10<cr>", { noremap = false, desc = "windows: resize right 10px" })
map("n", "<LocalLeader>[", "<cmd>vertical resize +10<cr>", { noremap = false, desc = "windows: resize left 10px" })
map("n", "<LocalLeader>-", "<cmd>resize -10<cr>", { noremap = false, desc = "windows: resize down 10px" })
map("n", "<LocalLeader>+", "<cmd>resize +10<cr>", { noremap = false, desc = "windows: resize up 10px" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "search: next" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "search: next" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "search: next" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "search: prev" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "search: prev" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "search: prev" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

map("n", "<LocalLeader>p", "<cmd>Lazy<cr>", { desc = "package: show manager" })
