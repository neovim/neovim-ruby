let s:suite = themis#suite(":ruby")
let s:expect = themis#helper("expect")

function! s:suite.before_each() abort
  1,$delete
  call append(0, ["one", "two"])
endfunction

function! s:suite.has_nvim() abort
  call s:expect(has("nvim")).to_equal(1)
endfunction

function! s:suite.defines_a_ruby_method() abort
  ruby def foo; Vim.command("let g:called = 1"); end
  ruby foo

  call s:expect(g:called).to_equal(1)
endfunction

function! s:suite.persists_curbuf_state() abort
  ruby $curbuf.instance_variable_set(:@foo, 123)
  ruby Vim.command("let g:foo = #{$curbuf.instance_variable_get(:@foo)}")

  call s:expect(g:foo).to_equal(123)
endfunction

function! s:suite.updates_working_directory() abort
  cd /
  ruby Vim.command("let g:ruby_pwd = '#{Dir.pwd.sub(/^C:/, "")}'")
  cd -

  call s:expect(g:ruby_pwd).to_equal("/")
endfunction

function! s:suite.updates_working_directory_implicitly() abort
  split | lcd /
  ruby Vim.command("let g:before_pwd = '#{Dir.pwd}'")
  wincmd p
  ruby Vim.command("let g:after_pwd = '#{Dir.pwd}'")
  wincmd p | lcd -

  call s:expect(g:before_pwd).not.to_equal(g:after_pwd)
endfunction

function! s:suite.supports_nesting() abort
  ruby Vim.command("ruby Vim.command('let g:ruby_nested = 123')")

  call s:expect(g:ruby_nested).to_equal(123)
endfunction

function! s:suite.handles_standard_error() abort
  try
    ruby raise "BOOM"
    throw "Nothing raised"
  catch /BOOM/
  endtry

  call s:suite.defines_a_ruby_method()
endfunction

function! s:suite.handles_syntax_error() abort
  try
    ruby puts[
    throw "Nothing raised"
  catch /SyntaxError/
  endtry

  call s:suite.defines_a_ruby_method()
endfunction

function! s:suite.exposes_Vim() abort
  ruby expect(Vim).to eq(VIM)
  ruby expect(Vim.strwidth("hi")).to eq(2)
endfunction

function! s:suite.exposes_Buffer() abort
  ruby expect($curbuf).to be_a(Neovim::Buffer)
  ruby expect(Vim::Buffer.current).to eq($curbuf)
endfunction

function! s:suite.exposes_Window() abort
  ruby expect($curwin).to be_a(Neovim::Window)
  ruby expect(Vim::Window.current).to eq($curwin)
endfunction
