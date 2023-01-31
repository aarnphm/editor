local M = {}

M.setup = function()
  local global_opt = {
    termguicolors = true,
    complete = ".,w,b,k",
    nrformats = "bin,hex",
    wildmenu = true,
    hlsearch = true,
    showmode = false,
    mouse = "a",
    wildmode = "longest:full,full",
    wildchar = 9,
    lazyredraw = true,
    undolevels = 9999,
    errorbells = true,
    visualbell = true,
    hidden = true,
    fileformats = "unix,mac,dos",
    magic = true,
    virtualedit = "block",
    encoding = "utf-8",
    viewoptions = "folds,cursor,curdir,slash,unix",
    sessionoptions = "curdir,help,tabpages,winsize",
    clipboard = "unnamedplus",
    wildignorecase = true,
    wildignore = ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**",
    backup = false,
    writebackup = false,
    swapfile = false,
    undodir = __editor_global.cache_dir .. "undo/",
    history = 2000,
    shada = "!,'300,<50,@100,s10,h",
    backupskip = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim",
    smarttab = true,
    shiftround = true,
    timeout = true,
    ttimeout = true,
    timeoutlen = 500,
    ttimeoutlen = 0,
    updatetime = 100,
    redrawtime = 1500,
    ignorecase = true,
    smartcase = true,
    infercase = true,
    incsearch = true,
    wrapscan = true,
    inccommand = "nosplit",
    grepformat = "%f:%l:%c:%m",
    grepprg = "rg --hidden --vimgrep --smart-case --",
    breakat = [[\ \	;:,!?]],
    startofline = false,
    whichwrap = "h,l,<,>,[,],~",
    splitbelow = true,
    splitright = true,
    switchbuf = "useopen",
    backspace = "indent,eol,start",
    diffopt = "filler,iwhite,internal,algorithm:patience",
    completeopt = "menuone,noselect",
    jumpoptions = "stack",
    shortmess = "aoOTIcF",
    scrolloff = 2,
    sidescrolloff = 5,
    mousescroll = "ver:3,hor:6",
    foldlevelstart = 99,
    ruler = true,
    cursorline = true,
    cursorcolumn = true,
    list = true,
    showtabline = 2,
    winwidth = 30,
    winminwidth = 10,
    pumheight = 15,
    helpheight = 12,
    previewheight = 12,
    showcmd = false,
    cmdheight = 1, -- 0, 1, 2
    cmdwinheight = 5,
    equalalways = false,
    laststatus = 2,
    display = "lastline",
    showbreak = "↳  ",
    listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←",
    autoread = true,
    autowrite = true,
    undofile = true,
    synmaxcol = 2500,
    formatoptions = "1jcroql",
    expandtab = true,
    autoindent = true,
    tabstop = 4,
    shiftwidth = 4,
    softtabstop = 4,
    breakindentopt = "shift:2,min:20",
    wrap = false,
    linebreak = true,
    number = true,
    relativenumber = true,
    foldenable = true,
    signcolumn = "yes",
    conceallevel = 0,
    concealcursor = "niv",
  }

  local isempty = function(s)
    return s == nil or s == ""
  end

  -- custom python provider
  local conda_prefix = os.getenv("CONDA_PREFIX")
  if not isempty(conda_prefix) then
    vim.g.python_host_prog = conda_prefix .. "/bin/python"
    vim.g.python3_host_prog = conda_prefix .. "/bin/python"
  else
    vim.g.python3_host_prog = vim.env["PYTHON3_HOST_PROG"]
  end

  if __editor_global.is_mac then
    vim.g.clipboard = {
      name = "macOS-clipboard",
      copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
      paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
      cache_enabled = 0,
    }
  end

  for name, value in pairs(global_opt) do
    vim.o[name] = value
  end
end

M.setup()

return M
