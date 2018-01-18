" themis: Utility functions.
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

let s:func_aliases = {}
let s:line_adjuster = {}

let s:StackInfo = {
\   'stack': '',
\   'type': '',
\   'line': 0,
\   'filled': 0,
\ }

function! s:StackInfo.fill_info() abort
  if self.filled
    return
  endif
  if themis#util#is_funcname(self.stack)
    call extend(self, themis#util#funcdata(self.stack), 'keep')
    let self.type = 'function'
  elseif filereadable(self.stack)
    let self.exists = 1
    let self.filename = self.stack
    let self.funcname = ''
    let self.type = 'file'
  else
    let self.exists = 0
    let self.funcname = self.stack
    let self.type = 'unknown'
  endif
  let self.filled = 1
endfunction

function! s:StackInfo.make_signature() abort
  let funcname = get(s:func_aliases, self.funcname, self.funcname)
  let args = join(self.arguments, ', ')
  let flags = ''
  if self.is_abort
    let flags .= ' abort'
  endif
  if self.has_range
    let flags .= ' range'
  endif
  if self.is_dict
    let flags .= ' dict'
  endif
  return printf('function %s(%s)%s', funcname, args, flags)
endfunction

function! s:StackInfo.format() abort
  call self.fill_info()
  if !self.exists
    return printf('function %s()  This function is already deleted.',
    \             self.funcname)
  endif

  if self.type ==# 'file'
    return printf('%s Line:%d', self.filename, self.line)
  endif
  if self.type ==# 'function'
    let result = self.make_signature()
    if self.line
      let result .= '  Line:' . self.adjusted_lnum()
    endif
    return result . '  (' . self.filename . ')'
  endif
  return 'Unknown Stack'
endfunction

function! s:StackInfo.get_line(...) abort
  let lnum = a:0 ? a:1 : self.line
  call self.fill_info()
  if self.type ==# 'file'
    if !has_key(self, 'body')
      let self.body = readfile(self.filename)
    endif
    return get(self.body, lnum, '')
  endif
  if self.type ==# 'function'
    " XXX: More improve speed
    for line in self.body
      if line =~# '^' . lnum
        let num_width = lnum < 1000 ? 3 : len(lnum)
        return line[num_width :]
      endif
    endfor
  endif
  return ''
endfunction

function! s:StackInfo.adjusted_lnum(...) abort
  let lnum = a:0 ? a:1 : self.line
  let adjuster = get(s:line_adjuster, self.funcname, 0)
  return lnum + adjuster
endfunction

function! s:StackInfo.get_line_with_lnum(...) abort
  let lnum = a:0 ? a:1 : self.line
  let line = self.get_line(lnum)
  return printf('%3d: %s', self.adjusted_lnum(lnum), line)
endfunction

function! themis#util#stack_info(stack) abort
  let info = deepcopy(s:StackInfo)
  let info.stack = a:stack

  let patterns = [
  \   '^\([^, ]\+\),\? .\{-}\(\d\+\)',
  \   '^\(.\{-}\)\[\(\d\+\)\]$',
  \ ]
  for pat in patterns
    let matched = matchlist(a:stack, pat)
    if !empty(matched)
      let info.stack = matched[1]
      let info.line = matched[2] - 0
    endif
  endfor

  return info
endfunction

function! themis#util#func_alias(dict, prefixes) abort
  let dict_t = type({})
  let func_t = type(function('type'))
  for [key, Value] in items(a:dict)
    let t = type(Value)
    if t == dict_t
      call themis#util#func_alias(Value, a:prefixes + [key])
    elseif t == func_t
      let name = join(a:prefixes + [key], '.')
      let s:func_aliases[themis#util#funcname(Value)] = name
    endif
    unlet Value
  endfor
endfunction

function! themis#util#adjust_func_line(target, line) abort
  let t = type(a:target)
  if t == type({})
    for V in values(a:target)
      call themis#util#adjust_func_line(V, a:line)
    endfor
  elseif t == type([])
    for V in a:target
      call themis#util#adjust_func_line(V, a:line)
    endfor
  elseif t == type(function('type'))
    let s:line_adjuster[themis#util#funcname(a:target)] = a:line
  endif
endfunction

function! themis#util#callstacklines(throwpoint, ...) abort
  let infos = call('themis#util#callstack', [a:throwpoint] + a:000)
  return map(infos, 'v:val.format()')
endfunction

function! themis#util#callstack(throwpoint, ...) abort
  let this_stacks = themis#util#parse_callstack(expand('<sfile>'))[: -2]
  let throwpoint_stacks = themis#util#parse_callstack(a:throwpoint)
  let start = a:0 ? len(this_stacks) + a:1 : 0
  if len(throwpoint_stacks) <= start ||
  \  this_stacks[0] != throwpoint_stacks[0]
    let start = 0
  endif
  return throwpoint_stacks[start :]
endfunction

function! themis#util#parse_callstack(callstack) abort
  let callstack_line = matchstr(a:callstack, '^\%(function\s\+\)\?\zs.*')
  let stack_infos = split(callstack_line, '\.\.')
  return map(stack_infos, 'themis#util#stack_info(v:val)')
endfunction

function! themis#util#funcdata(func) abort
  let func = type(a:func) == type(function('type')) ?
  \          themis#util#funcname(a:func) : a:func
  let fname = func =~# '^\d\+' ? '{' . func . '}' : func
  if !exists('*' . fname)
    return {
    \   'exists': 0,
    \   'funcname': func,
    \ }
  endif
  redir => body
  silent execute 'verbose function' fname
  redir END
  let lines = split(body, "\n")
  let signature = matchstr(lines[0], '^\s*\zs.*')
  let file = matchstr(lines[1], '^\t\%(Last set from\|.\{-}:\)\s*\zs.*$')
  let file = substitute(file, '[/\\]\+', '/', 'g')
  let arguments = split(matchstr(signature, '(\zs.*\ze)'), '\s*,\s*')
  let has_extra_arguments = get(arguments, -1, '') ==# '...'
  let arity = len(arguments) - (has_extra_arguments ? 1 : 0)
  return {
  \   'exists': 1,
  \   'filename': file,
  \   'funcname': func,
  \   'signature': signature,
  \   'arguments': arguments,
  \   'arity': arity,
  \   'has_extra_arguments': has_extra_arguments,
  \   'is_dict': signature =~# ').*dict',
  \   'is_abort': signature =~# ').*abort',
  \   'has_range': signature =~# ').*range',
  \   'body': lines[2 : -2],
  \ }
endfunction

function! themis#util#error_info(stacktrace) abort
  let tracelines = map(copy(a:stacktrace), 'v:val.format()')
  let tail = a:stacktrace[-1]
  if tail.line
    let tracelines += [tail.get_line_with_lnum()]
  endif
  return join(tracelines, "\n")
endfunction

function! themis#util#is_funcname(name) abort
  return a:name =~# '\v^%(\d+|%(\u|g:\u|s:|\<SNR\>\d+_)\w+|\h\w*%(#\w+)+)$'
endfunction

function! themis#util#funcname(funcref) abort
  if has('patch-7.4.1608')
    " From Vim 7.4.1608, the result of string() with Partial
    " (a kind of Funcref) contains {arglist} and {self} as follows
    "
    " function('100', [1], {'method': function('100')})
    "
    " E724 occurs if the {arglist} or {self} contains a circular reference
    " Ignore this error with :silent!
    silent! let str = string(function(a:funcref, {}))
  else
    let str = string(a:funcref)
  endif
  return matchstr(str, '^function(''\zs[^'']\{-}\ze''')
endfunction

function! themis#util#get_full_title(obj, ...) abort
  let obj = a:obj
  let titles = a:0 ? a:1 : []
  call insert(titles, obj.get_title())
  while has_key(obj, 'parent')
    let obj = obj.parent
    call insert(titles, obj.get_title())
  endwhile
  return join(filter(titles, 'v:val !=# ""'), ' ')
endfunction

function! themis#util#sortuniq(list) abort
  call sort(a:list)
  let i = len(a:list) - 1
  while 0 < i
    if a:list[i] == a:list[i - 1]
      call remove(a:list, i)
    endif
    let i -= 1
  endwhile
  return a:list
endfunction

function! themis#util#find_files(paths, filename) abort
  let todir =  'isdirectory(v:val) ? v:val : fnamemodify(v:val, ":h")'
  let dirs = map(copy(a:paths), todir)
  let mod = ':p:gs?\\\+?/?:s?/$??'
  call map(dirs, 'fnamemodify(v:val, mod)')
  let files = findfile(a:filename, join(map(dirs, 'v:val . ";"'), ','), -1)
  return themis#util#sortuniq(files)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
