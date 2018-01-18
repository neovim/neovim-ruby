let s:suite = themis#suite(":rubyfile")
let s:expect = themis#helper("expect")

function! s:suite.before_each() abort
  1,$delete
  call append(0, ["one", "two"])
endfunction

function! s:suite.has_nvim() abort
  call s:expect(has("nvim")).to_equal(1)
endfunction

function! s:suite.defines_a_ruby_method() abort
  rubyfile ./rubyfile/define_foo.rb
  rubyfile ./rubyfile/call_foo.rb

  call s:expect(g:called).to_equal(1)
endfunction

function! s:suite.persists_curbuf_state() abort
  rubyfile ./rubyfile/curbuf_ivar_set.rb
  rubyfile ./rubyfile/curbuf_ivar_get.rb

  call s:expect(g:foo).to_equal(123)
endfunction

function! s:suite.updates_working_directory() abort
  let g:rubyfile = getcwd() . "/rubyfile/set_pwd_before.rb"
  cd /
  exec "rubyfile " . g:rubyfile
  cd -

  call s:expect(g:pwd_before).to_equal("/")
endfunction

function! s:suite.updates_working_directory_implicitly() abort
  let g:before_file = getcwd() . "/rubyfile/set_pwd_before.rb"
  let g:after_file = getcwd() . "/rubyfile/set_pwd_after.rb"

  split | lcd /
  exec "rubyfile " . g:before_file
  wincmd p
  exec "rubyfile " . g:after_file
  wincmd p | lcd -

  call s:expect(g:pwd_before).not.to_equal(g:pwd_after)
endfunction

function! s:suite.supports_nesting() abort
  rubyfile ./rubyfile/nested.rb

  call s:expect(g:ruby_nested).to_equal(123)
endfunction

function! s:suite.handles_standard_error() abort
  try
    rubyfile ./rubyfile/raise_standard_error.rb
    throw "Nothing raised"
  catch /BOOM/
  endtry

  call s:suite.defines_a_ruby_method()
endfunction

function! s:suite.handles_load_error() abort
  try
    rubyfile /foo/bar/baz
    throw "Nothing raised"
  catch /LoadError/
  endtry

  call s:suite.defines_a_ruby_method()
endfunction

function! s:suite.handles_syntax_error() abort
  try
    rubyfile ./rubyfile/raise_syntax_error.rb
    throw "Nothing raised"
  catch /SyntaxError/
  endtry

  call s:suite.defines_a_ruby_method()
endfunction

function! s:suite.exposes_constants() abort
  rubyfile ./rubyfile/ruby_interface.rb
endfunction
