" Themis command line processor.
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

function! themis#command#start(args) abort
  let [paths, options] = s:parse_args(a:args)
  if get(options, 'exit', 0)
    return
  endif

  if empty(paths)
    let paths = filter(['./test', './t', './spec'], 'isdirectory(v:val)')[: 0]
  endif

  return themis#run(paths, options)
endfunction

" Command line option processor
let s:short_options = {
\   'h': 'help',
\   'r': 'recursive',
\   'v': 'version',
\ }
function! s:parse_args(args) abort
  let paths = []
  let options = themis#option#empty_options()
  let args = copy(a:args)
  while !empty(args)
    let arg = remove(args, 0)
    if arg =~# '^--'
      call s:process_option(arg[2 :], args, options)
    elseif arg =~# '^-'
      for option in split(arg[1 :], '.\zs')
        if !has_key(s:short_options, option)
          throw 'themis: Unknown option: -' . option
        endif
        call s:process_option(s:short_options[option], args, options)
      endfor
    else
      let paths += [arg]
    endif
  endwhile
  return [paths, options]
endfunction

let s:options = {}
function! s:options.exclude(args, options) abort
  if empty(a:args)
    throw 'themis: --exclude option requires {pattern}'
  endif
  let a:options.exclude += [remove(a:args, 0)]
endfunction

function! s:options.target(args, options) abort
  if empty(a:args)
    throw 'themis: --target option requires {pattern}'
  endif
  let a:options.target += [remove(a:args, 0)]
endfunction

function! s:options.recursive(args, options) abort
  let a:options.recursive = 1
endfunction

function! s:options.reporter(args, options) abort
  if empty(a:args)
    throw 'themis: --reporter option requires {name}'
  endif
  let a:options.reporter = remove(a:args, 0)
endfunction

function! s:options.reporter_list(args, options) abort
  let reporters = themis#module#list('reporter')
  call themis#log(join(reporters, "\n"))
  let a:options.exit = 1
endfunction

function! s:options.runtimepath(args, options) abort
  if empty(a:args)
    throw 'themis: --runtime option requires {path}'
  endif
  let a:options.runtimepath += [remove(a:args, 0)]
endfunction

function! s:options.debug(args, options) abort
  let $THEMIS_DEBUG = 1
endfunction

function! s:options.help(args, options) abort
  " TODO: automate options
  call themis#log(join([
  \   'themis: A testing framework for Vim script.',
  \   'Usage: themis [option]... [path]...',
  \   '',
  \   '   --exclude {pattern}      Exclude files',
  \   '   --target {pattern}       Run tests whose full title matches to {pattern}',
  \   '-r --recursive              Include sub directories',
  \   '   --reporter {name}        Select a reporter',
  \   '   --reporter-list          Show available reporters',
  \   '   --runtimepath {path}     Add runtimepath',
  \   '-v --version                Print version',
  \   '-h --help                   Show this help',
  \ ], "\n"))
  let a:options.exit = 1
endfunction

function! s:options.version(args, options) abort
  call themis#log('themis version ' . themis#version())
  let a:options.exit = 1
endfunction

function! s:process_option(name, args, options) abort
  let name = substitute(a:name, '-', '_', 'g')
  if has_key(s:options, name)
    call s:options[name](a:args, a:options)
  else
    " FIXME: wrong error for short option
    throw 'themis: Unknown option: --' . a:name
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
