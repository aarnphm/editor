local global = require("core.global")

local M = {}
M.__index = M

function M:bind_option(options)
  for k, v in pairs(options) do
    if v == true then
      vim.cmd("set " .. k)
    elseif v == false then
      vim.cmd("set no" .. k)
    else
      vim.cmd("set " .. k .. "=" .. v)
    end
  end
end

function M:load_options(config)
  local bw_local = {
    number = true,
    relativenumber = true,
    autoindent = true,
    title = false,
    wrap = false,
    conceallevel = 0,
    concealcursor = "niv",
    pumblend = 0,
    expandtab = true,
    shiftwidth = 4,
    tabstop = 4,
    softtabstop = -1,
    undofile = true,
    synmaxcol = 2500,
    formatoptions = "1jcroql",
    textwidth = 80,
    breakindentopt = "shift:2,min:20",
    linebreak = true,
    foldenable = true,
    signcolumn = "yes",
  }

  local global_local = {
    termguicolors = true,
    backspace = "indent,eol,start",
    complete = ".,w,b,k",
    smarttab = true,
    nrformats = "bin,hex",
    timeout = true,
    ttimeout = false,
    timeoutlen = 500,
    ttimeoutlen = 100,
    ruler = true,
    wildmenu = true,
    scrolloff = 1,
    sidescrolloff = 5,
    incsearch = true,
    hlsearch = true,
    showmode = false,
    hidden = true,
    clipboard = "unnamedplus",
    mouse = "a",
    wildmode = "longest:full,full",
    wildignorecase = true,
    wildignore = ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**",
    wildchar = 9,
    shortmess = "aoOTIcF",
    splitbelow = true,
    splitright = true,
    lazyredraw = true,
    swapfile = false,
    backup = false,
    writebackup = false,
    undodir = global.cache_dir .. "undo/",
    undolevels = 9999,
    encoding = "utf-8",
    list = true,
    errorbells = true,
    visualbell = true,
    autoread = true,
    fileformats = "unix,mac,dos",
    magic = true,
    virtualedit = "block",
    viewoptions = "folds,cursor,curdir,slash,unix",
    sessionoptions = "curdir,help,tabpages,winsize",
    history = 2000,
    shada = "!,'300,<50,@100,s10,h",
    backupskip = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim",
    shiftround = true,
    updatetime = 100,
    ignorecase = true,
    smartcase = true,
    infercase = true,
    wrapscan = true,
    inccommand = "nosplit",
    grepformat = "%f:%l:%c:%m",
    grepprg = "rg --hidden --vimgrep --smart-case --",
    breakat = [[\ \	;:,!?]],
    switchbuf = "useopen",
    diffopt = "filler,iwhite,internal,algorithm:patience",
    completeopt = "menuone,noselect",
    jumpoptions = "stack",
    foldlevelstart = 99,
    cursorline = true,
    cursorcolumn = true,
    showtabline = 2,
    winwidth = 30,
    winminwidth = 10,
    pumheight = 15,
    helpheight = 12,
    previewheight = 12,
    showcmd = false,
    cmdheight = 2,
    cmdwinheight = 5,
    equalalways = false,
    laststatus = 2,
    display = "lastline",
    showbreak = "↳  ",
    listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←",
    pumblend = 10,
    winblend = 10,
    autowrite = true,
  }

  vim.g.python3_host_prog = config.python3_host_prog

  if global.is_mac then
    vim.g.clipboard = {
      name = "macOS-clipboard",
      copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
      paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
      cache_enabled = 0,
    }
  end
  for name, value in pairs(global_local) do
    vim.o[name] = value
  end
  M:bind_option(bw_local)
end

return M
