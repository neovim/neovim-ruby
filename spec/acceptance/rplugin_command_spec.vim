let s:suite = themis#suite("Remote plugin command")
let s:expect = themis#helper("expect")

function! s:suite.before_each() abort
  1,$delete
  call append(0, ["one", "two", "three"])
  normal gg
endfunction

function! s:suite.has_nvim() abort
  call s:expect(has("nvim")).to_equal(1)
endfunction

function! s:suite.supports_arguments() abort
  RPluginCommandNargs0
  RPluginCommandNargs1 1
  RPluginCommandNargsN
  RPluginCommandNargsN 1
  RPluginCommandNargsN 1 2
  RPluginCommandNargsQ
  RPluginCommandNargsQ 1
  RPluginCommandNargsP 1
  RPluginCommandNargsP 1 2

  call s:expect(g:rplugin_command_nargs_0).to_equal(v:true)
  call s:expect(g:rplugin_command_nargs_1).to_equal("1")
  call s:expect(g:rplugin_command_nargs_n).to_equal(["1", "2"])
  call s:expect(g:rplugin_command_nargs_q).to_equal("1")
  call s:expect(g:rplugin_command_nargs_p).to_equal(["1", "2"])
endfunction

function! s:suite.supports_line_range() abort
  RPluginCommandRange
  call s:expect(g:rplugin_command_range).to_equal([1, 1])

  1,2RPluginCommandRange
  call s:expect(g:rplugin_command_range).to_equal([1, 2])

  %RPluginCommandRange
  call s:expect(g:rplugin_command_range).to_equal([1, 4])

  RPluginCommandRangeP
  call s:expect(g:rplugin_command_range_p).to_equal([1, 4])

  1,2RPluginCommandRangeP
  call s:expect(g:rplugin_command_range_p).to_equal([1, 2])

  %RPluginCommandRangeP
  call s:expect(g:rplugin_command_range_p).to_equal([1, 4])

  RPluginCommandRangeN
  call s:expect(g:rplugin_command_range_n).to_equal([1])

  2RPluginCommandRangeN
  call s:expect(g:rplugin_command_range_n).to_equal([2])
endfunction

function! s:suite.supports_count() abort
  RPluginCommandCountN
  call s:expect(g:rplugin_command_count_n).to_equal([1])

  2RPluginCommandCountN
  call s:expect(g:rplugin_command_count_n).to_equal([2])
endfunction

function! s:suite.supports_bang() abort
  RPluginCommandBang
  call s:expect(g:rplugin_command_bang).to_equal(0)

  RPluginCommandBang!
  call s:expect(g:rplugin_command_bang).to_equal(1)
endfunction

function! s:suite.supports_register() abort
  RPluginCommandRegister a
  call s:expect(g:rplugin_command_register).to_equal("a")
endfunction

function! s:suite.supports_completion() abort
  RPluginCommandCompletion foo
  call s:expect(g:rplugin_command_completion).to_equal(["buffer", "foo"])
endfunction

function! s:suite.supports_eval() abort
  let g:to_eval = {'a': 42}
  RPluginCommandEval
  call s:expect(g:rplugin_command_eval).to_equal({'a': 42, 'b': 43})
endfunction

function! s:suite.supports_asynchronous_commands() abort
  RPluginCommandAsync
  sleep 50m
  call s:expect(g:rplugin_command_async).to_equal(v:true)
endfunction

function! s:suite.supports_recursion() abort
  RPluginCommandRecursive 0
  call s:expect(g:rplugin_command_recursive).to_equal("10")
endfunction
