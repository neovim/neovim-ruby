" themis: style: vimspec: Spec style.
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

let s:func_t = type(function('type'))

function! s:parse_describe(tokens, lnum, context_stack, scope_id) abort
  let [command, description] = a:tokens[1 : 2]
  if description ==# ''
    throw printf('vimspec:%d::%s must take an argument', a:lnum, command)
  endif

  let bundle_new = printf(
  \   empty(a:context_stack) ?
  \     'themis#bundle(%s)' :
  \     'themis#bundle#new(%s, s:themis_vimspec_bundles[-1])',
  \   string(description)
  \ )

  let funcname = printf('s:themis_vimspec_scope_%d', a:scope_id)
  call add(a:context_stack, ['describe', a:lnum, funcname, a:scope_id])
  return [
  \   printf('function! %s() abort', funcname),
  \   printf('let s:themis_vimspec_bundles += [%s]', bundle_new),
  \   'let s:themis_vimspec_bundles[-1]._vimspec_hooks = {}',
  \   'function! s:themis_vimspec_bundles[-1]._vimspec_hooks.start_test()',
  \   printf('  call s:themis_vimspec_scopes.tmp_scope(%d)', a:scope_id),
  \   'endfunction',
  \ ]
endfunction

function! s:parse_example(tokens, lnum, context_stack, func_id) abort
  let [command, example] = a:tokens[1 : 2]
  if example ==# ''
    throw printf('vimspec:%d::%s must take an argument', a:lnum, command)
  endif
  if empty(a:context_stack) || a:context_stack[-1][0] !=# 'describe'
    throw printf('vimspec:%d::%s must put on :describe or :context block',
    \            a:lnum, command)
  endif
  let scope_id = 0
  call add(a:context_stack, ['example', a:lnum])
  let bundle_var = 's:themis_vimspec_bundles'
  let scope_var = 's:themis_vimspec_scopes'
  return [
  \   printf('let %s[-1].suite_descriptions["T_%05d"] = %s',
  \           bundle_var, a:func_id, string(example)),
  \   printf('function! %s[-1].suite.T_%05d() abort',
  \           bundle_var, a:func_id),
  \   printf('execute %s.extend("%s.scope(%d)", 0)',
  \           scope_var, scope_var, scope_id),
  \ ]
endfunction

function! s:parse_hook(tokens, lnum, context_stack) abort
  let [command, timing] = a:tokens[1 : 2]
  if empty(a:context_stack) || a:context_stack[-1][0] !=# 'describe'
    throw printf('vimspec:%d::%s must put on :describe or :context block',
    \            a:lnum, command)
  endif
  if timing ==# ''
    let timing = 'each'
  endif
  if timing !~# '^\%(each\|all\)$'
    throw printf('vimspec:%d:Invalid argument for "%s"', a:lnum, command)
  endif
  let hook_point = printf('%s_%s', tolower(command), timing)
  let [scope_id, copy] =
  \   timing ==# 'each'
  \     ? [0, 0]
  \     : [a:context_stack[-1][3], 1]
  call add(a:context_stack, ['hook', a:lnum, timing])
  let bundle_var = 's:themis_vimspec_bundles'
  let scope_var = 's:themis_vimspec_scopes'
  return [
  \   printf('function! %s[-1]._vimspec_hooks.%s() abort',
  \           bundle_var, hook_point),
  \   printf('execute %s.extend("%s.scope(%d)", %d)',
  \           scope_var, scope_var, scope_id, copy),
  \ ]
endfunction

function! s:parse_end(tokens, lnum, context_stack) abort
  if empty(a:context_stack)
    let command = a:tokens[1]
    throw printf('vimspec:%d:There is :%s, but not opened', a:lnum, command)
  endif
  let [context, lnum; rest] = remove(a:context_stack, -1)
  if context ==# 'describe'
    let [funcname, scope_id] = rest
    let parent_scope = empty(a:context_stack) ? -1 : a:context_stack[-1][3]
    let bundle_var = 's:themis_vimspec_bundles'
    return [
    \   printf('call s:themis_vimspec_scopes.push(copy(l:), %d, %d)',
    \           scope_id, parent_scope),
    \   printf('call themis#util#adjust_func_line(%s[-1]._vimspec_hooks, -1)',
    \           bundle_var),
    \   printf('call themis#util#adjust_func_line(%s[-1].suite, -1)',
    \           bundle_var),
    \   printf('call remove(%s, -1)', bundle_var),
    \   'endfunction',
    \   printf('call %s()', funcname),
    \ ]
  elseif context ==# 'hook'
    let timing = rest[0]
    let scope_id = timing ==# 'each' ? 0 : a:context_stack[-1][3]
    return [
    \   printf('call s:themis_vimspec_scopes.back(%d, l:)', scope_id),
    \   'endfunction',
    \ ]
  elseif context ==# 'example'
    return ['endfunction']
  endif
  return []
endfunction

