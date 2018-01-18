" themis: supporter: stats: Record test stats.
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim


let s:receiver = {
\   '_count': 0,
\   '_passes': 0,
\   '_failures': 0,
\   '_pendings': 0,
\ }
let s:supporter = {'receiver': s:receiver}


function! s:receiver.start_test(bundle, title) abort
  let self._count += 1
endfunction

function! s:receiver.pass(report) abort
  let self._passes += 1
endfunction

function! s:receiver.fail(report) abort
  let self._failures += 1
endfunction

function! s:receiver.pending(report) abort
  let self._pendings += 1
endfunction


function! s:supporter.count() abort
  return self.receiver._count
endfunction

function! s:supporter.pass() abort
  return self.receiver._passes
endfunction

function! s:supporter.fail() abort
  return self.receiver._failures
endfunction

function! s:supporter.pending() abort
  return self.receiver._pendings
endfunction

function! s:supporter.stat() abort
  let result = ['tests ' . self.count(), 'passes ' . self.pass()]

  let pending = self.pending()
  if pending != 0
    let result += ['pendings ' . pending]
  endif

  let fail = self.fail()
  if fail != 0
    let result += ['fails ' . fail]
  endif

  return join(result, "\n")
endfunction

function! themis#supporter#stats#new(runner) abort
  let supporter = deepcopy(s:supporter)
  call a:runner.add_event(supporter.receiver)
  return supporter
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
