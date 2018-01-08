Before:
  AssertEqual 1, has('nvim')

Given:
  one
  two

Execute (Define a Ruby method):
  rubyfile ./rubyfile/define_foo.rb

Execute (Call a Ruby method):
  rubyfile ./rubyfile/call_foo.rb

Then:
  AssertEqual 1, g:called

Execute (Update instance state on $curbuf):
  rubyfile ./rubyfile/curbuf_ivar_set.rb

Execute (Access instance state on $curbuf):
  rubyfile ./rubyfile/curbuf_ivar_get.rb

Then:
  AssertEqual 123, g:foo

Execute (Change the working directory explicitly):
  let g:rubyfile = getcwd() . "/rubyfile/set_pwd_before.rb"
  cd /
  exec "rubyfile " . g:rubyfile
  cd -

Then:
  AssertEqual "/", g:pwd_before

Execute (Change the working directory implicitly):
  let g:before_file = getcwd() . "/rubyfile/set_pwd_before.rb"
  let g:after_file = getcwd() . "/rubyfile/set_pwd_after.rb"

  split | lcd /
  exec "rubyfile " . g:before_file
  wincmd p
  exec "rubyfile " . g:after_file
  wincmd p | lcd -

Then:
  AssertNotEqual g:pwd_before, g:pwd_after

Execute (Run nested Ruby files):
  rubyfile ./rubyfile/nested.rb

Then:
  AssertEqual 123, g:ruby_nested

Execute (Raise a Ruby load error):
  try
    rubyfile /foo/bar/baz
    throw "Nothing raised"
  catch /LoadError/
  endtry

  ruby $curbuf[1] = "still works"

Expect:
  still works
  two

Execute (Raise a Ruby standard error):
  try
    rubyfile ./rubyfile/raise_standard_error.rb
    throw "Nothing raised"
  catch /BOOM/
  endtry

  ruby $curbuf[1] = "still works"

Expect:
  still works
  two

Execute (Raise a Ruby syntax error):
  try
    rubyfile ./rubyfile/raise_syntax_error.rb
    throw "Nothing raised"
  catch /SyntaxError/
  endtry

  ruby $curbuf[1] = "still works"

Expect:
  still works
  two

Execute (Access ruby interface):
  rubyfile ./rubyfile/ruby_interface.rb
