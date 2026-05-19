if !get(b:, "simple_bigfile", 0)
  finish
endif

syntax clear markdownError
syntax clear markdownItalic
syntax clear markdownBold
syntax clear markdownBoldItalic

let s:concealends = ""
if has("conceal") && get(g:, "markdown_syntax_conceal", 1) == 1
  let s:concealends = " concealends"
endif

execute 'syntax region markdownItalic matchgroup=markdownItalicDelimiter start="\*\S\@=" end="\S\@<=\*\|^$" skip="\\\*" contains=markdownLineStart,@Spell' . s:concealends
execute 'syntax region markdownBold matchgroup=markdownBoldDelimiter start="\*\*\S\@=" end="\S\@<=\*\*\|^$" skip="\\\*" contains=markdownLineStart,markdownItalic,@Spell' . s:concealends
execute 'syntax region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter start="\*\*\*\S\@=" end="\S\@<=\*\*\*\|^$" skip="\\\*" contains=markdownLineStart,@Spell' . s:concealends

unlet s:concealends
