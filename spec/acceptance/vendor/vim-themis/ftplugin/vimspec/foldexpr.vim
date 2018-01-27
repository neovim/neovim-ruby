" Vimspec filetype plugin for folding

if exists('b:did_fold')
  finish
endif
let b:did_fold = 1

setlocal foldexpr=GetVimspecFold(v:lnum)
setlocal foldmethod=expr

if exists('*GetVimspecFold')
  finish
endif

function! GetVimspecFold(lnum) abort
  let line = getline(a:lnum)
  if line =~# s:pattern_folds
    return 'a1'
  elseif line =~# s:pattern_folde
    return 's1'
  endif
  return '='
endfunction

let s:pattern_folds = '\v^\s*%([Dd]escribe|[Cc]ontext|[Ii]t|[Bb]efore|[Aa]fter)'
let s:pattern_folde = '\v^\s*[Ee]nd$'
