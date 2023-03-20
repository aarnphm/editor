--# selene: allow(global_usage)
local autocmd = vim.api.nvim_create_autocmd

-- simple configuration
local M = {
	window      = { resize = 10                                  },                                      -- Windows opts
	diagnostic  = { show_float = false, use_virtual_text = false },                                      -- Whether to show the diagnostic popup
	ui          = vim.NIL ~= vim.env.SIMPLE_UI          and vim.env.SIMPLE_UI		   or false,		 -- Whether to make completion fancy or simple border
	colorscheme = vim.NIL ~= vim.env.SIMPLE_COLORSCHEME and vim.env.SIMPLE_COLORSCHEME or "oxocarbon",   -- colorscheme go brr
	background  = vim.NIL ~= vim.env.SIMPLE_BACKGROUND  and vim.env.SIMPLE_BACKGROUND  or "dark",		 -- dark or light go brr
}

-- Some defaults and don't question it
vim.o.wrap           = false                                    -- egh i don't like wrap
vim.o.writebackup    = false                                    -- whos needs backup btw (i do sometimes)
vim.o.autowrite      = true                                     -- sometimes I forget to save
vim.o.guicursor      = ""                                       -- no gui cursor
vim.o.undofile       = true                                     -- set undofile to infinite undo
vim.o.breakindent    = true                                     -- enable break indent
vim.o.breakindentopt = "shift:2,min:20"                         -- wrap two spaces, with min of 20 text width
vim.o.clipboard      = "unnamedplus"                            -- sync system clipboard
vim.o.pumheight      = 8                                        -- larger completion windows
vim.o.completeopt    = "menuone,noselect,menu"                  -- better completion menu
vim.o.expandtab      = true                                     -- convert spaces to tabs
vim.o.mouse          = "a"                                      -- ugh who needs mouse (accept on SSH maybe)
vim.o.number         = true                                     -- number is good for nav
vim.o.relativenumber = true                                     -- relativenumber is useful, grow up
vim.o.swapfile       = false                                    -- I don't like swap files personally, found undofile to be better
vim.o.undofile       = true                                     -- better than swapfile
vim.o.undolevels     = 9999                                     -- infinite undo
vim.o.shortmess      = "aoOTIcF"                                -- insanely complex shortmess, but its cleannn
vim.o.laststatus     = 2                                        -- show statusline on buffer
vim.o.statusline     = require("user.utils").statusline.build() -- statusline PepeLaugh

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
vim.o.smartcase   = true
vim.o.ignorecase  = true
vim.o.infercase   = true
vim.o.grepprg     = "rg --hidden --vimgrep --smart-case --"  -- also its 2023 use rg
vim.o.linebreak   = true
vim.o.jumpoptions = "stack"
vim.o.listchars   = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"

-- Spaces and tabs config
vim.o.tabstop     = 4
vim.o.softtabstop = 4
vim.o.shiftwidth  = 4
vim.o.shiftround  = true

-- UI config
vim.o.cmdheight     = 1
vim.o.showtabline   = 0
vim.o.showcmd       = false
vim.o.showmode      = true
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
vim.opt.wildignore   = { "__pycache__", "*.o", "*~", "*.pyc", "*pycache*", "Cargo.lock", "lazy-lock.json" }

-- disable some default providers
for _, provider in ipairs { "node", "perl", "python3", "ruby" } do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end

if vim.loop.os_uname().sysname == "Darwin" then
	vim.g.clipboard = {
		name          = "macOS-clipboard",
		copy          = { ["+"] = "pbcopy",  ["*"] = "pbcopy"  },
		paste         = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
		cache_enabled = 0,
	}
