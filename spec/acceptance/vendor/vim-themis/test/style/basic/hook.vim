let s:hook = themis#suite('hook')

function! s:hook.before() abort
  let self.runner = themis#runner#new()
endfunction

function! s:hook.before_each() abort
  let self.bundle = themis#bundle#new('sample')
  let self.bundle.style = themis#module#style('basic')
  let self.suite = self.bundle.suite
  let self.suite.called = []
endfunction

function! s:hook.is_called_in_order() abort
  function! self.suite.before() abort
    let self.called += ['before']
  endfunction
  function! self.suite.before_each() abort
    let self.called += ['before_each']
  endfunction
  function! self.suite.test1() abort
    let self.called += ['test1']
  endfunction
  function! self.suite.test2() abort
    let self.called += ['test2']
  endfunction
  function! self.suite.after_each() abort
    let self.called += ['after_each']
  endfunction
  function! self.suite.after() abort
    let self.called += ['after']
  endfunction

  Assert HasKey(self.suite, 'called')
  Assert Equals(self.suite.called, [])
  call self.runner.run(self.bundle)
  Assert Equals(self.suite.called,
  \ [
  \   'before',
  \     'before_each',
  \       'test1',
  \     'after_each',
  \     'before_each',
  \       'test2',
  \     'after_each',
  \   'after'
  \ ])
endfunction

function! s:hook.with_parent_is_called_in_order() abort
  function! self.suite.before() abort
    let self.called += ['parent_before']
  endfunction
  function! self.suite.before_each() abort
    let self.called += ['parent_before_each']
  endfunction
  function! self.suite.parent_test() abort
    let self.called += ['parent_test']
  endfunction
  function! self.suite.after_each() abort
    let self.called += ['parent_after_each']
  endfunction
  function! self.suite.after() abort
    let self.called += ['parent_after']
  endfunction

  let child = themis#bundle#new()
  let child.suite.called = self.suite.called
  function! child.suite.before() abort
    let self.called += ['child_before']
  endfunction
  function! child.suite.before_each() abort
    let self.called += ['child_before_each']
  endfunction
  function! child.suite.parent_test1() abort
    let self.called += ['child_test1']
  endfunction
  function! child.suite.parent_test2() abort
    let self.called += ['child_test2']
  endfunction
  function! child.suite.after_each() abort
    let self.called += ['child_after_each']
  endfunction
  function! child.suite.after() abort
    let self.called += ['child_after']
  endfunction
  call self.bundle.add_child(child)

  Assert HasKey(self.suite, 'called')
  Assert Equals(self.suite.called, [])
  call self.runner.run(self.bundle)
  Assert Equals(self.suite.called,
  \ [
  \   'parent_before',
  \     'parent_before_each',
  \       'parent_test',
  \     'parent_after_each',
  \     'child_before',
  \       'parent_before_each',
  \         'child_before_each',
  \           'child_test1',
  \         'child_after_each',
  \       'parent_after_each',
  \       'parent_before_each',
  \         'child_before_each',
  \           'child_test2',
  \         'child_after_each',
  \       'parent_after_each',
  \     'child_after',
  \   'parent_after',
  \ ])
endfunction

