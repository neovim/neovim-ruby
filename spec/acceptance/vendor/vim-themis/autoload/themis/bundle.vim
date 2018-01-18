" themis: Test bundle.
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

let s:Bundle = {
\   'suite': {},
\   'suite_descriptions': {},
\   'children': [],
\ }

function! s:Bundle.get_title() abort
  if self.title !=# ''
    return self.title
  endif
  let filename = get(self, 'filename', '')
  if filename !=# ''
    return fnamemodify(filename, ':t')
  endif
  return ''
endfunction

function! s:Bundle.get_test_full_title(entry) abort
  return themis#util#get_full_title(self, [self.get_test_title(a:entry)])
endfunction

function! s:Bundle.get_test_title(entry) abort
  let description = self.get_description(a:entry)
  return description !=# '' ? description : a:entry
endfunction

function! s:Bundle.get_description(entry) abort
  return get(self.suite_descriptions, a:entry, '')
endfunction

function! s:Bundle.get_style() abort
  if has_key(self, 'style')
    return self.style
  endif
  if has_key(self, 'parent')
    return self.parent.get_style()
  endif
  return {}
endfunction

function! s:Bundle.has_parent() abort
  return has_key(self, 'parent')
endfunction

function! s:Bundle.get_parent() abort
  return get(self, 'parent', {})
endfunction

function! s:Bundle.add_child(bundle) abort
  if has_key(a:bundle, 'parent')
    call a:bundle.parent.remove_child(a:bundle)
  endif
  let self.children += [a:bundle]
  let a:bundle.parent = self
endfunction

function! s:Bundle.get_child(title) abort
  for child in self.children
    if child.title ==# a:title
      return child
    endif
  endfor
  return {}
endfunction

function! s:Bundle.remove_child(child) abort
  for i in range(len(self.children))
    if self.children[i] is a:child
      call remove(a:child, 'parent')
      call remove(self.children, i)
      break
    endif
  endfor
endfunction

function! s:Bundle.total_test_count() abort
  return len(self.get_test_entries())
  \    + s:sum(map(copy(self.children), 'v:val.total_test_count()'))
endfunction

function! s:Bundle.get_test_entries() abort
  if !has_key(self, 'test_entries')
    let self.test_entries = self.all_test_entries()
  endif
  return self.test_entries
endfunction

function! s:Bundle.select_tests_recursive(pattern) abort
  for child in self.children
    call child.select_tests_recursive(a:pattern)
  endfor
  call self.select_tests(a:pattern)
  return !self.is_empty()
endfunction

function! s:Bundle.select_tests(pattern) abort
  let test_entries = self.all_test_entries()
  call filter(test_entries, 'self.get_test_full_title(v:val) =~# a:pattern')
  let self.test_entries = test_entries
endfunction

function! s:Bundle.all_test_entries() abort
  let style = self.get_style()
  if empty(style)
    return []
  endif
  return style.get_test_names(self)
endfunction

function! s:Bundle.is_empty() abort
  return self.total_test_count() == 0
endfunction

function! s:Bundle.run_test(entry) abort
  call self.suite[a:entry]()
endfunction

function! s:sum(list) abort
  return empty(a:list) ? 0 : eval(join(a:list, '+'))
endfunction

function! themis#bundle#new(...) abort
  let bundle = deepcopy(s:Bundle)
  let bundle.title = 1 <= a:0 ? a:1 : ''
  if 2 <= a:0 && has_key(a:2, 'add_child')
    call a:2.add_child(bundle)
  endif
  return bundle
endfunction

function! themis#bundle#is_bundle(obj) abort
  return type(a:obj) == type({}) &&
  \   get(a:obj, 'run_test') is get(s:Bundle, 'run_test')
endfunction

call themis#func_alias({'themis/Bundle': s:Bundle})


let &cpo = s:save_cpo
unlet s:save_cpo
