let s:save_cpo = &cpo
set cpo&vim

let s:expect = {
\   '_negate' : 0,
\   'not' : {
\     '_negate' : 1
\   }
\ }

function! themis#helper#expect#_create_expect(actual) abort
  let expect = deepcopy(s:expect)
  let expect._actual = a:actual
  let expect.not._actual = a:actual
  return expect
endfunction

function! s:matcher_impl(name, f, error_msg, ...) dict abort
  let result = call(a:f, [self._actual] + a:000)
  if self._negate
    let result = !result
  endif
  if result
    return {'and' : self}
  else
    throw themis#failure(call(a:error_msg, [self._negate, a:name, self._actual] + a:000))
  endif
endfunction

function! s:expr_to_matcher(name, pred, ...) abort
  let func_name = 's:_matcher_' . a:name
  execute join([
  \ 'function! ' . func_name . '(...)',
  \ '  return ' . a:pred,
  \ 'endfunction'], "\n")
  return function(func_name)
endfunction

function! s:expr_to_failure_message(name, pred, ...) abort
  let func_name = 's:_failure_message_' . a:name
  execute join([
  \ 'function! ' . func_name . '(not, name, ...)',
  \ '  return ' . a:pred,
  \ 'endfunction'], "\n")
  return function(func_name)
endfunction

function! s:default_failure_message(not, name, ...) abort
  return printf('Expected %s %s%s%s.',
    \       string(a:1),
    \       (a:not ? 'not ' : ''),
    \       substitute(a:name, '_', ' ', 'g'),
    \       (a:0 >=# 2) ? (' ' . string(join(a:000[1:], ', '))) : '')
endfunction

let s:matchers = {}
let s:failure_messages = {}
function! themis#helper#expect#define_matcher(name, predicate, ...) abort
  if type(a:predicate) ==# type('')
    let s:matchers[a:name] = s:expr_to_matcher(a:name, a:predicate)
  elseif type(a:predicate) ==# type(function('function'))
    let s:matchers[a:name] = a:predicate
  endif
  if a:0 >=# 1
    if type(a:1) ==# type('')
      let s:failure_messages[a:name] = s:expr_to_failure_message(a:name, a:1)
    elseif type(a:1) ==# type(function('function'))
      let s:failure_messages[a:name] = a:1
    endif
  else
    let s:failure_messages[a:name] = function('s:default_failure_message')
  endif
  execute join([
  \ 'function! s:expect.' . a:name . '(...)',
  \ '  return call("s:matcher_impl", ['. string(a:name) . ', s:matchers.' . a:name . ', s:failure_messages.' . a:name . '] + a:000, self)',
  \ 'endfunction'], "\n")
  let s:expect.not[a:name] = s:expect[a:name]
endfunction

call themis#helper#expect#define_matcher('to_be_true', 'a:1 is 1')
call themis#helper#expect#define_matcher('to_be_false', 'a:1 is 0')
call themis#helper#expect#define_matcher('to_be_truthy', '(type(a:1) == type(0) || type(a:1) == type("")) && a:1')
call themis#helper#expect#define_matcher('to_be_falsy', '(type(a:1) != type(0) || type(a:1) != type("")) && !a:1')
call themis#helper#expect#define_matcher('to_be_greater_than', 'a:1 ># a:2')
call themis#helper#expect#define_matcher('to_be_less_than', 'a:1 <# a:2')
call themis#helper#expect#define_matcher('to_be_greater_than_or_equal', 'a:1 >=# a:2')
call themis#helper#expect#define_matcher('to_be_less_than_or_equal', 'a:1 <=# a:2')
call themis#helper#expect#define_matcher('to_equal', 'a:1 ==# a:2')
call themis#helper#expect#define_matcher('to_be_same', 'a:1 is a:2')
call themis#helper#expect#define_matcher('to_match', 'type(a:1) == type("") && type(a:2) == type("") && a:1 =~# a:2')
call themis#helper#expect#define_matcher('to_have_length', '(type(a:1) ==# type("") || type(a:1) == type([]) || type(a:1) == type({})) && len(a:1) == a:2')
call themis#helper#expect#define_matcher('to_exist', function('exists'))
call themis#helper#expect#define_matcher('to_be_empty', function('empty'))
call themis#helper#expect#define_matcher('to_have_key', 'type(a:1) ==# type([]) ? 0 <= a:2 && a:2 < len(a:1) : has_key(a:1, a:2)')

call themis#helper#expect#define_matcher('to_be_number', 'type(a:1) ==# type(0)')
call themis#helper#expect#define_matcher('to_be_string', 'type(a:1) ==# type("")')
call themis#helper#expect#define_matcher('to_be_func', 'type(a:1) ==# type(function("function"))')
call themis#helper#expect#define_matcher('to_be_list', 'type(a:1) ==# type([])')
call themis#helper#expect#define_matcher('to_be_dict', 'type(a:1) ==# type({})')
call themis#helper#expect#define_matcher('to_be_float', 'type(a:1) ==# type(0.0)')

function! themis#helper#expect#new(_) abort
  return function('themis#helper#expect#_create_expect')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
