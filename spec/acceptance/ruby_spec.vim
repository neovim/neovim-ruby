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
  ruby def foo; Vim.command("let g:called = 1"); end

Execute (Call a Ruby method):
  ruby foo

Then:
  AssertEqual 1, g:called

Execute (Update instance state on `$curbuf`):
  ruby $curbuf.instance_variable_set(:@foo, 123)
  ruby Vim.command("let g:foo = #{$curbuf.instance_variable_get(:@foo)}")

Then:
  AssertEqual 123, g:foo

Execute (Change the working directory explicitly):
  cd /
  ruby Vim.command("let g:ruby_pwd = '#{Dir.pwd}'")
  cd -

Then:
  if g:nvim_version['major'] > 0 || g:nvim_version['minor'] >= 2
    AssertEqual "/", g:ruby_pwd
  endif

Execute (Change the working directory implicitly):
  split | lcd /
  ruby Vim.command("let g:before_pwd = '#{Dir.pwd}'")
  wincmd p
  ruby Vim.command("let g:after_pwd = '#{Dir.pwd}'")
  wincmd p | lcd -

Then:
  if g:nvim_version['major'] > 0 || g:nvim_version['minor'] >= 2
    AssertNotEqual g:before_pwd, g:after_pwd
  endif

Execute (Raise a Ruby standard error):
  try
    ruby raise "BOOM"
    throw "Nothing raised"
  catch /BOOM/
  endtry

  ruby $curbuf[1] = "still works"

Expect:
  still works
  two

Execute (Raise a Ruby syntax error):
  try
    ruby puts[
    throw "Nothing raised"
  catch /SyntaxError/
  endtry

  ruby $curbuf[1] = "still works"

Expect:
  still works
  two

Execute (Access Vim interface):
  ruby expect(Vim).to eq(VIM)
  ruby expect(Vim.strwidth("hi")).to eq(2)

Execute (Access Vim::Buffer interface):
  ruby expect($curbuf).to be_a(Neovim::Buffer)
  ruby expect(Vim::Buffer.current).to eq($curbuf)

Execute (Access Vim::Window interface):
  ruby expect($curwin).to be_a(Neovim::Window)
  ruby expect(Vim::Window.current).to eq($curwin)
