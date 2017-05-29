Before (Generate rplugin manifest):
  silent UpdateRemotePlugins

Execute (Call rplugin commands with arguments):
  RPluginCommandNargs0
  RPluginCommandNargs1 1
  RPluginCommandNargsN
  RPluginCommandNargsN 1
  RPluginCommandNargsN 1 2
  RPluginCommandNargsQ
  RPluginCommandNargsQ 1
  RPluginCommandNargsP 1
  RPluginCommandNargsP 1 2
  sleep 100m

Then:
  AssertEqual v:true,     g:rplugin_command_nargs_0
  AssertEqual "1",        g:rplugin_command_nargs_1
  AssertEqual ["1", "2"], g:rplugin_command_nargs_n
  AssertEqual "1",        g:rplugin_command_nargs_q
  AssertEqual ["1", "2"], g:rplugin_command_nargs_p

Given:
  one
  two
  three

Execute (Call rplugin commands with a range):
  RPluginCommandRange
  sleep 50m
  AssertEqual [1, 1], g:rplugin_command_range

  1,2RPluginCommandRange
  sleep 50m
  AssertEqual [1, 2], g:rplugin_command_range

  %RPluginCommandRange
  sleep 50m
  AssertEqual [1, 3], g:rplugin_command_range

  RPluginCommandRangeP
  sleep 50m
  AssertEqual [1, 3], g:rplugin_command_range_p

  1,2RPluginCommandRangeP
  sleep 50m
  AssertEqual [1, 2], g:rplugin_command_range_p

  %RPluginCommandRangeP
  sleep 50m
  AssertEqual [1, 3], g:rplugin_command_range_p

  RPluginCommandRangeN
  sleep 50m
  AssertEqual [1], g:rplugin_command_range_n

  2RPluginCommandRangeN
  sleep 50m
  AssertEqual [2], g:rplugin_command_range_n

Execute (Call rplugin commands with a count):
  RPluginCommandCountN
  sleep 50m
  AssertEqual [1], g:rplugin_command_count_n

  2RPluginCommandCountN
  sleep 50m
  AssertEqual [2], g:rplugin_command_count_n

Execute (Call rplugin commands with a bang):
  RPluginCommandBang
  sleep 50m
  AssertEqual 0, g:rplugin_command_bang

  RPluginCommandBang!
  sleep 50m
  AssertEqual 1, g:rplugin_command_bang

Execute (Call rplugin commands with a register):
  RPluginCommandRegister a
  sleep 50m
  AssertEqual "a", g:rplugin_command_register

Execute (Call rplugin commands with completion):
  RPluginCommandCompletion
  sleep 50m
  AssertEqual "buffer", g:rplugin_command_completion

Execute (Call rplugin commands with eval):
  let g:to_eval = {'n': 42}
  RPluginCommandEval
  sleep 50m
  AssertEqual {'n': 42}, g:rplugin_command_eval

Execute (Call synchronous rplugin commands):
  RPluginCommandSync
  AssertEqual v:true, g:rplugin_command_sync
