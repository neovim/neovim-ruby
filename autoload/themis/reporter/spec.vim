" themis: reporter: Report with spec style.
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

if has('win32')
  let s:pass_symbol = 'o'
  let s:fail_symbol = 'x'
else
  let s:pass_symbol = '✓'
  let s:fail_symbol = '✖'
endif

let s:reporter = {}

function! s:reporter.init(runner, root_bundle) abort
  let self.stats = a:runner.supporter('stats')
  let self.indent = 0
endfunction

function! s:reporter.start(runner) abort
endfunction

function! s:reporter.before_suite(bundle) abort
  let title = a:bundle.get_title()
  if title !=# ''
    call self.print(title)
    let self.indent += 1
  endif
endfunction

function! s:reporter.after_suite(bundle) abort
  let title = a:bundle.get_title()
  if title !=# ''
    let self.indent -= 1
  endif
endfunction

function! s:reporter.pass(report) abort
  call self.print(printf('[%s] %s', s:pass_symbol, a:report.get_title()))
endfunction

function! s:reporter.fail(report) abort
  call self.print(printf('[%s] %s', s:fail_symbol, a:report.get_title()))
  call self.print(a:report.get_message(), '    ')
endfunction

function! s:reporter.pending(report) abort
  call self.print(printf('[-] %s', a:report.get_title()))
  call self.print(a:report.get_message(), '    ')
endfunction

function! s:reporter.error(phase, info) abort
  call themis#log(printf('Error occurred in %s.', a:phase))
  if has_key(a:info, 'stacktrace')
    call themis#log(themis#util#error_info(a:info.stacktrace))
  endif
  call themis#log(a:info.exception)
endfunction

function! s:reporter.end(runner) abort
  call themis#log('')
  call self.print(self.stats.stat())
endfunction


function! s:reporter.print(message, ...) abort
  let prefix = a:0 ? a:1 : ''
  for line in split(a:message, "\n")
    call themis#log(prefix . repeat('  ', self.indent) . line)
  endfor
endfunction

function! themis#reporter#spec#new() abort
  return deepcopy(s:reporter)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
