" themis: reporter: Report with xUnit style.
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

let s:reporter = {}

function! s:reporter.init(runner, root_bundle) abort
  let self.stats = a:runner.supporter('stats')
  let self.pending_list = []
  let self.failure_list = []
endfunction

function! s:reporter.pass(report) abort
  call themis#logn('.')
endfunction

function! s:reporter.fail(report) abort
  let self.failure_list += [a:report]
  call themis#logn('F')
endfunction

function! s:reporter.pending(report) abort
  let self.pending_list += [a:report]
  call themis#logn('P')
endfunction

function! s:reporter.end(runner) abort
  call themis#log("\n")

  call s:print_reports('Pending', self.pending_list)
  call s:print_reports('Failures', self.failure_list)

  call themis#log(self.stats.stat())
endfunction

function! s:reporter.error(phase, info) abort
  call themis#log('')
  call themis#log(printf('Error occurred in %s.', a:phase))
  if has_key(a:info, 'stacktrace')
    call themis#log(themis#util#error_info(a:info.stacktrace))
  endif
  call themis#log(a:info.exception)
endfunction

function! s:print_reports(title, reports) abort
  if empty(a:reports)
    return
  endif
  call themis#log(a:title . ':')
  let n = 1
  for report in a:reports
    call s:print_report(n, report)
    let n += 1
    call themis#log('')
  endfor
endfunction

function! s:print_report(n, report) abort
  call themis#log(printf('%3d) %s', a:n, a:report.get_full_title()))
  call themis#log(map(split(a:report.get_message(), "\n"), '"     " . v:val'))
endfunction

function! themis#reporter#dot#new() abort
  return deepcopy(s:reporter)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
