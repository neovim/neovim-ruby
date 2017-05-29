Execute (Set nvim_version):
  if has('nvim')
    let g:nvim_version = api_info()['version']
  else
    let g:nvim_version = {'major': 99, 'minor': 99, 'patch': 99}
  endif

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
  if g:nvim_version['major'] > 0 || g:nvim_version['minor'] >= 2
    AssertEqual "/", g:pwd_before
  endif

Execute (Change the working directory implicitly):
  let g:before_file = getcwd() . "/rubyfile/set_pwd_before.rb"
  let g:after_file = getcwd() . "/rubyfile/set_pwd_after.rb"

  split | lcd /
  exec "rubyfile " . g:before_file
  wincmd p
  exec "rubyfile " . g:after_file
  wincmd p | lcd -

Then:
  if g:nvim_version['major'] > 0 || g:nvim_version['minor'] >= 2
    AssertNotEqual g:pwd_before, g:pwd_after
  endif

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
