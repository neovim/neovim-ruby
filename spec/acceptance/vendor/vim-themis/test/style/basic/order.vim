let s:order = themis#suite('order')

function! s:order.__test__() abort
  let test = themis#suite('test')

  function! test.before() abort
    let self.count = 0
  endfunction
  function! test.first() abort
    let self.count += 1
    Assert Equals(self.count, 1)
  endfunction
  function! test.second() abort
    let self.count += 1
    Assert Equals(self.count, 2)
  endfunction
  function! test.third() abort
    let self.count += 1
    Assert Equals(self.count, 3)
  endfunction
  function! test.fourth() abort
    let self.count += 1
    Assert Equals(self.count, 4)
  endfunction
  function! test.fifth() abort
    let self.count += 1
    Assert Equals(self.count, 5)
  endfunction
  function! test.sixth() abort
    let self.count += 1
    Assert Equals(self.count, 6)
  endfunction
  function! test.seventh() abort
    let self.count += 1
    Assert Equals(self.count, 7)
  endfunction
  function! test.eighth() abort
    let self.count += 1
    Assert Equals(self.count, 8)
  endfunction
  function! test.ninth() abort
    let self.count += 1
    Assert Equals(self.count, 9)
  endfunction
  function! test.tenth() abort
    let self.count += 1
    Assert Equals(self.count, 10)
  endfunction

endfunction

function! s:order.__nested_bundle__() abort
  let nested_bundle = themis#suite('nested_bundle')

  function! nested_bundle.before() abort
    let g:count = 0
  endfunction
  function! nested_bundle.after() abort
    unlet! g:count
  endfunction
  function! nested_bundle.__first__() abort
    let first = themis#suite('first')
    function! first.count() abort
      let g:count += 1
      Assert Equals(g:count, 1)
    endfunction
  endfunction
  function! nested_bundle.__second__() abort
    let second = themis#suite('second')
    function! second.count() abort
      let g:count += 1
      Assert Equals(g:count, 2)
    endfunction
  endfunction
  function! nested_bundle.__third__() abort
    let third = themis#suite('third')
    function! third.count() abort
      let g:count += 1
      Assert Equals(g:count, 3)
    endfunction
  endfunction
  function! nested_bundle.__fourth__() abort
    let fourth = themis#suite('fourth')
    function! fourth.count() abort
      let g:count += 1
      Assert Equals(g:count, 4)
    endfunction
  endfunction
  function! nested_bundle.__fifth__() abort
    let fifth = themis#suite('fifth')
    function! fifth.count() abort
      let g:count += 1
      Assert Equals(g:count, 5)
    endfunction
  endfunction

endfunction