function! s:translate_script(lines) abort
  let result = [
  \   'let s:themis_vimspec_bundles = []',
  \   'let s:themis_vimspec_scopes = themis#style#vimspec#new_scope()',
  \ ]
  let context_stack = []
  let current_func_id = 1
  let current_scope_id = 1  " scope_id = 0 is special value for a test scope
  let lnum = 0

  for line in a:lines
    let lnum += 1

    let tokens = matchlist(line, '^\s*\([Dd]escribe\|[Cc]ontext\)\s*\(.*\)$')
    if !empty(tokens)
      let result +=
      \   s:parse_describe(tokens, lnum, context_stack, current_scope_id)
      let current_scope_id += 1
      continue
    endif

    let tokens = matchlist(line, '^\s*\([Ii]t\)\s*\(.*\)$')
    if !empty(tokens)
      let result +=
      \   s:parse_example(tokens, lnum, context_stack, current_func_id)
      let current_func_id += 1
      continue
    endif

    let tokens = matchlist(line,
    \                      '^\s*\([Bb]efore\|[Aa]fter\)\%(\s\+\(.*\)\)\?$')
    if !empty(tokens)
      let result += s:parse_hook(tokens, lnum, context_stack)
      continue
    endif

    let tokens = matchlist(line, '^\s*\([Ee]nd\)\s*$')
    if !empty(tokens)
      let result += s:parse_end(tokens, lnum, context_stack)
      continue
    endif

    let result += [line]
  endfor

  if !empty(context_stack)
    let opened_lnum = context_stack[0][1]
    throw printf('vimspec:%d:This declaration is not closed.', opened_lnum)
  endif

  return result
endfunction

function! s:compile_specfile(specfile_path, result_path) abort
  let slines = readfile(a:specfile_path)
  let rlines = s:translate_script(slines)
  call writefile(rlines, a:result_path)
endfunction


let s:ScopeKeeper = {'scopes': {}}

function! s:ScopeKeeper.push(scope, scope_id, parent) abort
  let self.scopes[a:scope_id] = {'scope': a:scope, 'parent': a:parent}
endfunction

function! s:ScopeKeeper.tmp_scope(from) abort
  call self.push(copy(self.scope(a:from)), 0, -1)
endfunction

function! s:ScopeKeeper.back(scope_id, back_scope) abort
  let scope = self.scopes[a:scope_id].scope
  for [k, Val] in items(a:back_scope)
    if k !=# 'self'
      let scope[k] = Val
    endif
    unlet Val
  endfor
endfunction

function! s:ScopeKeeper.scope(scope_id) abort
  let all = {}
  let scope_id = a:scope_id
  while has_key(self.scopes, scope_id)
    call extend(all, self.scopes[scope_id].scope, 'keep')
    let scope_id = self.scopes[scope_id].parent
  endwhile
  if has_key(all, 'self')
    call remove(all, 'self')
  endif
  return all
endfunction

function! s:ScopeKeeper.extend(val, copy) abort
  let val = a:copy ? printf('copy(%s)', a:val) : a:val
   return join([
   \   printf('for [s:__key, s:__val] in items(%s)', val),
   \   '  let {s:__key} = s:__val',
   \   '  unlet s:__key s:__val',
   \   'endfor',
   \ ], "\n")
endfunction

function! themis#style#vimspec#new_scope() abort
  return deepcopy(s:ScopeKeeper)
endfunction


let s:event = {
\   '_converted_files': []
\ }

function! s:event.start_test(bundle, entry) abort
  call s:call_hook(a:bundle, 'start_test')
endfunction

function! s:event.before_suite(bundle) abort
  call s:call_hook(a:bundle, 'before_all')
endfunction

function! s:event.before_test(bundle, entry) abort
  call s:call_hook(a:bundle, 'before_each')
endfunction

function! s:event.after_test(bundle, entry) abort
  call s:call_hook(a:bundle, 'after_each')
endfunction

function! s:event.after_suite(bundle) abort
  call s:call_hook(a:bundle, 'after_all')
endfunction

function! s:event.finish(runner) abort
  for file in self._converted_files
    if filereadable(file)
      call delete(file)
    endif
  endfor
endfunction

function! s:call_hook(bundle, point) abort
  if has_key(get(a:bundle, '_vimspec_hooks', {}), a:point)
    call call(a:bundle._vimspec_hooks[a:point], [], a:bundle.suite)
  endif
endfunction


let s:style = {
\   'event': s:event,
\ }

function! s:style.get_test_names(bundle) abort
  let expr = 'type(a:bundle.suite[v:val]) == s:func_t'
  return sort(filter(keys(a:bundle.suite), expr))
endfunction

function! s:style.can_handle(filename) abort
  return fnamemodify(a:filename, ':e') ==? 'vimspec'
endfunction

function! s:style.load_script(filename, base_bundle) abort
  let compiled_specfile_path = tempname()
  call add(self.event._converted_files, compiled_specfile_path)
  try
    call s:compile_specfile(a:filename, compiled_specfile_path)
    execute 'source' fnameescape(compiled_specfile_path)
  catch /^vimspec:/
    let pat = '\v^vimspec:(\d+):(.*)'
    let [lnum, message] = matchlist(v:exception, pat)[1 : 2]
    throw themis#exception('style-vimspec', [
    \   printf('Error occurred in %s:%d', a:filename, lnum),
    \   message,
    \ ])
  endtry
endfunction

function! themis#style#vimspec#new() abort
  return deepcopy(s:style)
endfunction

call themis#func_alias({'themis/style.vimspec.ScopeKeeper': s:ScopeKeeper})

let &cpo = s:save_cpo
unlet s:save_cpo
