if exists('b:current_syntax')
  finish
endif

exe 'source ' . $VIMRUNTIME . '/syntax/markdown.vim'
unlet! b:current_syntax

" Include tex math in markdown
syn include @tex syntax/tex.vim
syn region mkdMath start="\\\@<!\$" end="\$" skip="\\\$" contains=@tex keepend
syn region mkdMath start="\\\@<!\$\$" end="\$\$" skip="\\\$" contains=@tex keepend

" Define markdown groups
syn region mkdCode      matchgroup=mkdCodeDelimiter start=/\(\([^\\]\|^\)\\\)\@<!`/                     end=/`/                          concealends
syn region mkdCodeBlock matchgroup=mkdCodeDelimiter start=/\(\([^\\]\|^\)\\\)\@<!``/ skip=/[^`]`[^`]/   end=/``/                         concealends
syn region mkdCodeBlock matchgroup=mkdCodeDelimiter start=/^\s*\z(`\{3,}\)[^`]*$/                       end=/^\s*\z1`*\s*$/              concealends
syn region mkdCodeBlock matchgroup=mkdCodeDelimiter start=/\(\([^\\]\|^\)\\\)\@<!\~\~/                  end=/\(\([^\\]\|^\)\\\)\@<!\~\~/ concealends
syn region mkdCodeBlock matchgroup=mkdCodeDelimiter start=/^\s*\z(\~\{3,}\)\s*[0-9A-Za-z_+-]*\s*$/      end=/^\s*\z1\~*\s*$/             concealends
syn region mkdCodeBlock matchgroup=mkdCodeDelimiter start="<pre\(\|\_s[^>]*\)\\\@<!>"                   end="</pre>"                     concealends
syn region mkdCodeBlock matchgroup=mkdCodeDelimiter start="<code\(\|\_s[^>]*\)\\\@<!>"                  end="</code>"                    concealends
syn match  mkdCodeBlock /^\s*\n\(\(\s\{8,}[^ ]\|\t\t\+[^\t]\).*\n\)\+/
syn match  mkdCodeBlock /\%^\(\(\s\{4,}[^ ]\|\t\+[^\t]\).*\n\)\+/
syn match  mkdCodeBlock /^\s*\n\(\(\s\{4,}[^ ]\|\t\+[^\t]\).*\n\)\+/ contained

hi link mkdCode          markdownCode
hi link mkdCodeBlock     markdownCodeBlock
hi link mkdCodeDelimiter markdownCodeDelimiter

let b:current_syntax = 'markdown'