end

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
map("n", "<S-Tab>",         "<cmd>normal za<cr>",                                           { desc = "edit: Toggle code fold"                            })
map("n", "Y",               "y$",                                                           { desc = "edit: Yank text to EOL"                            })
map("n", "D",               "d$",                                                           { desc = "edit: Delete text to EOL"                          })
map("n", "J",               "mzJ`z",                                                        { desc = "edit: Join next line"                              })
map("n", "\\",              ":let @/=''<CR>:noh<CR>",                                       { silent = true, desc = "window: Clean highlight"            })
map("n", ";",               ":",                                                            { silent = false, desc = "command: Enter command mode"       })
map("n", ";;",               ";",                                                           { silent = false, desc = "normal: Enter Ex mode"             })
map("v", "J",               ":m '>+1<CR>gv=gv",                                             { desc = "edit: Move this line down"                         })
map("v", "K",               ":m '<-2<CR>gv=gv",                                             { desc = "edit: Move this line up"                           })
map("v", "<",               "<gv",                                                          { desc = "edit: Decrease indent"                             })
map("v", ">",               ">gv",                                                          { desc = "edit: Increase indent"                             })
map("c", "W!!",             "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!",   { desc = "edit: Save file using sudo"                        })
map("n", "<C-h>",           "<C-w>h",                                                       { desc = "window: Focus left"                                })
map("n", "<C-l>",           "<C-w>l",                                                       { desc = "window: Focus right"                               })
map("n", "<C-j>",           "<C-w>j",                                                       { desc = "window: Focus down"                                })
map("n", "<LocalLeader>|",  "<C-w>|",                                                       { desc = "window: Maxout width"                              })
map("n", "<LocalLeader>-",  "<C-w>_",                                                       { desc = "window: Maxout width"                              })
map("n", "<LocalLeader>=",  "<C-w>=",                                                       { desc = "window: Equal size"                                })
map("n", "<C-k>",           "<C-w>k",                                                       { desc = "window: Focus up"                                  })
map("n", "<Leader>qq",      "<cmd>wqa<cr>",                                                 { desc = "editor: write quit all"                            })
map("n", "<Leader>.",       "<cmd>bnext<cr>",                                               { desc = "buffer: next"                                      })
map("n", "<Leader>,",       "<cmd>bprevious<cr>",                                           { desc = "buffer: previous"                                  })
map("n", "<Leader>q",       "<cmd>copen<cr>",                                               { desc = "quickfix: Open quickfix"                           })
map("n", "<Leader>l",       "<cmd>lopen<cr>",                                               { desc = "quickfix: Open location list"                      })
map("n", "<Leader>n",       "<cmd>enew<cr>",                                                { desc = "buffer: new"                                       })
map("n", "<LocalLeader>sw", "<C-w>r",                                                       { desc = "window: swap position"                             })
map("n", "<LocalLeader>vs", "<C-w>v",                                                       { desc = "edit: split window vertically"                     })
map("n", "<LocalLeader>hs", "<C-w>s",                                                       { desc = "edit: split window horizontally"                   })
map("n", "<LocalLeader>cd", ":lcd %:p:h<cr>",                                               { desc = "misc: change directory to current file buffer"     })
map("n", "<LocalLeader>l",  "<cmd>set list! list?<cr>",                                     { silent = false, desc = "misc: toggle invisible characters" })
map("n", "<LocalLeader>]",  string.format("<cmd>vertical resize -%s<cr>", M.window.resize), { noremap = false, desc = "windows: resize right 10px"       })
map("n", "<LocalLeader>[",  string.format("<cmd>vertical resize +%s<cr>", M.window.resize), { noremap = false, desc = "windows: resize left 10px"        })
map("n", "<LocalLeader>-",  string.format("<cmd>resize -%s<cr>",          M.window.resize), { noremap = false, desc = "windows: resize down 10px"        })
map("n", "<LocalLeader>+",  string.format("<cmd>resize +%s<cr>",          M.window.resize), { noremap = false, desc = "windows: resize up 10px"          })
map("n", "<LocalLeader>f",  require('lsp').toggle,                                          { desc = "lsp: Toggle formatter"                             })
map("n", "<LocalLeader>p",  "<cmd>Lazy<cr>",                                                { desc = "package: show manager"                             })
map("n", "<C-\\>",          "<cmd>execute v:count . 'ToggleTerm direction=horizontal'<cr>", { desc = "terminal: Toggle horizontal"                       })
map("i", "<C-\\>",          "<Esc><cmd>ToggleTerm direction=horizontal<cr>",                { desc = "terminal: Toggle horizontal"                       })
map("t", "<C-\\>",          "<Esc><cmd>ToggleTerm<cr>",                                     { desc = "terminal: Toggle horizontal"                       })
map("n", "<C-t>",           "<cmd>execute v:count . 'ToggleTerm direction=vertical'<cr>",   { desc = "terminal: Toggle vertical"                         })
map("i", "<C-t>",           "<Esc><cmd>ToggleTerm direction=vertical<cr>",                  { desc = "terminal: Toggle vertical"                         })
map("t", "<C-t>",           "<Esc><cmd>ToggleTerm<cr>",                                     { desc = "terminal: Toggle vertical"                         })

-- NOTE: diagnostic config
for _, type in pairs { "Error", "Warn", "Hint", "Info" } do
	local hl = string.format("DiagnosticSign%s", type)
	vim.fn.sign_define(hl, { text = "●", texthl = hl, numhl = hl })
end

vim.diagnostic.config {
    severity_sort    = true,
    underline        = false,
    update_in_insert = false,
	virtual_text     = M.diagnostic.use_virtual_text and { prefix = "", spacing = 4 } or false,
	float            = not M.ui and {
		border = "simple",
		format = function(diagnostic) return string.format("%s (%s) [%s]", diagnostic.message, diagnostic.source, diagnostic.code or diagnostic.user_data.lsp.code) end,
	} or false,
}


M.toggle_float_diagnostic = function ()
	M.diagnostic.show_float = not M.diagnostic.show_float
	if M.diagnostic.show_float then
		vim.notify("diagnostic: Enable showing float on hover", vim.log.levels.INFO)
	else
		vim.notify("diagnostic: Disable showing float on hover", vim.log.levels.INFO)
	end
end

map("n", "<LocalLeader>d", M.toggle_float_diagnostic, { desc = "diagnostic: Toggle float" })

-- diagnostic on hover
autocmd({ "CursorHold", "CursorHoldI" }, {
	group = _G.simple_augroup "diagnostic_show_float",
	pattern = "*",
	callback = function()
		if require("user.options").diagnostic.show_float then
			vim.diagnostic.open_float(nil, { focus = false })
		end
	end,
})

return M
