let s:suite = themis#suite("Remote plugin function")
let s:expect = themis#helper("expect")

function! s:suite.before() abort
  silent UpdateRemotePlugins
endfunction

function! s:suite.before_each() abort
  1,$delete
  call append(0, ["one", "two", "three"])
endfunction

function! s:suite.has_nvim() abort
  call s:expect(has("nvim")).to_equal(1)
endfunction

function! s:suite.supports_arguments() abort
  call RPluginFunctionArgs(1, 2)
  sleep 50m

  call s:expect(g:rplugin_function_args).to_equal([1, 2])
endfunction

function! s:suite.supports_line_range() abort
  1,2call RPluginFunctionRange()
  sleep 50m

  call s:expect(g:rplugin_function_range).to_equal([1, 2])
endfunction

function! s:suite.supports_eval() abort
  let g:to_eval = {'a': 42}
  call RPluginFunctionEval()
  sleep 50m

  call s:expect(g:rplugin_function_eval).to_equal({"a": 42, "b": 43})
endfunction

function! s:suite.supports_synchronous_functions() abort
  call s:expect(RPluginFunctionSync()).to_equal(v:true)
endfunction

function! s:suite.supports_recursion() abort
  call s:expect(RPluginFunctionRecursive(0)).to_equal(10)
endfunction
