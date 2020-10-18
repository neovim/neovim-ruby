let s:suite = themis#suite(":rubyeval")
let s:expect = themis#helper("expect")

function! s:suite.evaluates_ruby_objects() abort
  call s:expect(rubyeval("123")).to_equal(123)
  call s:expect(rubyeval("1.2")).to_equal(1.2)
  call s:expect(rubyeval("'test'")).to_equal("test")
  call s:expect(rubyeval("nil")).to_equal(v:null)
  call s:expect(rubyeval("true")).to_equal(v:true)
  call s:expect(rubyeval("false")).to_equal(v:false)
  call s:expect(rubyeval("{x: 1}")).to_equal({"x": 1})
  call s:expect(rubyeval(":test")).to_equal("test")
  call s:expect(rubyeval(":test.class")).to_equal("Symbol")
endfunction

function! s:suite.propagates_exceptions() abort
  try
    rubyeval("raise 'BOOM'")
    throw "Nothing raised"
  catch /BOOM/
  endtry
endfunction
