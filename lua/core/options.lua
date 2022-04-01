local M = {}

function M.setup_options()
  local config = __editor_config

  local vim_opt = {
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
    termguicolors = true,
    backspace = "indent,eol,start",
    complete = ".,w,b,k",
    smarttab = true,
    nrformats = "bin,hex",
    timeout = true,
    ttimeout = false,
    timeoutlen = 500,
    ttimeoutlen = 100,
    ruler = false,
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
    undodir = __editor_global.cache_dir .. "undo/",
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
    winwidth = 35,
    winminwidth = 20,
    pumheight = 15,
    helpheight = 12,
    previewheight = 12,
    showcmd = false,
    cmdheight = 1,
    cmdwinheight = 5,
    equalalways = false,
    display = "lastline",
    showbreak = "↳  ",
    listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←",
    winblend = 10,
    autowrite = true,
  }

  vim.g.python3_host_prog = config.options.python3_host_prog

  if __editor_global.is_mac then
    vim.g.clipboard = {
      name = "macOS-clipboard",
      copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
      paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
      cache_enabled = 0,
    }
  end

  for name, value in pairs(vim_opt) do
    vim.o[name] = value
  end

  --Defer loading shada until after startup_
  vim.opt.shadafile = "NONE"
  vim.schedule(function()
    vim.opt.shadafile = __editor_config.options.shadafile
    vim.cmd([[ silent! rsh ]])
  end)
end

return M
