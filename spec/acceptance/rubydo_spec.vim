let s:suite = themis#suite(":rubydo")
let s:expect = themis#helper("expect")

function! s:suite.before_each() abort
  1,$delete
  call append(0, ["one", "two", "three", "four"])
endfunction

function! s:suite.has_nvim() abort
  call s:expect(has("nvim")).to_equal(1)
endfunction

function! s:suite.updates_one_line() abort
  2rubydo $_.upcase!

  call s:expect(getline(1, 4)).to_equal(["one", "TWO", "three", "four"])
endfunction

function! s:suite.updates_line_range() abort
  2,3rubydo $_.upcase!

  call s:expect(getline(1, 4)).to_equal(["one", "TWO", "THREE", "four"])
endfunction

function! s:suite.updates_large_line_range() abort
  1,$delete

  for _ in range(0, 6000)
    call append(0, "x")
  endfor

  %rubydo $_.succ!

  call s:expect(getline(1)).to_equal("y")
  call s:expect(getline(6001)).to_equal("y")
  call s:expect(getline(6002)).to_equal("")
endfunction

function! s:suite.updates_all_lines() abort
  %rubydo $_.upcase!

  call s:expect(getline(1, 4)).to_equal(["ONE", "TWO", "THREE", "FOUR"])
endfunction

function! s:suite.ignores_line_deletion() abort
  " Just ensure `Index out of bounds` exception isn't raised.
  "
  " Deleting or adding lines inside `:rubydo` is documented as not supported.
  " Therefore this will remain inconsistent with Vim, which deletes all but
  " the first line (?)
  %rubydo Vim.command("%d")
endfunction

function! s:suite.handles_standard_error() abort
  try
    1rubydo raise "BOOM"
    throw "Nothing raised"
  catch /BOOM/
  endtry

  call s:suite.updates_one_line()
endfunction

function! s:suite.handles_syntax_error() abort
  try
    1rubydo puts[
    throw "Nothing raised"
  catch /SyntaxError/
  endtry

  call s:suite.updates_one_line()
endfunction
