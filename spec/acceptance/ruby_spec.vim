Before:
  AssertEqual 1, has('nvim')

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
  ruby Vim.command("let g:ruby_pwd = '#{Dir.pwd.sub(/^C:/, '')}'")
  cd -

Then:
  AssertEqual "/", g:ruby_pwd

Execute (Change the working directory implicitly):
  split | lcd /
  ruby Vim.command("let g:before_pwd = '#{Dir.pwd}'")
  wincmd p
  ruby Vim.command("let g:after_pwd = '#{Dir.pwd}'")
  wincmd p | lcd -

Then:
  AssertNotEqual g:before_pwd, g:after_pwd

Execute (Run nested Ruby commands):
  ruby Vim.command("ruby Vim.command('let g:ruby_nested = 123')")

Then:
  AssertEqual 123, g:ruby_nested

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
