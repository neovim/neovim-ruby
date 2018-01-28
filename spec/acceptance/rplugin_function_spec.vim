let s:suite = themis#suite("Remote plugin function")
let s:expect = themis#helper("expect")

function! s:suite.before_each() abort
  1,$delete
  call append(0, ["one", "two", "three"])
endfunction

function! s:suite.has_nvim() abort
  call s:expect(has("nvim")).to_equal(1)
endfunction

function! s:suite.supports_arguments() abort
  call s:expect(RPluginFunctionArgs(1, 2)).to_equal([1, 2])
endfunction

function! s:suite.supports_line_range() abort
  3,4call RPluginFunctionRange()
  call s:expect(g:rplugin_function_range).to_equal([3, 4])
endfunction

function! s:suite.supports_eval() abort
  let g:to_eval = {'a': 42}
  call s:expect(RPluginFunctionEval()).to_equal({"a": 42, "b": 43})
endfunction

function! s:suite.supports_asynchronous_functions() abort
  call RPluginFunctionAsync()
  sleep 50m
  call s:expect(g:rplugin_function_async).to_equal(v:true)
endfunction

function! s:suite.supports_recursion() abort
  call s:expect(RPluginFunctionRecursive(0)).to_equal(10)
endfunction
