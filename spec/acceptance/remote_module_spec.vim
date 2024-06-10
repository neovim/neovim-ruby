let s:suite = themis#suite("Remote module")
let s:expect = themis#helper("expect")

call themis#helper('command').with(s:)

function! s:suite.defines_commands() abort
  RbSetVar set_from_rb_mod foobar
  call s:expect(g:set_from_rb_mod).to_equal('foobar')
endfunction

function! s:suite.propagates_errors() abort
  Throws /oops/ :RbWillRaise
endfunction
