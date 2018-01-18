" themis: helper: Access to script-local functions.
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpoptions
set cpoptions&vim

let s:Local = g:themis#vital.import('Vim.ScriptLocal')

let s:helper = {}

function! s:helper.funcs(path) abort
  return s:Local.sfuncs(a:path)
endfunction

function! s:helper.vars(path) abort
  return s:Local.svars(a:path)
endfunction

function! themis#helper#scope#new(runner) abort
  return  deepcopy(s:helper)
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
