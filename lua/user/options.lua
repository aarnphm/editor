local api     = vim.api
local autocmd = vim.api.nvim_create_autocmd

local M = {
    -- Whether to make completion fancy or simple border
    simple = true,
    -- Whether to show the diagnostic popup
    show_float_diagnostic = false,
    window = { resize = 10 }
}

-- Some defaults and don't question it
vim.o.wrap           = false                 -- egh i don't like wrap
vim.o.writebackup    = false                 -- whos needs backup btw (i do sometimes)
vim.o.autowrite      = true                  -- sometimes I forget to save
vim.o.guicursor      = ""                    -- no gui cursor
vim.o.undofile       = true                  -- set undofile to infinite undo
vim.o.breakindent    = true                  -- enable break indent
vim.o.breakindentopt = "shift:2,min:20"      -- wrap two spaces, with min of 20 text width
vim.o.clipboard      = "unnamedplus"         -- sync system clipboard
vim.o.pumheight      = 12                    -- larger completion windows
vim.o.completeopt    = "menuone,noselect"    -- better completion menu
vim.o.expandtab      = true                  -- convert spaces to tabs
vim.o.mouse          = "a"                   -- ugh who needs mouse (accept on SSH maybe)
vim.o.number         = true                  -- number is good for nav
vim.o.relativenumber = true                  -- relativenumber is useful, grow up
vim.o.swapfile       = false                 -- I don't like swap files personally, found undofile to be better
vim.o.undofile       = true                  -- better than swapfile
vim.o.undolevels     = 9999                  -- infinite undo
vim.o.shortmess      = "aoOTIcF"             -- insanely complex shortmess, but its cleannn

-- I refuse to have a complex statusline, but lualine is cool tho
vim.o.laststatus = 0
vim.o.statusline = "%f %m %= %=%y %l:%c ♥ "

-- NOTE: "1jcroql"
vim.opt.formatoptions = vim.opt.formatoptions
	- "a" -- Auto formatting is BAD.
	- "t" -- Don't auto format my code. I got linters for that.
	+ "c" -- In general, I like it when comments respect textwidth
	+ "q" -- Allow formatting comments w/ gq
	- "o" -- O and o, don't continue comments
	+ "r" -- But do continue when pressing enter.
	+ "n" -- Indent past the formatlistpat, not underneath it.
	+ "j" -- Auto-remove comments if possible.
	- "2" -- I'm not in gradeschool anymore


-- Better folding using tree-sitter
vim.o.foldlevelstart = 99
vim.o.foldmethod     = "expr"
vim.o.foldexpr       = "nvim_treesitter#foldexpr()"

-- searching and grep stuff
vim.o.smartcase  = true
vim.o.ignorecase = true
vim.o.infercase  = true
vim.o.grepprg    = "rg --hidden --vimgrep --smart-case --"  -- also its 2023 use rg

vim.o.linebreak   = true
vim.o.jumpoptions = "stack"
vim.o.listchars   = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"

-- Spaces and tabs config
vim.o.tabstop     = 4
vim.o.softtabstop = 4
vim.o.shiftwidth  = 4
vim.o.shiftround  = true

-- UI config
vim.o.showcmd       = false
vim.o.showbreak     = "↳  "
vim.o.sidescrolloff = 5
vim.o.signcolumn    = "yes:1"
vim.o.splitbelow    = true
vim.o.splitright    = true
vim.o.timeout       = true
vim.o.timeoutlen    = 200
vim.o.updatetime    = 200
vim.o.virtualedit   = "block"
vim.o.whichwrap     = "h,l,<,>,[,],~"

-- last but def not least, wildmenu
vim.o.wildchar       = 9
vim.o.wildignorecase = true
vim.o.wildmode       = "longest:full,full"
vim.opt.wildignore   = "__pycache__"
vim.opt.wildignore:append { "*.o", "*~", "*.pyc", "*pycache*" }
vim.opt.wildignore:append { "Cargo.lock", "lazy-lock.json" }

if vim.loop.os_uname().sysname == "Darwin" then
	vim.g.clipboard = {
		name          = "macOS-clipboard",
		copy          = { ["+"] = "pbcopy",  ["*"] = "pbcopy"  },
		paste         = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
		cache_enabled = 0,
	}
