" themis: supporter: builtin_assert: Handle Vim built-in assertion functions.
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpoptions
set cpoptions&vim

let s:receiver = {}

function! s:receiver.start_test(bundle, entry) abort
  if exists('v:errors')
    let v:errors = []
  endif
endfunction

function! s:receiver.end_test(report) abort
  if !exists('v:errors')
    return
  endif
  for error in v:errors
    let [throwpoint, exception] = matchlist(error, '\v([^:]+):\s*(.*)')[1 : 2]
    call a:report.add_exception(exception, throwpoint)
  endfor
  let v:errors = []
endfunction

function! s:parse_error(error) abort
  let matched = matchlist(a:error, '\v^(.{-}) line (\d+):\s*(.+)$')
endfunction

function! themis#supporter#builtin_assert#new(runner) abort
  call a:runner.add_event(deepcopy(s:receiver))
  return {}
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
