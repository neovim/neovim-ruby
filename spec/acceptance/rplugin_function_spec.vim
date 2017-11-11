Before (Generate rplugin manifest):
  silent UpdateRemotePlugins

Execute (Call rplugin functions with arguments):
  call RPluginFunctionArgs(1, 2)
  sleep 50m
  AssertEqual [1, 2], g:rplugin_function_args

Given:
  one
  two
  three

Execute (Call rplugin functions with a range):
  1,2call RPluginFunctionRange()
  sleep 50m
  AssertEqual [1, 2], g:rplugin_function_range

Execute (Call rplugin functions with eval):
  let g:to_eval = {'a': 42}
  call RPluginFunctionEval()
  sleep 50m
  AssertEqual {'a': 42, 'b': 43}, g:rplugin_function_eval

Execute (Call synchronous rplugin functions):
  AssertEqual v:true, RPluginFunctionSync()

Execute (Call recursive rplugin functions):
  AssertEqual 10, RPluginFunctionRecursive(0)