end

for _, type in pairs { "Error", "Warn", "Hint", "Info" } do
	local hl = string.format("DiagnosticSign%s", type)
	vim.fn.sign_define(hl, { text = "●", texthl = hl, numhl = hl })
end

vim.diagnostic.config {
	virtual_text     = false,
	underline        = false,
	update_in_insert = false,
	severity_sort    = true,
}

-- map leader to <Space> and localeader to +
vim.g.mapleader      = " "
vim.g.maplocalleader = "+"

vim.keymap.set({ "n", "x" }, " ", "", { noremap = true })

-- NOTE: Keymaps that are useful, use it and never come back.
local map = function(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
end

-- NOTE: normal mode
map("n", "<S-Tab>",         "<cmd>normal za<cr>",                                                                 { desc = "edit: Toggle code fold"                            })
map("n", "Y",               "y$",                                                                                 { desc = "edit: Yank text to EOL"                            })
map("n", "D",               "d$",                                                                                 { desc = "edit: Delete text to EOL"                          })
map("n", "J",               "mzJ`z",                                                                              { desc = "edit: Join next line"                              })
map("n", "<C-h>",           "<C-w>h",                                                                             { desc = "window: Focus left"                                })
map("n", "<C-l>",           "<C-w>l",                                                                             { desc = "window: Focus right"                               })
map("n", "<C-j>",           "<C-w>j",                                                                             { desc = "window: Focus down"                                })
map("n", "<C-k>",           "<C-w>k",                                                                             { desc = "window: Focus up"                                  })
map("n", "<LocalLeader>sw", "<C-w>r",                                                                             { desc = "window: swap position"                             })
map("n", "<LocalLeader>vs", "<C-w>v",                                                                             { desc = "edit: split window vertically"                     })
map("n", "<LocalLeader>hs", "<C-w>s",                                                                             { desc = "edit: split window horizontally"                   })
map("n", "<LocalLeader>cd", ":lcd %:p:h<cr>",                                                                     { desc = "misc: change directory to current file buffer"     })
map("n", "<leader>qq",      "<cmd>wqa<cr>",                                                                       { desc = "editor: write quit all"                            })
map("n", "<Leader>.",       "<cmd>bnext<cr>",                                                                     { desc = "buffer: next"                                      })
map("n", "<Leader>,",       "<cmd>bprevious<cr>",                                                                 { desc = "buffer: previous"                                  })
map("n", "<Leader>q",       "<cmd>copen<cr>",                                                                     { desc = "quickfix: Open quickfix"                           })
map("n", "<Leader>l",       "<cmd>lopen<cr>",                                                                     { desc = "quickfix: Open location list"                      })
map("n", "<Leader>n",       "<cmd>enew<cr>",                                                                      { desc = "buffer: new"                                       })
map("n", "\\",              ":let @/=''<CR>:noh<CR>",                                                             { silent = true, desc = "command: Search command history"    })
map("n", ";",               ":",                                                                                  { silent = false, desc = "command: Enter command mode"       })
map("n", "<LocalLeader>l",  "<cmd>set list! list?<cr>",                                                           { silent = false, desc = "misc: toggle invisible characters" })
map("n", "<LocalLeader>]",  string.format("<cmd>vertical resize -%s<cr>", M.window.resize),                       { noremap = false, desc = "windows: resize right 10px"       })
map("n", "<LocalLeader>[",  string.format("<cmd>vertical resize +%s<cr>", M.window.resize),                       { noremap = false, desc = "windows: resize left 10px"        })
map("n", "<LocalLeader>-",  string.format("<cmd>resize -%s<cr>",          M.window.resize),                       { noremap = false, desc = "windows: resize down 10px"        })
map("n", "<LocalLeader>+",  string.format("<cmd>resize +%s<cr>",          M.window.resize),                       { noremap = false, desc = "windows: resize up 10px"          })
map("n", "<LocalLeader>ft", require('lsp').toggle,                                                                { desc = "lsp: Toggle formatter"                             })
map("n", "<LocalLeader>p",  "<cmd>Lazy<cr>",                                                                      { desc = "package: show manager"                             })
map("v", "J",               ":m '>+1<CR>gv=gv",                                                                   { desc = "edit: Move this line down"                         })
map("v", "K",               ":m '<-2<CR>gv=gv",                                                                   { desc = "edit: Move this line up"                           })
map("v", "<",               "<gv",                                                                                { desc = "edit: Decrease indent"                             })
map("v", ">",               ">gv",                                                                                { desc = "edit: Increase indent"                             })
map("c", "W!!",             "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!",                         { desc = "edit: Save file using sudo"                        })
map("n", "<C-\\>",          "<cmd>execute v:count . 'ToggleTerm direction=horizontal'<cr>",                       { desc = "terminal: Toggle horizontal"                       })
map("i", "<C-\\>",          "<Esc><cmd>ToggleTerm direction=horizontal<cr>",                                      { desc = "terminal: Toggle horizontal"                       })
map("t", "<C-\\>",          "<Esc><cmd>ToggleTerm<cr>",                                                           { desc = "terminal: Toggle horizontal"                       })
map("n", "<C-t>",           "<cmd>execute v:count . 'ToggleTerm direction=vertical'<cr>",                         { desc = "terminal: Toggle vertical"                         })
map("i", "<C-t>",           "<Esc><cmd>ToggleTerm direction=vertical<cr>",                                        { desc = "terminal: Toggle vertical"                         })
map("t", "<C-t>",           "<Esc><cmd>ToggleTerm<cr>",                                                           { desc = "terminal: Toggle vertical"                         })

local augroup = function(name)
    return api.nvim_create_augroup("simple_"..name, {clear = true})
end

if M.show_float_diagnostic then
    -- diagnostic on hover
    autocmd({ "CursorHold", "CursorHoldI" }, {
        group = augroup("diagnostic"),
        pattern = "*",
        callback = function() vim.diagnostic.open_float(nil, { focus = false }) end,
    })
end

-- close some filetypes with <q>
autocmd("FileType", {
    group = augroup("filetype"),
	pattern = {
		"qf",
		"help",
		"man",
		"nowrite", -- fugitive
		"prompt",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neorepl",
		"alpha",
		"toggleterm",
		"health",
		"PlenaryTestPopup",
		"nofile",
		"scratch",
		"",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.api.nvim_buf_set_keymap(event.buf, "n", "q", "<cmd>close<cr>", { silent = true })
	end,
})

-- Makes switching between buffer and termmode feels like normal mode
autocmd("TermOpen", {
    group = augroup("term"),
	pattern = "term://*",
	callback = function()
		local opts = { noremap = true, silent = true }
		api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
		api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
	end,
})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
	pattern = "*",
	command = "checktime",
})
autocmd("VimResized", { group = augroup("resized"), command = "tabdo wincmd =" })

