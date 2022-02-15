local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd

-- default map
local def_map = {
    -- Vim map
    ["n|<C-x>k"] = map_cr("bdelete"):with_noremap():with_silent(),
    ["n|<C-s>"] = map_cu("write"):with_noremap(),
    ["n|Y"] = map_cmd("y$"),
    ["n|D"] = map_cmd("d$"),
    ["n|;"] = map_cmd(":"):with_noremap(),
    ['n|<leader>vs'] = map_cmd(":vsplit <C-r>=expand(\"%:p:h\")<cr>/"):with_noremap(),
    ['n|<leader>s'] = map_cmd(":split <C-r>=expand(\"%:p:h\")<cr>/"):with_noremap(),
    ['n|<leader>te'] = map_cmd(":tabedit <C-r>=expand(\"%:p:h\")<cr>/"):with_noremap(),
    ["n|<leader>["] = map_cr("vertical resize -5"):with_silent(),
    ["n|<leader>]"] = map_cr("vertical resize +5"):with_silent(),
    ["n|<leader>-"] = map_cr("resize -2"):with_silent(),
    ["n|<leader>="] = map_cr("resize +2"):with_silent(),
    ["n|<leader>o"] = map_cr("setlocal spell! spelllang=en_us"),
    ["n|<leader>I"] = map_cmd(":set list!<cr>"):with_noremap(),
    ["n|\\"] = map_cmd(":let @/=''<CR>:noh<CR>"):with_noremap(),
    ["n|<leader>p"] = map_cmd(":%s///g<CR>"):with_noremap():with_silent(),
    ["n|<leader>i"] = map_cmd("gg=G<CR>"):with_noremap():with_silent(),
    ["n|<leader>l"] = map_cmd(":set list! list?<CR>"):with_noremap(),
    ["n|<leader>t"] = map_cmd(":%s/\\s\\+$//e<CR>"):with_noremap(),
    -- Insert
    ["i|jj"] = map_cmd("<Esc>"):with_noremap(),
    ["i|<C-u>"] = map_cmd("<C-G>u<C-U>"):with_noremap(),
    -- command line
    ["c|<C-t>"] = map_cmd([[<C-R>=expand("%:p:h") . "/" <CR>]]):with_noremap(),
    ["c|w!!"] = map_cmd(
        "execute 'silent! write !sudo tee % >/dev/null' <bar> edit!"),
    -- Visual
    ["v|J"] = map_cmd(":m '>+1<cr>gv=gv"),
    ["v|K"] = map_cmd(":m '<-2<cr>gv=gv"),
    ["v|<"] = map_cmd("<gv"),
    ["v|>"] = map_cmd(">gv")
}

bind.nvim_load_mapping(def_map)
