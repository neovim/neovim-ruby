" themis: Module loader.
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

function! themis#module#exists(type, name) abort
  let path = printf('autoload/themis/%s/%s.vim', a:type, a:name)
  return globpath(&runtimepath, path, 1) !=# ''
endfunction

function! themis#module#list(type) abort
  let pat = 'autoload/themis/' . a:type . '/*.vim'
  return themis#util#sortuniq(map(split(globpath(&runtimepath, pat, 1), "\n"),
  \                     'fnamemodify(v:val, ":t:r")'))
endfunction

function! themis#module#load(type, name, args) abort
  try
    let module = call(printf('themis#%s#%s#new', a:type, a:name), a:args)
    " XXX: It may perform two or more times.
    call themis#func_alias(
    \   {printf('themis/%s[%s]', a:type, string(a:name)): module})
    let module.type = a:type
    let module.name = a:name
    return module
  catch /^Vim(\w\+):E117/
    throw printf('themis: Unknown %s: "%s"', a:type, a:name)
  endtry
endfunction

function! themis#module#style(name) abort
  return themis#module#load('style', a:name, [])
endfunction

function! themis#module#reporter(name) abort
  return themis#module#load('reporter', a:name, [])
endfunction

function! themis#module#supporter(name, runner) abort
  return themis#module#load('supporter', a:name, [a:runner])
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