-- Set noundofile for temporary files
autocmd("BufWritePre", {
	group = augroup("tempfile"),
	pattern = { "/tmp/*", "*.tmp", "*.bak" },
	command = "setlocal noundofile",
})
-- set filetype for header files
autocmd({ "BufNewFile", "BufRead" }, {
	group = augroup("cpp_headers"),
	pattern = { "*.h", "*.hpp", "*.hxx", "*.hh" },
	command = "setlocal filetype=c",
})

-- Set mapping for switching header and source file
autocmd("FileType", {
	group = augroup("cpp"),
	pattern = "c,cpp",
	callback = function(event)
		api.nvim_buf_set_keymap(
			event.buf,
			"n",
			"<Leader><Leader>h",
			":ClangdSwitchSourceHeaderVSplit<CR>",
			{ noremap = true }
		)
		api.nvim_buf_set_keymap(
			event.buf,
			"n",
			"<Leader><Leader>v",
			":ClangdSwitchSourceHeaderSplit<CR>",
			{ noremap = true }
		)
		api.nvim_buf_set_keymap(
			event.buf,
			"n",
			"<Leader><Leader>oh",
			":ClangdSwitchSourceHeader<CR>",
			{ noremap = true }
		)
	end,
})

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	pattern = "*",
	callback = function(_) vim.highlight.on_yank { higroup = "IncSearch", timeout = 40 } end,
})

return M
