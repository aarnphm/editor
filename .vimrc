vim9script
filetype plugin indent on

syntax enable

# use vim-plug because of its minimalistic
# ¯\_(ツ)_/¯

var data_dir = expand('~/.vim')
if empty(glob(data_dir .. '/autoload/plug.vim'))
  silent execute '!curl -fLo ' .. data_dir .. '/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

augroup vimrc
  autocmd!
  autocmd! BufWritePost $MYVIMRC source $MYVIMRC | echom "Reloaded $MYVIMRC"
augroup END

plug#begin()
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-apathy'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'rhysd/clever-f.vim'
Plug 'airblade/vim-gitgutter'
Plug 'girishji/vimcomplete'

Plug 'rose-pine/vim', { 'as': 'rose-pine' }

plug#end()

g:mapleader = ' '
g:maplocalleader = ','
g:is_gui = has('gui_running')
g:is_termguicolors = has('termguicolors') && !g:is_gui && $COLORTERM !=# 'xterm-256color'
# tree style file explorer
g:netrw_liststyle = 3

# Minimal
set background=light
colorscheme rosepine_dawn  # rosepine rosepine_dawn rosepine_moon

set number relativenumber

set backspace=indent,eol,start
set complete-=i

set nrformats-=octal

set laststatus=0
set ruler rulerformat=%70(%=%{GitStatus()}\ ›\ %y\ ›\ %{getfsize(@%)}B\ ›\ %P\ ›\ %l:%L%)
set wildmenu wildignore+=*.pyc,*.o,*.obj,*.swp,*.class,*.DS_Store,*.min.* wildmode=longest:full,full wildchar=<Tab>

set display+=lastline

set splitright splitbelow

set incsearch hlsearch
set noshowcmd showmode nojoinspaces
set notitle nowrap hidden
set clipboard=unnamed,unnamedplus
set mouse=a

set conceallevel=0
set foldmethod=manual #indent-syntax-manual
set shortmess+=Ic
set pastetoggle=<F2>

const WIDTH = 2
set expandtab smarttab autoindent
&shiftwidth = WIDTH
&softtabstop = WIDTH
&tabstop = WIDTH

# Performance tuning
set lazyredraw
set ignorecase smartcase

# Misc
set nobackup noswapfile nowritebackup
set undofile undolevels=9999
&undodir = data_dir .. '/undo'

set completeopt=menu,popup completepopup=highlight:Pmenu
set list listchars=tab:›\ ,nbsp:․,trail:·,extends:…,precedes:…
set autoread
&grepprg = 'rg -H --no-heading --vimgrep'
set grepformat=%f:%l:%c:%m

set viminfo='200,<500,s32
set history=1000
set sessionoptions-=options viewoptions-=options

set foldtext=gitgutter#fold#foldtext()

# Display an error message.
def Warn(msg: string)
  echohl ErrorMsg
  echomsg msg
  echohl NONE
enddef

# Call GitGutterGetHunkSummary to show list of git
def! g:GitStatus(): string
  var [a, m, r] = gitgutter#hunk#summary(winbufnr(0))
  return printf('+%d ~%d -%d', a, m, r)
enddef

# Command ':Bclose' executes ':bd' to delete buffer in current window.
# The window will show the alternate buffer (Ctrl-^) if it exists,
# or the previous buffer (:bp), or a blank buffer if no previous.
# Command ':Bclose!' is the same, but executes ':bd!' (discard changes).
# An optional argument can specify which buffer to close (name or number).
def Bclose(bang: string, buffer: string)
  var btarget: number
  if empty(buffer)
    btarget = bufnr('%')
  elseif buffer =~? '^\d\+$'
    btarget = bufnr(str2nr(buffer))
  else
    btarget = bufnr(buffer)
  endif
  if btarget < 0
    Warn('No matching buffer for ' .. buffer)
    return
  endif
  if empty(bang) && getbufvar(btarget, '&modified')
    Warn('No write since last change for buffer ' .. btarget .. ' (use :Bclose!)')
    return
  endif
  # Numbers of windows that view target buffer which we will delete.
  var wnums = range(1, winnr('$'))->filter('winbufnr(v:val) == btarget')
  if !g:bclose_multiple && len(wnums) > 1
    Warn('Buffer is in multiple windows (use ":let bclose_multiple=1")')
    return
  endif
  var wcurrent = winnr()
  for w in wnums
    execute w .. 'wincmd w'
    var prevbuf = bufnr('#')
    if prevbuf > 0 && buflisted(prevbuf) && prevbuf != btarget
      buffer #
    else
      bprevious
    endif
    if btarget == bufnr('%')
      # Numbers of listed buffers which are not the target to be deleted.
      var blisted = range(1, bufnr('$'))->filter('buflisted(v:val) && v:val != btarget')
      # Listed, not target, and not displayed.
      var bhidden = copy(blisted)->filter('bufwinnr(v:val) < 0')
      # Take the first buffer, if any (could be more intelligent).
      var bjump = (bhidden + blisted + [-1])[0]
      if bjump > 0
        execute 'buffer ' .. bjump
      else
        execute 'enew' .. bang
      endif
    endif
  endfor
  execute 'bdelete' .. bang .. ' ' .. btarget
  execute wcurrent .. 'wincmd w'
