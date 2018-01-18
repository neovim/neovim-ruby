" themis: A report of test.
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

let s:Report = {
\   'result': 'yet',
\   'exceptions': [],
\ }

function! s:Report.is_success() abort
  return self.result ==# 'pass'
endfunction

function! s:Report.get_full_title() abort
  return self.bundle.get_test_full_title(self.entry)
endfunction

function! s:Report.get_title() abort
  return self.bundle.get_test_title(self.entry)
endfunction

function! s:Report.get_message() abort
  return join(map(copy(self.exceptions), 'v:val.message'), "\n---\n")
endfunction

function! s:Report.add_exception(exception, throwpoint) abort
  let callstack = themis#util#callstacklines(a:throwpoint, -1)
  if a:exception =~? '^themis:\_s*report:'
    let result = matchstr(a:exception, '\c^themis:\_s*report:\_s*\zs.*')
    let [type, message] =
    \   matchlist(result, '\v^%((\w+):\s*)?(.*)')[1 : 2]
  else
    let type = 'error'
    let message = join(callstack, "\n") . "\n\n" . a:exception
  endif
  let self.exceptions += [{
  \   'type': type,
  \   'exception': a:exception,
  \   'throwpoint': a:throwpoint,
  \   'message': message,
  \   'callstack': callstack,
  \ }]

  if type =~# '^\u\+$' && self.result !=# 'fail'
    let self.result = 'pending'
  else
    let self.result = 'fail'
  endif
endfunction

function! themis#report#new(bundle, entry) abort
  let report = deepcopy(s:Report)
  let report.bundle = a:bundle
  let report.entry = a:entry
  return report
endfunction

call themis#func_alias({'themis/Report': s:Report})


let &cpo = s:save_cpo
unlet s:save_cpo
