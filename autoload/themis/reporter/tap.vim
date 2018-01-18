" themis: reporter: Report with TAP(Test Anything Protocol).
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

let s:reporter = {}

function! s:reporter.init(runner, root_bundle) abort
  let self.stats = a:runner.supporter('stats')
  let self.root_bundle = a:root_bundle
endfunction

function! s:reporter.start(runner) abort
  call themis#log('1..' . self.root_bundle.total_test_count())
endfunction

function! s:reporter.pass(report) abort
  let title = a:report.get_full_title()
  let mes = printf('ok %d - %s', self.stats.count(), title)
  call themis#log(mes)
endfunction

function! s:reporter.fail(report) abort
  let title = a:report.get_full_title()
  let mes = printf('not ok %d - %s', self.stats.count(), title)
  call themis#log(mes)
  call s:print_message(a:report.get_message())
endfunction

function! s:reporter.pending(report) abort
  let title = a:report.get_full_title()
  let mes = printf('ok %d - %s # SKIP', self.stats.count(), title)
  call themis#log(mes)
  call s:print_message(a:report.get_message())
endfunction

function! s:reporter.error(phase, info) abort
  call themis#log(printf('Bail out!  Error occurred in %s.', a:phase))
  if has_key(a:info, 'stacktrace')
    call s:print_message(themis#util#error_info(a:info.stacktrace))
  endif
  call s:print_message(a:info.exception)
endfunction

function! s:reporter.end(runner) abort
  call themis#log('')
  call s:print_message(self.stats.stat())
endfunction


function! s:print_message(message) abort
  let lines = type(a:message) == type([]) ? a:message : split(a:message, "\n")
  for line in lines
    call themis#log('# ' . line)
  endfor
endfunction

function! themis#reporter#tap#new() abort
  return deepcopy(s:reporter)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