enddef
command! -bang -complete=buffer -nargs=? Bclose Bclose(<q-bang>, <q-args>)

# Mapping
nnoremap ; :
imap jj <Esc>

# Thanks to Steve Losh for this liberating tip
# See http://stevelosh.com/blog/2010/09/coming-home-to-vim
if exists('plug')
  nnoremap / /\v
  vnoremap / /\v
endif

# We don't use arrow key in vim
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
inoremap <Up> <nop>
inoremap <Down> <nop>
inoremap <Left> <nop>
inoremap <Right> <nop>

# manual folding
inoremap <F5> <C-O>za
nnoremap <F5> za
onoremap <F5> <C-C>za
vnoremap <F5> zf
# Toggle show/hide invisible chars
nnoremap <leader>I :set list!<cr>
nnoremap \\ :let @/=''<CR>:noh<CR>
nnoremap <silent> <leader>p :%s///g<CR>
nnoremap <silent> <leader>i gg=G<CR>
nnoremap <leader># :g/\v^(#\|$)/d_<CR>
nnoremap <leader>b :ls<CR>:buffer<space>
nnoremap <leader>d :w !diff % -<CR>
nnoremap <leader>S :so $MYVIMRC<CR>
nnoremap <leader>l :set list! list?<CR>
nnoremap <leader>t :%s/\s\+$//e<CR>
# Remove the Windows ^M - when the encodings gets messed up
# for somereason bufread doesn't catch  it first
nnoremap <leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm
nnoremap <leader>w :set wrap! wrap?<CR>
# When you press <leader>r you can search and replace the selected text
nnoremap <leader>ml :call AppendModeLine()<CR>
# Visual mode pressing * or # searches for the current selection
# Super useful! From an idea by Michael Naumann
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>
# this is for transient
# Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
# Opens a new tab with the current buffer's path
# Super useful when editing files in the same directory
nnoremap <LocalLeader>vs :vsplit<CR>
nnoremap <LocalLeader>hs :split<CR>
nnoremap <silent><nowait> <space>l :bNext<cr>
nnoremap <silent><nowait> <space>h :bprevious<cr>
nnoremap <silent><nowait> <C-x> :Bclose<CR>
vmap J :m '>+1<cr>gv=gv<CR>
vmap K :m '<-2<cr>gv=gv<CR>

# remove Ex mode
map Q <Nop>
# added yank to clipboard shortcut
noremap <M-Y> "*y
noremap <M-P> "*p
noremap <M-y> "+y
noremap <M-p> "+p
# use this when lightline is not in use for minimal
nnoremap <F2> :set invpaste paste?<CR>
imap <F2><C-O>:set invpaste paste?<CR>
# quick resize for split
nnoremap <silent> <leader>+ :exe "resize " .. (winheight(0) * 3/2)<CR>
nnoremap <silent> <leader>- :exe "resize " .. (winheight(0) * 2/3)<CR>
nnoremap <LocalLeader>p :PlugUpdate<cr>

def CmdLine(str: string)
    feedkeys(':' .. str)
enddef

def VisualSelection(direction: string, extra_filter: string)
    var l:saved_reg = @"
    execute 'normal! vgvy'

    var l:pattern = escape(@", "\\/.*'$^~[]")
    l:pattern = substitute(l:pattern, '\n$', '', '')

    if direction ==? 'gv'
        CmdLine("Ack '" .. l:pattern .. "' ")
    elseif direction ==? 'replace'
        CmdLine('%s' .. '/' .. l:pattern .. '/')
    endif

    @/ = l:pattern
    @" = l:saved_reg
enddef

g:vim_markdown_folding_disabled = 1
g:vim_markdown_conceal = 0
g:vim_markdown_conceal_code_blocks = 0

# fzf
inoremap <expr> <c-x><c-f> fzf#vim#complete#path('fd')
inoremap <expr> <c-x><c-f> fzf#vim#complete#path('rg --files')

inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'window': { 'width': 0.2, 'height': 0.9, 'xoffset': 1 }})

# Default fzf layout
# - down / up / left / right
g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
g:fzf_action = { 'ctrl-s': 'split', 'ctrl-v': 'vsplit' }

# Enable per-command history
# History files will be stored in the specified directory
# When set, CTRL-N and CTRL-P will be bound to 'next-history' and
# 'previous-history' instead of 'down' and 'up'.
nnoremap <silent><nowait> <Leader>f :call fzf#run(fzf#wrap({'source': 'git ls-files', 'sink': 'e'}))<CR>
nnoremap <silent><nowait> <C-g> :Lines<CR>
nnoremap <silent><nowait> <Leader>b :Buffers<CR>

# gitgutter
def! g:GitGutterNextHunkCycle()
  var line = line('.')
  silent! GitGutterNextHunk
  if line('.') == line
    1
    GitGutterNextHunk
  endif
enddef

def! g:GitGutterPrevHunkCycle()
  var line = line('.')
  silent! GitGutterPrevHunk
  if line('.') == line
    normal! G
    GitGutterPrevHunk
  endif
enddef

g:gitgutter_enabled = 1
g:gitgutter_diff_args = '-w'
g:gitgutter_grep = 'rg'
nmap <silent> ]h :call GitGutterNextHunkCycle()<CR>
nmap <silent> [h :call GitGutterPrevHunkCycle()<CR>
